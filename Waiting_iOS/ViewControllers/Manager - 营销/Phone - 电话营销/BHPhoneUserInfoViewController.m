//
//  BHMarketingPhoneUserInfoViewController.m
//  Treasure
//
//  Created by QiuLiang Chen QQ：1123548362 on 2018/1/8.
//Copyright © 2018年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHPhoneUserInfoViewController.h"
#import <Masonry/Masonry.h>
#import "NSString+Helper.h"
#import "UIButton+countdown.h"
#import "FSNetWorkManager.h"
#import "LiteAlertLabel.h"
#import "BHUserModel.h"

@interface BHPhoneUserInfoViewController () <UITextFieldDelegate>

@property (nonatomic, strong) LiteAlertLabel     * remindLabel;
@property (nonatomic, strong) UITextField * mobileTextField;
@property (nonatomic, strong) UITextField * nameTextField;
@property (nonatomic, strong) UITextField * idCardTextField;
@property (nonatomic, strong) UITextField * verifyCodeTextField;
@property (nonatomic, strong) UIButton    * verifyCodeButton;

@property (nonatomic, strong) UIView      * firstLineView;
@property (nonatomic, strong) UIView      * secondLineView;
@property (nonatomic, strong) UIView      * thirdLineView;
@property (nonatomic, strong) UIButton    * confirmButton;

@end

@implementation BHPhoneUserInfoViewController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"电话资料完善";
    self.view.backgroundColor = UIColorFromRGB(0xF4F4F4);
    
    // You should add subviews here, just add subviews
    [self.view addSubview:self.remindLabel];
    [self.view addSubview:self.nameTextField];
    [self.view addSubview:self.idCardTextField];
    [self.view addSubview:self.mobileTextField];
    [self.view addSubview:self.verifyCodeTextField];
    [self.view addSubview:self.firstLineView];
    [self.view addSubview:self.secondLineView];
    [self.view addSubview:self.thirdLineView];
    [self.view addSubview:self.confirmButton];
    
    // You should add notification here
    
    
    // layout subviews
    [self layoutSubviews];
    
    // init data
    NSString * ownPhoneNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNumberUserDefault];
    NSString * ownName = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneNameUserDefault];
    NSString * ownIDCard = [[NSUserDefaults standardUserDefaults] objectForKey:kOwnPhoneIDCardUserDefault];
    self.mobileTextField.text = ownPhoneNumber;
    self.nameTextField.text = ownName;
    self.idCardTextField.text = ownIDCard;
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

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.remindLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.top.equalTo(self.view).offset(10);
        make.height.equalTo(@30);
    }];
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.remindLabel.mas_bottom).offset(10);
        make.height.equalTo(@50);
    }];
    [self.idCardTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.nameTextField.mas_bottom);
        make.height.equalTo(@50);
    }];
    [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.idCardTextField.mas_bottom);
        make.height.equalTo(@50);
    }];
    [self.verifyCodeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mobileTextField.mas_bottom);
        make.height.equalTo(@50);
    }];
    [self.firstLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.nameTextField.mas_bottom);
        make.height.equalTo(@1);
    }];
    [self.secondLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.idCardTextField.mas_bottom);
        make.height.equalTo(@1);
    }];
    [self.thirdLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.mobileTextField.mas_bottom);
        make.height.equalTo(@1);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.verifyCodeTextField.mas_bottom).offset(60);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.equalTo(@40);
    }];
}

