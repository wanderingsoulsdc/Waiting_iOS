//
//  LitePhoneSelectCustomViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LitePhoneSelectCustomViewController.h"
#import "Masonry/Masonry.h"
#import "MJRefresh.h"
#import "FSNetWorkManager.h"
#import "XZPickView.h"
#import "LitePhoneListCell.h"
#import "UIImage+category.h"
#import "LitePhoneDetailViewController.h"
#import "BHSobotService.h"

@interface LitePhoneSelectCustomViewController ()<UITableViewDelegate, UITableViewDataSource,XZPickViewDelegate, XZPickViewDataSource, UISearchBarDelegate>

@property (nonatomic , strong) UIView               * topView;
@property (nonatomic , strong) UIImageView          * topImageView;
@property (nonatomic , strong) UILabel              * custonNumLabel;
@property (nonatomic , strong) UIButton             * selectButton;
@property (nonatomic , strong) BHLoadFailedView     * noDataView;      //无数据页面

@property (nonatomic , strong) XZPickView           * pickView;        //筛选状态选择器
@property (nonatomic , strong) NSMutableArray       * selectArray;      //意向数组
@property (nonatomic , strong) NSString             * currentStatusStr; //当前意向

@property (nonatomic , strong) UIView               * searchView;       //搜索

@property (nonatomic , strong) UITableView          * tableView;       //电话列表
@property (nonatomic , strong) NSMutableArray       * listDataArray;   //电话列表数据
@property (nonatomic , assign) NSInteger            currentPage;       //电话数据当前页数
@property (nonatomic , strong) NSString             * currentDateStr;  //电话请求所需时间字符串

@property (nonatomic , strong) UIButton             * contactServiceButton; //联系客服

@property (nonatomic , strong) UISearchBar          * searchBar;        //搜索框🔍
@property (nonatomic , strong) UITableView          * searchTableView;  //搜索列表
@property (nonatomic , strong) UIView               * searchAccessoryView; //搜索背景遮罩层
@property (nonatomic , strong) NSMutableArray       * searchListDataArray; //搜索列表数据
@property (nonatomic , strong) NSString             * searchKeyStr;     //搜索关键词
@property (nonatomic , assign) BOOL                 isSearching;    //是否正在搜索

@end

@implementation LitePhoneSelectCustomViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择客户";
    
    [self createUI];
    
    [self layoutSubviews];
    
    [self loadNewData];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneMarkOperation:) name:kPhoneMarkOperationNotification object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.isSearching) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }else{
        [self.searchBar becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.currentStatusStr = @"";//全部意向
    
    [self.view addSubview:self.topView];
    [self.topView addSubview:self.topImageView];
    [self.topView addSubview:self.custonNumLabel];
    [self.topView addSubview:self.selectButton];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.contactServiceButton];
    
    [self.view addSubview:self.searchAccessoryView];
    [self.view addSubview:self.searchView];
    [self.view addSubview:self.searchTableView];

    //调整一下视图层级关系
    [self.view bringSubviewToFront:self.contactServiceButton]; //客服按钮移动到最上层
    
    [self initWithAutoRefresh];
    [self initSearchBar];
}

- (void)layoutSubviews{
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(1);
        make.height.equalTo(@48);
    }];
    [self.topImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView);
        make.height.width.equalTo(@20);
        make.left.equalTo(self.topView).offset(12);
    }];
  
    [self.custonNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topImageView.mas_right).offset(12);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@90);
        make.centerY.equalTo(self.topView);
    }];
    
    [self.selectButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView);
        make.height.equalTo(@30);
        make.right.equalTo(self.topView).offset(-12);
        make.width.equalTo(@120);
    }];
    
    [self.selectButton.superview layoutIfNeeded];
    [self layoutCallStatusSelectButton];
    
    [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom).offset(1);
        make.height.equalTo(@54);
    }];
    
    [self.searchTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchView.mas_bottom).offset(1);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchView.mas_bottom).offset(1);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
    
    [self.noDataView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.searchView.mas_bottom).offset(1);
        make.bottom.equalTo(self.view);
    }];
    
    [self.contactServiceButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@54);
        make.right.equalTo(self.view).offset(-10);
        make.bottom.equalTo(self.view).offset(-(20 + SafeAreaBottomHeight));
    }];
    
}

