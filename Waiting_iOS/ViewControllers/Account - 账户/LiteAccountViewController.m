//
//  LiteAccountViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/13.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountViewController.h"
#import "LiteAccountListCell.h"
#import "Masonry.h"
#import "LiteAccountQualificationViewController.h"
#import "LiteAccountTransactionViewController.h"
#import "LiteAccountInvoiceReportViewController.h"
#import "LiteAccountLabelWasteViewController.h"
#import "LiteAccountSetupViewController.h"
#import "LiteAccountRechargeViewController.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"

@interface LiteAccountViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据
@property (nonatomic, strong) UIView            * headerView;       //tableview头视图
@property (nonatomic, strong) UIButton          * headImageButton;    //头像
@property (nonatomic, strong) UILabel           * headTitleLabel;   //头像名称
@property (nonatomic, strong) UILabel           * headPhoneLabel;   //头像电话

@property (nonatomic, strong) UIView            * moneyView;        //余额视图
@property (nonatomic, strong) UILabel           * moneyTitleLabel;
@property (nonatomic, strong) UILabel           * moneyNumLabel;    //账户余额
@property (nonatomic, strong) UIButton          * rechargeButton;   //充值按钮

@property (nonatomic, assign) BOOL              isRequestUserInfo;
//是否正在请求用户信息

@end

@implementation LiteAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"";
    self.view.backgroundColor = UIColorBackGround;
    
    [self createListData];
    
    [self.view addSubview:self.tableView];
    
    [self initWithTableHeaderView];
    // Do any additional setup after loading the view.
    self.navigationController.delegate = self;
    
}

- (void)createListData{
    NSArray *listArr = @[@[@{@"title":@"资质信息",@"image":@"account_qualification"},
                           @{@"title":@"交易记录",@"image":@"account_Transaction_records"},
                           @{@"title":@"发票申请",@"image":@"account_invoice_apply"},
                           @{@"title":@"标签垃圾桶",@"image":@"account_label_waste"}
                           ],
                         @[@{@"title":@"设置",@"image":@"account_setup"}
                           ]
                         ];
    self.listDataArray = [listArr copy];
}

#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    
    [self.navigationController setNavigationBarHidden:isSelfVC animated:YES];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self requestUserInfo];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
#pragma mark - request

//请求用户详情
- (void)requestUserInfo
{
    WEAKSELF
    if (self.isRequestUserInfo) { //如果正在请求中,不做操作
        return;
    }
    self.isRequestUserInfo = YES;
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiGetUserInfo
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object];
                             if (kStringNotNull([BHUserModel sharedInstance].businessName)) {
                                 weakSelf.headTitleLabel.text = [BHUserModel sharedInstance].businessName;
                                 weakSelf.headPhoneLabel.text = [BHUserModel sharedInstance].userMobile;
                                 weakSelf.moneyNumLabel.text = [BHUserModel sharedInstance].balance;
                             }
                             [weakSelf.tableView reloadData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         weakSelf.isRequestUserInfo = NO;
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         weakSelf.isRequestUserInfo = NO;
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - Action

- (void)rechargeButtonAction:(UIButton *)button{
    NSLog(@"充值");
    LiteAccountRechargeViewController *rechargeVC = [[LiteAccountRechargeViewController alloc] init];
    rechargeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rechargeVC animated:YES];
}

- (void)headImageButtonClick:(UIButton *)button{
    NSLog(@"点击了头像");
}

#pragma mark - SystemDelegate

#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listDataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArr = [self.listDataArray objectAtIndex:section];
    return sectionArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * dict = self.listDataArray[indexPath.section][indexPath.row];
    [cell configWithData:dict];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 15.0f : 25.0f;
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
    if (indexPath.section == 0) {
        if (indexPath.row ==0) {        //资质管理
            LiteAccountQualificationViewController *qualificationVC = [[LiteAccountQualificationViewController alloc] init];
            qualificationVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:qualificationVC animated:YES];
        } else if (indexPath.row ==1){  //交易记录
            LiteAccountTransactionViewController *transactionVC = [[LiteAccountTransactionViewController alloc] init];
            transactionVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:transactionVC animated:YES];
        } else if (indexPath.row ==2){  //发票申请记录
            if ([[BHUserModel sharedInstance].auditStatus isEqualToString:@"1"]) {
                //资质审核状态  -1 未上传 0-审核中 1-审核通过  2-拒绝
                LiteAccountInvoiceReportViewController *invoiceApplyVC = [[LiteAccountInvoiceReportViewController alloc] init];
                invoiceApplyVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:invoiceApplyVC animated:YES];
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发票申请提示" message:@"\n资质审核通过后才能进行发票申请\n" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *button = [UIAlertAction actionWithTitle:@"朕知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alert addAction:button];
                [self presentViewController:alert animated:YES completion:nil];
                return;
            }
        } else if (indexPath.row ==3){  //标签垃圾桶
            LiteAccountLabelWasteViewController *labelWasteVC = [[LiteAccountLabelWasteViewController alloc] init];
            labelWasteVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:labelWasteVC animated:YES];
        }
    } else { //设置
        LiteAccountSetupViewController *setupVC = [[LiteAccountSetupViewController alloc] init];
        setupVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setupVC animated:YES];
    }
}


