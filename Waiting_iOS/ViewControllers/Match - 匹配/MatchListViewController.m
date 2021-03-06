//
//  MatchListViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MatchListViewController.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "MatchCardView.h"
#import "MatchVoiceViewController.h"
#import "MatchVideoViewController.h"
#import "ChatViewController.h"
#import "MatchDetailViewController.h"
#import "MyRechargeViewController.h"

typedef enum : NSUInteger {
    requestTypeVoice,
    requestTypeVideo,
} requestType;

@interface MatchListViewController ()<MatchCardDelegate,CAAnimationDelegate>

@property (weak, nonatomic) IBOutlet UIView * noDataView;    //无数据页面
@property (weak, nonatomic) IBOutlet UIView * backView;      //有数据背景视图
@property (weak, nonatomic) IBOutlet UIView * cardBackView;  //卡片背景图
@property (weak, nonatomic) IBOutlet UIView * bottomView;    //底部按键视图

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewBottomContraint;//底部按键视图距下约束
@property (strong, nonatomic) NSMutableArray    * cardDataArr;

@property (strong, nonatomic) BHUserModel       * currentModel;

@end

@implementation MatchListViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    self.bottomViewBottomContraint.constant = SafeAreaBottomHeight;
    
    [self requestMatchCardList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createCardView{
    MatchCardView  * matchCardView = [[MatchCardView alloc] initWithFrame:self.cardBackView.bounds];
    matchCardView.delegate = self;
    matchCardView.dataArr = self.cardDataArr;
    [self.cardBackView addSubview:matchCardView];

    self.backView.hidden = NO;
    self.noDataView.hidden = YES;
}

#pragma mark - ******* Common Delegate *******

- (void)CardsViewCurrentItem:(NSInteger)index{
    self.currentModel = self.cardDataArr[index];
    NSLog(@"userid = %@",self.currentModel.userID);
}

- (void)CardsViewActionWithModel:(BHUserModel *)model{
    MatchDetailViewController * vc = [[MatchDetailViewController alloc] init];
    vc.userModel = model;
    [self pushViewControllerAsPresent:vc];
}

#pragma mark - ******* Action *******
//聊天
- (IBAction)chatAction:(UIButton *)sender {
    NIMSession *session = [NIMSession session:self.currentModel.userID type:NIMSessionTypeP2P];
    ChatViewController *vc = [[ChatViewController alloc] initWithSession:session];
    [self.navigationController pushViewController:vc animated:YES];
}
//语音
- (IBAction)voiceChatAction:(UIButton *)sender {
    [self requestVideoInit:requestTypeVoice];
}

//视频
- (IBAction)videoChatAction:(UIButton *)sender {
    [self requestVideoInit:requestTypeVideo];
}

#pragma mark - ******* Private *******

#pragma mark - ******* Request *******

//请求首页数据
- (void)requestMatchCardList
{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiMainGetUserList
                        withParaments:@{@"limit":@"50",@"p":@"1"}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                              NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             
                             NSArray * array = dataDic[@"list"];
                             if (array.count > 0)
                             {
                                 NSMutableArray *tempArr = [[NSMutableArray alloc] init];
                                 for (NSDictionary * dict in array)
                                 {
                                     BHUserModel * model = [[BHUserModel alloc] init];
                                     model.userID = [dict stringValueForKey:@"uid" default:@""];
                                     model.userName = [dict stringValueForKey:@"nickname" default:@""];
                                     model.gender = [dict stringValueForKey:@"gender" default:@""];
                                     model.gender_txt = [dict stringValueForKey:@"gender_txt" default:@""];
                                     model.age = [dict stringValueForKey:@"age" default:@""];
                                     model.photoArray = [dict objectForKey:@"pic"];
                                     model.userHeadImageUrl = [dict objectForKey:@"photo"];
                                     model.remark = [dict stringValueForKey:@"remark" default:@""];
                                     model.hobbyArray = [dict objectForKey:@"hobby"];
                                     [tempArr addObject:model];
                                 }
                                 
                                 weakSelf.cardDataArr = [tempArr copy];
                                 weakSelf.currentModel = [tempArr firstObject];
                                 
                                 [weakSelf createCardView];
                                 
                             }else{
                                 weakSelf.backView.hidden = YES;
                                 weakSelf.noDataView.hidden = NO;
                             }
                         }
                         else
                         {
                             weakSelf.backView.hidden = YES;
                             weakSelf.noDataView.hidden = NO;
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         weakSelf.backView.hidden = YES;
                         weakSelf.noDataView.hidden = NO;
                     }];
}

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
                             @"user2":self.currentModel.userID      //被叫
                             };
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
                                         MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.currentModel.userID];
                                         vc.userModel = self.currentModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];

                                     } else if (type == requestTypeVideo){ //视频
                                         MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.currentModel.userID];
                                         vc.userModel = self.currentModel;
                                         vc.tvId = tvId;
                                         [weakSelf pushViewControllerAsPresent:vc];
                                     }
                                 }else if ([nextStatus isEqualToString:@"0"]){//余额不足以开启下一分钟对话
                                     UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:ZBLocalized(@"The current balance can only be called for 1 minute. Is it OK to initiate a call?", nil) preferredStyle:UIAlertControllerStyleAlert];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                     }]];
                                     [alertController addAction:[UIAlertAction actionWithTitle:ZBLocalized(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                         if (type == requestTypeVoice) { //音频
                                             MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:self.currentModel.userID];
                                             vc.userModel = self.currentModel;
                                             vc.tvId = tvId;
                                             [weakSelf pushViewControllerAsPresent:vc];

                                         } else if (type == requestTypeVideo){ //视频
                                             MatchVideoViewController * vc = [[MatchVideoViewController alloc] initWithCallee:self.currentModel.userID];
                                             vc.userModel = self.currentModel;
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

- (NSMutableArray *)cardDataArr{
    if (!_cardDataArr) {
        _cardDataArr = [[NSMutableArray alloc] init];
    }
    return _cardDataArr;
}

#pragma mark - ******* Other *******

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
