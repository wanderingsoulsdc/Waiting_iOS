//
//  LiteDeviceWorkStatusViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/5.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceWorkStatusViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>   //引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>     //引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "Masonry.h"
#import "LiteReadyStartViewController.h"
#import "LiteDeviceLabelListViewController.h"
#import "LiteCycleProgressButton.h"
#import "FSNetWorkManager.h"
#import "LiteAlertLabel.h"
#import "MyAnimatedAnnotationView.h"

typedef NS_ENUM(NSUInteger, ChangeLabelStatusType) {
    ChangeLabelStatusTypeStop,          //停止
    ChangeLabelStatusTypePause,         //暂停
    ChangeLabelStatusTypeWorking,       //收集中
};

#define buttonWH        90
#define buttonSpace     (kScreenWidth - 2 * buttonWH)/3 //按钮之间间隔
#define HandleViewH     300   //底部操作部分高度
//停止按钮长按时间
static CGFloat  stopLongPressSecond = 0.00; //0.01秒递增

@interface LiteDeviceWorkStatusViewController ()<BMKMapViewDelegate,UINavigationControllerDelegate,BMKGeoCodeSearchDelegate>
{
    BMKMapView          * _mapView;
    
    BMKPointAnnotation  * _animatedAnnotation;      //动画大头针
    MyAnimatedAnnotationView * _animatedAnnotationView; //动画大头针视图
    
    BMKCircle           * _circle;                  //圆形覆盖物
    BMKPointAnnotation  * _centerAnnotation;        //(覆盖物中心点)
    BMKGeoCodeSearch    * _geocodesearch;           //地理编码主类，用来查询、返回结果信息
    NSString            * _geocodeSearchResultStr;  //经纬度解析结果
}
@property (nonatomic , strong) UIView           *navView;
@property (nonatomic , strong) UIButton         *backButton;
@property (nonatomic , strong) UILabel          *midTitleLabel;

@property (nonatomic , strong) UIView           *startBottomHandleView;     //开始底部操作view
@property (nonatomic , strong) UIButton         *startButton;
@property (nonatomic , strong) UITextField      *startTextField;
@property (nonatomic , strong) UILabel          *startLabel;
@property (nonatomic , strong) UIButton         *startAddressButton;


@property (nonatomic , strong) UIView           * workingBottomHandleView;    //工作中底部操作view
@property (nonatomic , strong) UIButton         * pauseButton;
@property (nonatomic , strong) LiteCycleProgressButton  * stopButton;
@property (nonatomic , strong) UIButton         * continueButton;
@property (nonatomic , strong) UILabel          * workingCustomLabel;
@property (nonatomic , strong) UILabel          * customDescribeLabel;
@property (nonatomic , strong) UILabel          * workingTimeLabel;
@property (nonatomic , strong) UILabel          * timeDescribeLabel;
@property (nonatomic , strong) LiteAlertLabel   * alertLabel;
@property (nonatomic , strong) UIImageView      * longPressTipsImageView;

@property (nonatomic , strong) UIView           * successBottomHandleView;   //完成底部操作view
@property (nonatomic , strong) UIButton         * successButton;
@property (nonatomic , strong) UIButton         * successAddressButton;
@property (nonatomic , strong) UIImageView      * successImageView;
@property (nonatomic , strong) UILabel          * successCustomLabel;
@property (nonatomic , strong) UILabel          * successCustomDescribeLabel;
@property (nonatomic , strong) UILabel          * successDeviceNameLabel;
@property (nonatomic , strong) UILabel          * successDeviceDescribeLabel;
@property (nonatomic , strong) UILabel          * successTimeLabel;
@property (nonatomic , strong) UILabel          * successTimeDescribeLabel;

@property (nonatomic , strong) NSTimer          * stopLongPressTimer;       //停止按钮长按计时器
@property (nonatomic , strong) NSTimer          * checkLabelStatusTimer;    //查询标签状态计时器
@property (nonatomic , strong) NSTimer          * workSecondsTimer;         //工作时间(s)计时器
@property (nonatomic , strong) NSString         * deviceLabelId;    //标签ID

@property (nonatomic , assign) long             totalWorkSecond;    //总工作时长


@property (nonatomic , assign) BOOL             isRefreshWorkTimer; //是否已经根据服务器时间 刷新过 工作计时器
@property (nonatomic , assign) BOOL             isDeviceNotNet;     //设备是否正处于断网状态
@property (nonatomic , assign) BOOL             isCheckServerWorkTime; //是否从服务器校验过本地工作时间

@end

@implementation LiteDeviceWorkStatusViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;
    _geocodeSearchResultStr = @"未知地址";
    
    [self addAllSubViews];
    
    [self layoutSubviews];
    
    [self setupBaiduMap];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.workSecondsTimer invalidate];
    self.workSecondsTimer = nil;
    [self.checkLabelStatusTimer invalidate];
    self.checkLabelStatusTimer = nil;
    [self.stopLongPressTimer invalidate];
    self.stopLongPressTimer = nil;
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}

#pragma mark - ******* UINavigationController Delegate *******
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    if (isSelfVC) {
        [self.navigationController setNavigationBarHidden:isSelfVC animated:YES];
    }
}

