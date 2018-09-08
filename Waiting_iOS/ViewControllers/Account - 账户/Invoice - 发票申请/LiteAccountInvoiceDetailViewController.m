//
//  LiteAccountInvoiceDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceDetailViewController.h"
#import "LiteAccountInvoiceCell.h"
#import "NSString+Helper.h"
#import <Masonry/Masonry.h>
#import "FSNetWorkManager.h"
#import "LiteAccountInvoiceModel.h"


@interface LiteAccountInvoiceDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView       * tableView;
@property (nonatomic, strong) NSMutableArray    * listDataArray;    //列表数据
@property (nonatomic, strong) UIView            * headerView;       //tableview头视图
@property (nonatomic, strong) UILabel           * headStatusLabel;    //头像
@property (nonatomic, strong) UILabel           * headTimeLabel;   //头像名称
@property (nonatomic, strong) UILabel           * headContentLabel;   //头像电话

@property (nonatomic, strong) UIView            * footerView;       //tableview底部视图
@property (nonatomic, strong) UIButton          * footSubmitButton; //底部提交按钮

@property (nonatomic, strong) LiteAccountInvoiceModel *model;
@end

@implementation LiteAccountInvoiceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self layoutSubviews];
    
    [self requestDetail];
}

- (void)layoutSubviews{
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
}

- (void)createData{
    NSArray *oneArray =@[@{@"title":@"发票抬头",@"content":self.model.invoiceTitle},
                      @{@"title":@"发票项目",@"content":@"信息服务费"},
                      @{@"title":@"发票金额(元)",@"content":self.model.credit}];
    NSArray *twoArray = @[@{@"title":@"发票类型",@"content":[self.model.invoiceType isEqualToString:@"1"]?@"增值税普通发票":@"增值税专用发票"},
                        @{@"title":@"开户银行",@"content":self.model.bankName},
                        @{@"title":@"银行账号",@"content":self.model.bankNumber},
                        @{@"title":@"注册地址",@"content":self.model.registerAddress},
                        @{@"title":@"注册电话",@"content":self.model.registerPhone},
                        @{@"title":@"纳税人识别号",@"content":self.model.identify}];
    NSMutableArray *twoMutableArray = [[NSMutableArray alloc] initWithArray:twoArray];
    if ([self.model.invoiceType isEqualToString:@"2"]) { //专票
        [twoMutableArray addObject:@{@"title":@"银行纳税人证明",@"content":self.model.bankTaxpay}];
    }
    NSArray *threeArray = @[@{@"title":@"收件人姓名",@"content":self.model.consignee},
                            @{@"title":@"收件人电话",@"content":self.model.phone},
                            @{@"title":@"收件地址",@"content":self.model.address},
                            ];
    [self.listDataArray addObject:oneArray];
    
    if ([self.model.type integerValue] == 1) {
        [self.listDataArray addObject:twoMutableArray];
    }
    [self.listDataArray addObject:threeArray];
}

