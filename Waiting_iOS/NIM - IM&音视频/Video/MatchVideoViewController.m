//
//  MatchVideoViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/23.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MatchVideoViewController.h"
#import "NTESGLView.h"
#import "NTESBundleSetting.h"
#import "NetCallChatInfo.h"
#import "NTESBundleSetting.h"
#import "NTESVideoChatNetStatusView.h"
#import "LSLabel.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "MyRechargeViewController.h"

#define NTESUseGLView

@interface MatchVideoViewController ()

@property (nonatomic,assign) NIMNetCallCamera   cameraType;

@property (weak, nonatomic) IBOutlet UIView     * bigVideoView;     //视频大背景
@property (weak, nonatomic) IBOutlet UIView     * smallVideoView;   //视频小背景

@property (weak, nonatomic) IBOutlet UIView     * headDarkBackView;     //头像深色背景
@property (weak, nonatomic) IBOutlet UIView     * headShallowBackView;  //头像浅色背景
@property (weak, nonatomic) IBOutlet UIImageView * headImageView; //头像

@property (weak, nonatomic) IBOutlet UILabel    * userNameLabel;    //用户名
@property (weak, nonatomic) IBOutlet UILabel    * statusLabel;      //状态提示
@property (weak, nonatomic) IBOutlet UILabel    * timeLabel;        //通话时间
@property (weak, nonatomic) IBOutlet UIView     * netStatusBackView;//网络状况背景图

//被呼叫
@property (weak, nonatomic) IBOutlet UIButton   * refuseButton;     //被叫拒绝按钮
@property (weak, nonatomic) IBOutlet UIButton   * acceptButton;     //被叫接听按钮

//主叫
@property (weak, nonatomic) IBOutlet UIButton   * cancelButton;     //主叫取消按钮

//通话中
@property (weak, nonatomic) IBOutlet UIButton   * closeButton;      //通话结束按钮
@property (weak, nonatomic) IBOutlet UIView     * diamondView;      //钻石视图

@property (weak, nonatomic) IBOutlet UIButton   * switchCameraButton;  //前后摄像头切换

/////约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * refuseButtonBottomConstraint; //被叫拒绝按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * acceptButtonBottomConstraint; //被叫接听按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * cancelButtonBottomConstraint; //主叫取消按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * statusViewHeightConstraint;   //状态栏视图高度约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * diamondViewBottomConstraint;  //钻石视图距下约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * switchCameraBottomConstraint;   //摄像头切换按钮距下约束

@property (nonatomic,weak)   UIView             * localView;
@property (nonatomic,strong) UIView             * localVideoLayer;

@property (nonatomic,assign) BOOL               calleeBasy;
@property (nonatomic,assign) BOOL               oppositeCloseVideo;

#if defined (NTESUseGLView)
@property (nonatomic, strong) NTESGLView        * remoteGLView;
#endif

//额外用来判断点击屏幕清空界面
@property(nonatomic,assign) BOOL                isTouch;
//区别大小视图
@property(nonatomic,assign) int                 type;

@property (nonatomic,strong) NTESVideoChatNetStatusView * netStatusView;//网络状况

@end

@implementation MatchVideoViewController

#pragma mark - ******* Init *******

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeVideo;
        self.callInfo.useSpeaker = YES;
        _cameraType = [[NTESBundleSetting sharedConfig] startWithBackCamera] ? NIMNetCallCameraBack :NIMNetCallCameraFront;
    }
    return self;
}

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bigVideoView.userInteractionEnabled = YES;
    
    self.localView = self.smallVideoView;

    if (self.localVideoLayer) {
        self.localVideoLayer.frame = self.localView.bounds;
        [self.localView addSubview:self.localVideoLayer];
    }
    //设置UI
    [self createUI];
    //大小视图判断
    self.type = 1;

    //尝试点击小背景
    UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Actiondo:)];
    self.smallVideoView.userInteractionEnabled = YES;
    [self.smallVideoView addGestureRecognizer:tapGesture];
}
#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.statusViewHeightConstraint.constant = kStatusBarHeight;
    self.refuseButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.acceptButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.cancelButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.switchCameraBottomConstraint.constant = 15 + SafeAreaBottomHeight;
    self.diamondViewBottomConstraint.constant = 25 + SafeAreaBottomHeight;
    
    self.headDarkBackView.layer.borderWidth = 1.0f;
    self.headDarkBackView.layer.borderColor = UIAlplaColorFromRGB(0xC10CFF, 0.15).CGColor;
    self.headShallowBackView.layer.borderWidth = 1.0f;
    self.headShallowBackView.layer.borderColor = UIAlplaColorFromRGB(0xC10CFF, 0.99).CGColor;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.userModel.userHeadImageUrl] placeholderImage:kGetImageFromName(@"phone_default_head")];
    self.userNameLabel.text = self.userModel.userName;
    
    //网络状态
    [self.netStatusBackView addSubview:self.netStatusView];
    [self.netStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.netStatusBackView);
    }];
}