#pragma mark - ******* UI About *******
//子视图添加操作
- (void)addAllSubViews{
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self.view addSubview:self.navView];
    [self.navView addSubview:self.backButton];
    [self.navView addSubview:self.midTitleLabel];
    
    //创建标签操作区
    [self.startBottomHandleView addSubview:self.startButton];
    [self.startBottomHandleView addSubview:self.startTextField];
    [self.startBottomHandleView addSubview:self.startLabel];
    [self.startBottomHandleView addSubview:self.startAddressButton];
    
    //工作中和暂停中操作区
    [self.workingBottomHandleView addSubview:self.pauseButton];
    [self.workingBottomHandleView addSubview:self.stopButton];
    [self.workingBottomHandleView addSubview:self.continueButton];
    [self.workingBottomHandleView addSubview:self.customDescribeLabel];
    [self.workingBottomHandleView addSubview:self.timeDescribeLabel];
    [self.workingBottomHandleView addSubview:self.workingCustomLabel];
    [self.workingBottomHandleView addSubview:self.workingTimeLabel];
    [self.workingBottomHandleView addSubview:self.alertLabel];
    [self.workingBottomHandleView addSubview:self.longPressTipsImageView];
    //创建成功操作区
    [self.successBottomHandleView addSubview:self.successButton];
    [self.successBottomHandleView addSubview:self.successAddressButton];
    [self.successBottomHandleView addSubview:self.successImageView];
    [self.successBottomHandleView addSubview:self.successCustomLabel];
    [self.successBottomHandleView addSubview:self.successCustomDescribeLabel];
    [self.successBottomHandleView addSubview:self.successTimeLabel];
    [self.successBottomHandleView addSubview:self.successTimeDescribeLabel];
    [self.successBottomHandleView addSubview:self.successDeviceNameLabel];
    [self.successBottomHandleView addSubview:self.successDeviceDescribeLabel];
    
    [self.view addSubview:self.startBottomHandleView];
    [self.view addSubview:self.workingBottomHandleView];
    [self.view addSubview:self.successBottomHandleView];
    
    if (self.workType == DeviceStatusTypeWorking) { //工作中
        
        self.workingBottomHandleView.hidden = NO;
        self.pauseButton.hidden = NO;
        [self setNavDeviceNameAndMac];
        self.deviceLabelId = self.deviceModel.labelId;
        
        [self cycleRequestLabelDetail];
    }else if(self.workType == DeviceStatusTypeWorkPause){ //暂停中
        
        self.workingBottomHandleView.hidden = NO;
        self.stopButton.hidden = NO;
        self.continueButton.hidden = NO;
        [self setNavDeviceNameAndMac];
        self.deviceLabelId = self.deviceModel.labelId;
        
        [self cycleRequestLabelDetail];
    }else{ //创建标签
        self.startBottomHandleView.hidden = NO;
        [self getCurrentDate];
        [self setNavBackButtonAndTitle];
    }
    
    //初始化一个长按手势
    UILongPressGestureRecognizer *longPressGest = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
    //长按等待时间
    longPressGest.minimumPressDuration = 0.3;
    //长按时候,手指头可以移动的距离
    longPressGest.allowableMovement = 90;
    [self.stopButton addGestureRecognizer:longPressGest];
    
}
//视图布局
- (void)layoutSubviews{
    
    [self.navView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(kStatusBarAndNavigationBarHeight);
    }];
    
    [self.backButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navView).offset(15);
        make.bottom.equalTo(self.navView);
        make.height.equalTo(@44);
        make.width.equalTo(@40);
    }];
    
    [self.midTitleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.navView.mas_centerX);
        make.height.equalTo(@44);
        make.bottom.equalTo(self.navView);
        make.width.mas_equalTo(kScreenWidth - 80);
    }];
    
    [self.startBottomHandleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(HandleViewH);
    }];
    
    [self.workingBottomHandleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(HandleViewH);
    }];
    
    [self.successBottomHandleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.mas_equalTo(HandleViewH);
    }];
    
    [_mapView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.navView.mas_bottom);
        make.bottom.equalTo(self.startBottomHandleView.mas_top);
    }];

    [self.startButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.startBottomHandleView.mas_centerX);
        make.bottom.equalTo(self.startBottomHandleView.mas_bottom).offset(-40);
        make.width.height.mas_equalTo(buttonWH);
    }];
    
    [self.startTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startBottomHandleView).offset(55);
        make.right.equalTo(self.startBottomHandleView).offset(-55);
        make.bottom.equalTo(self.stopButton.mas_top).offset(-30);
        make.height.equalTo(@38);
    }];
    
    [self.startLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startBottomHandleView).offset(55);
        make.right.equalTo(self.startBottomHandleView).offset(-55);
        make.bottom.equalTo(self.startTextField.mas_top).offset(-10);
        make.height.equalTo(@20);
    }];
    
    [self.startAddressButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startBottomHandleView).offset(55);
        make.right.equalTo(self.startBottomHandleView).offset(-55);
        make.bottom.equalTo(self.startLabel.mas_top).offset(-25);
        make.height.equalTo(@20);
    }];
    
    [self.pauseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.workingBottomHandleView.mas_centerX);
        make.bottom.equalTo(self.workingBottomHandleView.mas_bottom).offset(-40);
        make.width.height.mas_equalTo(buttonWH);
    }];
    
    [self.stopButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.workingBottomHandleView.mas_bottom).offset(-40);
        make.left.equalTo(self.workingBottomHandleView).offset(buttonSpace);
        make.width.height.mas_equalTo(buttonWH);
    }];
    
    [self.longPressTipsImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.stopButton.mas_top).offset(-8);
        make.centerX.equalTo(self.stopButton.mas_centerX);
        make.height.equalTo(@27);
        make.width.equalTo(@60);
    }];
    
    [self.continueButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.workingBottomHandleView).offset(- buttonSpace);
        make.bottom.equalTo(self.workingBottomHandleView.mas_bottom).offset(-40);
        make.width.height.mas_equalTo(buttonWH);
    }];
    
    [self.customDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.workingBottomHandleView);
        make.bottom.equalTo(self.stopButton.mas_top).offset(-40);
        make.height.equalTo(@18);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.timeDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.workingBottomHandleView);
        make.bottom.equalTo(self.stopButton.mas_top).offset(-40);
        make.height.equalTo(@18);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.workingCustomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.workingBottomHandleView);
        make.bottom.equalTo(self.customDescribeLabel.mas_top).offset(-5);
        make.height.equalTo(@48);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.workingTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.workingBottomHandleView);
        make.bottom.equalTo(self.timeDescribeLabel.mas_top).offset(-5);
        make.height.equalTo(@48);
        make.width.mas_equalTo(kScreenWidth/2);
    }];
    
    [self.alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.workingBottomHandleView).offset(15);
        make.right.equalTo(self.workingBottomHandleView).offset(-15);
        make.top.equalTo(self.workingBottomHandleView).offset(15);
        make.height.equalTo(@30);
    }];
    
    [self.successButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.successBottomHandleView).offset(-40);
        make.left.equalTo(self.successBottomHandleView).offset(40);
        make.bottom.equalTo(self.successBottomHandleView).offset(-45);
        make.height.equalTo(@48);
    }];
    
    [self.successAddressButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successButton.mas_top).offset(-28);
        make.height.equalTo(@18);
    }];
    
    [self.successCustomDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successAddressButton.mas_top).offset(-28);
        make.height.equalTo(@18);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successTimeDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successAddressButton.mas_top).offset(-28);
        make.height.equalTo(@18);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successDeviceDescribeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successAddressButton.mas_top).offset(-28);
        make.height.equalTo(@18);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successCustomLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successCustomDescribeLabel.mas_top).offset(-1);
        make.height.equalTo(@30);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successCustomDescribeLabel.mas_top).offset(-1);
        make.height.equalTo(@30);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successDeviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.successBottomHandleView);
        make.bottom.equalTo(self.successCustomDescribeLabel.mas_top).offset(-1);
        make.height.equalTo(@30);
        make.width.mas_equalTo(kScreenWidth/3);
    }];
    
    [self.successImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(@120);
        make.top.equalTo(self.successBottomHandleView).offset(-60);
        make.left.equalTo(self.successBottomHandleView).offset((kScreenWidth - 120)/2);
    }];
    
    [self.view layoutIfNeeded];
}