//头视图（头像&充值）
- (void)initWithTableHeaderView
{
    NSInteger height = 85;
    if ([self.model.status integerValue] == 3) {
        //（审核拒绝）
        if (kStringNotNull(self.model.reason)) { //原因不为空
            height = 120;
        }
    }else if ([self.model.status integerValue] == 2){
        //（已寄出）
        if (kStringNotNull(self.model.expressName) || kStringNotNull(self.model.expressNumber)) { //快递名称和快递单号同时不为空
            height = 120;
        }
    }
    //高度85 (通过,审核中，已撤销) 高度120（审核拒绝,已寄出）
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = UIColorWhite;
    self.headerView.frame = CGRectMake(0, 0, kScreenWidth,height);
    
    self.headStatusLabel = [[UILabel alloc] init];
    self.headStatusLabel.textAlignment = NSTextAlignmentLeft;
    self.headStatusLabel.font = [UIFont systemFontOfSize:18];
    [self.headerView addSubview:self.headStatusLabel];
    switch ([self.model.status integerValue]) {
        case 1:
            self.headStatusLabel.text = @"审核中";
            self.headStatusLabel.textColor = UIColorAlert;
            break;
        case 2:
            self.headStatusLabel.text = @"已寄出";
            self.headStatusLabel.textColor = UIColorFromRGB(0x5ED7BC);
            break;
        case 3:
            self.headStatusLabel.text = @"审核拒绝";
            self.headStatusLabel.textColor = UIColorError;
            break;
        case 4:
            self.headStatusLabel.text = @"已撤销";
            self.headStatusLabel.textColor = UIColorlightGray;
            break;
        case 5:
            self.headStatusLabel.text = @"审核通过";
            self.headStatusLabel.textColor = UIColorBlue;
            break;
    }
    
    self.headTimeLabel = [[UILabel alloc] init];
    self.headTimeLabel.text = self.model.mtime;
    self.headTimeLabel.textAlignment = NSTextAlignmentLeft;
    self.headTimeLabel.textColor = UIColorlightGray;
    self.headTimeLabel.font = [UIFont systemFontOfSize:14];
    [self.headerView addSubview:self.headTimeLabel];
    
    if ([self.model.status integerValue] == 3) {
        //（审核拒绝）
        if (kStringNotNull(self.model.reason)) { //原因不为空
            self.headContentLabel = [[UILabel alloc] init];
            self.headContentLabel.text = self.model.reason;
            self.headContentLabel.textAlignment = NSTextAlignmentLeft;
            self.headContentLabel.textColor = UIColorDarkBlack;
            self.headContentLabel.font = [UIFont systemFontOfSize:14];
            [self.headerView addSubview:self.headContentLabel];
        }
    }else if ([self.model.status integerValue] == 2){
        //（已寄出）
        if (kStringNotNull(self.model.expressName) || kStringNotNull(self.model.expressNumber)) { //快递名称和快递单号同时不为空
            self.headContentLabel = [[UILabel alloc] init];
            self.headContentLabel.text = [[NSString stringWithFormat:@"快递单号 : %@",self.model.expressNumber] stringByAppendingString:kStringNotNull(self.model.expressName) ? [NSString stringWithFormat:@" (%@)",self.model.expressName]:@""];
            
            self.headContentLabel.textAlignment = NSTextAlignmentLeft;
            self.headContentLabel.textColor = UIColorDarkBlack;
            self.headContentLabel.font = [UIFont systemFontOfSize:14];
            [self.headerView addSubview:self.headContentLabel];
        }
    }

    [self layoutHeaderViews];
    self.tableView.tableHeaderView = self.headerView;
    
}

//头视图布局
- (void)layoutHeaderViews{
    
    [self.headStatusLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(15);
        make.top.equalTo(self.headerView).offset(20);
        make.height.equalTo(@25);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.headTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView).offset(15);
        make.top.equalTo(self.headStatusLabel.mas_bottom);
        make.height.equalTo(@20);
        make.width.greaterThanOrEqualTo(@100);
    }];
    
    if ([self.model.status integerValue] == 2 || [self.model.status integerValue] == 3) {
        //（审核拒绝,已寄出）
        [self.headContentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headerView).offset(15);
            make.top.equalTo(self.headTimeLabel.mas_bottom).offset(15);
            make.height.equalTo(@20);
            make.right.equalTo(self.headerView).offset(-15);
        }];
    }
}

//底视图
- (void)initWithFooterView
{
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = UIColorWhite;
    self.footerView.frame = CGRectMake(0, 0, kScreenWidth,56);
    
    self.footSubmitButton = [[UIButton alloc] init];
    [self.footSubmitButton setTitle:@"撤销申请" forState:UIControlStateNormal];
    [self.footSubmitButton setBackgroundColor:UIColorError];
    self.footSubmitButton.layer.cornerRadius = 3.0f;
    self.footSubmitButton.layer.masksToBounds = YES;
    [self.footSubmitButton addTarget:self action:@selector(footSubmitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.footSubmitButton];
    
    [self.view addSubview:self.footerView];
    [self layoutFooterViews];
}

//底部视图布局
- (void)layoutFooterViews{
    
    [self.footerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(56);
    }];
    
    [self.footSubmitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footerView).offset(48);
        make.top.equalTo(self.footerView).offset(8);
        make.right.equalTo(self.footerView).offset(-48);
        make.height.equalTo(@40);
    }];
    
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.footerView.mas_top);
     }];
}

#pragma mark - Request

