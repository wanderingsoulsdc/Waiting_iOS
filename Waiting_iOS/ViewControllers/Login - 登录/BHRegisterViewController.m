//
//  BHRegisterViewController.m
//  Customer
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/5/16.
//  Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHRegisterViewController.h"
#import <Masonry/Masonry.h>
#import "UIButton+countdown.h"
#import "ShowHudTool.h"
#import "BHRegisterVerifyCodeViewController.h"
#import "FSNetWorkManager.h"
#import "BHAgreementViewController.h"
#import "NSString+Helper.h"

@interface BHRegisterViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView      * mobileBgView;
@property (nonatomic, strong) UITextField * mobileTextField;
@property (nonatomic, strong) UIButton    * nextButton;
@property (nonatomic, strong) UIButton    * agreementButton;

@end

@implementation BHRegisterViewController
{
    NSString *previousTextFieldContent;
    UITextRange *previousSelection;
}


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type == ResetPassWordTypeRegister ? @"注册新用户" : @"找回密码";
    self.view.backgroundColor = UIColorFromRGB(0xF4F4F4);
    
    // You should add subviews here, just add subviews
    [self.view addSubview:self.mobileBgView];
    [self.view addSubview:self.mobileTextField];
    [self.view addSubview:self.nextButton];
    
    if (self.type == ResetPassWordTypeRegister)
    {
        [self.view addSubview:self.agreementButton];
    }
    
    // You should add notification here
    
    // layout subviews
    [self layoutSubviews];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.mobileTextField resignFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here

    [self.mobileBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@50);
    }];
    [self.mobileTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@50);
    }];

    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(self.view).offset(-80);
        make.top.equalTo(self.mobileTextField.mas_bottom).offset(50);
        make.height.equalTo(@48);
    }];
    if (self.type == ResetPassWordTypeRegister)
    {
        [self.agreementButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
            make.height.equalTo(@40);
        }];
    }
}

#pragma mark - SystemDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * str = [NSMutableString stringWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];
    if (str.length > 0){
    }else{
    }
    
    previousTextFieldContent = textField.text;
    previousSelection = textField.selectedTextRange;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 0){
        self.nextButton.backgroundColor = UIColorBlue;
        self.nextButton.userInteractionEnabled = YES;
    }else{
        self.nextButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
        self.nextButton.userInteractionEnabled = NO;
    }
    
    //限制手机账号长度（有两个空格）
    if (textField.text.length > 13) {
        textField.text = [textField.text substringToIndex:13];
    }
    
    NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSString *currentStr = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *preStr = [previousTextFieldContent stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    //正在执行删除操作时为0，否则为1
    char editFlag = 0;
    if (currentStr.length <= preStr.length) {
        editFlag = 0;
    }
    else {
        editFlag = 1;
    }
    
    NSMutableString *tempStr = [NSMutableString new];
    
    int spaceCount = 0;
    if (currentStr.length < 3 && currentStr.length > -1) {
        spaceCount = 0;
    }else if (currentStr.length < 7 && currentStr.length > 2) {
        spaceCount = 1;
    }else if (currentStr.length < 12 && currentStr.length > 6) {
        spaceCount = 2;
    }
    
    for (int i = 0; i < spaceCount; i++) {
        if (i == 0) {
            [tempStr appendFormat:@"%@%@", [currentStr substringWithRange:NSMakeRange(0, 3)], @" "];
        }else if (i == 1) {
            [tempStr appendFormat:@"%@%@", [currentStr substringWithRange:NSMakeRange(3, 4)], @" "];
        }else if (i == 2) {
            [tempStr appendFormat:@"%@%@", [currentStr substringWithRange:NSMakeRange(7, 4)], @" "];
        }
    }
    
    if (currentStr.length == 11) {
        [tempStr appendFormat:@"%@%@", [currentStr substringWithRange:NSMakeRange(7, 4)], @" "];
    }
    if (currentStr.length < 4) {
        [tempStr appendString:[currentStr substringWithRange:NSMakeRange(currentStr.length - currentStr.length % 3, currentStr.length % 3)]];
    }else if(currentStr.length > 3 && currentStr.length <12) {
        NSString *str = [currentStr substringFromIndex:3];
        [tempStr appendString:[str substringWithRange:NSMakeRange(str.length - str.length % 4, str.length % 4)]];
        if (currentStr.length == 11) {
            [tempStr deleteCharactersInRange:NSMakeRange(13, 1)];
        }
    }
    textField.text = tempStr;
    // 当前光标的偏移位置
    NSUInteger curTargetCursorPosition = targetCursorPosition;
    
    if (editFlag == 0) {
        //删除
        if (targetCursorPosition == 9 || targetCursorPosition == 4) {
            curTargetCursorPosition = targetCursorPosition - 1;
        }
    }else {
        //添加
        if (currentStr.length == 8 || currentStr.length == 4) {
            curTargetCursorPosition = targetCursorPosition + 1;
        }
    }
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:curTargetCursorPosition];
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition :targetPosition]];
}

