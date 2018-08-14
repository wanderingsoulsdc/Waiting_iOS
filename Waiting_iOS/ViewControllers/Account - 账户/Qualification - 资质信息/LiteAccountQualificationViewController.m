//
//  LiteAccountQualificationViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountQualificationViewController.h"
#import "LiteAccountQualificationCell.h"
#import "LiteAccountQualificationICPViewController.h"
#import <Masonry/Masonry.h>
#import "BHUserModel.h"
#import "FSNetWorkManager.h"
#import "UIViewController+NavigationItem.h"
#import "LiteAlertLabel.h"


@interface LiteAccountQualificationViewController ()<UITableViewDelegate, UITableViewDataSource, LiteAccountQualificationCellDelegate,LiteAccountQualificationICPViewControllerDelegate>

@property (nonatomic , strong) UITableView      * tableView;
@property (nonatomic , strong) NSMutableArray   * listDataArray;    //列表数据
@property (nonatomic , strong) UIView           * footerView;       //底部视图
@property (nonatomic , strong) UIButton         * footSubmitButton; //底部提交按钮
@property (nonatomic , strong) LiteAlertLabel   * alertLabel;

@property (nonatomic , strong) NSArray          * levelTradesArr;   //行业数据

@property (nonatomic , strong) NSString         * aptitudeOneId;    //一级行业id
@property (nonatomic , strong) NSString         * aptitudeTwoId;    //二级行业id
@property (nonatomic , strong) NSString         * businessName;     //营业执照名字
@property (nonatomic , strong) NSString         * businessLicenceImg; //营业执照图片链接
@property (nonatomic , strong) NSString         * auditStatus;      //营业执照审核状态  -1 未上传 0-审核中 1-审核通过  2-拒绝
@property (weak, nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;  //记录侧滑手势

@end

@implementation LiteAccountQualificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"资质信息";
    //记录侧滑返回
    _restoreInteractivePopGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;

    [self createListData];
    [self requesetTradesLevel];
    
    [self.view addSubview:self.alertLabel];

    if ([self.auditStatus isEqualToString:@"2"]) {
        self.alertLabel.titleLabel.text = [BHUserModel sharedInstance].refuseReason;
    }else{
        [self.alertLabel setAlertImageHidden:YES];
        self.alertLabel.titleLabel.text = @"资质审核通过后无法进行修改";
        self.alertLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if ([self.auditStatus isEqualToString:@"1"]) {  //审核通过后不可修改,底部按钮点击直接返回
            self.tableView.userInteractionEnabled = NO;
        }
    }
    
    [self.view addSubview:self.tableView];
    
    [self initWithFooterView];
    // Do any additional setup after loading the view.
    [self setLeftBarButtonTarget:self Action:@selector(leftBarButtonAction:) Image:@"nav_back"];
    
    [self layoutSubviews];

    if (![self.auditStatus isEqualToString:@"-1"]) {
        //只要不是未上传(-1) 按钮都可点
        [self.footSubmitButton setBackgroundColor:UIColorBlue]; //可点击背景色
        self.footSubmitButton.userInteractionEnabled = YES;
    }
}
- (void)leftBarButtonAction:(UIButton *)sender
{
    if (![self checkQualificationContent]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self showAlertWithTitle:@"是否放弃本次操作？" message:@"" type:1];
    }
    NSLog(@"返回");
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message type:(int)type{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alert addAction:cancel];
    
    if (type == 1) {
        UIAlertAction *button = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert addAction:button];
    } else {
        UIAlertAction *button = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self AddAptitudeRequest];
        }];
        [alert addAction:button];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    };
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)createListData{
    NSArray *listArr = @[@{@"title":@"营业执照名称"},
                         @{@"title":@"营业执照"},
                         @{@"title":@"行业分类"}
                         ];
    self.listDataArray = [listArr copy];
    self.businessLicenceImg = [BHUserModel sharedInstance].businessLicenceImg;
    self.businessName = [BHUserModel sharedInstance].businessName;
    self.aptitudeOneId = [BHUserModel sharedInstance].aptitudeOneId;
    self.aptitudeTwoId = [BHUserModel sharedInstance].aptitudeTwoId;
    self.auditStatus = [BHUserModel sharedInstance].auditStatus;
}

#pragma mark - ******* UIGestureRecognizer Delegate *******

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - Private methods

