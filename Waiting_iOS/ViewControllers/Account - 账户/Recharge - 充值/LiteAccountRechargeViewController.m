//
//  LiteAccountRechargeViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountRechargeViewController.h"
#import "LiteAlertLabel.h"
#import "Masonry.h"
#import "UIButton+countdown.h"
#import "WXApi.h"
#import "NSString+Helper.h"
#import <AlipaySDK/AlipaySDK.h>
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "LiteAccountQualificationViewController.h"

typedef enum : NSUInteger {
    UIAlertViewTagWeChat = 100,
    UIAlertViewTagAlipay,
} UIAlertViewTag;

@interface LiteAccountRechargeViewController ()<UITextFieldDelegate,WXApiDelegate, UIAlertViewDelegate>

@property (nonatomic , strong) NSDictionary     * wechatPrePayOrderDict;
@property (nonatomic , strong) NSDictionary     * prePayResponseDict;  // 没有资质继续支付

@property (nonatomic , strong) LiteAlertLabel   * alertLabel;
@property (nonatomic , strong) UIView           * rechargeNumView;
@property (nonatomic , strong) UIView           * wechatRechargeView;
@property (nonatomic , strong) UIView           * alipayRechargeView;

@property (nonatomic , strong) UIView           * lineView2; //横线

@property (nonatomic , strong) UIButton         * selectWechatButton;
@property (nonatomic , strong) UIButton         * wechatButton;         //扩大点击区域
@property (nonatomic , strong) UIButton         * alipayButton;         //扩大点击区域
@property (nonatomic , strong) UIButton         * selectAlipayButton;
@property (nonatomic , strong) UIButton         * rechargeButton;

@property (nonatomic , strong) UILabel          * rechargeNumLabel;
@property (nonatomic , strong) UILabel          * wechatLabel;
@property (nonatomic , strong) UILabel          * alipayLabel;

@property (nonatomic , strong) UITextField      * rechargeNumTextField;

@property (nonatomic , strong) UIImageView      * wechatImageview;
@property (nonatomic , strong) UIImageView      * alipayImageView;

@end

@implementation LiteAccountRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账号充值";
    
    [self creatUI];
    
    [self layoutSubviews];
    
    // You should add notification here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForAliPaymentResult:) name:kAliPayResaultNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationForWechatPaymentResult:) name:kWechatPayResaultNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.rechargeNumTextField resignFirstResponder];
}

