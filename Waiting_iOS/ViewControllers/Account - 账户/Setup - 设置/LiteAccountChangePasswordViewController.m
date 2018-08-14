//
//  LiteAccountChangePasswordViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/20.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountChangePasswordViewController.h"
#import "LiteAlertLabel.h"
#import <Masonry/Masonry.h>
#import "UIButton+countdown.h"
#import "BHUserModel.h"
#import "FSNetWorkManager.h"
#import "BHRegisterSuccessViewController.h"

@interface LiteAccountChangePasswordViewController ()<UITextFieldDelegate>

@property (nonatomic , strong) LiteAlertLabel   * alertLabel;
@property (nonatomic , strong) UIView           * verifyCodeView;
@property (nonatomic , strong) UIView           * setPasswordView;
@property (nonatomic , strong) UIView           * confirmPasswordView;

@property (nonatomic , strong) UIView           * lineView1; //竖线
@property (nonatomic , strong) UIView           * lineView2; //横线

@property (nonatomic , strong) UIButton         * sendVerifyCodeButton;
@property (nonatomic , strong) UIButton         * confirmButton;

@property (nonatomic , strong) UILabel          * verifyCodeLabel;
@property (nonatomic , strong) UILabel          * setPasswordLabel;
@property (nonatomic , strong) UILabel          * confirmPasswordLabel;


@property (nonatomic , strong) UITextField      * verifyCodeTextField;
@property (nonatomic , strong) UITextField      * setPasswordTextField;
@property (nonatomic , strong) UITextField      * confirmPasswordField;

@end

@implementation LiteAccountChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改密码";
    
    [self creatUI];
    
    [self layoutSubviews];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.sendVerifyCodeButton endSetting];
}
//创建页面UI
- (void)creatUI{
    [self.view addSubview:self.alertLabel];
    [self.verifyCodeView addSubview:self.verifyCodeLabel];
    [self.verifyCodeView addSubview:self.sendVerifyCodeButton];
    [self.verifyCodeView addSubview:self.lineView1];
    [self.verifyCodeView addSubview:self.verifyCodeTextField];
    [self.view addSubview:self.verifyCodeView];
    
    [self.setPasswordView addSubview:self.setPasswordLabel];
    [self.setPasswordView addSubview:self.setPasswordTextField];
    [self.setPasswordView addSubview:self.lineView2];
    [self.view addSubview:self.setPasswordView];
    
    [self.confirmPasswordView addSubview:self.confirmPasswordLabel];
    [self.confirmPasswordView addSubview:self.confirmPasswordField];
    [self.view addSubview:self.confirmPasswordView];
    
    [self.view addSubview:self.confirmButton];
    
}
//页面布局
- (void)layoutSubviews{
    
    [self.alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.height.equalTo(@32);
    }];
    [self.verifyCodeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.alertLabel.mas_bottom).offset(12);
        make.height.equalTo(@60);
    }];
    [self.verifyCodeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.left.equalTo(self.verifyCodeView.mas_left).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];

    [self.sendVerifyCodeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.right.equalTo(self.verifyCodeView.mas_right).offset(-12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];

    [self.lineView1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sendVerifyCodeButton.mas_left).offset(-12);
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.height.equalTo(@20);
        make.width.equalTo(@1);
    }];

    [self.verifyCodeTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.verifyCodeView.mas_centerY);
        make.right.equalTo(self.lineView1.mas_left).offset(-12);
        make.left.equalTo(self.verifyCodeLabel.mas_right).offset(12);
        make.height.equalTo(@40);
    }];
    
    [self.setPasswordView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.verifyCodeView.mas_bottom).offset(15);
        make.height.equalTo(@60);
    }];
    [self.setPasswordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.setPasswordView.mas_centerY);
        make.left.equalTo(self.setPasswordView.mas_left).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];
    [self.setPasswordTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.setPasswordView.mas_centerY);
        make.right.equalTo(self.setPasswordView.mas_right).offset(-12);
        make.left.equalTo(self.setPasswordLabel.mas_right).offset(12);
        make.height.equalTo(@40);
    }];
    
    [self.lineView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.setPasswordView.mas_right);
        make.left.equalTo(self.setPasswordView.mas_left).offset(8);
        make.bottom.equalTo(self.setPasswordView.mas_bottom);
        make.height.equalTo(@0.5);
    }];
    
    [self.confirmPasswordView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.setPasswordView.mas_bottom);
        make.height.equalTo(@60);
    }];
    [self.confirmPasswordLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPasswordView.mas_centerY);
        make.left.equalTo(self.confirmPasswordView.mas_left).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];
    [self.confirmPasswordField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.confirmPasswordView.mas_centerY);
        make.right.equalTo(self.confirmPasswordView.mas_right).offset(-12);
        make.left.equalTo(self.confirmPasswordLabel.mas_right).offset(12);
        make.height.equalTo(@40);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
        make.top.equalTo(self.confirmPasswordView.mas_bottom).offset(40);
        make.height.equalTo(@40);
    }];
    
}