//底视图
- (void)initWithFooterView
{
    self.footerView = [[UIView alloc] init];
    self.footerView.backgroundColor = UIColorWhite;
    self.footerView.frame = CGRectMake(0, 0, kScreenWidth,56);
    
    self.footSubmitButton = [[UIButton alloc] init];
    [self.footSubmitButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.footSubmitButton setBackgroundColor:UIColorlightGray]; //不可点击背景色
    self.footSubmitButton.userInteractionEnabled = NO;
    self.footSubmitButton.layer.cornerRadius = 3.0f;
    self.footSubmitButton.layer.masksToBounds = YES;
    [self.footSubmitButton addTarget:self action:@selector(footSubmitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.footSubmitButton];
    
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
    
    [self.footSubmitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.footerView).offset(48);
        make.top.equalTo(self.footerView).offset(8);
        make.right.equalTo(self.footerView).offset(-48);
        make.height.equalTo(@40);
    }];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    [self.alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.height.equalTo(@32);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertLabel.mas_bottom).offset(0);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
    }];
}
//检查提交状态  YES 可提交      NO 不可提交
- (void)checkSubmitStatus{
    if([self.auditStatus isEqualToString:@"-1"]){ //只有未上传才会检查按钮提交状态
        if (kStringNotNull(self.businessName) && kStringNotNull(self.businessLicenceImg) && kStringNotNull(self.aptitudeOneId) && kStringNotNull(self.aptitudeTwoId) && ![self.aptitudeOneId isEqualToString:@"0"] && ![self.aptitudeTwoId isEqualToString:@"0"]) {
            [self.footSubmitButton setBackgroundColor:UIColorBlue]; //可点击背景色
            self.footSubmitButton.userInteractionEnabled = YES;
        }else{
            [self.footSubmitButton setBackgroundColor:UIColorlightGray]; //不可点击背景色
            self.footSubmitButton.userInteractionEnabled = NO;
        }
    }
}
//检查资质内容是否编辑改变
- (BOOL)checkQualificationContent{
    if ([self.businessLicenceImg isEqualToString: [BHUserModel sharedInstance].businessLicenceImg] &&
        [self.businessName isEqualToString: [BHUserModel sharedInstance].businessName] &&
        [self.aptitudeOneId isEqualToString: [BHUserModel sharedInstance].aptitudeOneId] &&
        [self.aptitudeTwoId isEqualToString: [BHUserModel sharedInstance].aptitudeTwoId]){
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - Action

- (void)footSubmitButtonClick:(UIButton *)button{
    NSLog(@"点击了确定");
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9-_\\u4E00-\\u9FA5]+$"];
    if (![predicate evaluateWithObject:self.businessName]) {
        [ShowHUDTool showBriefAlert:@"营业执照名称不能包含特殊字符"];
        return;
    }
    
    if ([self.auditStatus isEqualToString:@"1"]) { //审核通过
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([self.auditStatus isEqualToString:@"0"]) { //审核中
        if (![self checkQualificationContent]){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showAlertWithTitle:@"重新提交资质？" message:@"当前资质状态为审核中，再次提交需重新进行审核，是否继续？" type:2];
        }
    } else if ([self.auditStatus isEqualToString:@"2"]) { //审核拒绝
        if (![self checkQualificationContent]){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self AddAptitudeRequest];
        }
    } else { //未上传
        [self AddAptitudeRequest];
    }
}
#pragma mark - Request

- (void)AddAptitudeRequest
{
    NSDictionary * params = @{@"businessName":self.businessName, @"businessLicenceImg":self.businessLicenceImg, @"aptitudeOneId":self.aptitudeOneId,@"aptitudeTwoId":self.aptitudeTwoId};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountAddAptitude
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [self.navigationController popViewControllerAnimated:YES];
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

//获取行业分类
- (void)requesetTradesLevel
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiBindTradesLevel
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus)
                         {
                             self.levelTradesArr = object[@"data"];
                             [self.tableView reloadData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - SystemDelegate
//行业选择结果
- (void)LevelTradesSelectResult:(NSDictionary *)dic{
    self.aptitudeOneId = [dic objectForKey:@"first"];
    self.aptitudeTwoId = [dic objectForKey:@"second"];
    NSLog(@"选择了第一行业ID是%@，第二行业ID是%@",self.aptitudeOneId,self.aptitudeTwoId);
    [self checkSubmitStatus];
}

//营业执照名称填写
- (void)businessNameResult:(NSString *)string{
    self.businessName = string;
    NSLog(@"营业执照名称:%@",self.businessName);
    [self checkSubmitStatus];
}

//营业执照上传回调
- (void)changeQualificationFinish:(NSString *)url Type:(ICPCellType)type{
    if (type == ICPCellTypeBusinessLicense) {
        self.businessLicenceImg = url;
        [self.tableView reloadData];
        [self checkSubmitStatus];
    }
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
    LiteAccountQualificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(self.class) forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.businessLicenceImg = self.businessLicenceImg;
    NSDictionary * dict = self.listDataArray[indexPath.row];
    [cell configWithData:dict levelTradesData:self.levelTradesArr];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 12.0f : 25.0f;
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
        if (indexPath.row ==1){ //营业执照
            LiteAccountQualificationICPViewController *ICP = [[LiteAccountQualificationICPViewController alloc] init];
            ICP.delegate =self;
            ICP.type = ICPCellTypeBusinessLicense;
            ICP.qualificationICPUrl = self.businessLicenceImg;
            [self.navigationController pushViewController:ICP animated:YES];

        }
    }
}

#pragma mark - Getters and Setters
// initialize views here, etc

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
        
        [_tableView registerClass:[LiteAccountQualificationCell class] forCellReuseIdentifier:NSStringFromClass(self.class)];
    }
    return _tableView;
}

- (LiteAlertLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        _alertLabel.titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _alertLabel;
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
