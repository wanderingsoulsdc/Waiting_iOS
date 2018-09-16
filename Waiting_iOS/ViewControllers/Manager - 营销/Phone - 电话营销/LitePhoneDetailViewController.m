//
//  LitePhoneDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LitePhoneDetailViewController.h"
#import "LitePhoneDetailCell.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "BHPhoneUserInfoViewController.h"
#import "BHCountDownView.h"
#import "UIViewController+NavigationItem.h"
#import "LitePhoneMarkViewController.h"


@import CoreTelephony;

@interface LitePhoneDetailViewController ()<BHMarketingPhoneUserInfoViewControllerDelegate,BHCountDownViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UILabel            * phoneLabel;    //电话
@property (weak, nonatomic) IBOutlet UILabel            * macLabel;      //mac
@property (weak, nonatomic) IBOutlet UILabel            * informationPhoneLabel; //个人信息电话
@property (weak, nonatomic) IBOutlet UIButton           * informationButton;     //个人信息修改按钮
@property (weak, nonatomic) IBOutlet UIView             * informationView;       //个人信息视图
@property (weak, nonatomic) IBOutlet UIButton           * callButton;    //打电话按钮

@property (weak, nonatomic) IBOutlet BHLoadFailedView   * noDataView;    //无数据页面
@property (weak, nonatomic) IBOutlet UITableView        * tableView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * noDataViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * tableViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * serviceBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoImageViewRightConstraint;

@property (nonatomic , strong) NSMutableArray       * listDataArray;   //列表数据
@property (nonatomic , assign) BOOL                 isCanCallPhone;   //是否可以打电话(个人信息是否完善)

@property (nonatomic , strong) NSString             * deviceId;         //设备id
@property (nonatomic , strong) NSString             * labelId;          //标签id

@property (nonatomic , strong) CTCallCenter         * callCenter;

@property (nonatomic , strong) NSString             * logId;    //标记id,标记号码时必传
@property (nonatomic , strong) NSString             * logTime;  //标记表时间戳,标记号码时必传

@property (weak, nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;  //记录侧滑手势

@end

@implementation LitePhoneDetailViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    //记录侧滑返回
    _restoreInteractivePopGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;
    
    [self createUI];
    [self checkPersonInformation];
    [self requestMarkInfo];
    [self requestCallHistoryList];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneMarkOperation:) name:kPhoneMarkOperationNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    };
    
}

#pragma mark - ******* UIGestureRecognizer Delegate *******

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    
    self.topViewHeightConstraint.constant =  kStatusBarAndNavigationBarHeight +180;
    self.topView.backgroundColor = UIColorBlue;
    self.tableViewBottomConstraint.constant = SafeAreaBottomHeight;
    self.noDataViewBottomConstraint.constant = SafeAreaBottomHeight;
    self.serviceBottomConstraint.constant = 20 + SafeAreaBottomHeight;

    if (IS_IPHONE5) {
        self.infoImageViewLeftConstraint.constant = 5;
        self.infoImageViewRightConstraint.constant = 5;
    }
    
    if (@available(iOS 11.0, *)) {
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.tableView.backgroundColor = UIColorClearColor;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([LitePhoneDetailCell class]) bundle:nil] forCellReuseIdentifier:@"LitePhoneDetailCell"];
    
}

#pragma mark - ******* Notification Methods*******

- (void)phoneMarkOperation:(NSNotification *)noti{
    [self.listDataArray removeAllObjects];
    [self requestCallHistoryList];
}

#pragma mark - ******* Private Methods *******
//检查用户信息,用于判断是否能打电话
- (void)checkPersonInformation{
    
    NSString * ownPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNumberUserDefault];
    NSString * ownName = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNameUserDefault];
    NSString * ownIDCard = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneIDCardUserDefault];
    
    if (kStringNotNull(ownPhoneNumber) && kStringNotNull(ownName) && kStringNotNull(ownIDCard)) { //个人信息完善
        self.informationView.backgroundColor = UIColorWhite;
        
        self.informationButton.layer.borderWidth = 1;
        self.informationButton.layer.borderColor = UIColorBlue.CGColor;
        self.informationButton.backgroundColor = UIColorWhite;
        [self.informationButton setTitle:@"修改号码" forState:UIControlStateNormal];
        [self.informationButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
        
        self.informationPhoneLabel.text = [NSString stringWithFormat:@"请使用 [ %@ ] 拨打电话！",ownPhoneNumber];
        self.informationPhoneLabel.textColor = UIColorFromRGB(0x797E81);

        self.isCanCallPhone = YES;
    }else{ //个人信息不完善
        self.informationView.backgroundColor = [UIColor colorWithRed:72/255.0 green:149/255.0 blue:242/255.0 alpha:0.2];
        self.informationButton.backgroundColor = UIColorBlue;
        [self.informationButton setTitle:@"立即设置" forState:UIControlStateNormal];
        [self.informationButton setTitleColor:UIColorWhite forState:UIControlStateNormal];

        self.informationPhoneLabel.text = @"设置本机号码后，才能拨打电话哦!";
        self.informationPhoneLabel.textColor = UIColorBlue;
        
        self.isCanCallPhone = NO;
    }
}
//旋转动画
- (void)startAnimation
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.0 ];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.callButton.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation
{
    [self.callButton.layer removeAllAnimations];
}