- (void)setNavBackButtonAndTitle{
    [self.backButton setImage:[UIImage imageNamed:@"nav_back_white"] forState:UIControlStateNormal];
    self.midTitleLabel.text = @"创建标签";
    self.startButton.hidden = NO;
}

- (void)setNavDeviceNameAndMac{
    [self.backButton setTitle:@"收起" forState:UIControlStateNormal];
    [self.backButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    NSString * frontAttributeString = self.deviceModel.deviceName;
    NSString * backAttributeString = self.deviceModel.mac;
    NSString * attributeString = [NSString stringWithFormat:@"%@\n%@",frontAttributeString,backAttributeString];
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:attributeString];
    
    UIFont *frontFont = [UIFont systemFontOfSize:14];
    if (IS_IPHONE5) {
        frontFont = [UIFont systemFontOfSize:13];
    }
    [mutableAttributedString addAttribute:NSFontAttributeName value:frontFont range:NSMakeRange(0, frontAttributeString.length)];
    
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x797E81) range:NSMakeRange(attributeString.length - backAttributeString.length, backAttributeString.length)];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(attributeString.length - backAttributeString.length, backAttributeString.length)];
    
    self.midTitleLabel.numberOfLines = 0;
    self.midTitleLabel.attributedText = mutableAttributedString;
}

#pragma mark - ******* Prive Method *******

//获取当前时间年月日
- (void)getCurrentDate{
    
    NSDate *currentDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:currentDate];
    self.startTextField.text = [NSString stringWithFormat:@"标签_%ld%02ld%02ld%03d",(long)dateComponents.year , (long)dateComponents.month,(long)dateComponents.day,[self.deviceModel.labelTodayNum intValue] + 1];
}
//从开始切换到工作状态
- (void)startToWorkingStatus{
    LiteReadyStartViewController *presentVC = [LiteReadyStartViewController new];
    CGRect frame = [self.startBottomHandleView convertRect:self.startButton.frame toView:self.view];
    presentVC.buttonFrame =  frame;
    WEAKSELF
    [self presentViewController:presentVC animated:YES completion:^{
        weakSelf.startBottomHandleView.hidden = YES;
        weakSelf.workingBottomHandleView.hidden = NO;
        weakSelf.pauseButton.hidden = NO;
        [weakSelf setNavDeviceNameAndMac];
        //请求标签详情
        weakSelf.workType = DeviceStatusTypeWorking;
        
        [weakSelf mapAddAnimationAnnotationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
        
        [weakSelf cycleRequestLabelDetail];
    }];
}
//切换到暂停状态(暂停按钮消失  停止&继续按钮出现 工作时间计时器停止)
- (void)switchPauseStatus{
    self.pauseButton.hidden = YES;
    self.stopButton.hidden = NO;
    self.continueButton.hidden = NO;
    
    [self.workSecondsTimer invalidate];
    self.workSecondsTimer = nil;
//    [self.checkLabelStatusTimer invalidate];
//    self.checkLabelStatusTimer = nil;
    self.isRefreshWorkTimer = NO;

    self.workType = DeviceStatusTypeWorkPause;
    
    [self mapAddCircleOverlayWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude radius:100];
}
//切换到继续状态(停止&继续按钮消失 暂停按钮出现)
- (void)switchWorkingStatus{
    self.pauseButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.longPressTipsImageView.hidden = YES;
    self.continueButton.hidden = YES;
    
    [self.checkLabelStatusTimer fire];
    self.workType = DeviceStatusTypeWorking;
    [self mapAddAnimationAnnotationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
}

//切换到停止状态(完成创建视图出现)
- (void)switchStopStatus{
    self.workingBottomHandleView.hidden = YES;
    self.successBottomHandleView.hidden = NO;
    self.backButton.hidden = YES;
    
    [self.checkLabelStatusTimer invalidate];
    self.checkLabelStatusTimer = nil;
    
    self.successTimeLabel.text = self.workingTimeLabel.text;
    self.successCustomLabel.text = self.workingCustomLabel.text;
    [self.successAddressButton setTitle:_geocodeSearchResultStr forState:UIControlStateNormal];
    
    [self mapAddCircleOverlayWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude radius:100];
}

//把工作时间解析成时间 00:00:00
- (NSString *)dealWorkTimeToTimeStr:(long)time{
    //重新计算 时/分/秒
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",self.totalWorkSecond / 3600];
    
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(self.totalWorkSecond % 3600) / 60];
    
    NSString *str_second = [NSString stringWithFormat:@"%02ld",self.totalWorkSecond % 60];
    
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    return format_time;
}

//校验是否创建标签
//创建标签人数如果低于10人，收集时长低于五分钟，结束出现弹窗提示：当前标签创建时间过短（人数过少），是否确认创建？继续按钮--结束创建进入完成页面;再看看，留在当前页面；
//收集人数为0时点击结束， 您此次创建标签人数为0，标签将不会被保存，是否继续？

- (void)checkLabelCreateStatus{
    WEAKSELF
    if ([self.workingCustomLabel.text longLongValue] == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标签提示" message:@"您此次创建标签人数为0，标签将不会被保存,是否继续？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"再看看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }];
        [alert addAction:cancelButton];
        
        UIAlertAction *button = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //删除标签
            [weakSelf deleteDeviceLabel];
        }];
        [alert addAction:button];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if ([self.workingCustomLabel.text longLongValue] < 10 || self.totalWorkSecond < 60 * 5) {
            NSString *tipsMessage = @"";
            if(self.totalWorkSecond < 60 * 5){
                tipsMessage = @"当前标签创建时间过短\n是否确认创建？";
            }
            if ([self.workingCustomLabel.text longLongValue] < 10) {
                tipsMessage = @"当前标签创建人数过少\n是否确认创建？";
            }
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"标签提示" message:tipsMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"再看看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }];
            [alert addAction:cancelButton];
            
            UIAlertAction *button = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakSelf requestChangeLabelStatus:ChangeLabelStatusTypeStop];

            }];
            [alert addAction:button];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [self requestChangeLabelStatus:ChangeLabelStatusTypeStop];
        }
    }
}
//长按提示显示  2s后消失
- (void)longPressTipsShow{
    if(self.longPressTipsImageView.hidden){
        self.longPressTipsImageView.hidden = NO;
        [self performSelector:@selector(longPressTipsHidden) withObject:nil afterDelay:2.0f];
    }
}