#pragma mark - ******* Action *******
//被叫接听
- (IBAction)acceptButtonAction:(UIButton *)sender {
    BOOL accept = (sender == self.acceptButton);
    //防止用户在点了接收后又点拒绝的情况
    [self response:accept];
}
//被叫拒绝
- (IBAction)refuseButtonAction:(UIButton *)sender {
    [self response:NO];
}
//主叫取消
- (IBAction)cancelButtonAction:(UIButton *)sender {
    //挂断
    [self hangup];
}
//关闭对话
- (IBAction)closeButtonAction:(UIButton *)sender {
    //挂断
    [self hangup];
}
//切换摄像头
- (IBAction)switchCameraButtonAction:(UIButton *)sender {
    if (self.cameraType == NIMNetCallCameraFront) {
        self.cameraType = NIMNetCallCameraBack;
    }else{
        self.cameraType = NIMNetCallCameraFront;
    }
    [[NIMAVChatSDK sharedSDK].netCallManager switchCamera:self.cameraType];
    
}

//礼物按钮
-(void)giftDidChick: (UIButton *)sender{
    
}

//小视图点击事件
-(void)Actiondo: (id)sender{
    
    [self initRemoteGLView: self.type];
    //    NSLog(@"点击了小视图");
}

//大视图点击清空屏幕事件
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (!_isTouch) {
        NSLog(@"隐藏");
        self.closeButton.hidden = YES;
        self.switchCameraButton.hidden = YES;
        self.smallVideoView.hidden = YES;
        self.netStatusBackView.hidden = YES;
        self.timeLabel.hidden = YES;
        _isTouch = YES;
        
    }else{
        NSLog(@"显示");
        self.closeButton.hidden = NO;
        self.switchCameraButton.hidden = NO;
        self.smallVideoView.hidden = NO;
        self.netStatusBackView.hidden = NO;
        self.timeLabel.hidden = NO;
        _isTouch = NO;
    }
    
}

#pragma mark - ******* Call Life 接收界面 初始化界面 *******

- (void)startByCaller{
    [super startByCaller];
    //正在接听中界面
    [self startInterface];
}
- (void)startByCallee{
    [super startByCallee];
    //选择是否接听界面
    [self waitToCallInterface];
}
- (void)onCalling{
    [super onCalling];
    //接听中界面(视频)
    [self videoCallingInterface];
}
- (void)waitForConnectiong{
    [super waitForConnectiong];
    //连接对方界面
    [self connectingInterface];
}
- (void)onCalleeBusy{
    _calleeBasy = YES;
    if (_localVideoLayer) {
        [_localVideoLayer removeFromSuperview];
    }
}


#pragma mark - Interface 4种界面
//正在接听中界面
- (void)startInterface{
    
    self.cancelButton.hidden = NO;
    self.statusLabel.text = @"正在等待对方接受邀请...";
    
    self.refuseButton.hidden = YES;
    self.acceptButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.switchCameraButton.hidden = YES;
    self.timeLabel.hidden = YES;
    self.netStatusBackView.hidden = YES;
    
    self.localView = self.bigVideoView;
    
}