//创建页面UI
- (void)creatUI{
    [self.view addSubview:self.alertLabel];
    [self.rechargeNumView addSubview:self.rechargeNumLabel];
    [self.rechargeNumView addSubview:self.rechargeNumTextField];
    [self.view addSubview:self.rechargeNumView];
    
    [self.wechatRechargeView addSubview:self.wechatLabel];
    [self.wechatRechargeView addSubview:self.wechatImageview];
    [self.wechatRechargeView addSubview:self.selectWechatButton];
    self.selectWechatButton.selected = YES;
    [self.wechatRechargeView addSubview:self.lineView2];
    [self.wechatRechargeView addSubview:self.wechatButton];
    [self.view addSubview:self.wechatRechargeView];
    
    [self.alipayRechargeView addSubview:self.alipayLabel];
    [self.alipayRechargeView addSubview:self.alipayImageView];
    [self.alipayRechargeView addSubview:self.selectAlipayButton];
    [self.alipayRechargeView addSubview:self.alipayButton];
    [self.view addSubview:self.alipayRechargeView];
    
    [self.view addSubview:self.rechargeButton];
    
}
//页面布局
- (void)layoutSubviews{
    
    [self.alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.height.equalTo(@32);
    }];
    [self.rechargeNumView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.alertLabel.mas_bottom).offset(12);
        make.height.equalTo(@60);
    }];
    [self.rechargeNumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rechargeNumView.mas_centerY);
        make.left.equalTo(self.rechargeNumView.mas_left).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];
    
    [self.rechargeNumTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.rechargeNumView.mas_centerY);
        make.right.equalTo(self.rechargeNumView.mas_right).offset(-12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@160);
    }];
    
    [self.wechatRechargeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.rechargeNumView.mas_bottom).offset(15);
        make.height.equalTo(@60);
    }];
    
    [self.wechatImageview mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.wechatRechargeView.mas_centerY);
        make.left.equalTo(self.wechatRechargeView.mas_left).offset(12);
        make.height.width.equalTo(@34);
    }];
    
    [self.wechatLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.wechatRechargeView.mas_centerY);
        make.left.equalTo(self.wechatImageview.mas_right).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];
    [self.selectWechatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.wechatRechargeView.mas_centerY);
        make.right.equalTo(self.wechatRechargeView.mas_right).offset(-12);
        make.height.width.equalTo(@14);
    }];
    
    [self.lineView2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(self.wechatRechargeView);
        make.left.equalTo(self.wechatRechargeView.mas_left).offset(8);
        make.height.equalTo(@0.5);
    }];
    
    [self.wechatButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.wechatRechargeView);
        make.top.bottom.equalTo(self.wechatRechargeView);
        make.width.equalTo(self.wechatRechargeView.mas_width).multipliedBy(1.0/2.0);
    }];
    
    [self.alipayRechargeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.wechatRechargeView.mas_bottom);
        make.height.equalTo(@60);
    }];
    
    [self.alipayImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.alipayRechargeView.mas_centerY);
        make.left.equalTo(self.alipayRechargeView.mas_left).offset(12);
        make.height.width.equalTo(@34);
    }];
    
    [self.alipayLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.alipayRechargeView.mas_centerY);
        make.left.equalTo(self.alipayImageView.mas_right).offset(12);
        make.height.equalTo(@40);
        make.width.greaterThanOrEqualTo(@60);
    }];
    [self.selectAlipayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.alipayRechargeView.mas_centerY);
        make.right.equalTo(self.alipayRechargeView.mas_right).offset(-12);
        make.height.width.equalTo(@14);
    }];
    
    [self.alipayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.alipayRechargeView);
        make.top.bottom.equalTo(self.alipayRechargeView);
        make.width.equalTo(self.alipayRechargeView.mas_width).multipliedBy(1.0/2.0);
    }];
    
    
    [self.rechargeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
        make.top.equalTo(self.alipayRechargeView.mas_bottom).offset(40);
        make.height.equalTo(@40);
    }];
    
}

#pragma mark - action

- (void)selectWechatOrAlipay:(UIButton *)button{
    
    [self.rechargeNumTextField resignFirstResponder];
    
    if (button == self.selectWechatButton || button == self.wechatButton) {
        self.selectWechatButton.selected = YES;
        self.selectAlipayButton.selected = NO;
        NSLog(@"选择微信支付");
    }else{
        self.selectWechatButton.selected = NO;
        self.selectAlipayButton.selected = YES;
        NSLog(@"选择支付宝支付");
    }
}
- (void)rechargeButtonAction:(UIButton *)button
{
    [self.rechargeNumTextField resignFirstResponder];

    if (!kStringNotNull(self.rechargeNumTextField.text)){
        [ShowHUDTool showBriefAlert:@"请输入充值金额"];
        return;
    }else{
        CGFloat moneyNum = [self.rechargeNumTextField.text doubleValue];
        if (moneyNum > 100000) {
            [ShowHUDTool showBriefAlert:@"单笔充值金额需要在1元到10万元以内"];
            return;
        }
        // APP
#if     TARGET_MODE==0           // 正式环境（Release）
        if (moneyNum < 1) {
            [ShowHUDTool showBriefAlert:@"单笔充值金额需要在1元到10万元以内"];
            return;
        }
#else
#endif
    }
    
    if (self.selectWechatButton.selected && !self.selectAlipayButton.selected) {
        NSLog(@"去微信支付");
        [self orderWithWechatAmount:self.rechargeNumTextField.text];
    }else if(!self.selectWechatButton.selected && self.selectAlipayButton.selected){
        NSLog(@"去支付宝支付");
        [self orderWithAlipayAmount:self.rechargeNumTextField.text];
    }
    
}
#pragma mark - Private methods
//请求账户余额
- (void)requestAccountMoney{
    [FSNetWorkManager   requestWithType:HttpRequestTypePost
                        withUrlString:[NSString string]
                        withParaments:nil
                        withSuccessBlock:^(NSDictionary *object) {
        
                        }
                        withFailureBlock:^(NSError *error) {
        
    }];
}

