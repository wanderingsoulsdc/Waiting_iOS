//
//  LiteADsMessageSetupViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/30.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageSetupViewController.h"
#import "LitePhoneSelectLabelViewController.h"
 
#import "FSNetWorkManager.h"

@interface LiteADsMessageSetupViewController ()<SelectLabelDelegate>
@property (weak, nonatomic) IBOutlet UITextField    * messageNameTextfield; //短信订单名称
@property (weak, nonatomic) IBOutlet UILabel        * selectLabelNumLabel;  //选择标签数量
@property (weak, nonatomic) IBOutlet UILabel        * totalCustomsLabel;    //总覆盖人数
@property (weak, nonatomic) IBOutlet UITextField    * totalCustomsNumTextField; //总覆盖人数数值
@property (weak, nonatomic) IBOutlet UILabel        * unitMessageLabel;     //每条短信价格label
@property (weak, nonatomic) IBOutlet UILabel        * orderTotalPriceLabel; //订单预扣费总额
@property (weak, nonatomic) IBOutlet UIButton       * bottonButton;         //底部按钮
@property (weak, nonatomic) IBOutlet UIButton       * selectNewCustomButton;//只针对新增客户投放按钮

@property (strong , nonatomic) NSString             * selectLabelMaxPeopleNum; //选择完标签的最大人数
@property (strong , nonatomic) NSString             * smsNum;               //单人次短信最大条数
@property (strong , nonatomic) NSString             * unitPrice;            //单条短信价格
@property (nonatomic , strong) NSString             * maxId;        //登陆用户在收集用户表中最大id

@property (nonatomic , strong) LiteADsMessageListModel * messageModel;

@end

@implementation LiteADsMessageSetupViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发送设置";
    [self createUI];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******
- (void)createUI{
    [self.messageNameTextfield addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.totalCustomsNumTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    //每条短信价格
    self.unitMessageLabel.text = [NSString stringWithFormat:@"每条短信%@元",[self.formDic objectForKey:@"unitMessagePrice"]];
    self.unitPrice = [self.formDic objectForKey:@"unitMessagePrice"];
    [self.formDic removeObjectForKey:@"unitMessagePrice"];
    //单人次最大短信条数
    self.smsNum = [self.formDic objectForKey:@"smsNum"];
    [self.formDic removeObjectForKey:@"smsNum"];
    
    //页面类型
    if (self.type == MessageContentTypeEdit) {  //编辑短信
        self.messageNameTextfield.text = [self.formDic objectForKey:@"orderName"];
        
        self.selectLabelNumLabel.text = [NSString stringWithFormat:@"已选%@个标签",[self.formDic objectForKey:@"labelNum"]];
        [self.formDic removeObjectForKey:@"labelNum"];

        if ([[self.formDic objectForKey:@"sendType"] isEqualToString:@"1"]) { //不是  只针对新增客户
            self.selectNewCustomButton.selected = NO;
        }else{
            self.selectNewCustomButton.selected = YES;
        }
        
        self.selectLabelMaxPeopleNum = [self.formDic objectForKey:@"peopleNum"];
        self.totalCustomsNumTextField.text = [self.formDic objectForKey:@"peopleNum"];
        self.totalCustomsLabel.text = [NSString stringWithFormat:@"总覆盖人数%@人",[self.formDic objectForKey:@"peopleNum"]];
        
        [self dealOrderTotalPrice];
        [self checkBottomButtonStatus];
    }else{  //新建短信
        //获取当前日期
        NSDate *currentDate = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
        NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:currentDate];
        NSString * messageNameStr = [NSString stringWithFormat:@"短信_%ld%02ld%02ld%03d",dateComponents.year,dateComponents.month,dateComponents.day,arc4random() % 1000];
        self.messageNameTextfield.text = messageNameStr;
        [self.formDic setValue:messageNameStr forKey:@"orderName"];

        [self.formDic setValue:@"1" forKey:@"sendType"];
        
        self.selectLabelMaxPeopleNum = @"0";
    }

}