- (void)longPressTipsHidden{
    self.longPressTipsImageView.hidden = YES;
}


#pragma mark - ******* GestureRecognizer Delegate *******

-(void)longPressView:(UILongPressGestureRecognizer *)longPressGest{
    
    NSLog(@"%ld",longPressGest.state);
    if (longPressGest.state==UIGestureRecognizerStateBegan) {
        [self longPressTipsShow];
        //设置定时器
        _stopLongPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(stopLongPressTimerAction) userInfo:nil repeats:YES];
        //启动后会每0.01秒钟调用一次方法
        NSLog(@"长按手势开启");
    } else if (longPressGest.state == UIGestureRecognizerStateEnded || longPressGest.state == UIGestureRecognizerStateCancelled){
        [_stopLongPressTimer invalidate];
        _stopLongPressTimer = nil;
        stopLongPressSecond = 0;
        [self.stopButton drawProgress:0];
        
        [self longPressTipsShow];
        NSLog(@"长按手势结束");
    }
    
}

#pragma mark - ******* Request *******
//创建标签
- (void)createDeviceLabel{
    WEAKSELF
    self.startButton.userInteractionEnabled = NO;
    
    NSDictionary * params = @{@"deviceId":self.deviceModel.deviceId, @"mac":self.deviceModel.mac,@"name":self.startTextField.text,@"startLongitude":[NSString stringWithFormat:@"%f",self.coordinate.longitude],@"startLatitude":[NSString stringWithFormat:@"%f",self.coordinate.latitude],@"addType":@"2"};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAddDeviceLabel
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            weakSelf.startButton.userInteractionEnabled = YES;
                            if (NetResponseCheckStaus)
                            {
                                NSDictionary *dic = object[@"data"];
                                weakSelf.deviceLabelId = [dic stringValueForKey:@"id" default:@""];
                                [weakSelf startToWorkingStatus];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            weakSelf.startButton.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//删除标签
- (void)deleteDeviceLabel{
    WEAKSELF
    self.stopButton.userInteractionEnabled = NO;
    self.continueButton.userInteractionEnabled = NO;
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiDeleteDeviceLabel
                        withParaments:@{@"labelId":self.deviceLabelId}
                        withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            weakSelf.stopButton.userInteractionEnabled = YES;
                            weakSelf.continueButton.userInteractionEnabled = YES;
                            if (NetResponseCheckStaus)
                            {
                                [weakSelf.navigationController popViewControllerAnimated:YES];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            weakSelf.stopButton.userInteractionEnabled = YES;
                            weakSelf.continueButton.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//按标签id获取标签详情
- (void)requestLabelDetail{
    WEAKSELF
    self.pauseButton.userInteractionEnabled = NO;

    NSDictionary * params = @{@"id":self.deviceLabelId};
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceLabelDetail
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            weakSelf.pauseButton.userInteractionEnabled = YES;

                            if (NetResponseCheckStaus)
                            {
                                NSDictionary *dataDic = object[@"data"];
                                
                                weakSelf.deviceLabelId = [dataDic stringValueForKey:@"id" default:@""];
                                weakSelf.workingCustomLabel.text = [dataDic stringValueForKey:@"personNum" default:@""];
                                
                                NSString *workTimeStr = [dataDic stringValueForKey:@"workTime" default:@""];
                                if (!weakSelf.isCheckServerWorkTime) {
                                    weakSelf.totalWorkSecond = [workTimeStr longLongValue];
                                    //修改倒计时标签及显示内容
                                    weakSelf.workingTimeLabel.text = [self dealWorkTimeToTimeStr:weakSelf.totalWorkSecond];
                                    weakSelf.isCheckServerWorkTime = YES;
                                }
                                
                                NSString *netStatus = [dataDic stringValueForKey:@"netStatus" default:@""];
                                if ([netStatus isEqualToString:@"2"]) {
                                    //已联网
                                    if (!weakSelf.isRefreshWorkTimer && weakSelf.workType == DeviceStatusTypeWorking) {
                                        //工作时间定时器没有开启 && 现在是工作状态
                                        //设置定时器
                                        weakSelf.workSecondsTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(workSecondsTimerAction) userInfo:nil repeats:YES];
                                        //启动计时后会每秒钟调用一次方法
                                        weakSelf.isRefreshWorkTimer = YES;
                                    }
                                    
                                    if (weakSelf.isDeviceNotNet) { //如果断网过
                                        weakSelf.alertLabel.hidden = YES;
                                        weakSelf.continueButton.backgroundColor = UIColorBlue;
                                        weakSelf.continueButton.userInteractionEnabled = YES;
                                        
                                        weakSelf.isDeviceNotNet = NO;
                                    }
                                } else {
                                    //未联网
                                    if (!weakSelf.isDeviceNotNet) {
                                        [weakSelf devicelabelNotNet];
                                    }
                                }
                                
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            weakSelf.pauseButton.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//按标签id更改标签状态( 1 收集中 2 暂停 3 结束)
- (void)requestChangeLabelStatus:(ChangeLabelStatusType)type{
    WEAKSELF
    self.pauseButton.userInteractionEnabled = NO;
    self.stopButton.userInteractionEnabled = NO;
    self.continueButton.userInteractionEnabled = NO;
    
    NSString *status = @"";
    if (type == ChangeLabelStatusTypeStop) {
        status = @"3";
    }else if (type == ChangeLabelStatusTypePause) {
        status = @"2";
    }else if (type == ChangeLabelStatusTypeWorking) {
        status = @"1";
    }
    
    NSDictionary * params = @{@"labelId":self.deviceLabelId,@"status":status};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiChangeDeviceLabelStatus
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            weakSelf.pauseButton.userInteractionEnabled = YES;
                            weakSelf.stopButton.userInteractionEnabled = YES;
                            weakSelf.continueButton.userInteractionEnabled = YES;

                            if (NetResponseCheckStaus){
                                
                                if (type == ChangeLabelStatusTypeStop) {
                                    [weakSelf switchStopStatus];
                                }else if (type == ChangeLabelStatusTypePause) {
                                    [weakSelf switchPauseStatus];
                                }else if (type == ChangeLabelStatusTypeWorking) {
                                    [weakSelf switchWorkingStatus];
                                }
                                
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            weakSelf.pauseButton.userInteractionEnabled = YES;
                            weakSelf.stopButton.userInteractionEnabled = YES;
                            weakSelf.continueButton.userInteractionEnabled = YES;

                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//设备没有联网(暂停标签并且继续按钮不可点,等待联网状态更新才可继续)
- (void)devicelabelNotNet{
    if (self.workType == DeviceStatusTypeWorking) {
        [self requestChangeLabelStatus:ChangeLabelStatusTypePause];
    }

    self.alertLabel.hidden = NO;
    
    self.continueButton.backgroundColor = UIColorlightGray;
    self.continueButton.userInteractionEnabled = NO;
    
    self.isDeviceNotNet = YES;
}

//进入工作状态 添加定时器 10秒 请求一次标签详情
- (void)cycleRequestLabelDetail{
    if (self.checkLabelStatusTimer == nil) {
        self.checkLabelStatusTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(requestLabelDetail) userInfo:nil repeats:YES];
        [self.checkLabelStatusTimer fire]; //立即执行
    }
}


#pragma mark - ******* Map About Private Method *******
//地图设置
- (void)setupBaiduMap{
    _mapView.zoomLevel = 19;      //放大等级
    _mapView.gesturesEnabled = NO;    //禁止所有用户手势
    
    //设置地图中心点在地图中的屏幕坐标位置
    //    [_mapView setMapCenterToScreenPt:CGPointMake(kScreenWidth/2,(kScreenHeight/2 - kStatusBarAndNavigationBarHeight)/2 + kStatusBarAndNavigationBarHeight)];
    
    _geocodesearch= [[BMKGeoCodeSearch alloc]init];
    //反编码地理位置
    BMKReverseGeoCodeSearchOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeocodeSearchOption.location= self.coordinate;
    if([_geocodesearch reverseGeoCode:reverseGeocodeSearchOption]){
        NSLog(@"反geo检索发送成功");
    }else{
        NSLog(@"反geo检索发送失败");
    }
    
    [_mapView setCenterCoordinate:self.coordinate animated:NO];
    
    if (self.workType == DeviceStatusTypeWorking) { //工作中
        [self mapAddAnimationAnnotationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    }else if(self.workType == DeviceStatusTypeWorkPause){ //暂停中
        [self mapAddCircleOverlayWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude radius:100];
    }else{ //创建标签
        [self mapAddCircleOverlayWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude radius:100];
    }
}

// 根据经纬度添加(动画大头针)
- (void)mapAddAnimationAnnotationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude{
    //清除之前的覆盖物和标注
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    //动画大头针
    _animatedAnnotation = [[BMKPointAnnotation alloc] init];
    _animatedAnnotation.isLockedToScreen = NO;
    _animatedAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_animatedAnnotation];
    //中心点大头针
    _centerAnnotation = [[BMKPointAnnotation alloc]init];
    _centerAnnotation.isLockedToScreen = NO;
    _centerAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_centerAnnotation];
}

// 根据经纬度添加圆形覆盖物
- (void)mapAddCircleOverlayWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude radius:(CGFloat)radius{
    //清除之前的覆盖物和标注
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    
    CLLocationCoordinate2D coor;
    coor.latitude = latitude;
    coor.longitude = longitude;
    _circle = [BMKCircle circleWithCenterCoordinate:coor radius:radius];
    [_mapView addOverlay:_circle];
    
    _centerAnnotation = [[BMKPointAnnotation alloc]init];
    _centerAnnotation.isLockedToScreen = NO;
    _centerAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [_mapView addAnnotation:_centerAnnotation];
}

#pragma mark - ******* Baidu SDK Delegate *******

// 根据anntation生成对应的View(自定义大头针)
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    //普通annotation
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        if (annotation == _centerAnnotation){
            NSString *AnnotationViewID = @"centerAnnotation";
            BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
            if (annotationView == nil) {
                annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
                // 设置颜色
                annotationView.pinColor = BMKPinAnnotationColorPurple;
                // 设置可拖拽
                annotationView.draggable = NO;
                //自定义大头针图案
                annotationView.image = [UIImage imageNamed:@"main_map_center_annotation"];
                annotationView.centerOffset = CGPointMake(0.5, 0.5);
                // 从天上掉下效果
                annotationView.animatesDrop = NO;
            }
            return annotationView;
        }else if (annotation == _animatedAnnotation){ //动画annotation
            NSString *AnnotationViewID = @"AnimatedAnnotation";
            MyAnimatedAnnotationView *annotationView = nil;
            if (annotationView == nil) {
                annotationView = [[MyAnimatedAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            }
            NSMutableArray *images = [NSMutableArray array];
            for (int i = 0; i < 60; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"animation_%d.png", i]];
                [images addObject:image];
            }
            annotationView.annotationImages = images;
            return annotationView;
        }
    }
    return nil;
}

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
    if ([overlay isEqual:_circle])
    {
        BMKCircleView * circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor alloc] initWithRed:170/255.0 green:199/255.0 blue:232/255.0 alpha:0.5];
        circleView.strokeColor = [[UIColor alloc] initWithRed:170/255.0 green:199/255.0 blue:232/255.0 alpha:0.5];
        return circleView;
    }
    return nil;
}