//选择意向状态按钮内文字和图片重新布局
- (void)layoutCallStatusSelectButton{
    CGFloat imageWidth = _selectButton.imageView.bounds.size.width;
    CGFloat labelWidth = _selectButton.titleLabel.bounds.size.width;
    _selectButton.imageEdgeInsets = UIEdgeInsetsMake(1, labelWidth+3, -1, -(labelWidth+3));
    _selectButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, 0, imageWidth);
}

- (void)initSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 54)];// 初始化，不解释
    
    self.searchBar.delegate = self;// 设置代理
    
    self.searchBar.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.searchBar sizeToFit];
    
    self.searchBar.placeholder = @"输入要搜索的内容";
    
    // 包着搜索框外层的颜色
    self.searchBar.barTintColor = [UIColor whiteColor];
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.searchBar.backgroundImage = [UIImage createImageWithColor:[UIColor whiteColor] size:CGSizeMake(0,self.searchBar.frame.size.height)];
    // 更改占位符颜色
    [searchField setValue:UIColorFromRGB(0x96A4B3) forKeyPath:@"_placeholderLabel.textColor"];
    searchField.font = [UIFont systemFontOfSize:14];
    // 设置输入框光标颜色
    self.searchBar.tintColor = UIColorBlueNav;
    // 隐藏边框黑线
    self.searchBar.layer.borderColor = [UIColor whiteColor].CGColor;
    self.searchBar.layer.borderWidth = 1;

    [self.searchView addSubview:self.searchBar];
}

#pragma mark - ******* Notification Methods*******

- (void)phoneMarkOperation:(NSNotification *)noti{
    LiteADsPhoneListModel *model = (LiteADsPhoneListModel *)noti.object;
    NSInteger index = -1;
    for (LiteADsPhoneListModel * phoneModel in self.listDataArray) {
        if ([phoneModel.phone isEqualToString:model.phone]) {
            index = [self.listDataArray indexOfObject:phoneModel];
            break;
        }
    }
    if (index >= 0) {
        [self.listDataArray replaceObjectAtIndex:index withObject:model];
        [self.tableView reloadData];
    }
    //↑↑↑ 正常列表 ↑↑↑
    
    //↓↓↓ 搜索列表 ↓↓↓
    [self requestPhoneListWithSearch:self.searchKeyStr];
 
}

#pragma mark - ******* Action Methods *******

