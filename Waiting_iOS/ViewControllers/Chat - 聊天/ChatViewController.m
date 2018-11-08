//
//  ChatViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/9/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "ChatViewController.h"
#import "MatchVoiceViewController.h"
#import "MatchVideoViewController.h"
#import "FSNetWorkManager.h"
#import "MyRechargeViewController.h"

typedef enum : NSUInteger {
    requestTypeVoice,
    requestTypeVideo,
} requestType;

@interface ChatViewController ()<CAAnimationDelegate>

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - ******* NIMSessionConfig 配置项 *******

- (id<NIMSessionConfig>)sessionConfig {
    //返回 nil，则使用默认配置，若需要自定义则自己实现
//    return nil;
    //返回自定义的 config，则使用此自定义配置
    return self.chatConfig;
}

//实时语音
- (void)onTapMediaItemAudioChat:(NIMMediaItem *)item
{
    NSLog(@"语音聊天");
    [self requestVideoInit:requestTypeVoice];
}

//视频聊天
- (void)onTapMediaItemVideoChat:(NIMMediaItem *)item
{
    NSLog(@"视频聊天");
    [self requestVideoInit:requestTypeVideo];
}

#pragma mark - ******* Private *******
//push控制器(类似Presen从下往上)
- (void)pushViewControllerAsPresent:(UIViewController *)viewController{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController pushViewController:viewController animated:NO];
    //push实现模态效果,注意：animated一定要设置为：NO
}

//pop控制器(类似dismiss从上往下)
- (void)popViewControllerAsDismiss{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
    //pop实现模态效果,注意：animated一定要设置为：NO
}


#pragma mark - ******* Request *******
//音视频建立会话
- (void)requestVideoInit:(requestType)type
{
    WEAKSELF
    //会话类型，1音频，2视频
    NSString *typeStr = @"";
    if (type == requestTypeVoice) {
        typeStr = @"1";
    } else if (type == requestTypeVideo) {
        typeStr = @"2";
    }
    NSDictionary *params = @{@"type":typeStr,
                             @"user1":[BHUserModel sharedInstance].userID,   //主叫
                             @"user2":self.session.sessionId      //被叫
                             };
    NIMKitInfo *info = [[NIMKit sharedKit] infoByUser:self.session.sessionId option:nil];
    BHUserModel * userModel = [[BHUserModel alloc] init];
    userModel.userHeadImageUrl = info.avatarUrlString;
    userModel.userName = info.showName;
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetVideoInit
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             
                             NSString *status = [dataDic stringValueForKey:@"status" default:@""];
                             NSString *tvId = [dataDic stringValueForKey:@"tvId" default:@""];
                             
                             if ([status isEqualToString:@"1"]) { //余额足够开启对话
                                 
                                 NSDictionary *nextDic = dataDic[@"next"];
                                 NSString *nextStatus = [nextDic stringValueForKey:@"status" default:@""];
                                 
                                 if ([nextStatus isEqualToString:@"1"]) {//余额足够开启下一分钟对话
                                     if (type == requestTypeVoice) { //音频
                                         MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.session.sessionId];
                                         vc.userModel = userModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];
                                         
                                     } else if (type == requestTypeVideo){ //视频
                                         MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.session.sessionId];
                                         vc.userModel = userModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];
                                     }
                                 }else if ([nextStatus isEqualToString:@"0"]){//余额不足以开启下一分钟对话
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"The current balance can only be called for 1 minute. Is it OK to initiate a call?", nil) preferredStyle:UIAlertControllerStyleAlert];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     }]];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                         if (type == requestTypeVoice) { //音频
                                             MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.session.sessionId];
                                             vc.userModel = userModel;
                                             vc.tvId = tvId;
                                             [weakSelf pushViewControllerAsPresent:vc];
                                             
                                         } else if (type == requestTypeVideo){ //视频
                                             MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.session.sessionId];
                                             vc.userModel = userModel;
                                             vc.tvId = tvId;
                                             [weakSelf pushViewControllerAsPresent:vc];
                                         }
                                     }]];
                                     [weakSelf presentViewController:alertController animated:YES completion:nil];
                                 }
                             } else if ([status isEqualToString:@"0"]){ //余额不足以开启对话
                                 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:ZBLocalized(@"Insufficient balance", nil) message:ZBLocalized(@"The current balance is not enough to continue, please recharge", nil) preferredStyle:UIAlertControllerStyleAlert];
                                 [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                 }]];
                                 [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Recharge", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     MyRechargeViewController *chargeVC = [[MyRechargeViewController alloc] init];
                                     [weakSelf.navigationController pushViewController:chargeVC animated:YES];
                                 }]];
                                 [weakSelf presentViewController:alertController animated:YES completion:nil];
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

#pragma mark - ******* Getter *******

- (ChatSessionConfig *)chatConfig{
    if (!_chatConfig) {
        _chatConfig = [[ChatSessionConfig alloc] init];
    }
    return _chatConfig;
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