#pragma mark - ******* 地理反编码的delegate *******
/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error;
{
    //addressDetail:层次化地址信息
    //address:地址名称
    //businessCircle:商圈名称
    // location:地址坐标
    // poiList:地址周边POI信息，成员类型为BMKPoiInfo
    if(error !=0) {
        NSLog(@"address:定位失败+++++");
    }else{
        NSLog(@"address:%@----%@-----%@",result.addressDetail, result.address,result.sematicDescription);
        //竞园国际影像产业基地内,竞园-27A内0米
        NSArray *array = [result.sematicDescription componentsSeparatedByString:@","];
        NSString *resultStr = @"";
        if (array.count > 1) {
            resultStr = array.lastObject;
        }else{
            resultStr = result.sematicDescription;
        }
        
        // 准备对象
        NSString *regExpString  = @"[0-9]+米"; //用于匹配的正则
        NSString *replaceString = @"";         //替换用的字符串
        _geocodeSearchResultStr =
        [resultStr stringByReplacingOccurrencesOfString:regExpString
                                             withString:replaceString
                                                options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                  range:NSMakeRange (0, resultStr.length)];
        
        [self.startAddressButton setTitle:_geocodeSearchResultStr forState:UIControlStateNormal];
        [self.successAddressButton setTitle:_geocodeSearchResultStr forState:UIControlStateNormal];
    }
}