#pragma mark - SystemDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.mobileTextField])
    {
        [self.nameTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.nameTextField])
    {
        [self.idCardTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    [self checkConfirmButtonStatus];
}

#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

- (void)confirmButtonAction:(UIButton *)sender
{
    if (![self isValid]) return;
    
    NSString * mobile = [self.mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * idCard = [self.idCardTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * verifyCode = [self.verifyCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    sender.userInteractionEnabled = NO;
    
    NSDictionary * params = @{@"checkCode":verifyCode,
                              @"mobile":mobile,
                              @"type":@"4"};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginCheckVerCode
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            sender.userInteractionEnabled = YES;
                            if (NetResponseCheckStaus)
                            {
                                [[NSUserDefaults standardUserDefaults] setObject:mobile forKey:kOwnPhoneNumberUserDefault];
                                [[NSUserDefaults standardUserDefaults] setObject:name forKey:kOwnPhoneNameUserDefault];
                                [[NSUserDefaults standardUserDefaults] setObject:idCard forKey:kOwnPhoneIDCardUserDefault];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                                
                                if ([self.delegate respondsToSelector:@selector(finishedEditUserInfo)])
                                {
                                    [self.delegate finishedEditUserInfo];
                                    [self.navigationController popViewControllerAnimated:YES];
                                }
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

- (void)verifyEvent:(UIButton *)sender {
    
    [self.view endEditing:YES];
    NSLog(@"发送验证码");
    
    //去空格
    NSString * mobile = [self.mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![mobile checkMobileNumber])
    {
        [ShowHUDTool showBriefAlert:@"手机号格式不正确"];
        return;
    }
    
    JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
    setting.strPrefix = @"";
    setting.strSuffix = @"秒";
    setting.strCommon = @"重新获取";
    setting.indexStart = 60;
    setting.colorDisable = UIColorFromRGB(0xFFFFFF);
    setting.colorCommon = UIColorFromRGB(0xFFFFFF);
    setting.colorTitle = UIColorBlue;
    setting.colorTitleDisable = UIColorFromRGB(0x7F93A4);
    [self.verifyCodeButton startWithSetting:setting];
    
    NSDictionary * params = @{@"mobile":mobile, @"type":@"4",@"token":[BHUserModel sharedInstance].token};
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

#pragma mark - Private methods

- (void)checkConfirmButtonStatus{
    if (!kStringNotNull(_mobileTextField.text) && !kStringNotNull(_nameTextField.text) && !kStringNotNull(_idCardTextField.text) && !kStringNotNull(_verifyCodeTextField.text)) {
        _confirmButton.backgroundColor = UIColorlightGray;
        _confirmButton.userInteractionEnabled = NO;
    } else {
        _confirmButton.backgroundColor = UIColorBlue;
        _confirmButton.userInteractionEnabled = YES;
    }
}

- (BOOL)isValid
{
    NSString * mobile = [self.mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * idCard = [self.idCardTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * verifyCode = [self.verifyCodeTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if([mobile length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"手机号不能为空"];
        return NO;
    }
    else if([name length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"姓名不能为空"];
        return NO;
    }
    else if ([idCard length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"身份证号不能为空"];
        return NO;
    }
    else if ([verifyCode length] == 0)
    {
        [ShowHUDTool showBriefAlert:@"验证码不能为空"];
        return NO;
    }
    
    if (![mobile checkMobileNumber])
    {
        [ShowHUDTool showBriefAlert:@"输入正确的手机号"];
        return NO;
    }
    else if (![name checkName])
    {
        [ShowHUDTool showBriefAlert:@"输入正确的姓名"];
        return NO;
    }
    else if (![idCard checkIDCardNumber])
    {
        [ShowHUDTool showBriefAlert:@"输入正确的身份证号"];
        return NO;
    }
    return YES;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (LiteAlertLabel *)remindLabel
{
    if (!_remindLabel)
    {
        _remindLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        _remindLabel.titleLabel.text = @"请务必填写本机号码，否则会影响电话接通。";
    }
    return _remindLabel;
}
- (UITextField *)mobileTextField
{
    if (!_mobileTextField)
    {
        _mobileTextField = [[UITextField alloc] init];
        _mobileTextField.backgroundColor = [UIColor whiteColor];
        _mobileTextField.textColor = UIColorFromRGB(0x7F93A4);
        _mobileTextField.textAlignment = NSTextAlignmentRight;
        _mobileTextField.font = [UIFont systemFontOfSize:14];
        _mobileTextField.borderStyle = UITextBorderStyleNone;
        _mobileTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _mobileTextField.returnKeyType = UIReturnKeyNext;
        _mobileTextField.keyboardType = UIKeyboardTypeNumberPad;
        _mobileTextField.placeholder = @"请输入手机号";
        _mobileTextField.delegate = self;
        [_mobileTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"手机号码";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDrakBlackText;
        leftLabel.frame = CGRectMake(0, 0, 70, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _mobileTextField.leftView = leftLabel;
        _mobileTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView * rightView = [[UIView alloc] init];
        rightView.frame = CGRectMake(0, 0, 12, 50);
        _mobileTextField.rightView = rightView;
        _mobileTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _mobileTextField;
}
- (UITextField *)nameTextField
{
    if (!_nameTextField)
    {
        _nameTextField = [[UITextField alloc] init];
        _nameTextField.backgroundColor = [UIColor whiteColor];
        _nameTextField.textColor = UIColorFromRGB(0x7F93A4);
        _nameTextField.textAlignment = NSTextAlignmentRight;
        _nameTextField.font = [UIFont systemFontOfSize:14];
        _nameTextField.borderStyle = UITextBorderStyleNone;
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameTextField.returnKeyType = UIReturnKeyNext;
        _nameTextField.placeholder = @"请输入姓名";
        _nameTextField.delegate = self;
        [_nameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"姓名";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDrakBlackText;
        leftLabel.frame = CGRectMake(0, 0, 42, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _nameTextField.leftView = leftLabel;
        _nameTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView * rightView = [[UIView alloc] init];
        rightView.frame = CGRectMake(0, 0, 12, 50);
        _nameTextField.rightView = rightView;
        _nameTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _nameTextField;
}
- (UITextField *)idCardTextField
{
    if (!_idCardTextField)
    {
        _idCardTextField = [[UITextField alloc] init];
        _idCardTextField.backgroundColor = [UIColor whiteColor];
        _idCardTextField.textColor = UIColorFromRGB(0x7F93A4);
        _idCardTextField.textAlignment = NSTextAlignmentRight;
        _idCardTextField.font = [UIFont systemFontOfSize:14];
        _idCardTextField.borderStyle = UITextBorderStyleNone;
        _idCardTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _idCardTextField.returnKeyType = UIReturnKeyDone;
        _idCardTextField.placeholder = @"请输入身份证号";
        _idCardTextField.delegate = self;
        [_idCardTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"身份证号";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDrakBlackText;
        leftLabel.frame = CGRectMake(0, 0, 70, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _idCardTextField.leftView = leftLabel;
        _idCardTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView * rightView = [[UIView alloc] init];
        rightView.frame = CGRectMake(0, 0, 12, 50);
        _idCardTextField.rightView = rightView;
        _idCardTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _idCardTextField;
}

- (UITextField *)verifyCodeTextField
{
    if (!_verifyCodeTextField)
    {
        _verifyCodeTextField = [[UITextField alloc] init];
        _verifyCodeTextField.backgroundColor = [UIColor whiteColor];
        _verifyCodeTextField.textColor = UIColorFromRGB(0x7F93A4);
        _verifyCodeTextField.textAlignment = NSTextAlignmentRight;
        _verifyCodeTextField.font = [UIFont systemFontOfSize:14];
        _verifyCodeTextField.borderStyle = UITextBorderStyleNone;
        _verifyCodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _verifyCodeTextField.returnKeyType = UIReturnKeyDone;
        _verifyCodeTextField.placeholder = @"请输入验证码";
        _verifyCodeTextField.delegate = self;
        [_verifyCodeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        UILabel * leftLabel = [[UILabel alloc] init];
        leftLabel.text = @"短信验证码";
        leftLabel.font = [UIFont systemFontOfSize:14];
        leftLabel.textColor = UIColorDrakBlackText;
        leftLabel.frame = CGRectMake(0, 0, 85, 50);
        leftLabel.textAlignment = NSTextAlignmentRight;
        _verifyCodeTextField.leftView = leftLabel;
        _verifyCodeTextField.leftViewMode = UITextFieldViewModeAlways;
        
        UIView * rightView = [[UIView alloc] init];
        rightView.frame = CGRectMake(0, 0, 100, 50);
        UIView * lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
        lineView.frame = CGRectMake(5, 0, 1, 15);
        lineView.centerY = rightView.height/2;
        [rightView addSubview:lineView];
        self.verifyCodeButton.frame = CGRectMake(rightView.width - 90, 0, 90, rightView.height);
        [rightView addSubview:self.verifyCodeButton];
        _verifyCodeTextField.rightView = rightView;
        _verifyCodeTextField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _verifyCodeTextField;
}

- (UIView *)firstLineView
{
    if (!_firstLineView)
    {
        _firstLineView = [[UIView alloc] init];
        _firstLineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    }
    return _firstLineView;
}
- (UIView *)secondLineView
{
    if (!_secondLineView)
    {
        _secondLineView = [[UIView alloc] init];
        _secondLineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    }
    return _secondLineView;
}
- (UIView *)thirdLineView
{
    if (!_thirdLineView)
    {
        _thirdLineView = [[UIView alloc] init];
        _thirdLineView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    }
    return _thirdLineView;
}

- (UIButton *)confirmButton
{
    if (!_confirmButton)
    {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.backgroundColor = UIColorlightGray;
        _confirmButton.userInteractionEnabled = NO;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _confirmButton.layer.cornerRadius = 2;
        _confirmButton.clipsToBounds = YES;
        [_confirmButton addTarget:self action:@selector(confirmButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}
- (UIButton *)verifyCodeButton
{
    if (!_verifyCodeButton)
    {
        _verifyCodeButton = [[UIButton alloc] init];
        _verifyCodeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_verifyCodeButton setTitleColor:UIColorBlue forState:UIControlStateNormal];
        [_verifyCodeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_verifyCodeButton addTarget:self action:@selector(verifyEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _verifyCodeButton;
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