//选择是否接听界面
- (void)waitToCallInterface{
    
    self.acceptButton.hidden = NO;
    self.refuseButton.hidden = NO;
    self.statusLabel.text = @"邀请你视频通话";
    
    self.cancelButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.timeLabel.hidden = YES;
    self.netStatusBackView.hidden = YES;
    self.switchCameraButton.hidden = YES;

    //拿到发起者姓名
    self.userNameLabel.text = self.nickName;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.headURLStr] placeholderImage:kGetImageFromName(@"phone_default_head")];
    
    //    NSString *nick = [NTESSessionUtil showNick:self.callInfo.caller inSession:nil];
    //    self.connectingLabel.text = [nick stringByAppendingString:@"的来电"];
    
}

//连接对方界面
- (void)connectingInterface{
    
    self.statusLabel.text = @"正在连接对方...";
    
    self.timeLabel.hidden = YES;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.timeLabel.hidden = YES;
    self.netStatusBackView.hidden = YES;
    self.switchCameraButton.hidden = YES;
}

//接听中界面(视频)
- (void)videoCallingInterface{
    
    //网络状态
    NIMNetCallNetStatus status = [[NIMAVChatSDK sharedSDK].netCallManager netStatus:self.peerUid];
    [self.netStatusView refreshWithNetState:status];
    
    self.headDarkBackView.hidden = YES;
    self.userNameLabel.hidden = YES;
    self.statusLabel.hidden = YES;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    self.cancelButton.hidden = YES;
    
    self.closeButton.hidden = NO;
    self.diamondView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.netStatusBackView.hidden = NO;
    self.switchCameraButton.hidden = NO;
    
    //默认开扬声器
//    self.callInfo.useSpeaker = YES;
//    [[NIMAVChatSDK sharedSDK].netCallManager setSpeaker:self.callInfo.useSpeaker];
    
    self.localVideoLayer.hidden = NO;
    
    //点击背景清空屏幕
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.bigVideoView addGestureRecognizer:singleTap];
    
}
#pragma mark - 拿取视频数据源方法
- (void)initRemoteGLView :(int)type{
#if defined (NTESUseGLView)
    _remoteGLView = [[NTESGLView alloc] init];
    [_remoteGLView setContentMode:[[NTESBundleSetting sharedConfig] videochatRemoteVideoContentMode]];
    [_remoteGLView setBackgroundColor:[UIColor clearColor]];
    _remoteGLView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //切换大小视图画面
    if (self.type == 0) {
        _remoteGLView.frame = _smallVideoView.bounds;
        [_smallVideoView addSubview:_remoteGLView];
        self.type = 1;
        if (self.localView == self.smallVideoView) {
            self.localView = self.bigVideoView;
            if (self.localVideoLayer) {
                [self onLocalDisplayviewReady:self.localVideoLayer];
            }
        }
    }else{
        _remoteGLView.frame = _bigVideoView.bounds;
        [_bigVideoView addSubview:_remoteGLView];
        self.type = 0;
        if (self.localView == self.bigVideoView) {
            self.localView = self.smallVideoView;
            if (self.localVideoLayer) {
                [self onLocalDisplayviewReady:self.localVideoLayer];
            }
        }
        
    }
    
    
#endif
}

#pragma mark - NIMNetCallManagerDelegate

//本地摄像头预览层回调
-(void)onLocalDisplayviewReady:(UIView *)displayView{
    if (_calleeBasy) {
        return;
    }
    if (self.localVideoLayer) {
        [self.localVideoLayer removeFromSuperview];
    }
    self.localVideoLayer = displayView;
    displayView.frame = self.localView.bounds;
    [self.localView.layer addSublayer:displayView.layer];
}

//远程视频YUV数据就绪,<渲染在OpenGL上比UIImageView贴图占用更少的cpu>
#if defined(NTESUseGLView)
- (void)onRemoteYUVReady:(NSData *)yuvData
                   width:(NSUInteger)width
                  height:(NSUInteger)height
                    from:(NSString *)user
{
    if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) && !self.oppositeCloseVideo) {
        
        if (!_remoteGLView) {
            [self initRemoteGLView: self.type];
        }
        [_remoteGLView render:yuvData width:width height:height];
    }
}
#else
//远程视频画面就绪
- (void)onRemoteImageReady:(CGImageRef)image{
    if (self.oppositeCloseVideo) {
        return;
    }
    self.bigVideoView.contentMode = UIViewContentModeScaleAspectFill;
    self.bigVideoView.image = [UIImage imageWithCGImage:image];
}
#endif


