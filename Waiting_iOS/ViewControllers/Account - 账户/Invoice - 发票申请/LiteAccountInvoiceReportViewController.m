//
//  LiteAccountInvoiceReportViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/21.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceReportViewController.h"
#import "LiteAccountInvoiceReportCell.h"
#import <Masonry/Masonry.h>
#import "FSNetWorkManager.h"
#import "MJRefresh.h"
#import "BHLoadFailedView.h"
#import "LiteAccountInvoiceApplyViewController.h"
#import "LiteAccountInvoiceDetailViewController.h"
#import "LiteAccountInvoiceModel.h"


@interface LiteAccountInvoiceReportViewController () <UITableViewDelegate, UITableViewDataSource,LiteAccountInvoiceDetailDelegate>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;
@property (nonatomic, assign) NSInteger             currentPage;
@property (nonatomic, strong) BHLoadFailedView  * noDataView;

@property (nonatomic, strong) UIView            * headerBackView;   //头视图背景
@property (nonatomic, strong) UIView            * headerView;       //tableview头视图
@property (nonatomic, strong) UIButton          * headButton;
@property (nonatomic, strong) UILabel           * headTitleLabel;

@end

@implementation LiteAccountInvoiceReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票申请记录";
    // You should add subviews here, just add subviews
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.tableView];
    [self initWithTableHeaderView];
    // You should add notification here
    
    // layout subviews
    [self layoutSubviews];
    
    // 添加上拉加载更多
    [self initWithAutoRefresh];
    
    [self loadNewData];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceApplySuccess:) name:kInvoiceApplySuccessNotification object:nil];
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

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
}

#pragma mark - SystemDelegate

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountInvoiceReportCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LiteAccountInvoiceModel * model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountInvoiceModel * model = self.listDataArray[indexPath.row];
    NSLog(@"点击了cell");
    LiteAccountInvoiceDetailViewController *vc = [[LiteAccountInvoiceDetailViewController alloc] init];
    vc.delegate = self;
    vc.title = model.number;
    vc.invoiceModel = model;
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Refresh

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
}

- (void)loadNewData
{
    self.currentPage = 1;
    [ShowHUDTool showLoading];

    [self.listDataArray removeAllObjects];
    self.tableView.mj_footer.hidden = NO;
    [self.tableView.mj_footer resetNoMoreData];
    [self requestData];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestData];
}

#pragma mark - ******* Common Delegate *******
//发票撤销成功刷新页面
- (void)invoiceRecallSuccess:(LiteAccountInvoiceModel *)invoiceModel{
    NSArray * dataArray = [self.listDataArray copy];
    NSInteger index = 0;
    for (LiteAccountInvoiceModel *model in dataArray) {
        if ([model.id isEqual:invoiceModel.id]) {
            index = [dataArray indexOfObject:model];
            [self.listDataArray replaceObjectAtIndex:index withObject:invoiceModel];
            [self.tableView reloadData];
            break;
        }
    }
}

#pragma mark - ******* Notification *******

- (void)invoiceApplySuccess:(NSNotification *)noti{
    [self loadNewData];
}

#pragma mark - action methods

- (void)headButtonClick:(UIButton *)button{
    NSLog(@"发票申请");
    LiteAccountInvoiceApplyViewController *vc = [[LiteAccountInvoiceApplyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private methods

- (void)requestData
{
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageSize":@"20",
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiInvoiceList
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
                                     LiteAccountInvoiceModel * model = [[LiteAccountInvoiceModel alloc] init];
                                     model.id = [dict stringValueForKey:@"id" default:@""];
                                     model.number = [dict stringValueForKey:@"number" default:@""];
                                     model.credit = [dict stringValueForKey:@"credit" default:@""];
                                     model.status = [dict stringValueForKey:@"status" default:@""];
                                     model.applyTime = [dict stringValueForKey:@"applyTime" default:@""];
                                     model.mtime = [dict stringValueForKey:@"mtime" default:@""];
                                     [self.listDataArray addObject:model];
                                 }
                                 
                                 [self.tableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic stringValueForKey:@"totalPage" default:@""] integerValue];
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


//头视图（头像&充值）
- (void)initWithTableHeaderView
{
    self.headerBackView = [[UIView alloc] init];
    self.headerBackView.backgroundColor = UIColorClearColor;
    self.headerBackView.layer.cornerRadius = 4;
    self.headerBackView.clipsToBounds = YES;
    self.headerBackView.frame = CGRectMake(0, 0, kScreenWidth,84);
    
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = UIColorWhite;
    [self.headerBackView addSubview:self.headerView];
    
    self.headButton = [[UIButton alloc] init];
    [self.headButton setImage:[UIImage imageNamed:@"account_invoice_add"] forState:UIControlStateNormal];
    [self.headButton addTarget:self action:@selector(headButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.headButton];
    
    self.headTitleLabel = [[UILabel alloc] init];
    self.headTitleLabel.text = @"申请发票";
    self.headTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.headTitleLabel.textColor = UIColorlightGray;
    self.headTitleLabel.font = [UIFont systemFontOfSize:12];
    [self.headerView addSubview:self.headTitleLabel];
    
    UIButton *button = [[UIButton alloc] initWithFrame:self.headerBackView.frame];
    [button addTarget:self action:@selector(headButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerBackView addSubview:button];
    
    [self layoutHeaderViews];
    self.tableView.tableHeaderView = self.headerBackView;
}

//头视图布局
- (void)layoutHeaderViews{
    
    [self.headerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.headerBackView);
        make.top.left.equalTo(self.headerBackView).offset(12);
        make.right.equalTo(self.headerBackView).offset(-12);
    }];
    
    [self.headButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.top.equalTo(self.headerView).offset(13);
        make.width.height.equalTo(@24);
    }];
    
    [self.headTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView);
        make.top.equalTo(self.headButton.mas_bottom).offset(5);
        make.height.equalTo(@17);
        make.width.greaterThanOrEqualTo(@80);
    }];
}


#pragma mark - Getters and Setters
// initialize views here, etc

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.height = IS_IPhoneX ? kScreenHeight-88-34 : kScreenHeight-64;
        _tableView.backgroundColor = UIColorClearColor;
        [_tableView registerClass:[LiteAccountInvoiceReportCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
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
