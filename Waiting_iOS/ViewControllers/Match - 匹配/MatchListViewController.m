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

@interface MatchListViewController ()<MatchCardDelegate>

@property (weak, nonatomic) IBOutlet UIView * noDataView;    //无数据页面
@property (weak, nonatomic) IBOutlet UIView * backView;      //有数据背景视图
@property (weak, nonatomic) IBOutlet UIView * cardBackView;  //卡片背景图
@property (weak, nonatomic) IBOutlet UIView * bottomView;    //底部按键视图

@property (strong, nonatomic) NSMutableArray * cardDataArr;

@end

@implementation MatchListViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
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
    NSLog(@"index = %ld",index);
}

#pragma mark - ******* Action *******
//语音
- (IBAction)voiceChatAction:(UIButton *)sender {
    
}
//聊天
- (IBAction)chatAction:(UIButton *)sender {
    
}
//视频
- (IBAction)videoChatAction:(UIButton *)sender {
    
}

#pragma mark - ******* Request *******

//请求通话历史
- (void)requestMatchCardList
{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiGetUserInfo
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             
                             NSArray * array = dataDic[@"list"];
                             if (array.count > 0 || 1)
                             {
                                 NSMutableArray *tempArr = [[NSMutableArray alloc] init];
//                                 for (NSDictionary * dict in array)
//                                 {
//                                     BHUserModel * model = [[BHUserModel alloc] init];
//                                     model.userName = [dict stringValueForKey:@"id" default:@""];
//                                     model.gender = [dict stringValueForKey:@"deviceName" default:@""];
//                                     model.age = [dict stringValueForKey:@"mac" default:@""];
//                                     model.photoNum = [dict stringValueForKey:@"netStatus" default:@""];
//
//                                     [tempArr addObject:model];
//                                 }
                                 for (int i = 0 ; i < 10; i++) {
                                     BHUserModel * model = [[BHUserModel alloc] init];
                                     model.userName = @"名字11111111111";
                                     model.gender = i%2 == 0?@"男":@"女";
                                     model.age = [NSString stringWithFormat:@"%d",2*i];
                                     model.photoNum = [NSString stringWithFormat:@"%d",i];
                                     [tempArr addObject:model];
                                 }
                                 
                                 weakSelf.cardDataArr = [tempArr copy];
                                 
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
