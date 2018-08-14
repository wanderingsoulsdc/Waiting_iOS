//
//  LiteAccountRechargeReportViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountRechargeReportViewController.h"
#import "PGDatePickManager.h"
#import <Masonry/Masonry.h>
#import "LiteAccountTransactionCell.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "LiteAccountTransactionModel.h"

@interface LiteAccountRechargeReportViewController ()<UITableViewDelegate, UITableViewDataSource,PGDatePickerDelegate>

@property (nonatomic , strong) UIButton          * dateButton;
@property (nonatomic , strong) UITableView       * tableView;
@property (nonatomic , strong) NSMutableArray    * listDataArray;    //列表数据

@property (nonatomic , assign) NSInteger         currentPage;
@property (nonatomic , strong) NSString          * currentDateStr;

@property (nonatomic , strong) BHLoadFailedView  * noDataView;

@property (nonatomic , strong) PGDatePickManager * datePickManager;

@end

@implementation LiteAccountRechargeReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = UIColorWhite;
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.dateButton];
    [self.view addSubview:self.tableView];
    [self layoutSubviews];
    
    [self initWithAutoRefresh];
    [self getCurrentDate];
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

#pragma mark - private method
//获取当前时间年月
- (void)getCurrentDate{
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:now];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%ld年%02ld月",(long)dateComponents.year , (long)dateComponents.month] forState:UIControlStateNormal];
    self.currentDateStr = [NSString stringWithFormat:@"%ld-%02ld",(long)dateComponents.year , (long)dateComponents.month];
    //请求第一次数据
    [self loadNewData];
}
//布局
- (void)layoutSubviews{
    [self.dateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.height.equalTo(@20);
        make.width.equalTo(@100);
        make.top.equalTo(self.view).offset(10);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.dateButton.mas_bottom).offset(10);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
    
    [self.dateButton.superview layoutIfNeeded];

    CGFloat imageWidth = _dateButton.imageView.bounds.size.width;
    CGFloat labelWidth = _dateButton.titleLabel.bounds.size.width;
    _dateButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _dateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
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
    // Enter the refresh status immediately
}

- (void)loadNewData
{
    self.currentPage = 1;
    [ShowHUDTool showLoading];

    [self.listDataArray removeAllObjects];
    self.tableView.mj_footer.hidden = NO;
    [self.tableView.mj_footer resetNoMoreData];
    [self requestTradeList];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestTradeList];
}

#pragma mark - Request

//获取交易记录
- (void)requestTradeList
{
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageNum":@"20",
                              @"type":@"1",
                              @"date":self.currentDateStr
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiAccountTradeList
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
                                     LiteAccountTransactionModel * model = [[LiteAccountTransactionModel alloc] init];
                                     model.transactionId = [dict stringValueForKey:@"id" default:@""];
                                     model.transactionMoney = [dict stringValueForKey:@"money" default:@""];
                                     model.transactionTime = [dict stringValueForKey:@"ctime" default:@""];
                                     model.transactionTitle = [dict stringValueForKey:@"title" default:@""];
                                     model.transactionStatus = [dict stringValueForKey:@"status" default:@""];
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

#pragma mark - action

- (void)dateButtonClick:(UIButton *)button{
    [self presentViewController:self.datePickManager animated:false completion:nil];
}

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.listDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountTransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.type = TransactionCellTypeRecharge;
    LiteAccountTransactionModel *model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
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
}


#pragma mark - PGDatePickerDelegate
- (void)datePicker:(PGDatePicker *)datePicker didSelectDate:(NSDateComponents *)dateComponents {
    NSLog(@"year = %ld month = %ld", (long)dateComponents.year , (long)dateComponents.month);
    [self.dateButton setTitle:[NSString stringWithFormat:@"%ld年%02ld月",(long)dateComponents.year , (long)dateComponents.month] forState:UIControlStateNormal];
    //请求新日期的数据
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%02ld",(long)dateComponents.year , (long)dateComponents.month];
    if (![self.currentDateStr isEqualToString:dateStr]) {
        self.currentDateStr = dateStr;
        //请求数据
        [self loadNewData];
    }
}

#pragma mark - getter
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
        _tableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[LiteAccountTransactionCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
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

- (UIButton *)dateButton{
    
    if (!_dateButton) {
        _dateButton = [[UIButton alloc] init];
        _dateButton.backgroundColor = [UIColor clearColor];
        [_dateButton setTitle:@"2018年05月" forState:UIControlStateNormal];
        _dateButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_dateButton setTitleColor:UIColorDrakBlackText forState:UIControlStateNormal];
        [_dateButton addTarget:self action:@selector(dateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_dateButton setImage:[UIImage imageNamed:@"down_triangle"] forState:UIControlStateNormal];
        _dateButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        
        _dateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;// 水平左对齐
        _dateButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;// 垂直居中对齐
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
    return _dateButton;
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

- (PGDatePickManager *)datePickManager{
    if (!_datePickManager)
    {
        _datePickManager = [[PGDatePickManager alloc] init];
        _datePickManager.style = PGDatePickManagerStyle3;
        _datePickManager.isShadeBackgroud = true;
        
        PGDatePicker *datePicker = _datePickManager.datePicker;
        datePicker.delegate = self;
        datePicker.datePickerType = PGPickerViewType2;
        datePicker.datePickerMode = PGDatePickerModeYearAndMonth;
        
        NSDate *currentDate = [NSDate date];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:2018];
        [dateComponents setMonth:06];
        NSDate *miniDate = [calendar dateFromComponents:dateComponents];
        
        datePicker.minimumDate = miniDate;
        datePicker.maximumDate = currentDate;
    }
    return _datePickManager;
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

