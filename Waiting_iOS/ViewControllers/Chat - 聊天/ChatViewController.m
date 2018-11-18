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
#import "NIMKitInfoFetchOption.h"

typedef enum : NSUInteger {
    requestTypeVoice,
    requestTypeVideo,
} requestType;

@interface ChatViewController ()<CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * statusViewHeightConstaint; //状态栏视图高度约束
@property (weak, nonatomic) IBOutlet UIButton   * headImageButton; //导航头像
@property (weak, nonatomic) IBOutlet UILabel    * headTitleLabel; //导航主标题
@property (weak, nonatomic) IBOutlet UILabel    * headSubTitleLabel; //导航副标题
@property (weak, nonatomic) IBOutlet UIView     * naviView; //导航视图

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - ******* UI About *******

- (void)createUI{
    /*
    self.statusViewHeightConstaint.constant = kStatusBarHeight;
    self.tableView.backgroundColor = UIColorBlue;
    NSLog(@" === %f === %f === %f === %f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
    NSLog(@" === %f === %f === %f === %f",self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);

    CGRect frame = self.tableView.frame;
    frame.origin.y = kStatusBarHeight + 80;
    self.tableView.frame = frame;
    [self.tableView.superview layoutIfNeeded];
    NSLog(@" === %f === %f === %f === %f",self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);
    */
    //上面注释的是改变的代码,下面这两行是为了暂时能看见原来什么样子,这个文件均可改,父类是SDK的文件
    self.statusViewHeightConstaint.constant = 0;
    self.naviView.hidden = YES;
}

//- (void)setupTableView
//{
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//    NSLog(@" === %f === %f === %f === %f",self.view.bounds.origin.x,self.view.bounds.origin.y,self.view.bounds.size.width,self.view.bounds.size.height);
//    NSLog(@" === %f === %f === %f === %f",self.tableView.frame.origin.x,self.tableView.frame.origin.y,self.tableView.frame.size.width,self.tableView.frame.size.height);
//
//    self.tableView.backgroundColor = UIColorClearColor;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.estimatedRowHeight = 0;
//    self.tableView.estimatedSectionHeaderHeight = 0;
//    self.tableView.estimatedSectionFooterHeight = 0;
//    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    if ([self.sessionConfig respondsToSelector:@selector(sessionBackgroundImage)] && [self.sessionConfig sessionBackgroundImage]) {
//        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//        imgView.image = [self.sessionConfig sessionBackgroundImage];
//        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        self.tableView.backgroundView = imgView;
//    }
//    [self.view addSubview:self.tableView];
//}


- (void)setupNav
{
    [self setUpTitleView];
}

- (void)setUpTitleView
{
    NIMKitInfo *info = nil;
    NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
    option.session = self.session;
    info = [[NIMKit sharedKit] infoByUser:self.session.sessionId option:option];
    
    NSURL *url = info.avatarUrlString ? [NSURL URLWithString:info.avatarUrlString] : nil;
    [self.headImageButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:info.avatarImage];
    self.headTitleLabel.text = self.sessionTitle;
    self.headSubTitleLabel.text = self.sessionSubTitle;
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