#pragma mark - ******* Common Delegate *******
//个人资料完善成功
- (void)finishedEditUserInfo
{
    [self checkPersonInformation];
}
//回拨倒计时完成
- (void)countDownFinish
{
    //从旋转变回原状
    [self stopAnimation];
    self.callButton.selected = NO;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未检测到回拨电话" message:@"电话平台网络不通,未检测到来电，如果您已成功拨打电话，请直接“标记用户”。" preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //跳转到标记页
        LitePhoneMarkViewController *markVC = [[LitePhoneMarkViewController alloc] init];
        markVC.logId = self.logId;
        markVC.logTime = self.logTime;
        markVC.phoneModel = self.phoneModel;
        [self.navigationController pushViewController:markVC animated:YES];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - ******* Action Methods *******
- (IBAction)informationButtonAction:(UIButton *)sender {
    BHPhoneUserInfoViewController * phoneUserInfoVC = [[BHPhoneUserInfoViewController alloc] init];
    phoneUserInfoVC.delegate = self;
    [self.navigationController pushViewController:phoneUserInfoVC animated:YES];
}
- (IBAction)leftButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)callButtonAction:(UIButton *)sender {
    //开始打电话,进入旋转
    if(!self.isCanCallPhone){
        BHPhoneUserInfoViewController * phoneUserInfoVC = [[BHPhoneUserInfoViewController alloc] init];
        phoneUserInfoVC.delegate = self;
        [self.navigationController pushViewController:phoneUserInfoVC animated:YES];
    }else{
        sender.selected = YES;
        [self startAnimation];
        [self requestPhoneCallOut];
    }
}
- (IBAction)contactServiceAction:(UIButton *)sender {
      
}
#pragma mark - ******* Request *******
//请求标记详情
- (void)requestMarkInfo
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiPhoneMarkInfo
                        withParaments:@{@"cipherPhone":self.phoneModel.cipherPhone}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"];
                             self.phoneLabel.text = [dic stringValueForKey:@"phone" default:@""];
                             self.deviceId = [dic stringValueForKey:@"deviceId" default:@""];
                             self.labelId = [dic stringValueForKey:@"labelId" default:@""];
                             self.macLabel.text = [NSString stringWithFormat:@"Mac %@",[dic stringValueForKey:@"mac" default:@""]];
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
//请求通话历史
- (void)requestCallHistoryList
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiPhoneCallHistory
                        withParaments:@{@"cipherPhone":self.phoneModel.cipherPhone}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSArray * array = object[@"data"];
                             if (array.count > 0)
                             {
                                 for (NSDictionary * dict in array)
                                 {
                                     LiteADsPhoneListModel * model = [[LiteADsPhoneListModel alloc] init];
                                     model.phone = [dict stringValueForKey:@"phone" default:@""];
                                     model.mark = [dict stringValueForKey:@"mark" default:@""];
                                     model.cipherPhone = [dict stringValueForKey:@"cipherPhone" default:@""];
                                     model.reportSpend = [dict stringValueForKey:@"reportSpend" default:@""];
                                     model.startTime = [dict stringValueForKey:@"startTime" default:@""];
                                     model.talkTime = [dict stringValueForKey:@"talkTime" default:@""];
                                     model.markInfo = [dict stringValueForKey:@"markInfo" default:@""];

                                     [self.listDataArray addObject:model];
                                 }
                                 
                                 [self.tableView reloadData];
                                 
                                 self.tableView.hidden = NO;
                                 self.noDataView.hidden = YES;
                             }
                             else
                             {
                                 self.tableView.hidden = YES;
                                 self.noDataView.hidden = NO;
                             }
                         }
                         else
                         {
                             self.tableView.hidden = YES;
                             self.noDataView.hidden = NO;
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         self.tableView.hidden = YES;
                         self.noDataView.hidden = NO;
                     }];
}
//请求打电话
- (void)requestPhoneCallOut{
 
    NSString * ownPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNumberUserDefault];
    NSString * ownName = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNameUserDefault];
    NSString * ownIDCard = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneIDCardUserDefault];
    
    NSDictionary *params = @{@"call":ownPhoneNumber,
                             @"cipherPhone":self.phoneModel.cipherPhone,
                             @"name":ownName,
                             @"cardId":ownIDCard,
                             @"deviceId":self.deviceId,
                             @"labelId":self.labelId,
                             };
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiPhoneCallOut
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus){
                             NSLog(@"请求成功");
                             NSDictionary * dic = object[@"data"];
                             /*
                              "data": {
                                "telX": "15669024160", //隐私号码
                                "logId": "50", //标记id,标记号码时必传
                                "logTime": 1529738395 //标记表时间戳,标记号码时必传
                                "callModel": 1  //1-主动呼出  2-被动接听
                              }*/
                             
                             weakSelf.logId = [dic stringValueForKey:@"logId" default:@""];
                             weakSelf.logTime = [dic stringValueForKey:@"logTime" default:@""];
                             
                             LitePhoneMarkViewController *markVC = [[LitePhoneMarkViewController alloc] init];
                             markVC.logId = weakSelf.logId;
                             markVC.logTime = weakSelf.logTime;
                             markVC.phoneModel = weakSelf.phoneModel;

                             if ([[dic stringValueForKey:@"callModel" default:@""] integerValue] == 1)
                             {
                                 NSMutableString * callPhone = [[NSMutableString alloc] initWithFormat:@"tel:%@",dic[@"telX"]];
                                 CGFloat version = [[[UIDevice currentDevice]systemVersion]floatValue];
                                 if (version >= 10.0) {
                                     /// 大于等于10.0系统使用此openURL方法
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone] options:@{} completionHandler:nil];
                                 } else {
                                     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
                                 }
                                 //从旋转变回原状
                                 [self stopAnimation];
                                 self.callButton.selected = NO;
                                 
                                 //跳转到标记页
                                 [weakSelf.navigationController pushViewController:markVC animated:YES];
                             }
                             else
                             {
                                 BHCountDownView * countDownView = [[BHCountDownView alloc] initWithView:[UIApplication sharedApplication].keyWindow];
                                 countDownView.countDownTime = 10;
                                 countDownView.delegate = self;
                                 countDownView.title = [NSString stringWithFormat:@"请等待电话平台回拨！"];
                                 countDownView.detailTitle = @"(客户接到的来电显示为您的小号号码)";
                                 [countDownView show];
                                 
                                 WEAKSELF;
                                 self.callCenter.callEventHandler = ^(CTCall* call) {
                                     STRONGSELF;
                                     if (call.callState == CTCallStateIncoming) {
                                         NSLog(@"来电");
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [countDownView hidden];
                                             //从旋转变回原状
                                             [strongSelf stopAnimation];
                                             strongSelf.callButton.selected = NO;
                                         });
                                     }else if (call.callState == CTCallStateDialing) {
                                         NSLog(@"呼出");
                                     }else if (call.callState == CTCallStateConnected) {
                                         NSLog(@"接通");
                                     }else if (call.callState == CTCallStateDisconnected) {
                                         NSLog(@"断开");
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             //跳转到标记页
                                             [strongSelf.navigationController pushViewController:markVC animated:YES];                                         });
                                     };
                                 };
                             }
                         }else{
                             //从旋转变回原状
                             [self stopAnimation];
                             self.callButton.selected = NO;
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         //从旋转变回原状
                         [self stopAnimation];
                         self.callButton.selected = NO;
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
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
    static NSString *identifier = @"LitePhoneDetailCell";
    LitePhoneDetailCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LitePhoneDetailCell" owner:nil options:nil].firstObject;
        NSLog(@"cell create at row:%ld", (long)indexPath.row);//此处要使用loadnib方式！
    }
    LiteADsPhoneListModel * model = self.listDataArray[indexPath.row];
    [cell configWithData:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0f;
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

#pragma mark - ******* Getter *******

- (NSMutableArray *)listDataArray
{
    if (!_listDataArray)
    {
        _listDataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _listDataArray;
}

- (CTCallCenter *)callCenter
{
    if (!_callCenter)
    {
        _callCenter = [[CTCallCenter alloc] init];
    }
    return _callCenter;
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
