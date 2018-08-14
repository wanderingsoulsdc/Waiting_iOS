//
//  LiteDeviceLabelListViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/11.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceLabelListViewController.h"
#import "LiteDeviceLabelListCell.h"
#import "Masonry/Masonry.h"
#import "LiteLabelModel.h"
#import "LiteDeviceLabelListCell.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "LiteDeviceLabelDetailViewController.h"
#import "LiteDeviceWorkStatusViewController.h"

@interface LiteDeviceLabelListViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate,LiteLabelDetailDelegate>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据
@property (nonatomic, assign) NSInteger         currentPage;

@property (nonatomic, strong) BHLoadFailedView  * noDataView;

@end

@implementation LiteDeviceLabelListViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签列表";
    self.navigationController.delegate = self;

    [self.view addSubview:self.noDataView];
    
    [self.view addSubview:self.tableView];
    
    [self layoutSubviews];
    // Do any additional setup after loading the view.
    [self initWithAutoRefresh];
    [self loadNewData];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UINavigationController Delegate *******
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    if (isSelfVC) {
        //是自己不隐藏导航条
        [self.navigationController setNavigationBarHidden:!isSelfVC animated:YES];
    }
}

#pragma mark - ******* Action Methods *******

#pragma mark - ******* Private Methods *******

- (void)initWithAutoRefresh
{
    // 上拉加载更多
    MJRefreshAutoNormalFooter * footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    footer.stateLabel.textColor = UIColorFooderText;
    // 设置文字
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"加载数据中~喵~" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"全部加载完啦~喵喵~" forState:MJRefreshStateNoMoreData];
    
    self.tableView.mj_footer = footer;
    // Enter the refresh status immediately
}

- (void)loadNewData
{
    self.currentPage = 1;
    [ShowHUDTool showLoading];

    [self.listDataArray removeAllObjects];
    self.tableView.mj_footer.hidden = NO;
    [self.tableView.mj_footer resetNoMoreData];
    [self requestLabelList];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestLabelList];
}

#pragma mark - request
//请求标签列表
/*
 * deviceId     设备id
 * delete       标签是否加回收站 1 正常 2 回收站
 * page         页码
 * pageNum      每页显示数
 */
- (void)requestLabelList
{
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageNum":@"20",
                              @"delete":@"1",
                              @"deviceId":self.deviceModel.deviceId
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceLabelList
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         [ShowHUDTool hideAlert];
                         
                         if ([self.tableView.mj_footer isRefreshing]) {
                             [self.tableView.mj_footer endRefreshing];
                         }
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteLabelModel * model = [[LiteLabelModel alloc] init];
                                     model.labelID = [dict stringValueForKey:@"id" default:@""];
                                     model.name = [dict stringValueForKey:@"name" default:@""];
                                     model.ctime = [dict stringValueForKey:@"ctime" default:@""];
                                     model.status = [dict stringValueForKey:@"status" default:@""];
                                     model.startAddress = [dict stringValueForKey:@"startAddress" default:@""];
                                     model.personNum = [dict stringValueForKey:@"personNum" default:@""];
                                     model.startLatitude = [dict stringValueForKey:@"startLatitude" default:@""];
                                     model.startLongitude = [dict stringValueForKey:@"startLongitude" default:@""];
                                     [self.listDataArray addObject:model];
                                 }
                                 
                                 [self.tableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic objectForKey:@"totalPage"] integerValue];
                                 if (self.currentPage >= totalPage) {
                                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.noDataView.hidden = YES;
                             }
                             else
                             {
                                 if (self.currentPage == 1)
                                 {
                                     // 第一页无数据
                                     [self.listDataArray removeAllObjects];
                                     [self.tableView reloadData];
                                     self.tableView.mj_footer.hidden = YES;
                                     self.noDataView.hidden = NO;
                                 }
                                 else
                                 {
                                     self.currentPage -- ;
                                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool hideAlert];
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         
                         if ([self.tableView.mj_footer isRefreshing]) {
                             [self.tableView.mj_footer endRefreshing];
                             self.currentPage -- ;
                         }
                     }];
}

#pragma mark - ******* Common Delegate *******
//详情操作成功刷新页面
- (void)changeLabelNameSuccess:(LiteLabelModel *)labelModel{
    NSArray * dataArray = [self.listDataArray copy];
    NSInteger index = 0;
    for (LiteLabelModel *model in dataArray) {
        if ([model.labelID isEqual:labelModel.labelID]) {
            index = [dataArray indexOfObject:model];
            [self.listDataArray replaceObjectAtIndex:index withObject:labelModel];
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)deleteLabelSuccess:(LiteLabelModel *)labelModel{
    NSArray * dataArray = [self.listDataArray copy];
    NSInteger index = 0;
    for (LiteLabelModel *model in dataArray) {
        if ([model.labelID isEqual:labelModel.labelID]) {
            index = [dataArray indexOfObject:model];
            [self.listDataArray removeObject:model];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteDeviceLabelListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LiteLabelModel * model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 135.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteLabelModel *model = [self.listDataArray objectAtIndex:indexPath.row];
    //标签状态 1 收集中 2 暂停 3 结束
    if ([model.status isEqualToString:@"3"]) {
        LiteDeviceLabelDetailViewController *vc = [[LiteDeviceLabelDetailViewController alloc] init];
        vc.labelModel = model;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        LiteDeviceWorkStatusViewController *deviceWorkStatusVC = [[LiteDeviceWorkStatusViewController alloc] init];
        deviceWorkStatusVC.deviceModel = self.deviceModel;
        if ([model.status isEqualToString:@"1"]) {// 1 收集中 2 已暂停工作
            deviceWorkStatusVC.coordinate = CLLocationCoordinate2DMake([model.startLatitude doubleValue], [model.startLongitude doubleValue]);
            deviceWorkStatusVC.workType = DeviceStatusTypeWorking;
        }else if ([model.status isEqualToString:@"2"]) {
            deviceWorkStatusVC.coordinate = CLLocationCoordinate2DMake([model.startLatitude doubleValue], [model.startLongitude doubleValue]);
            deviceWorkStatusVC.workType = DeviceStatusTypeWorkPause;
        }
        [self.navigationController pushViewController:deviceWorkStatusVC animated:YES];
    }

    NSLog(@"点击了cell");
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColorClearColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.bounces = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[LiteDeviceLabelListCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

- (NSMutableArray *)listDataArray
{
    if (!_listDataArray)
    {
        _listDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listDataArray;
}

- (BHLoadFailedView *)noDataView
{
    if (!_noDataView)
    {
        _noDataView = [[BHLoadFailedView alloc] init];
        _noDataView.backgroundColor = [UIColor clearColor];
        _noDataView.hidden = YES;
        
        _noDataView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _noDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
        _noDataView.loadFailedLabel.text = @"没有数据啊！喵~";
    }
    return _noDataView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