#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

- (void)nextButtonAction:(UIButton *)sender
{
    NSLog(@"下一步");
    [self.view endEditing:YES];
    
    //去空格
    NSString * mobile = [self.mobileTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![mobile checkMobileNumber])
    {
        [ShowHUDTool showBriefAlert:@"请输入正确的手机号码"];
        return;
    }

    NSDictionary * params = @{@"mobile":mobile,@"token":self.token};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:@""
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus){
                                NSString *isRegister = [object stringValueForKey:@"data" default:@""];
                                if ([isRegister isEqualToString:@"1"]) {
                                    if (self.type == ResetPassWordTypeRegister) {
                                        [ShowHUDTool showBriefAlert:@"手机号码已注册"];
                                    }else{
                                        [self sendVerCode:mobile];
                                    }
                                }else{
                                    if (self.type == ResetPassWordTypeRegister) {
                                        [self sendVerCode:mobile];
                                    }else{
                                        [ShowHUDTool showBriefAlert:@"手机号码未注册"];
                                    }
                                }
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

- (void)agreementButtonAction:(UIButton *)sender
{
    NSLog(@"协议");
    BHAgreementViewController * agreementViewController = [[BHAgreementViewController alloc] init];
    agreementViewController.url = kApiWebRegisterAgreement;
    agreementViewController.type = BHAgreementTypeRegister;
    [self.navigationController pushViewController:agreementViewController animated:YES];
}

#pragma mark - Private methods
//发送验证码
- (void)sendVerCode:(NSString *)mobile{
    self.nextButton.userInteractionEnabled = NO;
    NSDictionary * params = @{@"mobile":mobile, @"type":self.type == ResetPassWordTypeRegister ? @"1":@"2",@"token":self.token};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginGetVerCode
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            self.nextButton.userInteractionEnabled = YES;
                            
                            if (NetResponseCheckStaus)
                            {
                                BHRegisterVerifyCodeViewController * registerVerifyCodeVC = [[BHRegisterVerifyCodeViewController alloc] init];
                                registerVerifyCodeVC.mobileString = self.mobileTextField.text;
                                registerVerifyCodeVC.type = self.type;
                                registerVerifyCodeVC.token = self.token;
                                [self.navigationController pushViewController:registerVerifyCodeVC animated:YES];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            self.nextButton.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UIView *)mobileBgView
{
    if (!_mobileBgView)
    {
        _mobileBgView = [[UIView alloc] init];
        _mobileBgView.backgroundColor = [UIColor whiteColor];
    }
    return _mobileBgView;
}

- (UITextField *)mobileTextField
{
    if (!_mobileTextField)
    {
        _mobileTextField = [[UITextField alloc] init];
        _mobileTextField.backgroundColor = [UIColor whiteColor];
        _mobileTextField.textColor = UIColorDarkBlack;
        _mobileTextField.textAlignment = NSTextAlignmentRight;
        _mobileTextField.font = [UIFont systemFontOfSize:14];
        _mobileTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xD3D9DF)}];
        _mobileTextField.borderStyle = UITextBorderStyleNone;
        _mobileTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _mobileTextField.returnKeyType = UIReturnKeyDone;
        _mobileTextField.keyboardType = UIKeyboardTypePhonePad;
        _mobileTextField.delegate = self;
        [_mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"手机号码";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDarkBlack;
        leftLabel.frame = CGRectMake(0, 0, 80, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _mobileTextField.leftView = leftLabel;
        _mobileTextField.leftViewMode = UITextFieldViewModeAlways;
    }
    return _mobileTextField;
}
- (UIButton *)nextButton
{
    if (!_nextButton)
    {
        _nextButton = [[UIButton alloc] init];
        _nextButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
        _nextButton.userInteractionEnabled = NO;
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _nextButton.userInteractionEnabled = NO;
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _nextButton.layer.cornerRadius = 2;
        _nextButton.clipsToBounds = YES;
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
- (UIButton *)agreementButton
{
    if (!_agreementButton)
    {
        NSString * registerString = @"注册即表示同意并阅读《璧合用户服务协议》";
        NSString * registerAttributeString = @"《璧合用户服务协议》";
        _agreementButton = [[UIButton alloc] init];
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:registerString];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorBlue range:NSMakeRange(registerString.length - registerAttributeString.length, registerAttributeString.length)];
        [_agreementButton setAttributedTitle:mutableAttributedString forState:UIControlStateNormal];
        _agreementButton.titleLabel.textColor = UIColorFromRGB(0x969696);
        _agreementButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _agreementButton.titleLabel.numberOfLines = 0;
        _agreementButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _agreementButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _agreementButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_agreementButton addTarget:self action:@selector(agreementButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _agreementButton;
}

#pragma mark - MemoryWarning

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