#pragma mark - action

- (void)sendVerifyCode:(UIButton *)button{
    NSLog(@"获取验证码");
    
    JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
    setting.strPrefix = @"";
    setting.strSuffix = @"s后重新获取";
    setting.strCommon = @"获取验证码";
    setting.colorTitle = UIColorBlue;
    setting.indexStart = 60;
    setting.colorDisable = [UIColor clearColor];
    setting.colorCommon = [UIColor clearColor];
    setting.colorTitleDisable = UIColorFromRGB(0x969696);
    [self.sendVerifyCodeButton startWithSetting:setting];
    
    NSDictionary * params = @{@"mobile":[BHUserModel sharedInstance].mobile, @"type":@"3",@"token":[BHUserModel sharedInstance].token};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginGetVerCode
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            if (NetResponseCheckStaus){
                               
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
    
}
- (void)confirmButtonAction:(UIButton *)button
{
    NSLog(@"确认");
    [self.view endEditing:YES];
    if (![self isValid]) {
        return;
    }
    NSDictionary * params = @{@"mobile":[BHUserModel sharedInstance].mobile, @"password":self.setPasswordTextField.text,@"checkCode":self.verifyCodeTextField.text};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiLoginResetPW
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            if (NetResponseCheckStaus)
                            {
                                BHRegisterSuccessViewController * registerSuccessViewController = [[BHRegisterSuccessViewController alloc] init];
                                
                                registerSuccessViewController.type = ResetPassWordTypeReset;
                                [BHUserModel sharedInstance].passwd = self.setPasswordTextField.text;
                                
                                [[BHUserModel sharedInstance] saveToDisk];
                                
                                [self.navigationController pushViewController:registerSuccessViewController animated:YES];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}
#pragma mark - Private methods
//检查底部按钮状态
- (void)checkFootButtonStatus{
    if (kStringNotNull(self.setPasswordTextField.text) && kStringNotNull(self.confirmPasswordField.text) && kStringNotNull(self.verifyCodeTextField.text)) {
        self.confirmButton.backgroundColor = UIColorBlue;
        self.confirmButton.userInteractionEnabled = YES;
    } else {
        self.confirmButton.backgroundColor = UIColorlightGray;
        self.confirmButton.userInteractionEnabled = NO;
    }
}

//内容校验
- (BOOL)isValid
{
    if (self.verifyCodeTextField.text.length < 6) {
        [ShowHUDTool showBriefAlert:@"验证码由6位数字组成"];
    }
    
    NSString * password = [self.setPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * confirmPassword = [self.confirmPasswordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![password isEqualToString:confirmPassword]) {
        [ShowHUDTool showBriefAlert:@"密码输入不一致"];
        return NO;
    }
    
    NSString *regex =@"[a-zA-Z0-9]{8,18}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:password] == NO) {
        [ShowHUDTool showBriefAlert:@"密码只能由8-18位英文或数字构成"];
        return NO;
    }
    return YES;
}

#pragma mark - System Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.setPasswordTextField])
    {
        [self.confirmPasswordField becomeFirstResponder];
    }
    else if ([textField isEqual:self.confirmPasswordField])
    {
        if ([self.setPasswordTextField.text isEqualToString:self.confirmPasswordField.text]) {
            [textField resignFirstResponder];
        } else {
            [ShowHUDTool showBriefAlert:@"两次输入密码不一致"];
        }
        [textField resignFirstResponder];
    }else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * str = [NSMutableString stringWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];

    if ([string isEqualToString:@" "])
    {
        return NO;
    }
    
    if ([textField isEqual:self.verifyCodeTextField])
    {
        if (str.length > 6) { // 最多6位验证码
            return NO;
        }
        //匹配数字
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+$"];
        return [predicate evaluateWithObject:str] ? YES : NO;
    }
    
    if ([textField isEqual:self.setPasswordTextField] || [textField isEqual:self.confirmPasswordField])
    {
        return str.length <= 18;    // 最多18位密码
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    [self checkFootButtonStatus];
}

#pragma mark - Getter

- (LiteAlertLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        _alertLabel.titleLabel.text = [NSString stringWithFormat:@"请使用 %@ 查收验证码",[BHUserModel sharedInstance].mobile];
    }
    return _alertLabel;
}

- (UIView *)verifyCodeView{
    if (!_verifyCodeView) {
        _verifyCodeView = [[UIView alloc] init];
        _verifyCodeView.backgroundColor = UIColorWhite;
    }
    return _verifyCodeView;
}

- (UIView *)setPasswordView{
    if (!_setPasswordView) {
        _setPasswordView = [[UIView alloc] init];
        _setPasswordView.backgroundColor = UIColorWhite;
    }
    return _setPasswordView;
}

- (UIView *)confirmPasswordView{
    if (!_confirmPasswordView) {
        _confirmPasswordView = [[UIView alloc] init];
        _confirmPasswordView.backgroundColor = UIColorWhite;
    }
    return _confirmPasswordView;
}

- (UIView *)lineView1{
    if (!_lineView1) {
        _lineView1 = [[UIView alloc] init];
        _lineView1.backgroundColor = UIColorLine;
    }
    return _lineView1;
}

- (UIView *)lineView2{
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = UIColorLine;
    }
    return _lineView2;
}

