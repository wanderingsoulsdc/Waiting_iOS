//
//  LiteADsMessageHistoryViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageHistoryViewController.h"
#import "LiteADsMessageHistoryCell.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "Masonry.h"

@interface LiteADsMessageHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView          * tableView;       //列表

@property (nonatomic , strong) NSMutableArray       * listDataArray;   //列表数据

@property (nonatomic , strong) NSMutableArray       * selectArray;      //状态数组

@property (nonatomic , assign) NSInteger            currentPage;       //当前页数

@property (nonatomic , strong) BHLoadFailedView     * noDataView;      //短信无数据页面

@property (nonatomic , strong) UIView               * footerView;       //底部视图
@property (nonatomic , strong) UIButton             * footButton; //底部提交按钮

@end

@implementation LiteADsMessageHistoryViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择历史短信记录";
    
    [self createUI];
    
    [self layoutSubviews];
    
    [self loadNewData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******
- (void)createUI{

    [self.view addSubview:self.tableView];
    [self.view addSubview:self.noDataView];
    
    [self initWithAutoRefresh];

    [self initWithFooterView];
}

//底视图
- (void)initWithFooterView
{
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = UIColorWhite;
    self.footerView.frame = CGRectMake(0, 0, kScreenWidth,56);
    
    self.footButton = [[UIButton alloc] init];
    [self.footButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.footButton setBackgroundColor:UIColorlightGray]; //不可点击背景色
    self.footButton.userInteractionEnabled = NO;
    self.footButton.layer.cornerRadius = 3.0f;
    self.footButton.layer.masksToBounds = YES;
    [self.footButton addTarget:self action:@selector(footButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.footButton];
    
    [self.view addSubview:self.footerView];
    [self layoutFooterViews];
}

//底视图布局
- (void)layoutFooterViews{
    
    [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(56);
    }];
    
    [self.footButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footerView).offset(48);
        make.top.equalTo(self.footerView).offset(8);
        make.right.equalTo(self.footerView).offset(-48);
        make.height.equalTo(@40);
    }];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.footerView.mas_top).offset(0.5 - SafeAreaBottomHeight);
    }];
}

#pragma mark - ******* Action Methods *******

- (void)footButtonClick:(UIButton *)button{
    NSLog(@"点击了确定");
    if ([self.delegate respondsToSelector:@selector(messageHistorySelectResult:)]) {
        [self.delegate messageHistorySelectResult:[self.selectArray lastObject]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - ******* Refresh *******

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
    [self requestMessageHistory];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestMessageHistory];
}
#pragma mark - ******* Request Methods *******
//获取短信列表
- (void)requestMessageHistory
{
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageNum":@"20",
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageGetHistory
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
                                     LiteADsMessageListModel * model = [[LiteADsMessageListModel alloc] init];
                                     model.orderId = [dict stringValueForKey:@"id" default:@""];
                                     model.sign = [dict stringValueForKey:@"sign" default:@""];
                                     model.orderName = [dict stringValueForKey:@"orderName" default:@""];
                                     model.ctime = [dict stringValueForKey:@"ctime" default:@""];
                                     model.smsNum = [dict stringValueForKey:@"smsNum" default:@""];
                                     model.content = [dict stringValueForKey:@"content" default:@""];
                                     
                                     [self.listDataArray addObject:model];
                                 }
                                 
                                 [self.tableView reloadData];
                                 
                                 NSUInteger totalPage = [[dic stringValueForKey:@"totalPage" default:@""] integerValue];
                                 if (self.currentPage >= totalPage) {
                                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                     
                                 }
                                 self.footerView.hidden = NO;
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
                                     self.footerView.hidden = YES;
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

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"LiteADsMessageHistoryCell";
    LiteADsMessageHistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LiteADsMessageHistoryCell" owner:nil options:nil].firstObject;
        NSLog(@"cell create at row:%ld", (long)indexPath.row);//此处要使用loadnib方式！
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LiteADsMessageListModel * model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    
    if ([self.selectArray containsObject:model]) {
        [cell cellBecomeSelected];
    }else{ //选择该标签
        [cell cellBecomeUnselected];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 233.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
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
    return 0.1f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了cell");
    LiteADsMessageListModel *model = [self.listDataArray objectAtIndex:indexPath.row];
    
    if (![self.selectArray containsObject:model]) {
        [self.selectArray removeAllObjects];
        [self.selectArray addObject:model];
        [self.tableView reloadData];
    }
    
    NSLog(@"点击了cell");
    [self checkFootButtonStatus];
}

#pragma mark - ******* Private Methods *******

//检查底部按钮状态
- (void)checkFootButtonStatus{
    if (self.selectArray.count > 0) {
        self.footButton.backgroundColor = UIColorBlue;
        self.footButton.userInteractionEnabled = YES;
    } else {
        self.footButton.backgroundColor = UIColorlightGray;
        self.footButton.userInteractionEnabled = NO;
    }
}


#pragma mark - ******* Getter *******

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = UIColorClearColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //        _tableView.bounces = NO;
        
        // 分割线位置
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LiteADsMessageHistoryCell class]) bundle:nil] forCellReuseIdentifier:@"LiteADsMessageHistoryCell"];
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
        
        _noDataView.frame = CGRectMake(0, - kStatusBarAndNavigationBarHeight, kScreenWidth, kScreenHeight);
        _noDataView.loadFailedImageView.image = [UIImage imageNamed:@"no_data"];
        _noDataView.loadFailedLabel.text = @"没有数据啊！喵~";
    }
    return _noDataView;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray)
    {
        _selectArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectArray;
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
