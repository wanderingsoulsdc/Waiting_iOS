//
//  BHRegisterSetPWViewController.m
//  Waiting_iOS
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/6/10.
//  Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHRegisterSetPWViewController.h"
#import <Masonry/Masonry.h>
#import "BHRegisterSuccessViewController.h"
#import "FSNetWorkManager.h"
#import "ShowHUDTool.h"
#import "BHUserModel.h"
#import "FSDeviceManager.h"

@interface BHRegisterSetPWViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel     * remindLabel;
@property (nonatomic, strong) UITextField * passwordTextField;
@property (nonatomic, strong) UIButton    * commitButton;
@property (nonatomic, strong) UIImageView * tipsImageView;

@end

@implementation BHRegisterSetPWViewController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.type == ResetPassWordTypeRegister ? @"设置登录密码" : @"重置登录密码";
    self.view.backgroundColor = UIColorFromRGB(0xFAFAFA);
    // You should add subviews here, just add subviews
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.remindLabel];
    [self.view addSubview:self.commitButton];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.passwordTextField becomeFirstResponder];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    
    [self.passwordTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.height.equalTo(@50);
    }];
    
    [self.tipsImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(12);
        make.height.width.equalTo(@16);
    }];
    
    [self.remindLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(self.tipsImageView.mas_right).offset(6);
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(10);
        make.height.equalTo(@20);
    }];
    
    [self.commitButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.remindLabel.mas_bottom).offset(30);
        make.left.equalTo(self.view).offset(40);
        make.right.equalTo(self.view).offset(-40);
        make.height.equalTo(@40);
    }];
}

#pragma mark - SystemDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * str = [NSMutableString stringWithString:textField.text];
    [str replaceCharactersInRange:range withString:string];
    if (str.length > 0)
    {
        self.commitButton.backgroundColor = UIColorBlue;
        self.commitButton.userInteractionEnabled = YES;
    }
    else
    {
        self.commitButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
        self.commitButton.userInteractionEnabled = NO;
    }
    
    return YES;
}


#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

- (void)commitButtonAction:(UIButton *)sender
{
    NSLog(@"提交");
    [self.view endEditing:YES];
    if (![self isValid]) {
        return;
    }
    //去空格
    NSString * mobile = [self.mobileString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    sender.userInteractionEnabled = NO;
    NSDictionary * params = @{@"mobile":mobile, @"password":password, @"checkCode":self.verifyCodeString,@"token":self.token,@"version":[[FSDeviceManager sharedInstance] getAppVersion],@"device":[[FSDeviceManager sharedInstance] getDeviceID]};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:self.type == ResetPassWordTypeRegister ? kApiLoginRegister : kApiLoginForgetPW
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            sender.userInteractionEnabled = YES;
                            if (NetResponseCheckStaus)
                            {
                                BHRegisterSuccessViewController * registerSuccessViewController = [[BHRegisterSuccessViewController alloc] init];
                                
                                if (self.type == ResetPassWordTypeRegister) {
                                    [BHUserModel sharedInstance].token = self.token;
                                    registerSuccessViewController.token = self.token;
                                }
                                [BHUserModel sharedInstance].mobile = mobile;
                                [BHUserModel sharedInstance].passwd = password;
                                
                                [[BHUserModel sharedInstance] saveToDisk];
                                
                                
                                registerSuccessViewController.type = self.type;
                                [self.navigationController pushViewController:registerSuccessViewController animated:YES];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            sender.userInteractionEnabled = YES;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}
- (void)passwordRightButtonAction:(UIButton *)sender
{
    NSLog(@"右侧按钮被点击");
    if (self.passwordTextField.secureTextEntry == YES)
    {
        [sender setImage:[UIImage imageNamed:@"login_eye_open"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = NO;
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"login_eye_close"] forState:UIControlStateNormal];
        self.passwordTextField.secureTextEntry = YES;
    }
    
}

#pragma mark - Private methods
//内容校验
- (BOOL)isValid
{
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([password length] < 8)
    {
        [ShowHUDTool showBriefAlert:@"密码不能少于8位"];
        return NO;
    }
    else if([password length] > 18)
    {
        [ShowHUDTool showBriefAlert:@"密码不能多于18位"];
        return NO;
    }
    
    NSString *regex =@"[a-zA-Z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:password] == NO) {
        [ShowHUDTool showBriefAlert:@"密码只允许字母或数字"];
        return NO;
    }
    return YES;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UIImageView *)tipsImageView{
    if (!_tipsImageView)
    {
        _tipsImageView = [[UIImageView alloc] init];
        _tipsImageView.image = [UIImage imageNamed:@"login_warning"];
        _tipsImageView.contentMode = UIViewContentModeScaleAspectFit;;
    }
    return _tipsImageView;
}

- (UILabel *)remindLabel
{
    if (!_remindLabel)
    {
        _remindLabel = [[UILabel alloc] init];
        _remindLabel.text = @"登录密码由8~18位英文字母或数字组成";
        _remindLabel.textAlignment = NSTextAlignmentLeft;
        _remindLabel.textColor = UIColorFromRGB(0x969696);
        _remindLabel.font = [UIFont systemFontOfSize:13];
    }
    return _remindLabel;
}
- (UITextField *)passwordTextField
{
    if (!_passwordTextField)
    {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.textColor = UIColorFromRGB(0x7F93A4);
        _passwordTextField.textAlignment = NSTextAlignmentRight;
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xD3D9DF)}];
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.delegate = self;
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"设置密码";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDarkBlack;
        leftLabel.frame = CGRectMake(0, 0, 70, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _passwordTextField.leftView = leftLabel;
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIButton * rightButton = [[UIButton alloc] init];
        rightButton.frame = CGRectMake(0, 0, 50, 50);
        [rightButton setImage:[UIImage imageNamed:@"login_eye_open"] forState:UIControlStateNormal];
        rightButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [rightButton addTarget:self action:@selector(passwordRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _passwordTextField.rightView = rightButton;
        _passwordTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}
- (UIButton *)commitButton
{
    if (!_commitButton)
    {
        _commitButton = [[UIButton alloc] init];
        _commitButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
        _commitButton.userInteractionEnabled = NO;
        [_commitButton setTitle:@"提交" forState:UIControlStateNormal];
        [_commitButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _commitButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _commitButton.layer.cornerRadius = 2;
        _commitButton.clipsToBounds = YES;
        [_commitButton addTarget:self action:@selector(commitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitButton;
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