#pragma mark - ******* Common Methods *******

- (void)messageSelectLabelResult:(LiteADsMessageListModel *)model maxId:(NSString *)maxId{

    self.selectLabelNumLabel.text = [NSString stringWithFormat:@"已选%@个标签",model.labelNum];
    [self.formDic setValue:model.labelId forKey:@"labelId"];
    [self.formDic setValue:model.peopleNum forKey:@"peopleNum"];
    self.totalCustomsLabel.text = [NSString stringWithFormat:@"总覆盖人数%@人",model.peopleNum];
    self.totalCustomsNumTextField.text = model.peopleNum;
    self.selectLabelMaxPeopleNum = model.peopleNum;
    
    self.maxId = maxId;
    self.messageModel = model;
    
    [self checkBottomButtonStatus];
    [self dealOrderTotalPrice];
}

#pragma mark - ******* Request Methods *******

- (void)requestAddOrEditMessage{
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiMessageAdd
                        withParaments:self.formDic
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAddOrEditSuccessNotification object:self.messageNameTextfield.text];
                             [self.navigationController popToRootViewControllerAnimated:YES];
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


//根据选择标签请求人数
- (void)requestLabelPerson{
    if (!kStringNotNull(self.maxId)) {
        return;
    }
    WEAKSELF
    NSDictionary * params = @{@"labelId":[self.formDic objectForKey:@"labelId"],
                              @"type":self.selectNewCustomButton.selected ? @"2":@"1",
                              @"maxId":self.maxId
                              };
    
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageGetLabelPerson
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求标签统计人数成功");
                             NSDictionary *dic = object[@"data"];
                             NSString *total = [dic stringValueForKey:@"total" default:@""];
                             
                             weakSelf.totalCustomsNumTextField.text = total;
                             weakSelf.totalCustomsLabel.text = [NSString stringWithFormat:@"总覆盖人数%@人",total];
                             [self.formDic setValue:total forKey:@"peopleNum"];
                             [weakSelf dealOrderTotalPrice];
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
    
}


#pragma mark - ******* Action Methods *******
//选择标签
- (IBAction)selectLabelAction:(UIButton *)sender {
    LitePhoneSelectLabelViewController *selectLabelVC = [[LitePhoneSelectLabelViewController alloc] init];
    selectLabelVC.delegate = self;
    selectLabelVC.selectLabelType = SelectLabelTypeMessage;
    selectLabelVC.customType = self.selectNewCustomButton.selected ? AdsCustomTypeOnlyNew : AdsCustomTypeAll;
    selectLabelVC.messageModel = self.messageModel;
    [self.navigationController pushViewController:selectLabelVC animated:YES];
}
//是否只针对新增客户投放
- (IBAction)selectNewCustomAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.formDic setValue:@"2" forKey:@"sendType"];
    }else{
        [self.formDic setValue:@"1" forKey:@"sendType"];
    }
    //每次切换都要重新请求
    [self requestLabelPerson];
}
//总覆盖人数增加
- (IBAction)totalCustomUpAction:(UIButton *)sender {
    int personNum = [self.totalCustomsNumTextField.text intValue];
    if (personNum + 50 > [self.selectLabelMaxPeopleNum intValue]) {
        personNum = [self.selectLabelMaxPeopleNum intValue];
        if ([self.totalCustomsNumTextField.text intValue] > 100) {
            [ShowHUDTool showBriefAlert:[NSString stringWithFormat:@"短信发送人数在%@-%@之间",@"100",self.selectLabelMaxPeopleNum]];
        } else {
            [ShowHUDTool showBriefAlert:@"发送人数不能超过总覆盖人数"];
        }
    } else {
        personNum +=50;
    }
    
    NSString *personNumStr = [NSString stringWithFormat:@"%d",personNum];
    
    [self.formDic setValue:personNumStr forKey:@"peopleNum"];
    self.totalCustomsNumTextField.text = personNumStr;
    
    [self checkBottomButtonStatus];
    [self dealOrderTotalPrice];
}
//总覆盖人数减少
- (IBAction)totalCustomDownAction:(UIButton *)sender {
    int personNum = [self.totalCustomsNumTextField.text intValue];
    if (personNum - 50 < 0) {
        personNum = 0;
    } else {
        personNum -=50;
    }
    
    NSString *personNumStr = [NSString stringWithFormat:@"%d",personNum];
    
    [self.formDic setValue:personNumStr forKey:@"peopleNum"];
    self.totalCustomsNumTextField.text = personNumStr;
    
    [self checkBottomButtonStatus];
    [self dealOrderTotalPrice];
}
//联系客服
- (IBAction)contactServiceAction:(id)sender {
      
}
//底部按钮点击事件
- (IBAction)bottomButtonAction:(UIButton *)sender {
    if (![self checkMessageName]) {
        return;
    }
    if ([self.totalCustomsNumTextField.text longLongValue] < 100) {
        [ShowHUDTool showBriefAlert:@"发送人数不得低于100人"];
        return;
    }
    [self requestAddOrEditMessage];
}

