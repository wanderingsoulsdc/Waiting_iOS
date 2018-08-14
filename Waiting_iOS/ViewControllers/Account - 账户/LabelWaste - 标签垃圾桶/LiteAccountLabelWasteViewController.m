//
//  LiteAccountLabelWasteViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountLabelWasteViewController.h"
#import "Masonry/Masonry.h"
#import "LiteLabelModel.h"
#import "LiteAccountLabelWasteCell.h"
#import "XZPickView.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "LiteDeviceModel.h"

@interface LiteAccountLabelWasteViewController ()<UITableViewDelegate, UITableViewDataSource,XZPickViewDelegate, XZPickViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) UIView            * topView;
@property (nonatomic, strong) UIButton          * deviceSelectButton;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据
@property (nonatomic, strong) NSMutableArray    * deviceArray;      //设备数据
@property (nonatomic, strong) NSMutableArray    * labelSelectArray; //选中标签数组
@property (nonatomic, strong) UIButton          * footButton;       //底部按钮
@property (nonatomic, strong) XZPickView        * pickView;         //设备选择器

@property (nonatomic, assign) NSInteger         currentPage;
@property (nonatomic, strong) NSString          * currentDevice;

@property (nonatomic, strong) BHLoadFailedView  * noDataView;

@end

@implementation LiteAccountLabelWasteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标签垃圾桶";
    self.currentDevice = @"";
    [self.view addSubview:self.noDataView];

    [self.topView addSubview:self.deviceSelectButton];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.footButton];
    
    [self layoutSubviews];
    // Do any additional setup after loading the view.
    [self initWithAutoRefresh];
    [self requestDeviceList];
    [self loadNewData];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(1);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@35);
    }];
    
    [self.deviceSelectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.topView);
        make.left.equalTo(self.topView).offset(24);
        make.right.equalTo(self.topView).offset(-24);
    }];
    
    [self.footButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@50);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
        make.bottom.equalTo(self.footButton.mas_top);
    }];
    
    [self.deviceSelectButton.superview layoutIfNeeded];
    
    [self layoutDeviceButton];
}

//按钮内文字和图片重新布局
- (void)layoutDeviceButton{
    CGFloat imageWidth = _deviceSelectButton.imageView.bounds.size.width;
    CGFloat labelWidth = _deviceSelectButton.titleLabel.bounds.size.width;
    _deviceSelectButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _deviceSelectButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Action

- (void)deviceSelectButtonClick:(UIButton *)button{
    NSLog(@"设备筛选");
    [self showPickView];
}

- (void)footButtonAction:(UIButton *)button{
    NSLog(@"重新启用");
    [self requestLabelUpdate];
}

#pragma mark - Private methods

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
    [self.labelSelectArray removeAllObjects];
    self.tableView.mj_footer.hidden = NO;
    [self.tableView.mj_footer resetNoMoreData];
    [self requestLabelList];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestLabelList];
}
//检查底部按钮状态
- (void)checkFootButtonStatus{
    if (self.labelSelectArray.count > 0) {
        self.footButton.backgroundColor = UIColorBlue;
        self.footButton.userInteractionEnabled = YES;
    } else {
        self.footButton.backgroundColor = UIColorlightGray;
        self.footButton.userInteractionEnabled = NO;
    }
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
                              @"delete":@"2",
                              @"deviceId":self.currentDevice
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
                                     model.startAddress = [dict stringValueForKey:@"startAddress" default:@""];
                                     model.personNum = [dict stringValueForKey:@"personNum" default:@""];
                                     [self.listDataArray addObject:model];
                                 }
                                 
                                 [self.tableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic objectForKey:@"totalPage"] integerValue];
                                 if (self.currentPage >= totalPage) {
                                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.footButton.hidden = NO;
                                 [self checkFootButtonStatus];
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
                                     self.footButton.hidden = YES;
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
//请求设备列表
- (void)requestDeviceList
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceList
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             NSArray * array = object[@"data"][@"list"];
                             if (array.count > 0)
                             {
                                 LiteDeviceModel * model = [[LiteDeviceModel alloc] init];
                                 model.deviceId = @"";
                                 model.deviceName = @"全部设备";
                                 [self.deviceArray addObject:model];
                                 
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteDeviceModel * model = [[LiteDeviceModel alloc] init];
                                     model.deviceId = [dict stringValueForKey:@"id" default:@""];
                                     model.deviceName = [dict stringValueForKey:@"deviceName" default:@""];
                                     [self.deviceArray addObject:model];
                                 }
                             }
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

//重新启用标签
/*
 *  id      标签id,多个使用英文逗号连接 如:(1,2,3)
 *  status  标签目标状态 1 正常 2 回收站
 */