#pragma mark - Pay Method

- (void)orderWithWechatAmount:(NSString *)amount
{
    NSLog(@"微信支付");
    if (![WXApi isWXAppInstalled])
    {
        UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"您尚未安装微信，无法使用微信支付" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSDictionary * params = @{@"total_fee":amount};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiWechatGetSign
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             if ([object[@"info"] integerValue] == 100100100)
                             {
                                 self.prePayResponseDict = object;
                                 UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"没有上传资质充值金额产生的消耗不能开票" message:nil delegate:self cancelButtonTitle:@"完善资质" otherButtonTitles:@"继续支付", nil];
                                 alertView.tag = UIAlertViewTagWeChat;
                                 [alertView show];
                                 return;
                             }
                             NSDictionary * dict = [object objectForKey:@"data"];
                             NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                             //调起微信支付
                             PayReq* req             = [[PayReq alloc] init];
                             req.openID              = [dict objectForKey:@"appid"];
                             req.partnerId           = [dict objectForKey:@"partnerid"];
                             req.prepayId            = [dict objectForKey:@"prepayid"];
                             req.package             = [dict objectForKey:@"package"];
                             req.nonceStr            = [dict objectForKey:@"noncestr"];
                             req.timeStamp           = stamp.intValue;
                             req.sign                = [dict objectForKey:@"sign"];
                             [WXApi sendReq:req];
                             
                             self.wechatPrePayOrderDict = dict;
                             //日志输出
                             NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         
                     } withFailureBlock:^(NSError *error) {
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}
- (void)orderWithAlipayAmount:(NSString *)amount
{
    NSLog(@"支付宝支付");
    NSDictionary * params = @{@"total_fee":amount};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiAlipayGetSign
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {
                             if ([object[@"info"] integerValue] == 100100100)
                             {
                                 self.prePayResponseDict = object;
                                 UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:@"没有上传资质充值金额产生的消耗不能开票" message:nil delegate:self cancelButtonTitle:@"完善资质" otherButtonTitles:@"继续支付", nil];
                                 alertView.tag = UIAlertViewTagAlipay;
                                 [alertView show];
                                 return;
                             }
                             NSString * signData = [object objectForKey:@"data"];
                             [[AlipaySDK defaultService] payOrder:signData fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                                 [self dealWithAliPayResult:resultDic];
                             }];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                         
                     } withFailureBlock:^(NSError *error) {
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

- (void)notificationForAliPaymentResult:(NSNotification *)notification
{
    NSDictionary * resultDict = notification.userInfo;
    
    [self dealWithAliPayResult:resultDict];
}
- (void)notificationForWechatPaymentResult:(NSNotification *)notification
{
    NSDictionary * resultDict = notification.userInfo;
    
    [self dealWithWechatPayResult:resultDict];
}
- (void)dealWithAliPayResult:(NSDictionary *)payResultDict
{
    if([payResultDict[@"resultStatus"] isEqualToString:@"9000"])
    {
        NSLog(@"支付成功");
        // 去服务器验证支付结果
        [self checkAliPayResultWithPayResultDict:payResultDict];
    }
    else
    {
        NSLog(@"支付失败");
    }
}
- (void)dealWithWechatPayResult:(NSDictionary *)payResultDict
{
    if([payResultDict[@"resultStatus"] isEqualToString:@"9000"])
    {
        NSLog(@"支付成功");
        // 去服务器验证支付结果
        [self checkWechatPayResultWithPayResultDict:payResultDict];
    }
    else
    {
        NSLog(@"支付失败");
    }
}
- (void)checkAliPayResultWithPayResultDict:(NSDictionary *)payResultDict
{
    NSLog(@"校验支付结果");
    // 解析 auth code
    NSString * result = payResultDict[@"result"];
    NSDictionary * resultDict = [result dictionaryWithJsonString];
    NSString * out_trade_no = resultDict[@"alipay_trade_app_pay_response"][@"out_trade_no"];
    NSString * trade_no = resultDict[@"alipay_trade_app_pay_response"][@"trade_no"];
    
    NSDictionary * params = @{@"out_trade_no":out_trade_no, @"trade_no":trade_no};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiAlipayCheckStatus
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         if (NetResponseCheckStaus)
                         {
                             NSString * message = nil;
                             NSString * statusData = [object objectForKey:@"data"];
                             if ([statusData isEqualToString:@"WAIT_BUYER_PAY"])
                             {
                                 NSLog(@"交易创建，等待买家付款");
                                 message = @"交易创建，等待买家付款";
                             }
                             else if ([statusData isEqualToString:@"TRADE_CLOSED"])
                             {
                                 NSLog(@"未付款交易超时关闭，或支付完成后全额退款");
                                 message = @"未付款交易超时关闭，或支付完成后全额退款";
                             }
                             else if ([statusData isEqualToString:@"TRADE_SUCCESS"])
                             {
                                 NSLog(@"交易支付成功");
                                 message = @"交易支付成功";
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                             else if ([statusData isEqualToString:@"TRADE_FINISHED"])
                             {
                                 NSLog(@"交易结束，不可退款");
                                 message = @"交易结束，不可退款";
                             }
                             
                             /**
                              UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:message message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                              // 展示出来
                              [alertView show];
                              */
                             [ShowHUDTool showBriefAlert:message];
                             
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}
- (void)checkWechatPayResultWithPayResultDict:(NSDictionary *)payResultDict
{
    NSLog(@"校验支付结果");
    NSString * out_trade_no = self.wechatPrePayOrderDict[@"out_trade_no"];
    
    NSDictionary * params = @{@"out_trade_no":out_trade_no};
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiWechatCheckStatus
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         if (NetResponseCheckStaus)
                         {
                             NSString * message = nil;
                             NSString * statusData = [object objectForKey:@"data"];
                             if ([statusData isEqualToString:@"SUCCESS"])
                             {
                                 NSLog(@"支付成功");
                                 message = @"支付成功";
                                 [self.navigationController popViewControllerAnimated:YES];
                             }
                             else if ([statusData isEqualToString:@"REFUND"])
                             {
                                 NSLog(@"转入退款");
                                 message = @"转入退款";
                             }
                             else if ([statusData isEqualToString:@"NOTPAY"])
                             {
                                 NSLog(@"未支付");
                                 message = @"未支付";
                             }
                             else if ([statusData isEqualToString:@"CLOSED"])
                             {
                                 NSLog(@"已关闭");
                                 message = @"已关闭";
                             }
                             else if ([statusData isEqualToString:@"REVOKED"])
                             {
                                 NSLog(@"已撤销");
                                 message = @"已撤销";
                             }
                             else if ([statusData isEqualToString:@"USERPAYING"])
                             {
                                 NSLog(@"用户支付中");
                                 message = @"用户支付中";
                             }
                             else if ([statusData isEqualToString:@"PAYERROR"])
                             {
                                 NSLog(@"支付失败");
                                 message = @"支付失败";
                             }
                             
                             /**
                              UIAlertView * alertView=[[UIAlertView alloc]initWithTitle:message message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                              // 展示出来
                              [alertView show];
                              */
                             [ShowHUDTool showBriefAlert:message];
                             
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == UIAlertViewTagAlipay)
    {
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"完善资料");
                LiteAccountQualificationViewController * accountQualificationVC = [[LiteAccountQualificationViewController alloc] init];
                [self.navigationController pushViewController:accountQualificationVC animated:YES];
            }
                break;
            case 1:
            {
                NSLog(@"继续支付");
                NSString * signData = [self.prePayResponseDict objectForKey:@"data"];
                [[AlipaySDK defaultService] payOrder:signData fromScheme:kAppScheme callback:^(NSDictionary *resultDic) {
                    [self dealWithAliPayResult:resultDic];
                }];
            }
                break;
            default:
                break;
        }
    }
    else if (alertView.tag == UIAlertViewTagWeChat)
    {
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"完善资料");
                LiteAccountQualificationViewController * accountQualificationVC = [[LiteAccountQualificationViewController alloc] init];
                [self.navigationController pushViewController:accountQualificationVC animated:YES];
            }
                break;
            case 1:
            {
                NSLog(@"继续支付");
                NSDictionary * dict = [self.prePayResponseDict objectForKey:@"data"];
                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.openID              = [dict objectForKey:@"appid"];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.package             = [dict objectForKey:@"package"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.sign                = [dict objectForKey:@"sign"];
                [WXApi sendReq:req];
                
                self.wechatPrePayOrderDict = dict;
                //日志输出
                NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
            }
                break;
            default:
                break;
        }
    }
}


