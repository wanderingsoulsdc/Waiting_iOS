//
//  BHLoginViewController.m
//  Customer
//
//  Created by ChenQiuLiang on 2017/5/11.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHLoginViewController.h"
#import "BHRegisterViewController.h"
#import "Masonry/Masonry.h"
#import "FSLaunchManager.h"
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "JPUSHService.h"
#import "FSDeviceManager.h"
#import "FSPushManager.h"
#import "BHAgreementViewController.h"
#import "NSString+Helper.h"
#import "IQKeyboardManager/IQKeyboardManager.h"
#import "YYKit.h"

@interface BHLoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView * bgImageView;
@property (nonatomic, strong) UIView      * bgView;
@property (nonatomic, strong) UIImageView * logoImageView;
@property (nonatomic, strong) UITextField * userNameTextField;
@property (nonatomic, strong) UITextField * passwordTextField;
@property (nonatomic, strong) UIButton    * forgetButton;
@property (nonatomic, strong) UIButton    * loginButton;
@property (nonatomic, strong) UIButton    * registerButton;
@property (nonatomic, assign) BOOL          userNameNotNull;
@property (nonatomic, assign) BOOL          passWordNotNull;

@property (nonatomic, strong) NSString    * token;
@property (nonatomic, assign) BOOL        isTokenRequesting;//是否正在请求token
@end

@implementation BHLoginViewController

- (void)dealloc
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isTokenRequesting = NO;
    //如果本地不存在token
    if (!kStringNotNull(self.token)&&!kStringNotNull([BHUserModel sharedInstance].token)) {
        [self requestUserToken];
    }
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    _userNameNotNull = NO;
    _passWordNotNull = NO;
    
    [self.view addSubview:self.bgImageView];
    [self.bgView addSubview:self.logoImageView];
    [self.bgView addSubview:self.userNameTextField];
    [self.bgView addSubview:self.passwordTextField];
    [self.bgView addSubview:self.forgetButton];
    [self.bgView addSubview:self.loginButton];
    [self.bgView addSubview:self.registerButton];
    [self.view addSubview:self.bgView];

    // layout subviews
    [self layoutSubviews];
    
    // You should add notification here
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [IQKeyboardManager sharedManager].enable = YES;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [IQKeyboardManager sharedManager].enable = NO;

    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

//页面布局
- (void)layoutSubviews
{
    [self.bgImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(-5);
        make.bottom.right.equalTo(self.view).offset(5);
    }];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-55);
        make.height.equalTo(@365);
    }];
    
    [self.logoImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView);
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-90);
        make.height.equalTo(self.logoImageView.mas_width).multipliedBy(1.0/3.1);
    }];
    [self.userNameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(60);
        make.height.equalTo(@40);
        make.left.equalTo(self.bgView).offset(40);
        make.right.equalTo(self.bgView).offset(-40);
    }];
    [self.passwordTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameTextField.mas_bottom).offset(20);
        make.left.height.right.equalTo(self.userNameTextField);
    }];
    
    [self.loginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(40);
        make.left.equalTo(self.passwordTextField);
        make.right.equalTo(self.passwordTextField);
        make.height.equalTo(@48);
    }];
    [self.registerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom).offset(15);
        make.left.equalTo(self.loginButton);
        make.height.equalTo(@20);
        make.width.equalTo(@80);
    }];
    
    [self.forgetButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom).offset(15);
        make.right.equalTo(self.loginButton);
        make.width.equalTo(@80);
        make.height.equalTo(@20);
    }];
}