//请求发票详情
- (void)requestDetail
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiInvoiceDetail
                        withParaments:@{@"id":self.invoiceModel.id}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             NSDictionary *dict = object[@"data"];
                             LiteAccountInvoiceModel *model = [[LiteAccountInvoiceModel alloc] init];
                             model.id = [dict stringValueForKey:@"id" default:@""];
                             model.number = [dict stringValueForKey:@"number" default:@""];
                             model.credit = [dict stringValueForKey:@"credit" default:@""];
                             model.status = [dict stringValueForKey:@"status" default:@""];
                             model.applyTime = [dict stringValueForKey:@"applyTime" default:@""];
                             model.accountId = [dict stringValueForKey:@"accountId" default:@""];
                             model.expressName = [dict stringValueForKey:@"expressName" default:@""];
                             model.invoiceType = [dict stringValueForKey:@"invoiceType" default:@""];
                             model.invoiceTitle = [dict stringValueForKey:@"invoiceTitle" default:@""];
                             model.expressNumber = [dict stringValueForKey:@"expressNumber" default:@""];
                             model.registerAddress = [dict stringValueForKey:@"registerAddress" default:@""];
                             model.registerPhone = [dict stringValueForKey:@"registerPhone" default:@""];
                             model.bankTaxpay = [dict stringValueForKey:@"bankTaxpay" default:@""];
                             model.bankNumber = [dict stringValueForKey:@"bankNumber" default:@""];
                             model.consignee = [dict stringValueForKey:@"consignee" default:@""];
                             model.bankName = [dict stringValueForKey:@"bankName" default:@""];
                             model.identify = [dict stringValueForKey:@"identify" default:@""];
                             model.address = [dict stringValueForKey:@"address" default:@""];
                             model.remark = [dict stringValueForKey:@"remark" default:@""];
                             model.reason = [dict stringValueForKey:@"reason" default:@""];
                             model.mtime = [dict stringValueForKey:@"mtime" default:@""];
                             model.phone = [dict stringValueForKey:@"phone" default:@""];
                             model.type = [dict stringValueForKey:@"type" default:@""];
                             model.phone = [dict stringValueForKey:@"phone" default:@""];
                             self.model = model;
                             
                             [self createData];
                             [self initWithTableHeaderView];
                             if ([self.model.status integerValue] == 1) {   //审核中
                                 [self initWithFooterView];
                             }
                             
                             [self.tableView reloadData];
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
//发票撤销
/*
 id         发票id
 status     发票状态 4 撤销申请
 */
- (void)requestRevocation
{
    WEAKSELF;
    NSDictionary *params = @{@"id":self.invoiceModel.id,
                             @"status":@"4"
                             };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                         withUrlString:kApiInvoiceUpdateStatus
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             [[ShowHUDTool shareManager] showAlertWithCustomImage:@"login_register_success" title:@"发票申请撤销成功" message:@""];
                             [weakSelf.navigationController popViewControllerAnimated:YES];
                             
                             if ([weakSelf.delegate respondsToSelector:@selector(invoiceRecallSuccess:)]) {
                                 weakSelf.invoiceModel.status = @"4";
                                 NSDictionary *dataDic = object[@"data"];
                                 weakSelf.invoiceModel.mtime = [dataDic stringValueForKey:@"mtime" default:@""];
                                 [weakSelf.delegate invoiceRecallSuccess:weakSelf.invoiceModel];
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

#pragma mark - Action

- (void)footSubmitButtonClick:(UIButton *)button{
    NSLog(@"点击申请撤销");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"撤销发票申请?" message:@"撤销当前发票申请后不可恢复，您可继续提交一个新的申请。" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancel];
    
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"立即撤销" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self requestRevocation];
    }];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.listDataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.listDataArray[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LiteAccountInvoiceCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSArray *arr = self.listDataArray[indexPath.section];
    
    [cell configWithData:arr[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.listDataArray[indexPath.section];
    NSDictionary *dic = arr[indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"收件地址"]) {
        NSString *content = [dic objectForKey:@"content"];
        CGSize constraintSize;
        constraintSize.width = kScreenWidth - 15*2 -16;
        constraintSize.height = MAXFLOAT;
        CGSize size = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:constraintSize];
        return 15+30+5+size.height+15;
    }
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = UIColorDarkBlack;
    label.font = [UIFont systemFontOfSize:12];
    label.backgroundColor = UIColorClearColor;
    if (section == 0) {
        label.text = @"   发票信息";
    }
    if ([self.model.type integerValue] == 1) {   //企业
        if (section == 2){
            label.text = @"   收件信息";
        }
    }else{
        if (section == 1){
            label.text = @"   收件信息";
        }
    }
    return label;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }
    
    if ([self.model.type integerValue] == 1) {   //企业
        if (section == 2){
            return 30;
        }else if (section == 1){
            return 10;
        }
    }else{
        if (section == 1){
            return 30;
        }
    }
    
    return 0.1f;
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
    
}

#pragma mark - Getters and Setters

- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.height = IS_IPhoneX ? kScreenHeight-88-34 : kScreenHeight-64;
        _tableView.backgroundColor = UIColorFromRGB(0xF4F4F4);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        
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
        
        [_tableView registerClass:[LiteAccountInvoiceCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
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

- (LiteAccountInvoiceModel *)model
{
    if (!_model)
    {
        _model = [[LiteAccountInvoiceModel alloc] init];
    }
    return _model;
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
