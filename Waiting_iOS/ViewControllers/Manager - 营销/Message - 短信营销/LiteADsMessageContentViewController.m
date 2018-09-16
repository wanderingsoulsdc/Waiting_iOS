//
//  LiteADsMessageContentViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/27.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsMessageContentViewController.h"
#import "FSNetWorkManager.h"
#import "NSDictionary+YYAdd.h"
 
#import "UITextView+Placeholder.h"
#import "IQKeyboardManager.h"
#import "LiteADsMessageSetupViewController.h"
#import "LiteADsMessageHistoryViewController.h"
#import "LiteADsMessageContentInfoViewController.h"
#import "UIViewController+NavigationItem.h"

@interface LiteADsMessageContentViewController ()<LiteADsMessageHistoryDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * nextButtonBottomConstraint; //底部视图距下约束

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * progressViewHeightConstraint; //进度条视图高度约束


@property (weak, nonatomic) IBOutlet UIButton * nextButton; //下一步按钮

@property (weak, nonatomic) IBOutlet UITextView     * messageContentTextView; //短信内容
@property (weak, nonatomic) IBOutlet UITextField    * messageSignTextField; //短信签名
@property (weak, nonatomic) IBOutlet UILabel        * messageWordInfoLabel; //短信文字说明(含签名和“回T退订”)
@property (weak, nonatomic) IBOutlet UIButton       * messageHistoryButton; //短信历史按钮
@property (weak, nonatomic) IBOutlet UILabel        * messageContentNumLabel;    //短信字数label

@property (nonatomic , strong) NSArray              * messageConfigArr;   //短信敏感词数组
@property (nonatomic , strong) NSString             * unitMessagePrice;   //单条短信价格
@property (nonatomic , strong) NSMutableDictionary  * formDic;   //提交数组

@property (weak, nonatomic) id<UIGestureRecognizerDelegate> restoreInteractivePopGestureDelegate;  //记录侧滑手势

@end

@implementation LiteADsMessageContentViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type == MessageContentTypeAdd ? @"设置短信内容" : @"编辑短信内容";
    [self setLeftBarButtonTarget:self Action:@selector(leftBarButtonAction:) Image:@"nav_back"];
    //记录侧滑返回
    _restoreInteractivePopGestureDelegate = self.navigationController.interactivePopGestureRecognizer.delegate;

    [self createUI];
    
    [self checkMessageContentNum];
    [self checkNextButtonStatus];
    
    [self requestMessageConfig];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [IQKeyboardManager sharedManager].enable = YES;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = _restoreInteractivePopGestureDelegate;
    };

}

#pragma mark - ******* UIGestureRecognizer Delegate *******

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

#pragma mark - ******* UI Methods *******
- (void)createUI{
    self.nextButtonBottomConstraint.constant = SafeAreaBottomHeight;
    
    self.messageContentTextView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入短信内容" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];

    if (IS_IPHONE5) {
        self.messageWordInfoLabel.text = @"   ";
    }else{
        self.messageWordInfoLabel.text = @"（含签名和“回T退订”）";
    }
    
    [self.messageSignTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    self.formDic = [[NSMutableDictionary alloc] init];
    
    if (self.type == MessageContentTypeAdd) {
        [self.formDic setValue:@"add" forKey:@"type"];
        [self.formDic setValue:@"0" forKey:@"smsId"];
    }else{
        [self.formDic setValue:@"edit" forKey:@"type"];
        [self.formDic setValue:self.messageModel.orderId forKey:@"smsId"];
        [self.formDic setValue:self.messageModel.content forKey:@"content"];
        [self.formDic setValue:self.messageModel.sign forKey:@"sign"];
        [self.formDic setValue:self.messageModel.orderName forKey:@"orderName"];
        [self.formDic setValue:self.messageModel.peopleNum forKey:@"peopleNum"];
        [self.formDic setValue:self.messageModel.labelId forKey:@"labelId"];
        [self.formDic setValue:self.messageModel.sendType forKey:@"sendType"];
        //下个页面用完删除
        [self.formDic setValue:self.messageModel.labelNum forKey:@"labelNum"];
        [self.formDic setValue:self.messageModel.smsNum forKey:@"smsNum"];

        self.messageSignTextField.text = self.messageModel.sign;
        self.messageContentTextView.text = self.messageModel.content;
        
        self.progressViewHeightConstraint.constant = 0;   //隐藏进度条视图
        [self.nextButton setTitle:@"确定" forState:UIControlStateNormal]; //下方按钮变为确定
        
        [self checkNextButtonStatus];
        [self checkMessageContentNum];
    }
}

#pragma mark - ******* Common Delegate *******

- (void)messageHistorySelectResult:(LiteADsMessageListModel *)model{
    [self.formDic setValue:model.content forKey:@"content"];
    [self.formDic setValue:model.sign forKey:@"sign"];
    self.messageSignTextField.text = model.sign;
    self.messageContentTextView.text = model.content;
    [self checkNextButtonStatus];
    [self checkMessageContentNum];
}

#pragma mark - ******* TextView Delegate *******

- (void)textViewDidChange:(UITextView *)textView
{
    [self checkNextButtonStatus];
    [self checkMessageContentNum];
    [self.formDic setValue:textView.text forKey:@"content"];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    NSMutableString * str = [NSMutableString stringWithString:textView.text];
    [str replaceCharactersInRange:range withString:text];
    
    if (str.length > 300){
        [ShowHUDTool showBriefAlert:@"您输入的内容过长"];
        return NO;// 最多300个字
    }
    return YES;
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
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    [self checkNextButtonStatus];
    [self checkMessageContentNum];
    [self.formDic setValue:textField.text forKey:@"sign"];
}

#pragma mark - ******* Private Methods *******
//校验短信签名格式
- (BOOL)checkMessageSign{
    
    if (self.messageSignTextField.text.length > 6) {
        [ShowHUDTool showBriefAlert:@"短信签名不能超过6个字符"];
        return NO;          // 最多6位字符
    }
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9-_\\u4E00-\\u9FA5]+$"];
    if ([predicate evaluateWithObject:self.messageSignTextField.text]) {
        return YES;
    }else{
        [ShowHUDTool showBriefAlert:@"短信签名不能包含特殊字符"];
        return NO;
    }
}

