//
//  LiteDeviceDetailViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/3.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceDetailViewController.h"
#import "LiteAccountInvoiceView.h"
#import <Masonry/Masonry.h>
#import "FSNetWorkManager.h"

@interface LiteDeviceDetailViewController ()<UITextFieldDelegate,UINavigationControllerDelegate>

@property (nonatomic , strong) LiteAccountInvoiceView * deviceNameView; //设备名字
@property (nonatomic , strong) LiteAccountInvoiceView * deviceMacView;  //设备mac
@property (nonatomic , strong) LiteAccountInvoiceView * timeView;       //使用期限

@property (nonatomic , strong) UIView           * expireView;        //到期视图
@property (nonatomic , strong) UILabel          * expireLabel;       //到期剩余天数

@property (nonatomic , strong) UIButton         * confirmButton;

@property (nonatomic , strong) NSString         * deviceName;        //原来的设备名称

@end

@implementation LiteDeviceDetailViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.delegate = self;

    [self createUI];
    
    [self requestDeviceDetail];
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
}

#pragma mark - ******* UINavigationController Delegate *******
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 判断要显示的控制器是否是自己
    BOOL isSelfVC = [viewController isKindOfClass:[self class]];
    if (isSelfVC) {
        //是自己不隐藏导航条
        [self.navigationController setNavigationBarHidden:!isSelfVC animated:YES];
    }
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    //设备名字
    self.deviceNameView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 60) withType:typeTextField];
    self.deviceNameView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入设备名称" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.deviceNameView.textField.delegate = self;
    [self.deviceNameView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.deviceNameView.leftTitleLabel.text = @"设备名称";
    self.deviceNameView.textField.clearsOnBeginEditing = YES;
    [self.view addSubview:self.deviceNameView];
    
    //设备mac
    self.deviceMacView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 + 15, kScreenWidth, 60) withType:typeLabel];
    self.deviceMacView.lineView.hidden = YES;
    self.deviceMacView.leftTitleLabel.text = @"设备号";
    self.deviceMacView.rightTitleLabel.text = @"";
    self.deviceMacView.rightTitleLabel.textColor = UIColorlightGray;
    [self.view addSubview:self.deviceMacView];
    
    //使用期限
    self.timeView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60*2 + 15 +15, kScreenWidth, 60) withType:typeLabel];
    self.timeView.leftTitleLabel.text = @"使用期限";
    self.timeView.rightTitleLabel.text = @"2010.01.01 至 2010.01.01";
    self.timeView.rightTitleLabel.textColor = UIColorlightGray;
    [self.view addSubview:self.timeView];
    
    //到期天数
    self.expireView = [[UIView alloc] initWithFrame:CGRectMake(0, 60*3 + 15 +15, kScreenWidth, 60)];
    self.expireView.backgroundColor = UIColorWhite;
    UILabel *expireTopLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 7, kScreenWidth/2, 25)];
    expireTopLabel.text = @"距离下次续费还剩";
    expireTopLabel.textColor = UIColorDarkBlack;
    expireTopLabel.font = [UIFont systemFontOfSize:14];
    expireTopLabel.textAlignment = NSTextAlignmentLeft;
    [self.expireView addSubview:expireTopLabel];
    UILabel *expireBottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 32, kScreenWidth/2, 20)];
    expireBottomLabel.text = @"续费问题请您咨询客服";
    expireBottomLabel.textColor = UIColorFromRGB(0x797E81);
    expireBottomLabel.font = [UIFont systemFontOfSize:12];
    expireBottomLabel.textAlignment = NSTextAlignmentLeft;
    [self.expireView addSubview:expireBottomLabel];
    
    self.expireLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth/2+15, 0, kScreenWidth/2-30, 60)];
    self.expireLabel.text = @"0天";
    self.expireLabel.textColor = UIColorBlue;
    self.expireLabel.font = [UIFont systemFontOfSize:32];
    self.expireLabel.textAlignment = NSTextAlignmentRight;
    [self.expireView addSubview:self.expireLabel];
    [self.view addSubview:self.expireView];
    
    [self.view addSubview:self.confirmButton];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-SafeAreaBottomHeight);
        make.left.right.equalTo(self.view).offset(0);
        make.height.equalTo(@50);
    }];
}

#pragma mark - action method

- (void)confirmButtonAction:(UIButton *)button{
    
    NSLog(@"确定");
    if ([self.deviceName isEqualToString:self.deviceNameView.textField.text]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self requestChangeDeviceName];
}

#pragma mark - request

//请求设备列表
- (void)requestDeviceDetail
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiDeviceDetail
                        withParaments:@{@"id":self.deviceId}
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             NSDictionary *deviceDic = [object objectForKey:@"data"];
                             self.deviceNameView.textField.text = [deviceDic stringValueForKey:@"deviceName" default:@""];
                             self.deviceName = [deviceDic stringValueForKey:@"deviceName" default:@""];
                             self.deviceMacView.rightTitleLabel.text = [deviceDic stringValueForKey:@"mac" default:@""];
                             self.timeView.rightTitleLabel.text = [NSString stringWithFormat:@"%@ 至 %@",[[deviceDic stringValueForKey:@"activeTime" default:@""] substringToIndex:10],[[deviceDic stringValueForKey:@"expiryTime" default:@""] substringToIndex:10]];
                             self.expireLabel.text = [NSString stringWithFormat:@"%@天",[deviceDic stringValueForKey:@"expiryDay" default:@""]];
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

//更改设备名称
- (void)requestChangeDeviceName{
    
    if (self.deviceNameView.textField.text.length > 16) {
        [ShowHUDTool showBriefAlert:@"设备名称不能超过16个字符"];
        return;          // 最多16位字符
    }
    
    //匹配数字,字母和中文
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9-_\\u4E00-\\u9FA5]+$"];
    if (![predicate evaluateWithObject:self.deviceNameView.textField.text]) {
        [ShowHUDTool showBriefAlert:@"设备名称不能包含特殊字符"];
        return;
    }
    
    NSDictionary *params = @{@"id":self.deviceId,@"deviceName":self.deviceNameView.textField.text};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiDeviceEdit
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             if ([self.delegate respondsToSelector:@selector(LiteDeviceDetailEditSuccess)]) {
                                 [self.delegate LiteDeviceDetailEditSuccess];
                             }
                             [self.navigationController popViewControllerAnimated:YES];
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - textfieldDelegate

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
    NSLog(@"%@",textField.text);
}
#pragma mark - Getter

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_confirmButton setBackgroundColor:UIColorBlue];
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