#pragma mark - ******* Action Event *******
// button、gesture, etc
//停止按钮长按计时动作
-(void)stopLongPressTimerAction{
    
    stopLongPressSecond += 0.01;
    
    [self.stopButton drawProgress:stopLongPressSecond / 0.8];
    
    //长按时间足够,取消定时器,并进行下一步操作
    if(stopLongPressSecond >= 0.8){
        [_stopLongPressTimer invalidate];
        _stopLongPressTimer = nil;
        stopLongPressSecond = 0;
        //下一步操作
        [self checkLabelCreateStatus];
    }
    
}

//实现计时动作
-(void)workSecondsTimerAction{
    //计时 +1s
    self.totalWorkSecond ++;
    
    //修改倒计时标签及显示内容
    self.workingTimeLabel.text = [self dealWorkTimeToTimeStr:self.totalWorkSecond];
}

- (void)leftBarButtonAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)startButtonAction:(UIButton *)sender{
    
    if (!kStringNotNull(self.startTextField.text)) {
        [ShowHUDTool showBriefAlert:@"请输入标签名称"];
        return;
    }
    
    if (self.startTextField.text.length > 16) {
        [ShowHUDTool showBriefAlert:@"标签名称不能超过16个字符"];
        return;
    }
    
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9-_\\u4E00-\\u9FA5]+$"];
    if ([predicate evaluateWithObject:self.startTextField.text]) {
        [self createDeviceLabel];
    }else{
        [ShowHUDTool showBriefAlert:@"标签名称不能包含特殊字符"];
    }
    
}

- (void)pauseButtonAction:(UIButton *)sender{
    [self requestChangeLabelStatus:ChangeLabelStatusTypePause];
}

- (void)stopButtonAction:(UIButton *)sender{
    NSLog(@"点击停止按钮");
    [self longPressTipsShow];
}

- (void)continueButtonAction:(UIButton *)sender{
    [self requestChangeLabelStatus:ChangeLabelStatusTypeWorking];
}

- (void)successButtonAction:(UIButton *)sender{
    
    [self.navigationController popToRootViewControllerAnimated:NO];

    [[NSNotificationCenter defaultCenter] postNotificationName:kLabelAddSuccessNotification object:self.deviceModel];
    
}

//输入框清除按钮
- (void)textFieldContentClear:(UIButton *)button{
    self.startTextField.text = @"";
}

#pragma mark - ******* Textfield Delegate *******

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "])
    {
        return NO;
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    
}

#pragma mark - ******* Notification Events *******

- (void)keyboardWillShow:(NSNotification *)notification
{
    WEAKSELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.view.frame = CGRectMake(0, -200, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    WEAKSELF
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.view.frame = CGRectMake(0, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
    }];
}

#pragma mark - ******* Getter *******

- (UIView *)navView{
    if (!_navView) {
        _navView = [[UIView alloc] init];
        _navView.backgroundColor = UIColorDarkBlack;
    }
    return _navView;
}