#pragma mark - Private methods

//头视图（头像&充值）
- (void)initWithTableHeaderView
{
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = UIColorBlue;
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth,150 + kStatusBarAndNavigationBarHeight);
    
    self.headImageButton = [[UIButton alloc] init];
    [self.headImageButton setImage:[UIImage imageNamed:@"account_default_head"] forState:UIControlStateNormal];
    [self.headImageButton addTarget:self action:@selector(headImageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.headImageButton];
    
    self.headTitleLabel = [[UILabel alloc] init];
    self.headTitleLabel.text =  kStringNotNull([BHUserModel sharedInstance].businessName)?[BHUserModel sharedInstance].businessName:@"未设置名称";
    self.headTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.headTitleLabel.textColor = UIColorWhite;
    self.headTitleLabel.font = [UIFont systemFontOfSize:16];
    [self.headerView addSubview:self.headTitleLabel];
    
    self.headPhoneLabel = [[UILabel alloc] init];
    self.headPhoneLabel.text = kStringNotNull([BHUserModel sharedInstance].userMobile)?[BHUserModel sharedInstance].userMobile:@"";
    self.headPhoneLabel.textAlignment = NSTextAlignmentLeft;
    self.headPhoneLabel.textColor = UIColorWhite;
    self.headPhoneLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:self.headPhoneLabel];
    
    self.moneyView = [[UIView alloc] init];
    self.moneyView.backgroundColor = UIColorWhite;
    
    self.moneyTitleLabel = [[UILabel alloc] init];
    self.moneyTitleLabel.text = @"账户余额(元)";
    self.moneyTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.moneyTitleLabel.textColor = UIColorDarkBlack;
    self.moneyTitleLabel.font = [UIFont systemFontOfSize:12];
    [self.moneyView addSubview:self.moneyTitleLabel];
    
    
    self.moneyNumLabel = [[UILabel alloc] init];
    NSString *moneyNum = [BHUserModel sharedInstance].balance;
    self.moneyNumLabel.text = kStringNotNull(moneyNum)?moneyNum:@"0.00";
    self.moneyNumLabel.textAlignment = NSTextAlignmentLeft;
    self.moneyNumLabel.textColor = UIColorAlert;
    self.moneyNumLabel.font = [UIFont systemFontOfSize:20];
    [self.moneyView addSubview:self.moneyNumLabel];
    
    self.rechargeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rechargeButton.backgroundColor = UIColorFromRGB(0xECF4FE);
    [self.rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
    [self.rechargeButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
    self.rechargeButton.titleLabel.font = [UIFont systemFontOfSize:12];
    self.rechargeButton.layer.cornerRadius = 14;
    self.rechargeButton.layer.masksToBounds = YES;
    [self.rechargeButton addTarget:self action:@selector(rechargeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.moneyView addSubview:self.rechargeButton];

    [self.headerView addSubview:self.moneyView];
    
    [self layoutHeaderViews];
    self.tableView.tableHeaderView = self.headerView;
}

//头视图布局
- (void)layoutHeaderViews{
    
    [self.headImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(20);
        make.top.equalTo(self.headerView).offset(4 + kStatusBarAndNavigationBarHeight);
        make.width.height.equalTo(@60);
    }];
    
    [self.headTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageButton.mas_right).offset(20);
        make.top.equalTo(self.headImageButton.mas_top);
        make.height.equalTo(@35);
        make.right.equalTo(self.headerView).offset(-12);
    }];
    
    [self.headPhoneLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImageButton.mas_right).offset(20);
        make.top.equalTo(self.headTitleLabel.mas_bottom);
        make.height.equalTo(@25);
        make.right.equalTo(self.headerView).offset(-12);
    }];

    [self.moneyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.headerView);
        make.height.equalTo(@54);
    }];
    
    [self.moneyTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moneyView).offset(15);
        make.centerY.equalTo(self.moneyView.mas_centerY);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@70);
    }];
    
    [self.moneyNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moneyTitleLabel.mas_right).offset(12);
        make.centerY.equalTo(self.moneyView.mas_centerY);
        make.height.equalTo(@30);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    [self.rechargeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.moneyView).offset(-20);
        make.centerY.equalTo(self.moneyView.mas_centerY);
        make.height.equalTo(@30);
        make.width.equalTo(@80);
    }];
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.height = kScreenHeight - 49 - SafeAreaBottomHeight;
        _tableView.backgroundColor = UIColorFromRGB(0xF4F4F4);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        
        // 分割线位置
        _tableView.separatorInset = UIEdgeInsetsMake(0,10, 0, 10);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = UIColorLine;  // 分割线颜色
        /*
            automaticallyAdjustsScrollViewInsets，当设置为YES时（默认YES），如果视图里面存在唯一一个UIScrollView或其子类View，
            那么它会自动设置相应的内边距，这样可以让scroll占据整个视图，又不会让导航栏遮盖。
            在iOS 11废弃了automaticallyAdjustsScrollViewInsets，而是给UIScrollView增加了contentInsetAdjustmentBehavior属性。
         */
        if (@available(iOS 11.0, *)) {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            [self setAutomaticallyAdjustsScrollViewInsets:NO];
        }
        
        [_tableView registerClass:[LiteAccountListCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
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
