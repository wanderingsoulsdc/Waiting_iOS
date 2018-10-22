//
//  MatchVoiceViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MatchVoiceViewController.h"
#import "NetCallChatInfo.h"
#import "LSLabel.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "MyRechargeViewController.h"

@interface MatchVoiceViewController ()

@property (weak, nonatomic) IBOutlet UIView     * headDarkBackView;     //头像深色背景
@property (weak, nonatomic) IBOutlet UIView     * headShallowBackView;  //头像浅色背景
@property (weak, nonatomic) IBOutlet UIImageView * headImageView; //头像

@property (weak, nonatomic) IBOutlet UILabel    * userNameLabel;    //用户名
@property (weak, nonatomic) IBOutlet UILabel    * statusLabel;      //状态提示
@property (weak, nonatomic) IBOutlet UILabel    * timeLabel;        //通话时间

//被呼叫
@property (weak, nonatomic) IBOutlet UIButton   * refuseButton;     //被叫拒绝按钮
@property (weak, nonatomic) IBOutlet UIButton   * acceptButton;     //被叫接听按钮

//主叫
@property (weak, nonatomic) IBOutlet UIButton   * cancelButton;     //主叫取消按钮

//通话中
@property (weak, nonatomic) IBOutlet UIButton   * closeButton;      //通话结束按钮
@property (weak, nonatomic) IBOutlet UIView     * diamondView;      //钻石视图
@property (weak, nonatomic) IBOutlet UIButton   * speakerButton;    //扬声器按钮
@property (weak, nonatomic) IBOutlet UIButton   * muteButton;       //静音按钮


/////约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * refuseButtonBottomConstraint; //被叫拒绝按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * acceptButtonBottomConstraint; //被叫接听按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * cancelButtonBottomConstraint; //主叫取消按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * statusViewHeightConstraint;   //状态栏视图高度约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * diamondViewBottomConstraint;  //钻石视图距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * muteButtonBottomConstraint;   //静音按钮距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * speakerButtonBottomConstraint;//扬声器按钮距下约束


@end

@implementation MatchVoiceViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* Init *******

//父类方法
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeAudio;
    }
    return self;
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.statusViewHeightConstraint.constant = kStatusBarHeight;
    self.refuseButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.acceptButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.cancelButtonBottomConstraint.constant = 64 + SafeAreaBottomHeight;
    self.muteButtonBottomConstraint.constant = 15 + SafeAreaBottomHeight;
    self.speakerButtonBottomConstraint.constant = 15 + SafeAreaBottomHeight;
    self.diamondViewBottomConstraint.constant = 25 + SafeAreaBottomHeight;
    
    self.headDarkBackView.layer.borderWidth = 1.0f;
    self.headDarkBackView.layer.borderColor = UIAlplaColorFromRGB(0xC10CFF, 0.15).CGColor;
    self.headShallowBackView.layer.borderWidth = 1.0f;
    self.headShallowBackView.layer.borderColor = UIAlplaColorFromRGB(0xC10CFF, 0.99).CGColor;

}

#pragma mark - ******* Call Life *******

- (void)startByCaller{
    [super startByCaller];
    [self startInterface];
}

- (void)startByCallee{
    [super startByCallee];
    [self waitToCallInterface];
}

- (void)onCalling{
    [super onCalling];
    [self audioCallingInterface];
}

- (void)waitForConnectiong{
    [super onCalling];
    [self connectingInterface];
}
#pragma mark - ******* Interface *******
//主动拨打界面
- (void)startInterface{
    
    self.cancelButton.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"正在等待对方接受邀请...", nil);
    
    self.timeLabel.hidden = YES;
    self.refuseButton.hidden = YES;
    self.acceptButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.speakerButton.hidden = YES;
    self.muteButton.hidden = YES;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.userModel.userHeadImageUrl] placeholderImage:kGetImageFromName(@"phone_default_head")];
    self.userNameLabel.text = self.userModel.userName;
}

//选择是否接听界面
- (void)waitToCallInterface{
    self.acceptButton.hidden = NO;
    self.refuseButton.hidden = NO;
    self.statusLabel.text = NSLocalizedString(@"邀请你语音通话", nil);
    
    self.timeLabel.hidden = YES;
    self.cancelButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.speakerButton.hidden = YES;
    self.muteButton.hidden = YES;
    
    self.userNameLabel.text = self.nickName;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.headURLStr] placeholderImage:kGetImageFromName(@"phone_default_head")];
}

//连接对方界面
- (void)connectingInterface{
    self.statusLabel.text = NSLocalizedString(@"正在连接对方...", nil);
    
    self.timeLabel.hidden = YES;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.closeButton.hidden = YES;
    self.diamondView.hidden = YES;
    self.speakerButton.hidden = YES;
    self.muteButton.hidden = YES;
    
}