#pragma mark - System Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
    
    if (str.length > 9) {
        return NO;          // 100000.00 最多9位字符
    }
    //匹配两位小数
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(([1-9]{1}\\d*)|([0]{1}))(\\.(\\d){0,2})?$"];

    return [predicate evaluateWithObject:str] ? YES : NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    
}

#pragma mark - Getter

- (LiteAlertLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        [_alertLabel setAlertImageHidden:YES];
        _alertLabel.titleLabel.text = [NSString stringWithFormat:@"账户余额：%@",[BHUserModel sharedInstance].balance];
        _alertLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _alertLabel;
}

- (UIView *)rechargeNumView{
    if (!_rechargeNumView) {
        _rechargeNumView = [[UIView alloc] init];
        _rechargeNumView.backgroundColor = UIColorWhite;
    }
    return _rechargeNumView;
}

- (UIView *)wechatRechargeView{
    if (!_wechatRechargeView) {
        _wechatRechargeView = [[UIView alloc] init];
        _wechatRechargeView.backgroundColor = UIColorWhite;
    }
    return _wechatRechargeView;
}

- (UIView *)alipayRechargeView{
    if (!_alipayRechargeView) {
        _alipayRechargeView = [[UIView alloc] init];
        _alipayRechargeView.backgroundColor = UIColorWhite;
    }
    return _alipayRechargeView;
}

