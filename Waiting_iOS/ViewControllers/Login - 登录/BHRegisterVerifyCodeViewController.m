//
//  BHRegisterVerifyCodeViewController.m
//  Waiting_iOS
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/6/9.
//  Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHRegisterVerifyCodeViewController.h"
#import <Masonry/Masonry.h>
#import "WLUnitField.h"
#import "BHRegisterSetPWViewController.h"
#import "FSNetWorkManager.h"
#import "UIButton+countdown.h"
#import "NSString+Helper.h"

@interface BHRegisterVerifyCodeViewController () <WLUnitFieldDelegate>

@property (nonatomic, strong) UILabel     * mobileLabel;
@property (nonatomic, strong) WLUnitField * verifyCodeField;
@property (nonatomic, strong) UIButton    * nextButton;
@property (nonatomic, strong) UIButton    * sendMessageButton;

@end

@implementation BHRegisterVerifyCodeViewController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"填写验证码";
    self.view.backgroundColor = UIColorFromRGB(0xFAFAFA);
    // You should add subviews here, just add subviews
    [self.view addSubview:self.mobileLabel];
    [self.view addSubview:self.verifyCodeField];
    [self.view addSubview:self.nextButton];
    [self.view addSubview:self.sendMessageButton];
    
    // You should add notification here
    
    // layout subviews
    [self layoutSubviews];
    
    [self setSendButtonTimer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.verifyCodeField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    [self.mobileLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(30);
        make.height.equalTo(@20);
    }];
    [self.verifyCodeField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mobileLabel.mas_bottom).offset(25);
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.height.equalTo(@50);
    }];
    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.top.equalTo(self.verifyCodeField.mas_bottom).offset(50);
        make.height.equalTo(@40);
    }];
    [self.sendMessageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.nextButton.mas_bottom).offset(20);
        make.height.equalTo(@20);
    }];
}

#pragma mark - SystemDelegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.verifyCodeField resignFirstResponder];
}

#pragma mark - CustomDelegate

- (BOOL)unitField:(WLUnitField *)uniField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString * str = [NSMutableString stringWithString:uniField.text];
    [str replaceCharactersInRange:range withString:string];
    if (str.length == 6)
    {
        self.nextButton.backgroundColor = UIColorBlue;
        self.nextButton.userInteractionEnabled = YES;
    }
    else
    {
        self.nextButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
        self.nextButton.userInteractionEnabled = NO;
        _verifyCodeField.trackTintColor = UIColorFromRGB(0x4895F2); //已输入边框颜色
    }
    
    return YES;
}

#pragma mark - Event response
// button、gesture, etc

