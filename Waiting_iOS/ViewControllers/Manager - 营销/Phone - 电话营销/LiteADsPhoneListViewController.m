//
//  LiteADsPhoneListViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/18.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsPhoneListViewController.h"
#import "Masonry/Masonry.h"
#import "PGDatePickManager.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "XZPickView.h"
#import "LiteADsPhoneListCell.h"
#import "LiteADsPhoneListModel.h"
#import "LitePhoneDetailViewController.h"
#import "NSDictionary+YYAdd.h"

@interface LiteADsPhoneListViewController ()<UITableViewDelegate, UITableViewDataSource,PGDatePickerDelegate,XZPickViewDelegate, XZPickViewDataSource>

@property (nonatomic , strong) UIView               * topView;         //上部视图
@property (nonatomic , strong) UIButton             * dateButton;      //上部时间选择按钮
@property (nonatomic , strong) UILabel              * expenseLabel;    //上部电话花费
@property (nonatomic , strong) UILabel              * personNumLabel;  //上部通讯人数
@property (nonatomic , strong) UILabel              * expenseTitleLabel;//上部电话花费标题
@property (nonatomic , strong) UILabel              * personTitleLabel;//上部通讯人数标题
@property (nonatomic , strong) PGDatePickManager    * datePickManager; //日期选择管理器

@property (nonatomic , strong) UIView               * selectView;      //电话筛选视图
@property (nonatomic , strong) UIButton             * selectButton;    //电话筛选按钮
@property (nonatomic , strong) XZPickView           * pickView;        //筛选状态选择器
@property (nonatomic , strong) NSMutableArray       * selectArray;      //意向数组
@property (nonatomic , strong) NSString             * currentStatusStr; //当前意向

@property (nonatomic , strong) UITableView          * tableView;       //电话列表
@property (nonatomic , strong) NSMutableArray       * listDataArray;   //电话列表数据
@property (nonatomic , assign) NSInteger            currentPage;       //电话数据当前页数
@property (nonatomic , strong) NSString             * currentDateStr;  //电话请求所需时间字符串

@property (nonatomic , strong) BHLoadFailedView     * noDataView;      //电话无数据页面
@end

@implementation LiteADsPhoneListViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createUI];
    
    [self layoutSubviews];
    
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

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.currentStatusStr = @"";//全部意向
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.dateButton];
    [self.topView addSubview:self.expenseTitleLabel];
    [self.topView addSubview:self.expenseLabel];
    [self.topView addSubview:self.personTitleLabel];
    [self.topView addSubview:self.personNumLabel];
    
    [self.view addSubview:self.selectView];
    [self.selectView addSubview:self.selectButton];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.noDataView];

    [self initWithAutoRefresh];
}

- (void)layoutSubviews{
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.equalTo(@150);
    }];
    [self.dateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView);
        make.height.equalTo(@20);
        make.width.equalTo(@100);
        make.top.equalTo(self.topView).offset(20);
    }];
    [self.dateButton.superview layoutIfNeeded];
    
    CGFloat imageWidth = _dateButton.imageView.bounds.size.width;
    CGFloat labelWidth = _dateButton.titleLabel.bounds.size.width;
    _dateButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _dateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
    
    [self.expenseTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView);
        make.height.equalTo(@20);
        make.width.mas_equalTo(kScreenWidth/2);
        make.top.equalTo(self.dateButton.mas_bottom).offset(20);
    }];
    
    [self.expenseLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView);
        make.height.equalTo(@42);
        make.width.mas_equalTo(kScreenWidth/2);
        make.top.equalTo(self.expenseTitleLabel.mas_bottom).offset(2);
    }];
    
    [self.personTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView);
        make.height.equalTo(@20);
        make.width.mas_equalTo(kScreenWidth/2);
        make.top.equalTo(self.dateButton.mas_bottom).offset(20);
    }];
    [self.personNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topView);
        make.height.equalTo(@42);
        make.width.mas_equalTo(kScreenWidth/2);
        make.top.equalTo(self.personTitleLabel.mas_bottom).offset(2);
    }];
    
    [self.selectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.equalTo(@36);
        make.top.equalTo(self.topView.mas_bottom).offset(12);
    }];
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.selectView);
        make.left.equalTo(self.selectView).offset(15);
        make.width.equalTo(@70);
    }];
    
    [self.selectButton.superview layoutIfNeeded];
    [self layoutCallStatusSelectButton];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.selectView.mas_bottom).offset(1);
        make.bottom.equalTo(self.view);
    }];
    
    [self.noDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.selectView.mas_bottom).offset(1);
        make.bottom.equalTo(self.view);
    }];
    
}