#pragma mark - ******* TextField Delegate *******

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
    
    if (textField == self.totalCustomsNumTextField) {
        //匹配数字
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];

        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+$"];
        if (![predicate evaluateWithObject:str]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    
    if (textField == self.messageNameTextfield) {
        [self.formDic setValue:textField.text forKey:@"orderName"];
    }
    
    if (textField == self.totalCustomsNumTextField) {
        if ([textField.text isEqualToString:@""]) {
            textField.text = @"0";
        }
        
        if ([textField.text longLongValue] > [self.selectLabelMaxPeopleNum intValue]) {
            if ([self.totalCustomsNumTextField.text intValue] > 100) {
                [ShowHUDTool showBriefAlert:[NSString stringWithFormat:@"短信发送人数在%@-%@之间",@"100",self.selectLabelMaxPeopleNum]];
            } else {
                [ShowHUDTool showBriefAlert:@"发送人数不能超过总覆盖人数"];
            }
            textField.text = self.selectLabelMaxPeopleNum;
        }else{
            textField.text = [NSString stringWithFormat:@"%lld",[textField.text longLongValue]];
        }
        
        [self.formDic setValue:textField.text forKey:@"peopleNum"];
        
        [self dealOrderTotalPrice];
    }
    
    [self checkBottomButtonStatus];

}

#pragma mark - ******* Private Methods *******

//自定义签名与短信内容都为必填项，如有一项未填入内容则 “下一步”按钮置灰不可点击
- (void)checkBottomButtonStatus{
    if (kStringNotNull(self.messageNameTextfield.text) && ![self.totalCustomsNumTextField.text isEqualToString:@"0"] && ![self.selectLabelMaxPeopleNum isEqualToString:@"0"]) {
        self.bottonButton.userInteractionEnabled = YES;
        self.bottonButton.backgroundColor = UIColorBlue;
    } else {
        self.bottonButton.userInteractionEnabled = NO;
        self.bottonButton.backgroundColor = UIColorlightGray;
    }
}

//处理计算订单预扣费总额
- (void)dealOrderTotalPrice{
    int smsNum = [self.smsNum intValue];
    CGFloat unitPrice = [self.unitPrice floatValue];
    long totalCustomNum = [self.totalCustomsNumTextField.text longLongValue];
    
    double orderTotalPrice = smsNum * unitPrice * totalCustomNum;
    
    self.orderTotalPriceLabel.text = [NSString stringWithFormat:@"%.2f",orderTotalPrice];
}

//校验短信名称格式
- (BOOL)checkMessageName{
    
    if (self.messageNameTextfield.text.length > 16) {
        [ShowHUDTool showBriefAlert:@"短信订单名称不能超过16个字符"];
        return NO;          // 最多6位字符
    }
    return YES;
}

#pragma mark - ******* Getter *******

- (LiteADsMessageListModel *)messageModel{
    if (!_messageModel) {
        _messageModel = [[LiteADsMessageListModel alloc] init];
    }
    return _messageModel;
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