- (UIButton *)backButton{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_backButton addTarget:self action:@selector(leftBarButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)midTitleLabel{
    if (!_midTitleLabel) {
        _midTitleLabel = [[UILabel alloc] init];
        _midTitleLabel.textColor = UIColorWhite;
        _midTitleLabel.textAlignment = NSTextAlignmentCenter;
        _midTitleLabel.font = [UIFont systemFontOfSize:17];
    }
    return _midTitleLabel;
}

- (UIView *)startBottomHandleView{
    if (!_startBottomHandleView) {
        _startBottomHandleView = [[UIView alloc] init];
        _startBottomHandleView.backgroundColor = UIColorDarkBlack;
        _startBottomHandleView.hidden = YES;
    }
    return _startBottomHandleView;
}

- (UIView *)workingBottomHandleView{
    if (!_workingBottomHandleView) {
        _workingBottomHandleView = [[UIView alloc] init];
        _workingBottomHandleView.backgroundColor = UIColorDarkBlack;
        _workingBottomHandleView.hidden = YES;
    }
    return _workingBottomHandleView;
}

- (UIView *)successBottomHandleView{
    if (!_successBottomHandleView) {
        _successBottomHandleView = [[UIView alloc] init];
        _successBottomHandleView.backgroundColor = UIColorDarkBlack;
        _successBottomHandleView.hidden = YES;
    }
    return _successBottomHandleView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)startButton{
    if (!_startButton) {
        _startButton = [[UIButton alloc] init];
        [_startButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_startButton setTitle:@"开始" forState:UIControlStateNormal];
        _startButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _startButton.backgroundColor = UIColorFromRGB(0x2F84EA);
        _startButton.layer.cornerRadius = buttonWH/2;
        _startButton.layer.masksToBounds = YES;
        [_startButton addTarget:self action:@selector(startButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startButton;
}

- (UIButton *)pauseButton{
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc] init];
        [_pauseButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
        _pauseButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _pauseButton.backgroundColor = UIColorAlert;
        _pauseButton.layer.cornerRadius = buttonWH/2;
        _pauseButton.layer.masksToBounds = YES;
        _pauseButton.hidden = YES;
        [_pauseButton addTarget:self action:@selector(pauseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseButton;
}

- (LiteCycleProgressButton *)stopButton{
    if (!_stopButton) {
        _stopButton = [[LiteCycleProgressButton alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
        [_stopButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_stopButton setTitle:@"结束" forState:UIControlStateNormal];
        _stopButton.titleLabel.font = [UIFont systemFontOfSize:20];
//        _stopButton.backgroundColor = UIColorError;
//        _stopButton.layer.cornerRadius = buttonWH/2;
//        _stopButton.layer.masksToBounds = YES;
        _stopButton.hidden = YES;
        [_stopButton addTarget:self action:@selector(stopButtonAction:) forControlEvents:UIControlEventTouchDown];
    }
    return _stopButton;
}

- (UIButton *)continueButton{
    if (!_continueButton) {
        _continueButton = [[UIButton alloc] init];
        [_continueButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_continueButton setTitle:@"继续" forState:UIControlStateNormal];
        _continueButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _continueButton.backgroundColor = UIColorBlue;
        _continueButton.layer.cornerRadius = buttonWH/2;
        _continueButton.layer.masksToBounds = YES;
        _continueButton.hidden = YES;
        [_continueButton addTarget:self action:@selector(continueButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _continueButton;
}

- (UITextField *)startTextField{
    if (!_startTextField) {
        _startTextField = [[UITextField alloc] init];
        _startTextField.textColor = UIColorWhite;
        _startTextField.textAlignment = NSTextAlignmentCenter;
        _startTextField.font = [UIFont systemFontOfSize:14];
        _startTextField.borderStyle = UITextBorderStyleLine;
        _startTextField.returnKeyType = UIReturnKeyDone;
        _startTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        UIButton * rightView = [[UIButton alloc] init];
        rightView.frame = CGRectMake(0, 0, 30, 30);
        [rightView setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
        [rightView addTarget:self action:@selector(textFieldContentClear:) forControlEvents:UIControlEventTouchUpInside];
        _startTextField.rightView = rightView;
        _startTextField.rightViewMode = UITextFieldViewModeAlways;
        
        _startTextField.layer.cornerRadius = 3.0f;
        _startTextField.layer.masksToBounds = YES;
        _startTextField.layer.borderColor = [UIColor whiteColor].CGColor;
        _startTextField.layer.borderWidth = 1.0;
        _startTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入标签名称" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        
    }
    return _startTextField;
}

- (UIButton *)startAddressButton{
    if (!_startAddressButton) {
        _startAddressButton = [[UIButton alloc] init];
        [_startAddressButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_startAddressButton setTitle:_geocodeSearchResultStr forState:UIControlStateNormal];
        [_startAddressButton setImage:[UIImage imageNamed:@"account_location_image"] forState:UIControlStateNormal];
        _startAddressButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        _startAddressButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _startAddressButton.backgroundColor = UIColorClearColor;
        _startAddressButton.userInteractionEnabled = NO;
    }
    return _startAddressButton;
}

- (UILabel *)startLabel{
    if (!_startLabel) {
        _startLabel = [[UILabel alloc] init];
        _startLabel.font = [UIFont systemFontOfSize:12];
        _startLabel.textAlignment =NSTextAlignmentCenter;
        _startLabel.textColor = UIColorWhite;
        _startLabel.text = [NSString stringWithFormat:@"%@(%@)的标签名称",self.deviceModel.deviceName,self.deviceModel.mac];
    }
    return _startLabel;
}

- (UILabel *)customDescribeLabel{
    if (!_customDescribeLabel) {
        _customDescribeLabel = [[UILabel alloc] init];
        _customDescribeLabel.font = [UIFont systemFontOfSize:12];
        _customDescribeLabel.textAlignment =NSTextAlignmentCenter;
        _customDescribeLabel.textColor = UIColorFromRGB(0x797E81);
        _customDescribeLabel.text = @"客户人数";
    }
    return _customDescribeLabel;
}

- (UILabel *)workingCustomLabel{
    if (!_workingCustomLabel) {
        _workingCustomLabel = [[UILabel alloc] init];
        _workingCustomLabel.font = [UIFont systemFontOfSize:36];
        _workingCustomLabel.textAlignment =NSTextAlignmentCenter;
        _workingCustomLabel.textColor = UIColorWhite;
        _workingCustomLabel.text = @"0";
    }
    return _workingCustomLabel;
}

- (UILabel *)timeDescribeLabel{
    if (!_timeDescribeLabel) {
        _timeDescribeLabel = [[UILabel alloc] init];
        _timeDescribeLabel.font = [UIFont systemFontOfSize:12];
        _timeDescribeLabel.textAlignment =NSTextAlignmentCenter;
        _timeDescribeLabel.textColor = UIColorFromRGB(0x797E81);
        _timeDescribeLabel.text = @"工作时间";
    }
    return _timeDescribeLabel;
}

- (UILabel *)workingTimeLabel{
    if (!_workingTimeLabel) {
        _workingTimeLabel = [[UILabel alloc] init];
        _workingTimeLabel.font = [UIFont systemFontOfSize:36];
        _workingTimeLabel.textAlignment =NSTextAlignmentCenter;
        _workingTimeLabel.textColor = UIColorWhite;
        _workingTimeLabel.text = @"00:00:00";
    }
    return _workingTimeLabel;
}

- (LiteAlertLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        _alertLabel.alertImageView.image = [UIImage imageNamed:@"main_device_label_net_off"];
        _alertLabel.backgroundColor = UIColorClearColor;
        _alertLabel.titleLabel.text = @"设备已断网，请联网重试或结束工作！";
        _alertLabel.hidden = YES;
    }
    return _alertLabel;
}

- (UIImageView *)longPressTipsImageView{
    if (!_longPressTipsImageView) {
        _longPressTipsImageView = [[UIImageView alloc] init];
        _longPressTipsImageView.image =[UIImage imageNamed:@"main_long_press_tips"];
        _longPressTipsImageView.contentMode = UIViewContentModeScaleAspectFit;
        _longPressTipsImageView.hidden = YES;
    }
    return _longPressTipsImageView;
}

- (UILabel *)successTimeDescribeLabel{
    if (!_successTimeDescribeLabel) {
        _successTimeDescribeLabel = [[UILabel alloc] init];
        _successTimeDescribeLabel.font = [UIFont systemFontOfSize:12];
        _successTimeDescribeLabel.textAlignment =NSTextAlignmentCenter;
        _successTimeDescribeLabel.textColor = UIColorFromRGB(0x797E81);
        _successTimeDescribeLabel.text = @"工作时间";
    }
    return _successTimeDescribeLabel;
}

- (UILabel *)successCustomDescribeLabel{
    if (!_successCustomDescribeLabel) {
        _successCustomDescribeLabel = [[UILabel alloc] init];
        _successCustomDescribeLabel.font = [UIFont systemFontOfSize:12];
        _successCustomDescribeLabel.textAlignment =NSTextAlignmentCenter;
        _successCustomDescribeLabel.textColor = UIColorFromRGB(0x797E81);
        _successCustomDescribeLabel.text = @"客户人数";
    }
    return _successCustomDescribeLabel;
}

- (UILabel *)successDeviceDescribeLabel{
    if (!_successDeviceDescribeLabel) {
        _successDeviceDescribeLabel = [[UILabel alloc] init];
        _successDeviceDescribeLabel.font = [UIFont systemFontOfSize:12];
        _successDeviceDescribeLabel.textAlignment =NSTextAlignmentCenter;
        _successDeviceDescribeLabel.textColor = UIColorFromRGB(0x797E81);
        _successDeviceDescribeLabel.text = @"设备";
    }
    return _successDeviceDescribeLabel;
}

- (UILabel *)successTimeLabel{
    if (!_successTimeLabel) {
        _successTimeLabel = [[UILabel alloc] init];
        _successTimeLabel.font = [UIFont systemFontOfSize:16];
        _successTimeLabel.textAlignment =NSTextAlignmentCenter;
        _successTimeLabel.textColor = UIColorWhite;
        _successTimeLabel.text = @"00:00:00";
    }
    return _successTimeLabel;
}

- (UILabel *)successCustomLabel{
    if (!_successCustomLabel) {
        _successCustomLabel = [[UILabel alloc] init];
        _successCustomLabel.font = [UIFont systemFontOfSize:16];
        _successCustomLabel.textAlignment =NSTextAlignmentCenter;
        _successCustomLabel.textColor = UIColorWhite;
        _successCustomLabel.text = @"1";
    }
    return _successCustomLabel;
}

- (UILabel *)successDeviceNameLabel{
    if (!_successDeviceNameLabel) {
        _successDeviceNameLabel = [[UILabel alloc] init];
        _successDeviceNameLabel.font = [UIFont systemFontOfSize:16];
        _successDeviceNameLabel.textAlignment =NSTextAlignmentCenter;
        _successDeviceNameLabel.textColor = UIColorWhite;
        _successDeviceNameLabel.text = self.deviceModel.deviceName;
    }
    return _successDeviceNameLabel;
}

- (UIButton *)successButton{
    if (!_successButton) {
        _successButton = [[UIButton alloc] init];
        [_successButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_successButton setTitle:@"创建成功" forState:UIControlStateNormal];
        _successButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _successButton.backgroundColor = UIColorBlue;
        _successButton.layer.cornerRadius = 24;
        _successButton.layer.masksToBounds = YES;
        [_successButton addTarget:self action:@selector(successButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _successButton;
}

- (UIButton *)successAddressButton{
    if (!_successAddressButton) {
        _successAddressButton = [[UIButton alloc] init];
        [_successAddressButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_successAddressButton setTitle:_geocodeSearchResultStr forState:UIControlStateNormal];
        [_successAddressButton setImage:[UIImage imageNamed:@"account_location_image"] forState:UIControlStateNormal];
        _successAddressButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        _successAddressButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _successAddressButton.backgroundColor = UIColorClearColor;
        _successAddressButton.userInteractionEnabled = NO;
    }
    return _successAddressButton;
}

- (UIImageView *)successImageView
{
    if (!_successImageView)
    {
        _successImageView = [[UIImageView alloc] init];
        _successImageView.contentMode = UIViewContentModeScaleAspectFit;
        _successImageView.image = [UIImage imageNamed:@"login_register_success"];
    }
    return _successImageView;
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