//收到对方网络通话控制信息，用于方便通话双方沟通信息
- (void)onControl:(UInt64)callID
             from:(NSString *)user
             type:(NIMNetCallControlType)control{
    [super onControl:callID from:user type:control];
    switch (control) {
        case NIMNetCallControlTypeToAudio:
            //            [self switchToAudio];
            break;
        case NIMNetCallControlTypeCloseVideo:
            //            [self resetRemoteImage];
            self.oppositeCloseVideo = YES;
            [SVProgressHUD showErrorSVP:@"对方关闭了摄像头"];
            break;
        case NIMNetCallControlTypeOpenVideo:
            self.oppositeCloseVideo = NO;
            [SVProgressHUD showErrorSVP:@"对方开启了摄像头"];
            break;
        default:
            break;
    }
}



//点对点通话建立成功
-(void)onCallEstablished:(UInt64)callID
{
    if (self.callInfo.callID == callID) {
        [super onCallEstablished:callID];
        
        self.timeLabel.hidden = NO;
        self.timeLabel.text = self.durationDesc;
        
        //        if (self.localView == self.bigVideoView) {
        //            self.localView = self.smallVideoView;
        //
        //            if (self.localVideoLayer) {
        //                [self onLocalPreviewReady:self.localVideoLayer];
        //            }
        //        }
    }
    
    
}
//当前通话网络状态
- (void)onNetStatus:(NIMNetCallNetStatus)status user:(NSString *)user
{
    NSLog(@"当前网络通话状态： %ld",(long)status);
    if ([user isEqualToString:self.peerUid]) {
        [self.netStatusView refreshWithNetState:status];
    }
}

//通话时长
- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    [super onNTESTimerFired:holder];
    self.timeLabel.text = self.durationDesc;
    
}


//显示时间
- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    
    if ([self.callInfo.callee isEqualToString:[BHUserModel sharedInstance].userID]) {
        if ((int)duration%60 == 59) {
            [self requestVideoFree];
        }
    }
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

//- (void)resetRemoteImage{
//#if defined (NTESUseGLView)
//    [self.remoteGLView render:nil width:0 height:0];
//#endif
//
//    self.bigVideoView.image = [UIImage imageNamed:@"netcall_bkg"];
//}

#pragma mark - ******* Request *******
//请求音视频通话预扣
- (void)requestVideoFree{
    WEAKSELF
    NSDictionary * params = @{@"user1":self.callInfo.callee,/*主叫*/
                              @"user2":self.callInfo.caller,/*被叫*/
                              @"tvId":[NSString stringWithFormat:@"%llu",self.callInfo.callID],/*通话ID*/
                              };
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetVideoFree
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                NSArray *arr = object[@"data"][@"next"];
                                if ([[arr firstObject] isEqualToString:@"0"]) {
                                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[arr lastObject] preferredStyle:UIAlertControllerStyleAlert];
                                    
                                    UIAlertAction *button = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                        
                                    }];
                                    [alert addAction:button];
                                    
                                    UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"充值" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                        MyRechargeViewController *vc = [[MyRechargeViewController alloc] init];
                                        [self.navigationController pushViewController:vc animated:YES];
                                    }];
                                    [alert addAction:button2];
                                    
                                    [weakSelf presentViewController:alert animated:YES completion:nil];
                                }
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

#pragma mark - ******* Getter *******

//网络状态
-(NTESVideoChatNetStatusView* )netStatusView{
    if (!_netStatusView) {
        _netStatusView = [[NTESVideoChatNetStatusView alloc]init];
        _netStatusView.backgroundColor = [UIColor clearColor];
    }
    return _netStatusView;
}

#pragma mark - ******* Other *******


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
