//
//  LiteADsMessageDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageDetailViewController.h"
#import "FSNetWorkManager.h"
#import "NSDictionary+YYAdd.h"
#import "BHSobotService.h"
#import "LiteADsMessageContentViewController.h"
#import "LiteADsMessageSendDetailViewController.h"

@interface LiteADsMessageDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewHeightConstraint; //底部视图高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewBottomConstraint; //底部视图距下约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * serviceToStatusConstraint;//客服视图距离审核状态视图约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * serviceToTextViewConstraint;//客服视图距离TextView视图约束

@property (weak, nonatomic) IBOutlet UIView *statusView;        //审核状态视图

@property (weak, nonatomic) IBOutlet UIButton *bottomButton;    //底部按钮

@property (weak, nonatomic) IBOutlet UITextView *topTextView;   //上部短信内容

@property (weak, nonatomic) IBOutlet UIButton *statusMarkButton; //状态标签
@property (weak, nonatomic) IBOutlet UILabel *statusMarkInfoLabel; //状态描述
@property (weak, nonatomic) IBOutlet UILabel *statusMarkTimeLabel; //状态时间
@property (weak, nonatomic) IBOutlet UIButton *statusQuicklyButton;//催审按钮

@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel; //单位价格
@property (weak, nonatomic) IBOutlet UILabel *labelsIncludeLabel; //覆盖标签
@property (weak, nonatomic) IBOutlet UILabel *orderBudgetLabel;//订单预算

@property (weak, nonatomic) IBOutlet UILabel *personsIncludeLabel; //覆盖人数
@property (weak, nonatomic) IBOutlet UILabel *messageNumLabel;  //短信条数
@property (weak, nonatomic) IBOutlet UILabel *messageCreateTimeLabel;//创建时间

@end

@implementation LiteADsMessageDetailViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.messageModel.orderName;
    [self createUI];
    
    [self requestMessageDetail];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******
- (void)createUI{
    self.bottomViewBottomConstraint.constant = SafeAreaBottomHeight;
    [self.topTextView setContentInset:UIEdgeInsetsMake(10, 10 , 10 , 10)];//设置UITextView的内边距
    
    [self checkMessageStatus];
}

/*
 具有优先级1000（UILayoutPriorityRequired）的约束为强制约束（Required Constraint），
 优先级小于1000的约束为可选约束（Optional Constraint）。
 默认创建的是强制约束。
 需要注意的是，只能修改可选约束的优先级(不能修改强制约束)，
 也就是说：  不允许将优先级由小于1000的值改为1000
           不允许将优先级由1000修改为小于1000的值
 */

//根据短信状态 更新ui
- (void)checkMessageStatus{
    //status 订单状态 1 发送中，2 发送成功，3 发送失败，4 审核中，5 审核拒绝
    if ([self.messageModel.status isEqualToString:@"4"]) { //审核中 底部无按钮   其他状态有
        self.bottomViewHeightConstraint.constant = 0;

        //显示审核视图 通过修改优先级
        self.statusView.hidden = NO;
        self.serviceToStatusConstraint.priority = 970;
        self.serviceToTextViewConstraint.priority = 960;
        
        [self.statusMarkButton setTitle:@"审核中" forState:UIControlStateNormal];
        self.statusMarkButton.backgroundColor = UIColorFromRGB(0xFFC880);
        
        self.statusMarkTimeLabel.text = self.messageModel.mtime;
        self.statusMarkInfoLabel.text = @"";
        
        self.statusQuicklyButton.hidden = NO;
        if ([self.messageModel.remindersId isEqualToString:@"0"]) { //未催审
            [self.statusQuicklyButton setTitle:@"催审" forState:UIControlStateNormal];
            [self.statusQuicklyButton setBackgroundColor:UIColorBlue];
            [self.statusQuicklyButton setUserInteractionEnabled:YES];
        }else{ //已催审
            [self.statusQuicklyButton setTitle:@"已催审" forState:UIControlStateNormal];
            [self.statusQuicklyButton setBackgroundColor:UIColorlightGray];
            [self.statusQuicklyButton setUserInteractionEnabled:NO];
        }
        
    }else{
        self.bottomViewHeightConstraint.constant = 56;
        if ([self.messageModel.status isEqualToString:@"5"]) { //审核拒绝底部按钮 是 编辑短信
            [self.bottomButton setTitle:@"编辑短信" forState:UIControlStateNormal];

            //显示审核视图 通过修改优先级
            self.statusView.hidden = NO;
            self.serviceToStatusConstraint.priority = 970;
            self.serviceToTextViewConstraint.priority = 960;
            
            [self.statusMarkButton setTitle:@"审核拒绝" forState:UIControlStateNormal];
            self.statusMarkButton.backgroundColor = UIColorError;
            
            self.statusMarkInfoLabel.text = self.messageModel.rejectReason;
            self.statusMarkTimeLabel.text = self.messageModel.mtime;
            
            self.statusQuicklyButton.hidden = YES;

        }else{ //其他状态 是 查看发送明细
            [self.bottomButton setTitle:@"查看发送明细" forState:UIControlStateNormal];
            
            //隐藏审核视图 通过修改优先级
            self.statusView.hidden = YES;
            self.serviceToStatusConstraint.priority = 960;
            self.serviceToTextViewConstraint.priority = 970;
        }
    }
}
#pragma mark - ******* Action Methods *******
//底部按钮
- (IBAction)bottomButtonAction:(UIButton *)sender {
    if ([self.messageModel.status isEqualToString:@"5"]) { //审核拒绝底部按钮 是 编辑短信
        LiteADsMessageContentViewController *setMessageContentVC = [[LiteADsMessageContentViewController alloc] init];
        setMessageContentVC.type = MessageContentTypeEdit;
        setMessageContentVC.messageModel = self.messageModel;
        [self.navigationController pushViewController:setMessageContentVC animated:YES];
    }else{ //其他状态 是 查看发送明细
        LiteADsMessageSendDetailViewController *sendDetailVC = [[LiteADsMessageSendDetailViewController alloc] init];
        sendDetailVC.messageModel = self.messageModel;
        [self.navigationController pushViewController:sendDetailVC animated:YES];
    }
}