//筛选状态选择
- (void)selectButtonClick:(UIButton *)button{
    [self showPickView];
}
//联系客服
- (void)contactServiceAction:(UIButton *)sender {
    [[BHSobotService sharedInstance] startSoBotCustomerServiceWithViewController:self];
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
//请求电话列表
- (void)requestPhoneList
{
    /*
     page    页码
     pageNum     每页显示最大条数
     signType    标记类型 0未拨打 1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
     maxId    当前数据最大id,标签列表的maxId字段
     labelId      标签id 格式: 12 或者 12,13,14,15
     mobile    要搜索的手机后四位
     */
    //标记类型 1有意向，3未接通， 4空号 ，5无标记, 6无意向
    NSDictionary * params = @{@"page":@(self.currentPage),
                              @"pageNum":@"20",
                              @"signType":self.currentStatusStr,
                              @"maxId":self.maxId,
                              @"labelId":self.labelIds,
                              @"mobile":@""
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiPhoneList
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
                             self.custonNumLabel.text = [NSString stringWithFormat:@"共找到%@人",[dic stringValueForKey:@"num" default:@""]];
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.mark = [dict stringValueForKey:@"mark" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     
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

//根据搜索关键词请求电话列表
- (void)requestPhoneListWithSearch:(NSString *)searchString
{
    /*
     page    页码
     pageNum     每页显示最大条数
     signType    标记类型 0未拨打 1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向
     maxId    当前数据最大id,标签列表的maxId字段
     labelId      标签id 格式: 12 或者 12,13,14,15
     mobile    要搜索的手机后四位
     */
    //标记类型 1有意向，3未接通， 4空号 ，5无标记, 6无意向
    
    [self.searchListDataArray removeAllObjects];
    
    NSDictionary * params = @{@"page":@"1",
                              @"pageNum":@"20",
                              @"signType":@"",
                              @"maxId":self.maxId,
                              @"labelId":self.labelIds,
                              @"mobile":searchString
                              };
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiPhoneList
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             NSArray * array = [dic objectForKey:@"list"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.mark = [dict stringValueForKey:@"mark" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     
                                     [weakSelf.searchListDataArray addObject:model];
                                 }
                             }
                             [weakSelf.searchTableView reloadData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                             [weakSelf searchTableViewReloadEmptyData];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         [weakSelf searchTableViewReloadEmptyData];
                     }];
}


#pragma mark - ******* Private Methods *******

//1.搜索结果为空2.请求失败3.搜索长度不符合要求的时候，清空搜索数据源，搜索tableview刷新页面
- (void)searchTableViewReloadEmptyData{
    [self.searchListDataArray removeAllObjects];
    [self.searchTableView reloadData];
}

#pragma mark - ******* UISearchBar Delegate *******

// UISearchBar得到焦点并开始编辑时，执行该方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
    self.isSearching = YES;
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.2 animations:^{  //动画代码
        
        [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(kStatusBarHeight);
            make.height.equalTo(@56);
        }];
        
        self.searchTableView.hidden = NO;
        self.searchAccessoryView.hidden = NO;
    }];
    return YES;
}
// 取消按钮被按下时，执行的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    self.isSearching = NO;

    [self.searchBar resignFirstResponder];
    
    self.searchBar.text = @"";
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [UIView animateWithDuration:0.2 animations:^{
        [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.topView.mas_bottom).offset(1);
            make.height.equalTo(@56);
        }];
        
        self.searchTableView.hidden = YES;
        self.searchAccessoryView.hidden = YES;
    }];
    
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    NSLog(@"---%@",searchBar.text);
    //在内容变化方法执行搜索  该方法不做操作
}

// 当搜索内容变化时，执行该方法。很有用，可以实现时实搜索
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;{
    
    NSLog(@"textDidChange---%@",searchBar.text);
    if (searchBar.text.length == 4) {
        self.searchKeyStr = searchBar.text;
        [self requestPhoneListWithSearch:self.searchKeyStr];
    }else{
        [self searchTableViewReloadEmptyData];
    }
}

#pragma mark - ******* UITableView Delegate *******

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return self.listDataArray.count;
    }
    return self.searchListDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LitePhoneListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    LiteADsPhoneListModel *model = [LiteADsPhoneListModel new];
    
    if (tableView == self.tableView) {
        model = self.listDataArray[indexPath.row];
    }else{
        model = self.searchListDataArray[indexPath.row];
    }
    
    [cell configWithData:model];
    return  cell;
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
    LiteADsPhoneListModel *model = [LiteADsPhoneListModel new];
    
    if (tableView == self.tableView) {
        model = self.listDataArray[indexPath.row];
    }else{
        model = self.searchListDataArray[indexPath.row];
    }
    
    LitePhoneDetailViewController * detailVC = [[LitePhoneDetailViewController alloc] init];
    detailVC.phoneModel = model;
    [self.navigationController pushViewController:detailVC animated:YES];
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
    //标记类型  全部,0 未拨打 1有意向，，3未接通， 4空号 ，5无标记, 6无意向
    NSString *statusStr = @"";
    switch (index) {
        case 0: //全部
            statusStr = @"";
            break;
        case 1: //未拨打
            statusStr = @"0";
            break;
        case 2: //有意向
            statusStr = @"1";
            break;
        case 3: //未接通
            statusStr = @"3";
            break;
        case 4: //空号
            statusStr = @"4";
            break;
        case 5: //无标记
            statusStr = @"5";
            break;
        case 6: //无意向
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


#pragma mark - ******* Getter *******

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = UIColorWhite;
    }
    return _topView;
}