- (UILabel *)verifyCodeLabel{
    if (!_verifyCodeLabel) {
        _verifyCodeLabel = [[UILabel alloc] init];
        _verifyCodeLabel.text = @"短信验证码";
        _verifyCodeLabel.font = [UIFont systemFontOfSize:14];
        _verifyCodeLabel.textColor = UIColorDrakBlackText;
    }
    return _verifyCodeLabel;
}
- (UILabel *)setPasswordLabel{
    if (!_setPasswordLabel) {
        _setPasswordLabel = [[UILabel alloc] init];
        _setPasswordLabel.text = @"新密码";
        _setPasswordLabel.font = [UIFont systemFontOfSize:14];
        _setPasswordLabel.textColor = UIColorDrakBlackText;
    }
    return _setPasswordLabel;
}
- (UILabel *)confirmPasswordLabel{
    if (!_confirmPasswordLabel) {
        _confirmPasswordLabel = [[UILabel alloc] init];
        _confirmPasswordLabel.text = @"确认新密码";
        _confirmPasswordLabel.font = [UIFont systemFontOfSize:14];
        _confirmPasswordLabel.textColor = UIColorDrakBlackText;
    }
    return _confirmPasswordLabel;
}

- (UITextField *)verifyCodeTextField
{
    if (!_verifyCodeTextField)
    {
        _verifyCodeTextField = [[UITextField alloc] init];
        _verifyCodeTextField.textColor = UIColorDrakBlackText;
        _verifyCodeTextField.textAlignment = NSTextAlignmentRight;
        _verifyCodeTextField.font = [UIFont systemFontOfSize:14];
        _verifyCodeTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入验证码" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        _verifyCodeTextField.borderStyle = UITextBorderStyleNone;
        _verifyCodeTextField.returnKeyType = UIReturnKeyDone;
        _verifyCodeTextField.keyboardType = UIKeyboardTypeNumberPad;
        _verifyCodeTextField.delegate = self;
        [_verifyCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _verifyCodeTextField;
}

- (UITextField *)setPasswordTextField
{
    if (!_setPasswordTextField)
    {
        _setPasswordTextField = [[UITextField alloc] init];
        _setPasswordTextField.textColor = UIColorDrakBlackText;
        _setPasswordTextField.textAlignment = NSTextAlignmentRight;
        _setPasswordTextField.font = [UIFont systemFontOfSize:14];
        _setPasswordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入新密码" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        _setPasswordTextField.borderStyle = UITextBorderStyleNone;
        _setPasswordTextField.returnKeyType = UIReturnKeyNext;
//        _setPasswordTextField.secureTextEntry = YES;
        _setPasswordTextField.delegate = self;
        [_setPasswordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _setPasswordTextField;
}

- (UITextField *)confirmPasswordField
{
    if (!_confirmPasswordField)
    {
        _confirmPasswordField = [[UITextField alloc] init];
        _confirmPasswordField.textColor = UIColorDrakBlackText;
        _confirmPasswordField.textAlignment = NSTextAlignmentRight;
        _confirmPasswordField.font = [UIFont systemFontOfSize:14];
        _confirmPasswordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请再次输入新密码" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        _confirmPasswordField.borderStyle = UITextBorderStyleNone;
        _confirmPasswordField.returnKeyType = UIReturnKeyDone;
//        _confirmPasswordField.secureTextEntry = YES;
        _confirmPasswordField.delegate = self;
        [_confirmPasswordField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _confirmPasswordField;
}

- (UIButton *)sendVerifyCodeButton{
    if (!_sendVerifyCodeButton) {
        _sendVerifyCodeButton = [[UIButton alloc] init];
        _sendVerifyCodeButton.backgroundColor = [UIColor clearColor];
        _sendVerifyCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendVerifyCodeButton.titleLabel.textAlignment = NSTextAlignmentCenter;[_sendVerifyCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_sendVerifyCodeButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
        [_sendVerifyCodeButton addTarget:self action:@selector(sendVerifyCode:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendVerifyCodeButton;
}

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.backgroundColor = UIColorlightGray;
        _confirmButton.userInteractionEnabled = NO;
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.layer.cornerRadius = 3.0f;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _confirmButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
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