//联系在线客服
- (IBAction)contactService:(UIButton *)sender {
    [[BHSobotService sharedInstance] startSoBotCustomerServiceWithViewController:self];
}
//催审
- (IBAction)statusQuicklyButtonAction:(UIButton *)sender {
    [self requestMessageReminder];
}

#pragma mark - ******* Request Methods *******
//短信详情
- (void)requestMessageDetail{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageDetail
                        withParaments:@{@"id":self.messageModel.orderId}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             /*"data": {
                              "orderName": "短信12345678901234",  //短信名称
                              "content": "测试短信测测试短信测测试短信测测试短信测测试短信测测试短信测",  //短信内容
                              "sign": "测试", //签名
                              "auditTime": "0000-00-00 00:00:00", //审核时间
                              "budget": "19.00",  //预算
                              "rejectReason": "", //拒绝原因
                              "peopleNum": 222, //覆盖人数
                              "labelId": "1,2,3,4,5,6,7,8", //标签id ,多个逗号分隔
                              "smsNum": 1, //单人次短信最大条数
                              "smsPrice": "0.09", //单价
                              "sendType": 1//是否针对新增客户投放 1 否 2 是
                              "ctime": "2018-06-28 20:30:20", //创建时间
                              "labelNum": 8, //标签数
                              "smsTotal": 222, //短信条数
                              "status": 4 //短信状态 1 发送中，2 发送成功，3 发送失败，4 审核中，5 审核拒绝,
                              "remindersId": 0,  //  0-未催审  否则-已催审
                              "mtime": "2018-06-28 20:30:20" //更新时间(如催审 为催审时间)
                              }
                              */
                             NSDictionary *dic = object[@"data"];
                             
                             weakSelf.messageModel.orderName = [dic stringValueForKey:@"orderName" default:@""];
                             weakSelf.messageModel.content = [dic stringValueForKey:@"content" default:@""];
                             weakSelf.messageModel.sign = [dic stringValueForKey:@"sign" default:@""];
                             weakSelf.messageModel.auditTime = [dic stringValueForKey:@"auditTime" default:@""];
                             weakSelf.messageModel.budget = [dic stringValueForKey:@"budget" default:@""];
                             weakSelf.messageModel.rejectReason = [dic stringValueForKey:@"rejectReason" default:@""];
                             weakSelf.messageModel.peopleNum = [dic stringValueForKey:@"peopleNum" default:@""];
                             
                             NSArray * labelArr = [dic objectForKey:@"labelId"];
                             if (labelArr.count >0 ) {
                                 NSString *labelIds = @"";
                                 for (NSString *labelStr in labelArr) {
                                     labelIds = [labelIds stringByAppendingFormat:@",%@",labelStr];
                                 }
                                 weakSelf.messageModel.labelId = [labelIds substringWithRange:NSMakeRange(1,labelIds.length - 1)];
                             }else{
                                 weakSelf.messageModel.labelId = @"";
                             }
                             
                             weakSelf.messageModel.smsNum = [dic stringValueForKey:@"smsNum" default:@""];
                             weakSelf.messageModel.smsPrice = [dic stringValueForKey:@"smsPrice" default:@""];
                             weakSelf.messageModel.sendType = [dic stringValueForKey:@"sendType" default:@""];
                             weakSelf.messageModel.ctime = [dic stringValueForKey:@"ctime" default:@""];
                             weakSelf.messageModel.labelNum = [dic stringValueForKey:@"labelNum" default:@""];
                             weakSelf.messageModel.smsTotal = [dic stringValueForKey:@"smsTotal" default:@""];
                             weakSelf.messageModel.status = [dic stringValueForKey:@"status" default:@""];
                             weakSelf.messageModel.remindersId = [dic stringValueForKey:@"remindersId" default:@""];
                             weakSelf.messageModel.mtime = [dic stringValueForKey:@"mtime" default:@""];

                             
                             weakSelf.topTextView.text = [NSString stringWithFormat:@"【%@】%@回T退订",weakSelf.messageModel.sign,weakSelf.messageModel.content];
                             
                             weakSelf.unitPriceLabel.text = weakSelf.messageModel.smsPrice;
                             weakSelf.labelsIncludeLabel.text = [NSString stringWithFormat:@"%@个标签",weakSelf.messageModel.labelNum];
                             weakSelf.orderBudgetLabel.text = weakSelf.messageModel.budget;
                             weakSelf.personsIncludeLabel.text = weakSelf.messageModel.peopleNum;
                             weakSelf.messageNumLabel.text = weakSelf.messageModel.smsTotal;
                             weakSelf.messageCreateTimeLabel.text = weakSelf.messageModel.ctime;
                             
                             [weakSelf checkMessageStatus];
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

//短信催审
- (void)requestMessageReminder{
    WEAKSELF
    NSDictionary * params = @{@"smsId":self.messageModel.orderId};
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageReminder
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                [weakSelf.statusQuicklyButton setTitle:@"已催审" forState:UIControlStateNormal];
                                [weakSelf.statusQuicklyButton setBackgroundColor:UIColorlightGray];
                                [weakSelf.statusQuicklyButton setUserInteractionEnabled:NO];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
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