#pragma mark - System Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.userNameTextField])
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else
    {
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
    if ([textField isEqual:self.userNameTextField])
    {
        return str.length <= 11;    // 最多11位
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{

    if ([textField isEqual:self.userNameTextField]) {
        if (kStringNotNull(textField.text)) {
            _userNameNotNull = YES ;
        } else {
            _userNameNotNull = NO ;
        }
    }else{
        if (kStringNotNull(textField.text)) {
            _passWordNotNull = YES ;
        } else {
            _passWordNotNull = NO ;
        }
    }
    
    if (_userNameNotNull && _passWordNotNull) {
        self.loginButton.backgroundColor = UIColorBlue;
        self.loginButton.userInteractionEnabled = YES;
    }else{
        self.loginButton.backgroundColor = UIAlplaColorFromRGB(0xFFFFFF,0.2);
        self.loginButton.userInteractionEnabled = NO;
    }
}

#pragma mark - Notification Events
- (void)keyboardWillShow:(NSNotification *)notification
{
//    [UIView animateWithDuration:0.25 animations:^{
//        self.view.frame = CGRectMake(0, -80, self.view.frame.size.width, self.view.frame.size.height);
//    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
//    [UIView animateWithDuration:0.25 animations:^{
//        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//    }];
}

#pragma mark - Action

//
- (void)loginButtonAction:(UIButton *)sender
{
    if (self.isTokenRequesting) {
        return;
    }
    
    if (!kStringNotNull(self.token)) {
        [ShowHUDTool showBriefAlert:@"努力登录中~"];
        [self requestUserToken];
        return;
    }
    
    NSLog(@"登录");
    [self.view endEditing:YES];
    
    if (![self isValid]) return;
    NSString * mobile = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    [ShowHUDTool showLoading];
    NSDictionary * params = @{@"mobile":mobile,
                              @"password":password,
                              @"token":self.token,
                              @"idfa":[[FSDeviceManager sharedInstance] getDeviceID],
                              @"appVersion":[[FSDeviceManager sharedInstance] getAppVersion],
                              @"system":[[FSDeviceManager sharedInstance] getSystemName],
                              @"systemVersion":[[FSDeviceManager sharedInstance] getSystemVersion],
                              @"deviceName":[[FSDeviceManager sharedInstance] getDeviceModel],
                              @"netType":[[FSDeviceManager sharedInstance] getNetType],
                              @"carrierName":[[FSDeviceManager sharedInstance] getCarrierName],
                              @"deviceModel":[[FSDeviceManager sharedInstance] getDeviceModel],
                              };
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiLogin
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            [ShowHUDTool hideAlert];
                            
                            if (NetResponseCheckStaus)
                            {
                                [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object Mobile:mobile Passwd:password Token:self.token];
                                NSInteger deviceNum = [object[@"data"][@"deviceNum"] integerValue];
                            
                                [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];

                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            [ShowHUDTool hideAlert];
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}
- (void)forgetButtonAction:(UIButton *)sender
{
    if (self.isTokenRequesting) {
        return;
    }
    if (kStringNotNull(self.token)) {
        NSLog(@"忘记密码");
        BHRegisterViewController * registerViewController = [[BHRegisterViewController alloc] init];
        registerViewController.type = ResetPassWordTypeForget;
        registerViewController.token = self.token;
        [self.navigationController pushViewController:registerViewController animated:YES];
    }else{
        [ShowHUDTool showBriefAlert:@"努力连接中，请您稍后再试~"];
        [self requestUserToken];
    }
}
- (void)registerButtonAction:(UIButton *)sender
{
    if (self.isTokenRequesting) {
        return;
    }
    if (kStringNotNull(self.token)) {
        NSLog(@"注册");
        BHRegisterViewController * registerViewController = [[BHRegisterViewController alloc] init];
        registerViewController.type = ResetPassWordTypeRegister;
        registerViewController.token = self.token;
        [self.navigationController pushViewController:registerViewController animated:YES];
    }else{
        [ShowHUDTool showBriefAlert:@"努力连接中，请您稍后再试~"];
        [self requestUserToken];
    }
    NSLog(@"注册");
}

//账号&密码右侧清除按钮  账号tag：1001 密码tag：1002
- (void)textFieldContentClear:(UIButton *)button{
    if (button.tag == 1001) {
        _userNameTextField.text = @"";
        _userNameNotNull = NO ;
        _passwordTextField.text = @"";
        _passWordNotNull = NO ;
    } else {
        _passwordTextField.text = @"";
        _passWordNotNull = NO ;
    }
    self.loginButton.backgroundColor = UIAlplaColorFromRGB(0xFFFFFF,0.3);
    self.loginButton.userInteractionEnabled = NO;
}

#pragma mark - Private methods
//内容校验
- (BOOL)isValid
{
    NSString * mobile = [self.userNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([mobile length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"用户名不能为空"];
        return NO;
    }
    else if([password length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"密码不能为空"];
        return NO;
    }
    
    if (![mobile checkMobileNumber]) {
        [ShowHUDTool showBriefAlert:@"请输入正确的手机号码"];
        return NO;
    }else{
        NSString *regex =@"[a-zA-Z0-9]{8,18}";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        if ([pred evaluateWithObject:password] == NO) {
            [ShowHUDTool showBriefAlert:@"密码只能由8-18位英文或数字构成"];
            return NO;
        }
    }
    return YES;
}
//请求用户token
- (void)requestUserToken
{
    if (self.isTokenRequesting) {
        return;
    }
    NSDictionary * params = @{@"source":@"11",@"time":[self getTimestampFromCurrentTime],@"secret":[self getMD5Encrypt]};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginGetToken
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求token成功");
                             NSDictionary *dic = object[@"data"];
                             self.token = dic[@"token"];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         self.isTokenRequesting = NO;
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                         self.isTokenRequesting = NO;
                     }];
}

#pragma mark - 获取接口参数
//md5(本地秘钥+当前时间戳)

- (NSString *)getMD5Encrypt{
    NSString *string = [NSString stringWithFormat:@"%@%@",kTokenLocalKey,[self getTimestampFromCurrentTime]];
    return [string md5String];
}


//获取当前时间的 时间戳
- (NSString *)getTimestampFromCurrentTime{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];// ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    //设置时区,这个对于时间的处理有时很重要
    //例如你在国内发布信息,用户在国外的另一个时区,你想让用户看到正确的发布时间就得注意时区设置,时间的换算.
    //例如你发布的时间为2010-01-26 17:40:50,那么在英国爱尔兰那边用户看到的时间应该是多少呢?
    //他们与我们有7个小时的时差,所以他们那还没到这个时间呢...那就是把未来的事做了
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *nowtimeStr = [formatter stringFromDate:datenow];//----------将nsdate按formatter格式转成nsstring
    
    NSLog(@"%@", nowtimeStr);
    
    // 时间转时间戳的方法:
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    NSLog(@"timeSp:%@",timeSp);//时间戳的值
    
    return timeSp;
}

#pragma mark - Getter

- (UIImageView *)bgImageView
{
    if (!_bgImageView)
    {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"login_bg"];
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _bgImageView;
}

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = UIColorClearColor;
    }
    return _bgView;
}