//选择意向状态按钮内文字和图片重新布局
- (void)layoutCallStatusSelectButton{
    CGFloat imageWidth = _selectButton.imageView.bounds.size.width;
    CGFloat labelWidth = _selectButton.titleLabel.bounds.size.width;
    _selectButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _selectButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
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
    [self requestPhoneList];
}

- (void)loadMoreData
{
    self.currentPage ++;
    [self requestPhoneList];
}

#pragma mark - ******* Request *******
//获取电话列表
- (void)requestPhoneList
{
    //标记类型 1有意向，3未接通， 4空号 ，5无标记, 6无意向
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageNum":@"20",
                              @"signType":self.currentStatusStr,
                              @"date":self.currentDateStr
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiReportPhoneList
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
                             
                             NSDictionary *reportDic = dic[@"report"];
                             self.personNumLabel.text = [reportDic stringValueForKey:@"num" default:@"0"];
                             self.expenseLabel.text = [reportDic stringValueForKey:@"reportSpend" default:@"0"];
                             
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.reportSpend = [dict stringValueForKey:@"reportSpend" default:@"0"];
                                     model.startTime = dict[@"startTime"];
                                     model.talkTime = [dict stringValueForKey:@"talkTime" default:@"0"];
                                     model.mark = [dict stringValueForKey:@"mark" default:@""];

                                     model.cipherPhone = dict[@"cipherPhone"];

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

#pragma mark - ******* UITableView Delegate *******

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
    LiteADsPhoneListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    LiteADsPhoneListModel *model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0f;
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
    LiteADsPhoneListModel *model = self.listDataArray[indexPath.row];
    LitePhoneDetailViewController * detailVC = [[LitePhoneDetailViewController alloc] init];
    detailVC.phoneModel = model;
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark - ******* PGDatePicker Delegate *******

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

#pragma mark - ******* PickView Delegate *******

- (void)showPickView{
    [self.pickView reloadData];
    [[UIApplication sharedApplication].keyWindow addSubview:self.pickView];
    [self.pickView show];
}


-(void)pickView:(XZPickView *)pickerView confirmButtonClick:(UIButton *)button{
    
    NSInteger index = [pickerView selectedRowInComponent:0];
    
    NSLog(@"选择筛选状态：%@",self.selectArray[index]);
    [self.selectButton setTitle:self.selectArray[index] forState:UIControlStateNormal];
    [self layoutCallStatusSelectButton];
    //标记类型 1有意向，3未接通， 4空号 ，5无标记, 6无意向
    NSString *statusStr = @"";
    switch (index) {
        case 0: //全部意向
            statusStr = @"";
            break;
        case 1: //有意向
            statusStr = @"1";
            break;
        case 2: //未接通
            statusStr = @"3";
            break;
        case 3: //空号
            statusStr = @"4";
            break;
        case 4: //无标记
            statusStr = @"5";
            break;
        case 5: //无意向
            statusStr = @"6";
            break;
        default:
            break;
    }
    
    if (![self.currentStatusStr isEqualToString:statusStr]) {
        self.currentStatusStr = statusStr;
        [self loadNewData];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(XZPickView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(XZPickView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return self.selectArray.count;
}

-(void)pickerView:(XZPickView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

-(NSString *)pickerView:(XZPickView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.selectArray[row];
}

#pragma mark - ******* Private Methods *******
//获取当前时间年月
- (void)getCurrentDate{
    
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:currentDate];
    [self.dateButton setTitle:[NSString stringWithFormat:@"%ld年%02ld月",(long)dateComponents.year , (long)dateComponents.month] forState:UIControlStateNormal];
    self.currentDateStr = [NSString stringWithFormat:@"%ld-%02ld",(long)dateComponents.year , (long)dateComponents.month];
    //请求第一次数据
    [self loadNewData];
}

#pragma mark - ******* Action Methods *******
//日期选择
- (void)dateButtonClick:(UIButton *)button{
    [self presentViewController:self.datePickManager animated:false completion:nil];
}
//筛选状态选择
- (void)selectButtonClick:(UIButton *)button{
    [self showPickView];
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
        _tableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[LiteADsPhoneListCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
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
        [_dateButton setTitle:@"2018年06月" forState:UIControlStateNormal];
        _dateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_dateButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_dateButton addTarget:self action:@selector(dateButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_dateButton setImage:[UIImage imageNamed:@"down_triangle_white"] forState:UIControlStateNormal];
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
        CGFloat imageWidth = _dateButton.imageView.bounds.size.width;
        CGFloat labelWidth = _dateButton.titleLabel.bounds.size.width;
        _dateButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
        _dateButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
    }
    return _dateButton;
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

- (UIView *)topView{
    if (!_topView){
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorBlue;
    }
    return _topView;
}
- (UILabel *)expenseLabel{
    if (!_expenseLabel){
        _expenseLabel = [[UILabel alloc] init];
        _expenseLabel.text = @"0";
        _expenseLabel.textColor = UIColorWhite;
        _expenseLabel.textAlignment = NSTextAlignmentCenter;
        _expenseLabel.font = [UIFont systemFontOfSize:36];
    }
    return _expenseLabel;
}

- (UILabel *)expenseTitleLabel{
    if (!_expenseTitleLabel){
        _expenseTitleLabel = [[UILabel alloc] init];
        _expenseTitleLabel.text = @"电话花费（元）";
        _expenseTitleLabel.textColor = UIColorWhite;
        _expenseTitleLabel.textAlignment = NSTextAlignmentCenter;
        _expenseTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _expenseTitleLabel;
}
- (UILabel *)personTitleLabel{
    if (!_personTitleLabel){
        _personTitleLabel = [[UILabel alloc] init];
        _personTitleLabel.text = @"通讯人数（人）";
        _personTitleLabel.textColor = UIColorWhite;
        _personTitleLabel.textAlignment = NSTextAlignmentCenter;
        _personTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _personTitleLabel;
}

- (UILabel *)personNumLabel{
    if (!_personNumLabel){
        _personNumLabel = [[UILabel alloc] init];
        _personNumLabel.text = @"0";
        _personNumLabel.textColor = UIColorWhite;
        _personNumLabel.textAlignment = NSTextAlignmentCenter;
        _personNumLabel.font = [UIFont systemFontOfSize:36];
    }
    return _personNumLabel;
}

- (UIView *)selectView{
    if (!_selectView) {
        _selectView = [[UIView alloc] init];
        _selectView.backgroundColor = UIColorWhite;
    }
    return _selectView;
}

- (UIButton *)selectButton{
    
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.backgroundColor = [UIColor clearColor];
        [_selectButton setTitle:@"全部意向" forState:UIControlStateNormal];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_selectButton setTitleColor:UIColorDarkBlack forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectButton setImage:[UIImage imageNamed:@"down_triangle"] forState:UIControlStateNormal];
        _selectButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        
        _selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;// 水平you对齐
        _selectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;// 垂直居中对齐
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
    return _selectButton;
}

- (XZPickView *)pickView{
    if(!_pickView){
        _pickView = [[XZPickView alloc]initWithFrame:[UIScreen mainScreen].bounds title:@""];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray)
    {   /*全部意向，有意向，无意向，未接通，空号，无标记*/
        _selectArray = [NSMutableArray arrayWithObjects:@"全部意向",@"有意向",@"未接通",@"空号",@"无标记",@"无意向",nil];
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
