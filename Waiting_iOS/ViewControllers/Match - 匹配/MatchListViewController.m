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
#import "LSAudioController.h"
#import "LSVideoController.h"
#import "MatchVoiceViewController.h"

@interface MatchListViewController ()<MatchCardDelegate>

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

#pragma mark - ******* Action *******
//聊天
- (IBAction)chatAction:(UIButton *)sender {
    MatchVoiceViewController * vc = [[MatchVoiceViewController alloc] initWithCallee:NIMCount2];
    [self presentViewController:vc animated:YES completion:nil];
}
//语音
- (IBAction)voiceChatAction:(UIButton *)sender {
    //这个参数 自己修改成创建好的 云信账号
    LSAudioController* vc =[[LSAudioController alloc]initWithCallee:NIMCount1];
    //这两个参数是我用来传递姓名头像地址
    vc.nickName = @"被叫宝宝";
    vc.headURLStr = @"suibiansuibian";
    
    [self presentViewController:vc animated:YES completion:nil];
}

//视频
- (IBAction)videoChatAction:(UIButton *)sender {
    //这个参数 自己修改成创建好的 云信账号
    LSVideoController* vc =[[LSVideoController alloc]initWithCallee:NIMCount1];
    //这两个参数是我用来传递姓名头像地址
    vc.nickName = @"被叫宝宝";
    vc.headURLStr = @"suibiansuibian";
    
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - ******* Request *******

//请求通话历史
- (void)requestMatchCardList
{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
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
                                     model.userID = [dict stringValueForKey:@"id" default:@""];
                                     model.userName = [dict stringValueForKey:@"nickname" default:@""];
                                     model.gender = [dict stringValueForKey:@"gender" default:@""];
                                     model.age = [dict stringValueForKey:@"age" default:@""];
                                     model.photoArray = [dict objectForKey:@"pic"];
                                     model.userHeadImageUrl = [dict objectForKey:@"photo"];

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