- (UIImageView * )logoImageView
{
    if (!_logoImageView)
    {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.image = [UIImage imageNamed:@"login_logo"];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _logoImageView;
}
- (UITextField *)userNameTextField
{
    if (!_userNameTextField)
    {
        _userNameTextField = [[UITextField alloc] init];
        _userNameTextField.textColor = UIColorFromRGB(0x7F93A4);
        _userNameTextField.textAlignment = NSTextAlignmentLeft;
        _userNameTextField.font = [UIFont systemFontOfSize:14];
        _userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入账号" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xD6D6D6)}];
        _userNameTextField.borderStyle = UITextBorderStyleNone;
        _userNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userNameTextField.returnKeyType = UIReturnKeyNext;
        _userNameTextField.keyboardType = UIKeyboardTypeNumberPad;
        _userNameTextField.delegate = self;
        [_userNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        UIButton * rightView = [[UIButton alloc] init];
        rightView.tag = 1001;
        rightView.frame = CGRectMake(0, 0, 30, 30);
        [rightView setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
        [rightView addTarget:self action:@selector(textFieldContentClear:) forControlEvents:UIControlEventTouchUpInside];
        _userNameTextField.rightView = rightView;
        _userNameTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width-80, 1);
        lineView.backgroundColor = UIColorFromRGB(0xEFEFEF);
        [_userNameTextField addSubview:lineView];
    }
    return _userNameTextField;
}
- (UITextField *)passwordTextField
{
    if (!_passwordTextField)
    {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.textColor = UIColorFromRGB(0x7F93A4);
        _passwordTextField.textAlignment = NSTextAlignmentLeft;
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入密码" attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0xD6D6D6)}];
        _passwordTextField.borderStyle = UITextBorderStyleNone;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.delegate = self;
        [_passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UIButton * rightView = [[UIButton alloc] init];
        rightView.tag = 1002;
        rightView.frame = CGRectMake(0, 0, 30, 30);
        [rightView setImage:[UIImage imageNamed:@"login_clear"] forState:UIControlStateNormal];
        [rightView addTarget:self action:@selector(textFieldContentClear:) forControlEvents:UIControlEventTouchUpInside];
        _passwordTextField.rightView = rightView;
        _passwordTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        
        UIView * lineView = [[UIView alloc] init];
        lineView.frame = CGRectMake(0, 39, [UIScreen mainScreen].bounds.size.width-80, 1);
        lineView.backgroundColor = UIColorFromRGB(0xEFEFEF);
        [_passwordTextField addSubview:lineView];
    }
    return _passwordTextField;
}
- (UIButton *)forgetButton
{
    if (!_forgetButton)
    {
        _forgetButton = [[UIButton alloc] init];
        _forgetButton.backgroundColor = [UIColor clearColor];
        [_forgetButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
        [_forgetButton setTitleColor:UIColorFromRGB(0x96A4B3) forState:UIControlStateNormal];
        _forgetButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _forgetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;    // 文字右对齐
        [_forgetButton addTarget:self action:@selector(forgetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forgetButton;
}
- (UIButton *)loginButton
{
    if (!_loginButton)
    {
        _loginButton = [[UIButton alloc] init];
        _loginButton.backgroundColor = UIAlplaColorFromRGB(0xFFFFFF,0.2);
        self.loginButton.userInteractionEnabled = YES;
        [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:UIColorFromRGB(0xFFFFFF) forState:UIControlStateNormal];
        _loginButton.userInteractionEnabled = NO;
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _loginButton.layer.cornerRadius = 2;
        _loginButton.clipsToBounds = YES;
        [_loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginButton;
}
- (UIButton *)registerButton
{
    if (!_registerButton)
    {
        _registerButton = [[UIButton alloc] init];
        _registerButton.backgroundColor = [UIColor clearColor];
        [_registerButton setTitle:@"注册新用户" forState:UIControlStateNormal];
        [_registerButton setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _registerButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _registerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;    // 文字左对齐
        [_registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _registerButton;
}

#pragma mark -

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