//校验短信内容
- (BOOL)checkMessageContent{
    
    if (self.messageContentTextView.text.length < 20) {
        [ShowHUDTool showBriefAlert:@"短信内容不能少于20个字符"];
        return NO;
    }
    return YES;
}

//敏感词校验
- (BOOL)checkMessageConfig{
    
    for (NSString * configStr in self.messageConfigArr) {
        if ([self.messageSignTextField.text containsString:configStr]) {
            [ShowHUDTool showBriefAlert:@"短信签名不能包含敏感词"];
            return NO;
        }
    }
    
    for (NSString * configStr in self.messageConfigArr) {
        if ([self.messageContentTextView.text containsString:configStr]) {
            [ShowHUDTool showBriefAlert:@"短信内容不能包含敏感词"];
            return NO;
        }
    }
    return YES;
}

//自定义签名与短信内容都为必填项，如有一项未填入内容则 “下一步”按钮置灰不可点击
- (void)checkNextButtonStatus{
    if (kStringNotNull(self.messageContentTextView.text) && kStringNotNull(self.messageSignTextField.text)) {
        self.nextButton.userInteractionEnabled = YES;
        self.nextButton.backgroundColor = UIColorBlue;
    } else {
        self.nextButton.userInteractionEnabled = NO;
        self.nextButton.backgroundColor = UIColorlightGray;
    }
}

//校验短信内容字数
- (void)checkMessageContentNum{
    
    long messageLength = self.messageContentTextView.text.length + self.messageSignTextField.text.length + 2/*【】*/ + 4/* 回T退订 */; //整条短信字数长度
    if (messageLength <= 70) { //小于等于算一条
        self.messageContentNumLabel.text = [NSString stringWithFormat:@"1条/%ld个字",messageLength];
        [self.formDic setValue:@"1" forKey:@"smsNum"];
    } else { //大于70条   按64字算一条
        NSString *smsNum = @"1";
        if (messageLength % 64 == 0) {
            smsNum = [NSString stringWithFormat:@"%ld",messageLength / 64];
        } else {
            smsNum = [NSString stringWithFormat:@"%ld",messageLength / 64 + 1];
        }
        self.messageContentNumLabel.text = [NSString stringWithFormat:@"%@条/%ld个字",smsNum ,messageLength];
        [self.formDic setValue:smsNum forKey:@"smsNum"];
    }
    
}

#pragma mark - ******* Action Methods *******
//底部按钮
- (IBAction)nextButtonAction:(UIButton *)sender {
    if (![self checkMessageSign]) {
        return;
    }
    
    if (![self checkMessageContent]) {
        return;
    }
    
    if (![self checkMessageConfig]) {
        return;
    }
    
    if (!kStringNotNull(self.unitMessagePrice)) {
        [ShowHUDTool showBriefAlert:@"请求失败，请检查网络重试"];
        [self requestMessageConfig];
        return;
    }
    
    if (self.type == MessageContentTypeAdd) {
        LiteADsMessageSetupViewController *vc = [[LiteADsMessageSetupViewController alloc] init];
        vc.formDic = [self.formDic mutableCopy];
        vc.type = self.type;
        [self.navigationController pushViewController:vc  animated:YES];
    } else {
        [self requestAddOrEditMessage];
    }
}
    

//联系在线客服
- (IBAction)contactService:(UIButton *)sender {
      
}
//短信内容说明
- (IBAction)messageContentInformationAction:(UIButton *)sender {
    LiteADsMessageContentInfoViewController * vc = [[LiteADsMessageContentInfoViewController alloc] init];
    vc.url = kApiWebMessageInfo;
    [self.navigationController pushViewController:vc animated:YES];
}
//选择历史短信
- (IBAction)messageHistoryButtonAction:(UIButton *)sender {
    LiteADsMessageHistoryViewController *historyVC = [[LiteADsMessageHistoryViewController alloc] init];
    historyVC.delegate = self;
    [self.navigationController pushViewController:historyVC animated:YES];
}

//返回按钮
- (void)leftBarButtonAction:(UIButton *)sender
{
    if (!kStringNotNull(self.messageSignTextField.text) && !kStringNotNull(self.messageContentTextView.text)){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"已编辑内容将不会被保存，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        [alert addAction:cancel];
        
        UIAlertAction *button = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
        [alert addAction:button];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    NSLog(@"返回");
}

#pragma mark - ******* Request Methods *******

//请求短信配置,敏感词等
- (void)requestMessageConfig{
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiMessageConfig
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             weakSelf.messageConfigArr = dataDic[@"keywords"];
                             weakSelf.unitMessagePrice = [dataDic stringValueForKey:@"price" default:@""];
                             [self.formDic setValue:weakSelf.unitMessagePrice forKey:@"unitMessagePrice"];
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
//编辑添加短信
- (void)requestAddOrEditMessage{
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiMessageAdd
                        withParaments:self.formDic
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAddOrEditSuccessNotification object:self.messageModel.orderName];
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