- (void)requestLabelUpdate
{
    NSString *labelIds = @"";
    for (LiteLabelModel *model in self.labelSelectArray) {
        labelIds = [labelIds stringByAppendingFormat:@",%@",model.labelID];
    }
    labelIds = [labelIds substringWithRange:NSMakeRange(1,labelIds.length - 1)];

    NSDictionary * params = @{@"id":labelIds,
                              @"status":@"1"
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiDeviceLabelUpdateDelete
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             NSString *message = [NSString stringWithFormat:@"已重新启用了%ld个标签",self.labelSelectArray.count];
                             [[ShowHUDTool shareManager] showAlertWithCustomImage:@"login_register_success" title:@"标签启用成功" message:message];
                             [self loadNewData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - SystemDelegate

#pragma mark - PickViewDelegate

- (void)showPickView{
    [self.pickView reloadData];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    [self.pickView show];
}


-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{
    
    NSInteger index = [pickerView selectedRowInComponent:0];
    LiteDeviceModel *model = self.deviceArray[index];
    self.currentDevice = model.deviceId;
    NSLog(@"选择设备：%@",model.deviceName);
    [self.deviceSelectButton setTitle:model.deviceName forState:UIControlStateNormal];
    [self layoutDeviceButton];
    
    [self loadNewData];
}

-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.deviceArray.count;
}

-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    LiteDeviceModel *model = self.deviceArray[row];
    return model.deviceName;
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountLabelWasteCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LiteLabelModel * model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    
    if ([self.labelSelectArray containsObject:model]) {
        [cell cellBecomeSelected];
    }else{ //选择该标签
        [cell cellBecomeUnselected];
    }
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
    LiteAccountLabelWasteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    LiteLabelModel *model = [self.listDataArray objectAtIndex:indexPath.row];
    
    if ([self.labelSelectArray containsObject:model]) { //删除选择
        [cell cellBecomeUnselected];
        //记录选择数组删除该标签
        [self.labelSelectArray removeObject:model];
    }else{ //选择该标签
        [cell cellBecomeSelected];
        [self.labelSelectArray addObject:model];
        //记录选择数组添加该标签
    }
    NSLog(@"点击了cell");
    [self checkFootButtonStatus];
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
        
        [_tableView registerClass:[LiteAccountLabelWasteCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

- (XZPickView *)pickView{
    if(!_pickView){
        _pickView = [[XZPickView alloc]initWithFrame:[UIScreen mainScreen].bounds title:@""];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

- (UIButton *)deviceSelectButton{
    
    if (!_deviceSelectButton) {
        _deviceSelectButton = [[UIButton alloc] init];
        _deviceSelectButton.backgroundColor = [UIColor clearColor];
        [_deviceSelectButton setTitle:@"全部设备" forState:UIControlStateNormal];
        _deviceSelectButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_deviceSelectButton setTitleColor:UIColorDrakBlackText forState:UIControlStateNormal];
        [_deviceSelectButton addTarget:self action:@selector(deviceSelectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_deviceSelectButton setImage:[UIImage imageNamed:@"down_triangle"] forState:UIControlStateNormal];
        _deviceSelectButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        
        _deviceSelectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
        _deviceSelectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;// 垂直居中对齐
        /**
         * 按照上面的操作 按钮的内容对津贴屏幕左边缘 不美观 可以添加一下代码实现间隔已达到美观
         * UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
         *    top: 为正数：表示向下偏移  为负数：表示向上偏移
         *   left: 为正数：表示向右偏移  为负数：表示向左偏移
         * bottom: 为正数：表示向上偏移  为负数：表示向下偏移
         *  right: 为正数：表示向左偏移  为负数：表示向右偏移
         *
         **/
    }
    return _deviceSelectButton;
}

- (NSMutableArray *)listDataArray
{
    if (!_listDataArray)
    {
        _listDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listDataArray;
}
- (NSMutableArray *)deviceArray
{
    if (!_deviceArray)
    {
        _deviceArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _deviceArray;
}
- (NSMutableArray *)labelSelectArray
{
    if (!_labelSelectArray)
    {
        _labelSelectArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _labelSelectArray;
}

- (UIView *)topView
{
    if (!_topView)
    {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorWhite;
    }
    return _topView;
}

- (UIButton *)footButton{
    if (!_footButton) {
        _footButton = [[UIButton alloc] init];
        [_footButton setTitle:@"重新启用" forState:UIControlStateNormal];
        [_footButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_footButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_footButton setBackgroundColor:UIColorlightGray];
        _footButton.hidden = YES;
        [_footButton addTarget:self action:@selector(footButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _footButton.userInteractionEnabled = NO;
    }
    return _footButton;
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