- (UIView *)lineView2{
    if (!_lineView2) {
        _lineView2 = [[UIView alloc] init];
        _lineView2.backgroundColor = UIColorLine;
    }
    return _lineView2;
}

- (UILabel *)rechargeNumLabel{
    if (!_rechargeNumLabel) {
        _rechargeNumLabel = [[UILabel alloc] init];
        _rechargeNumLabel.text = @"充值金额（元）";
        _rechargeNumLabel.font = [UIFont systemFontOfSize:14];
        _rechargeNumLabel.textColor = UIColorDrakBlackText;
    }
    return _rechargeNumLabel;
}
- (UILabel *)wechatLabel{
    if (!_wechatLabel) {
        _wechatLabel = [[UILabel alloc] init];
        _wechatLabel.text = @"微信";
        _wechatLabel.font = [UIFont systemFontOfSize:14];
        _wechatLabel.textColor = UIColorDrakBlackText;
    }
    return _wechatLabel;
}
- (UILabel *)alipayLabel{
    if (!_alipayLabel) {
        _alipayLabel = [[UILabel alloc] init];
        _alipayLabel.text = @"支付宝";
        _alipayLabel.font = [UIFont systemFontOfSize:14];
        _alipayLabel.textColor = UIColorDrakBlackText;
    }
    return _alipayLabel;
}