- (void)sendMessageButtonAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    NSLog(@"发送验证码");
    
    //去空格
    NSString * mobile = [self.mobileString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![mobile checkMobileNumber])
    {
        [ShowHUDTool showBriefAlert:@"请输入正确的手机号码"];
        return;
    }
    
    NSDictionary * params = @{@"mobile":mobile, @"type":self.type == ResetPassWordTypeRegister ? @"1":@"2",@"token":self.token};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginGetVerCode
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            
                            if (NetResponseCheckStaus)
                            {
                                [self.sendMessageButton setAttributedTitle:nil forState:UIControlStateNormal];
                                JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
                                setting.strPrefix = @"";
                                setting.strSuffix = @"s 后重发短信";
                                setting.strCommon = @"收不到验证码？重发短信";
                                setting.indexStart = 60;
                                setting.colorDisable = [UIColor clearColor];
                                setting.colorCommon = [UIColor clearColor];
                                setting.colorTitleDisable = UIColorFromRGB(0x969696);
                                setting.attributeString = @"s";
                                setting.attributeColor = UIColorFromRGB(0x5595DF);
                                NSString * registerString = @"收不到验证码？重发短信";
                                NSString * registerAttributeString = @"重发短信";
                                NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:registerString];
                                [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x199CDC) range:NSMakeRange(registerString.length - registerAttributeString.length, registerAttributeString.length)];
                                setting.attributedTitle = mutableAttributedString;
                                [self.sendMessageButton startWithSetting:setting];
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
- (void)nextButtonAction:(UIButton *)sender
{
    NSLog(@"下一步");
    NSLog(@"verifyCode is %@", self.verifyCodeField.text);
    [self.view endEditing:YES];
    
    if (self.verifyCodeField.text.length != 6)
    {
        [ShowHUDTool showBriefAlert:@"请输入验证码"];
        return;
    }
    //去空格
    sender.userInteractionEnabled = NO;
    NSString * mobile = [self.mobileString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSDictionary * params = @{@"checkCode":self.verifyCodeField.text,
                              @"mobile":mobile,
                              @"type":self.type == ResetPassWordTypeRegister ? @"1" : @"2",@"token":self.token};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiLoginCheckVerCode
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            sender.userInteractionEnabled = YES;
                            if (NetResponseCheckStaus)
                            {
                                BHRegisterSetPWViewController * setPWViewController = [[BHRegisterSetPWViewController alloc] init];
                                setPWViewController.token = self.token;
                                setPWViewController.type = self.type;
                                setPWViewController.mobileString = self.mobileString;
                                setPWViewController.verifyCodeString = self.verifyCodeField.text;
                                [self.navigationController pushViewController:setPWViewController animated:YES];
                            }
                            else
                            {
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                                self.nextButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
                                self.nextButton.userInteractionEnabled = NO;
                                self.verifyCodeField.trackTintColor = UIColorError; //已输入边框颜色 (输入错误变红框)

                            }
                            
                        } withFailureBlock:^(NSError *error) {
                            NSLog(@"error is %@", error);
                            self.nextButton.backgroundColor = UIColorFromRGB(0xCCCCCC);
                            self.nextButton.userInteractionEnabled = NO;
                            self.verifyCodeField.trackTintColor = UIColorError; //已输入边框颜色 (输入错误变红框)
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

#pragma mark - Private methods

//设置发送验证码按钮倒计时
- (void)setSendButtonTimer{
    
    [self.sendMessageButton setAttributedTitle:nil forState:UIControlStateNormal];
    
    JxbScaleSetting* setting = [[JxbScaleSetting alloc] init];
    setting.strPrefix = @"";
    setting.strSuffix = @"s 后重发短信";
    setting.strCommon = @"收不到验证码？重发短信";
    setting.indexStart = 60;
    setting.colorDisable = [UIColor clearColor];
    setting.colorCommon = [UIColor clearColor];
    setting.colorTitleDisable = UIColorFromRGB(0x969696);
    setting.attributeString = @"s";
    setting.attributeColor = UIColorFromRGB(0x5595DF);
    
    NSString * registerString = @"收不到验证码？重发短信";
    NSString * registerAttributeString = @"重发短信";
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:registerString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x199CDC) range:NSMakeRange(registerString.length - registerAttributeString.length, registerAttributeString.length)];
    
    setting.attributedTitle = mutableAttributedString;
    
    [self.sendMessageButton startWithSetting:setting];
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UILabel *)mobileLabel
{
    if (!_mobileLabel)
    {
        _mobileLabel = [[UILabel alloc] init];
        _mobileLabel.textColor = UIColorFromRGB(0x969696);
        _mobileLabel.textAlignment = NSTextAlignmentCenter;
        _mobileLabel.font = [UIFont systemFontOfSize:16];
        NSString * contentString = @"验证码已发送到手机";
        if (kStringNotNull(self.mobileString)) {
            NSArray *mobileArray = [self.mobileString componentsSeparatedByString:@" "];

            if (mobileArray.count == 3) {
                contentString = [NSString stringWithFormat:@"验证码已发送到%@%@%@",[mobileArray objectAtIndex:0] ,@"****",[mobileArray objectAtIndex:2]];
            } else {
                [NSString stringWithFormat:@"验证码已发送到%@%@%@", [self.mobileString substringToIndex:4],@"****",[self.mobileString substringFromIndex:7]];
            }
        } else {
            contentString = [NSString stringWithFormat:@"验证码已发送到%@", @"***********"];
        }
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:contentString];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x7F93A4) range:NSMakeRange(contentString.length - self.mobileString.length, self.mobileString.length)];
        [_mobileLabel setAttributedText:mutableAttributedString];

    }
    return _mobileLabel;
}
- (WLUnitField *)verifyCodeField
{
    if (!_verifyCodeField)
    {
        _verifyCodeField = [[WLUnitField alloc] init];
        _verifyCodeField.delegate = self;
        _verifyCodeField.secureTextEntry = NO;
        _verifyCodeField.unitSpace = 12;
        _verifyCodeField.trackTintColor = UIColorFromRGB(0x4895F2); //已输入边框颜色
        _verifyCodeField.textColor = UIColorDarkBlack;
        _verifyCodeField.cursorColor = UIColorFromRGB(0x6C8094);
        _verifyCodeField.tintColor = UIColorFromRGB(0xF0F0F0);      //未输入边框颜色
        _verifyCodeField.defaultReturnKeyType = UIReturnKeyDone;
    }
    return _verifyCodeField;
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
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _nextButton.layer.cornerRadius = 2;
        _nextButton.clipsToBounds = YES;
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
- (UIButton *)sendMessageButton
{
    if (!_sendMessageButton)
    {
        NSString * registerString = @"收不到验证码？重发短信";
        NSString * registerAttributeString = @"重发短信";
        _sendMessageButton = [[UIButton alloc] init];
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithString:registerString];
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x199CDC) range:NSMakeRange(registerString.length - registerAttributeString.length, registerAttributeString.length)];
        [_sendMessageButton setAttributedTitle:mutableAttributedString forState:UIControlStateNormal];
        _sendMessageButton.titleLabel.textColor = UIColorFromRGB(0x969696);
        _sendMessageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _sendMessageButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _sendMessageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _sendMessageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_sendMessageButton addTarget:self action:@selector(sendMessageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendMessageButton;
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
