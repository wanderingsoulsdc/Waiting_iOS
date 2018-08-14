//
//  LiteDeviceEditNameViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/1.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteDeviceEditNameViewController.h"
#import "LiteAccountInvoiceView.h"
#import <Masonry/Masonry.h>
#import "FSNetWorkManager.h"
#import "BHUserModel.h"
#import "FSTools.h"

@interface LiteDeviceEditNameViewController ()<UITextFieldDelegate>

@property (nonatomic , strong) LiteAccountInvoiceView * deviceNameView; //设备名字
@property (nonatomic , strong) LiteAccountInvoiceView * deviceMacView;  //设备mac

@property (nonatomic , strong) UIButton         * confirmButton;

@end

@implementation LiteDeviceEditNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加设备";
    
    [self createUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)createUI{
    
    int deviceNum = [[BHUserModel sharedInstance].deviceNum intValue];
    
    NSString *deviceNumStr = [FSTools ArebicNumberTranslateToChineseNumber:[NSString stringWithFormat:@"%d",deviceNum + 1]];
    
    //设备名字
    self.deviceNameView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 15, kScreenWidth, 60) withType:typeTextField];
    self.deviceNameView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入设备名称" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.deviceNameView.textField.delegate = self;
    [self.deviceNameView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.deviceNameView.leftTitleLabel.text = @"设备名称";
    self.deviceNameView.textField.text = [NSString stringWithFormat:@"设备名称%@",deviceNumStr];
    [self.view addSubview:self.deviceNameView];
    
    //设备mac
    self.deviceMacView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 + 15, kScreenWidth, 60) withType:typeLabel];
    self.deviceMacView.lineView.hidden = YES;
    self.deviceMacView.leftTitleLabel.text = @"设备号";
    self.deviceMacView.rightTitleLabel.text = self.mac;
    self.deviceMacView.rightTitleLabel.textColor = UIColorlightGray;
    [self.view addSubview:self.deviceMacView];
    
    [self.view addSubview:self.confirmButton];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.deviceMacView.mas_bottom).offset(40);
        make.left.equalTo(self.view).offset(48);
        make.right.equalTo(self.view).offset(-48);
        make.height.equalTo(@48);
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
    if (textField.text.length > 0) {
        [_confirmButton setBackgroundColor:UIColorBlue];
        [_confirmButton setUserInteractionEnabled:YES];
    }else{
        [_confirmButton setBackgroundColor:UIColorlightGray];
        [_confirmButton setUserInteractionEnabled:NO];
    }
}

- (void)postAddSuccessNotification{
     [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceAddSuccessNotification object:self.mac];
}

#pragma mark - action method

- (void)confirmButtonAction:(UIButton *)button{
    
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
    
    NSDictionary *params = @{@"deviceName":self.deviceNameView.textField.text,@"mac":self.mac};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAddDevice
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {

                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeMain];
                             
                             [self performSelector:@selector(postAddSuccessNotification) withObject:nil afterDelay:1.0f];
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
#pragma mark - Getter

- (UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [[UIButton alloc] init];
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        _confirmButton.layer.cornerRadius = 4 ;
        _confirmButton.layer.masksToBounds = YES;
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