- (UITextField *)rechargeNumTextField
{
    if (!_rechargeNumTextField)
    {
        _rechargeNumTextField = [[UITextField alloc] init];
        _rechargeNumTextField.textColor = UIColorDrakBlackText;
        _rechargeNumTextField.textAlignment = NSTextAlignmentRight;
        _rechargeNumTextField.font = [UIFont systemFontOfSize:14];
        _rechargeNumTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入充值金额" attributes:@{NSForegroundColorAttributeName: UIColorFooderText}];
        _rechargeNumTextField.text = @"100";
        _rechargeNumTextField.clearsOnBeginEditing = YES;
        _rechargeNumTextField.borderStyle = UITextBorderStyleNone;
        _rechargeNumTextField.returnKeyType = UIReturnKeyDone;
        _rechargeNumTextField.keyboardType = UIKeyboardTypeDecimalPad;
        _rechargeNumTextField.delegate = self;
        [_rechargeNumTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _rechargeNumTextField;
}

- (UIButton *)selectWechatButton{
    if (!_selectWechatButton) {
        _selectWechatButton = [[UIButton alloc] init];
        [_selectWechatButton setImage:[UIImage imageNamed:@"account_recharge_unselected"] forState:UIControlStateNormal];
        [_selectWechatButton setImage:[UIImage imageNamed:@"account_recharge_selected"] forState:UIControlStateSelected];
        [_selectWechatButton addTarget:self action:@selector(selectWechatOrAlipay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectWechatButton;
}

- (UIButton *)wechatButton{
    if (!_wechatButton) {
        _wechatButton = [[UIButton alloc] init];
        _wechatButton.backgroundColor = UIColorClearColor;
        [_wechatButton addTarget:self action:@selector(selectWechatOrAlipay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wechatButton;
}

- (UIButton *)selectAlipayButton{
    if (!_selectAlipayButton) {
        _selectAlipayButton = [[UIButton alloc] init];
        [_selectAlipayButton setImage:[UIImage imageNamed:@"account_recharge_unselected"] forState:UIControlStateNormal];
        [_selectAlipayButton setImage:[UIImage imageNamed:@"account_recharge_selected"] forState:UIControlStateSelected];
        [_selectAlipayButton addTarget:self action:@selector(selectWechatOrAlipay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectAlipayButton;
}

- (UIButton *)alipayButton{
    if (!_alipayButton) {
        _alipayButton = [[UIButton alloc] init];
        _alipayButton.backgroundColor = UIColorClearColor;
        [_alipayButton addTarget:self action:@selector(selectWechatOrAlipay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _alipayButton;
}

- (UIImageView *)wechatImageview{
    if (!_wechatImageview) {
        _wechatImageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_recharge_wechat"]];
    }
    return _wechatImageview;
}

- (UIImageView *)alipayImageView{
    if (!_alipayImageView) {
        _alipayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_recharge_alipay"]];
    }
    return _alipayImageView;
}

- (UIButton *)rechargeButton{
    if (!_rechargeButton) {
        _rechargeButton = [[UIButton alloc] init];
        _rechargeButton.backgroundColor = UIColorBlue;
        _rechargeButton.layer.masksToBounds = YES;
        _rechargeButton.layer.cornerRadius = 3.0f;
        [_rechargeButton setTitle:@"充值" forState:UIControlStateNormal];
        [_rechargeButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        _rechargeButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rechargeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_rechargeButton addTarget:self action:@selector(rechargeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rechargeButton;
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