//接听中界面(音频)
- (void)audioCallingInterface{
    
    //    NSString *peerUid = ([[NIMSDK sharedSDK].loginManager currentAccount] == self.callInfo.caller) ? self.callInfo.caller : self.callInfo.callee;
    ////
    //    NIMNetCallNetStatus status = [[NIMAVChatSDK sharedSDK].netCallManager netStatus:peerUid];
    //    [self.netStatusView refreshWithNetState:status];
    
    self.statusLabel.text = NSLocalizedString(@"已接听", nil);
    
    self.timeLabel.hidden = NO;
    self.acceptButton.hidden = YES;
    self.refuseButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.closeButton.hidden = NO;
    self.diamondView.hidden = NO;
    self.speakerButton.hidden = NO;
    self.muteButton.hidden = NO;
    
    self.muteButton.selected    = self.callInfo.isMute;
    self.speakerButton.selected = self.callInfo.useSpeaker;

}


//点对点通话建立成功
-(void)onCallEstablished:(UInt64)callID
{
    if (self.callInfo.callID == callID) {
        [super onCallEstablished:callID];
        //告诉接口 会话建立成功
        [self requestCreatedConnection];
        
        self.timeLabel.hidden = NO;
        self.timeLabel.text = self.durationDesc;
    }
}

//当前通话网络状态
//- (void)onNetStatus:(NIMNetCallNetStatus)status user:(NSString *)user
//{
//    if ([user isEqualToString:self.peerUid]) {
////        [self.netStatusView refreshWithNetState:status];
//    }
//}
//通话时长
#pragma mark - ******* M80TimerHolder Delegate *******
- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    [super onNTESTimerFired:holder];
    self.timeLabel.text = self.durationDesc;
}

#pragma mark - ******* Misc *******
- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    
    if ([self.callInfo.caller isEqualToString:[BHUserModel sharedInstance].userID]) {
        if ((int)duration%60 == 59) {
            [self requestVoiceFree];
        }
    }
    
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

#pragma mark - ******* Request *******
//对话连接建立成功
- (void)requestCreatedConnection{
    NSDictionary * params = @{@"type":@"2",//1音频，2视频
                              @"user1":self.callInfo.caller,/*主叫*/
                              @"user2":self.callInfo.callee,/*被叫*/
                              @"status":@"1",//会话通信状态，1成功，2失败
                              @"tvId":self.tvId,/*通话ID*/
                              };
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetVideo
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            if (NetResponseCheckStaus){
                                
                            }
                        }withFailureBlock:^(NSError *error) {
                            
                        }];
}
//请求音视频通话预扣
- (void)requestVoiceFree{
    WEAKSELF
    NSDictionary * params = @{@"type":@"1",//1音频，2视频
                              @"user1":self.callInfo.caller,/*主叫*/
                              @"user2":self.callInfo.callee,/*被叫*/
                              @"tvId":self.tvId,/*通话ID*/
                              };
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetVideoFree
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                NSDictionary *nextDic = object[@"data"][@"next"];
                                NSString *status = [nextDic stringValueForKey:@"status" default:@""];
                                if ([status isEqualToString:@"0"]) {
                                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"余额不足", nil) message:NSLocalizedString(@"当前余额不足以开启下一分钟,请充值后进行操作", nil) preferredStyle:UIAlertControllerStyleAlert];
                                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"取消", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    }]];
                                    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"充值", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        MyRechargeViewController *chargeVC = [[MyRechargeViewController alloc] init];
                                        [weakSelf.navigationController pushViewController:chargeVC animated:YES];
                                    }]];
                                    
                                    [weakSelf presentViewController:alertController animated:YES completion:nil];
                                }
                            }else if([[object stringValueForKey:@"status" default:@""] isEqualToString:@"0"]){
                                //当前分钟扣费失败,结束对话
                                [weakSelf hangup];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
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
//扬声器
- (IBAction)speakerButtonAction:(UIButton *)sender {
    self.callInfo.useSpeaker = !self.callInfo.useSpeaker;
    self.speakerButton.selected = self.callInfo.useSpeaker;
    [[NIMAVChatSDK sharedSDK].netCallManager setSpeaker:self.callInfo.useSpeaker];
}
//静音
- (IBAction)muteButtonAction:(UIButton *)sender {
    self.callInfo.isMute = !self.callInfo.isMute;
    //    self.player.volume = !self.callInfo.isMute;
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:self.callInfo.isMute];
    self.muteButton.selected = self.callInfo.isMute;
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