- (UIImageView *)topImageView
{
    if (!_topImageView)
    {
        _topImageView = [[UIImageView alloc] init];
        _topImageView.image = [UIImage imageNamed:@"ads_phone_custom_num"];
        _topImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _topImageView;
}

- (UILabel *)custonNumLabel{
    if (!_custonNumLabel){
        _custonNumLabel = [[UILabel alloc] init];
        _custonNumLabel.text = @"共找到0人";
        _custonNumLabel.textColor = UIColorDrakBlackText;
        _custonNumLabel.textAlignment = NSTextAlignmentLeft;
        _custonNumLabel.font = [UIFont systemFontOfSize:12];
    }
    return _custonNumLabel;
}

- (UIButton *)selectButton{
    
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        _selectButton.backgroundColor = [UIColor clearColor];
        [_selectButton setTitle:@"全部" forState:UIControlStateNormal];
        _selectButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_selectButton setTitleColor:UIColorDrakBlackText forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_selectButton setImage:[UIImage imageNamed:@"down_triangle"] forState:UIControlStateNormal];
        _selectButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        
        _selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;// 水平右对齐
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

- (UIButton *)contactServiceButton{
    
    if (!_contactServiceButton) {
        _contactServiceButton = [[UIButton alloc] init];
        [_contactServiceButton setImage:[UIImage imageNamed:@"ads_contact_service"] forState:UIControlStateNormal];
        _contactServiceButton.adjustsImageWhenHighlighted = NO;// 取消图片的高亮状态
        [_contactServiceButton addTarget:self action:@selector(contactServiceAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactServiceButton;
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
    {   /*全部,0 未拨打 1有意向，2黑名单，3未接通， 4空号 ，5无标记, 6无意向*/
        _selectArray = [NSMutableArray arrayWithObjects:@"全部",@"未拨打",@"有意向",@"未接通",@"空号",@"无标记",@"无意向",nil];
    }
    return _selectArray;
}

- (NSMutableArray *)listDataArray
{
    if (!_listDataArray)
    {
        _listDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listDataArray;
}

- (UIView *)searchView{
    if (!_searchView) {
        _searchView = [[UIView alloc] init];
        _searchView.backgroundColor = UIColorWhite;
    }
    return _searchView;
}

- (UIView *)searchAccessoryView{
    if (!_searchAccessoryView) {
        _searchAccessoryView = [[UIView alloc] initWithFrame:self.view.bounds];
        _searchAccessoryView.backgroundColor = UIColorWhite;
        _searchAccessoryView.hidden = YES;
    }
    return _searchAccessoryView;
}

- (NSMutableArray *)searchListDataArray
{
    if (!_searchListDataArray)
    {
        _searchListDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _searchListDataArray;
}

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
        
        [_tableView registerClass:[LitePhoneListCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

- (UITableView *)searchTableView
{
    if (!_searchTableView)
    {
        _searchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _searchTableView.backgroundColor = UIColorClearColor;
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        //        _tableView.bounces = NO;
        
        // 分割线位置
        _searchTableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchTableView.separatorColor = UIColorLine;  // 分割线颜色
        
        if (@available(iOS 11.0, *)) {
            _searchTableView.estimatedRowHeight = 0;
            _searchTableView.estimatedSectionHeaderHeight = 0;
            _searchTableView.estimatedSectionFooterHeight = 0;
            _searchTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        _searchTableView.hidden = YES;
        
        [_searchTableView registerClass:[LitePhoneListCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _searchTableView;
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
