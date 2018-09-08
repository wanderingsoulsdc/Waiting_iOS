//
//  LiteAccountInvoiceReceiverViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/24.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceReceiverViewController.h"
#import <Masonry/Masonry.h>
#import "LiteAccountInvoiceView.h"
#import "NSString+Helper.h"
#import "UIView+Addition.h"
#import "FSNetWorkManager.h"
#import "LiteAccountInvoiceApplySuccessViewController.h"

@interface LiteAccountInvoiceReceiverViewController ()<UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic , strong) UIView           * progressView;
@property (nonatomic , strong) UIImageView      * progressImageView;
@property (nonatomic , strong) UILabel          * progressLeftLabel;
@property (nonatomic , strong) UILabel          * progressRightLabel;
@property (nonatomic , strong) UIButton         * confirmButton;

@property (nonatomic , strong) LiteAccountInvoiceView * consigneeView;  //收件人姓名
@property (nonatomic , strong) LiteAccountInvoiceView * phoneView;      //收件人电话
@property (nonatomic , strong) LiteAccountInvoiceView * addressView;    //收件人地址

@end

@implementation LiteAccountInvoiceReceiverViewController
//progress_right
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票申请";
    [self.view addSubview:self.progressView];
    [self.progressView addSubview:self.progressImageView];
    [self.progressView addSubview:self.progressLeftLabel];
    [self.progressView addSubview:self.progressRightLabel];
    [self.view addSubview:self.confirmButton];
    // Do any additional setup after loading the view.
    [self layoutSubviews];
    
    [self addSubViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addSubViews{
    
    UIView *bgView = [[UIView alloc] init];
    [self.view addSubview:bgView];
    
    [bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.progressView.mas_bottom).offset(15);
        make.bottom.equalTo(self.confirmButton.mas_top);
    }];
    
    self.consigneeView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60) withType:typeTextField];
    self.consigneeView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入收件人姓名" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.consigneeView.textField.delegate = self;
    [self.consigneeView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.consigneeView.leftTitleLabel.text = @"收件人姓名";
    [bgView addSubview:self.consigneeView];
    
    self.phoneView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 1 , kScreenWidth, 60) withType:typeTextField];
    self.phoneView.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.phoneView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入收件人电话" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.phoneView.textField.delegate = self;
    [self.phoneView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.phoneView.leftTitleLabel.text = @"收件人电话";
    [bgView addSubview:self.phoneView];
    
    self.addressView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 2 , kScreenWidth, 100) withType:typeTextView];
    self.addressView.lineView.hidden = YES;
    self.addressView.textView.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入收件地址" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.addressView.textView.delegate = self;
    self.addressView.leftTitleLabel.text = @"收件地址";
    [bgView addSubview:self.addressView];
    
}

- (void)layoutSubviews{
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(1);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@56);
    }];
    
    [self.progressImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView).offset(12);
        make.left.equalTo(self.progressView).offset(52);
        make.right.equalTo(self.progressView).offset(-52);
        make.height.equalTo(@16);
    }];
    
    [self.progressLeftLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressImageView.mas_bottom).offset(1);
        make.left.equalTo(self.progressView).offset(36);
        make.height.equalTo(@18);
        make.width.greaterThanOrEqualTo(@30);
    }];
    
    [self.progressRightLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressImageView.mas_bottom).offset(1);
        make.right.equalTo(self.progressView).offset(-36);
        make.height.equalTo(@18);
        make.width.greaterThanOrEqualTo(@30);
    }];
    
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.equalTo(@48);
    }];
}

#pragma mark - Notification Events
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (IS_IPHONE5 || IS_IPhone6) {
        [UIView animateWithDuration:0.25 animations:^{
                self.view.frame = CGRectMake(0, self.view.frame.origin.x-25, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, kStatusBarAndNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark - action

- (void)confirmButtonAction:(UIButton *)button{
    if ([self checkTextFieldStatus]) {
        [self requestAddInvoice];
    }
}
//检查输入内容
- (BOOL)checkTextFieldStatus{
    if (!kStringNotNull(self.consigneeView.textField.text)) {
        [ShowHUDTool showBriefAlert:@"请填写收件人姓名"];
        return NO;
    }else{
        //匹配数字,字母和中文
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9\\u4E00-\\u9FA5]+$"];
        if (![predicate evaluateWithObject:self.consigneeView.textField.text]) {
            [ShowHUDTool showBriefAlert:@"收件人姓名不允许输入特殊字符"];
            return NO;
        };
    }
    
    if (!kStringNotNull(self.phoneView.textField.text)) {
        [ShowHUDTool showBriefAlert:@"请填写收件人电话"];
        return NO;
    }else{
        if (self.phoneView.textField.text.length < 11) {
            [ShowHUDTool showBriefAlert:@"请填写正确的收件人电话"];
            return NO;
        }
    }
    if (!kStringNotNull(self.addressView.textView.text)) {
        [ShowHUDTool showBriefAlert:@"请填写收件人地址"];
        return NO;
    }else{
        //匹配数字,字母和中文
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9\\u4E00-\\u9FA5]+$"];
        if (![predicate evaluateWithObject:self.addressView.textView.text]) {
            [ShowHUDTool showBriefAlert:@"收件人地址不允许输入特殊字符"];
            return NO;
        };
    }
    return YES;
}

#pragma mark - request
/*
 type           开票人类型 1 企业 2 个人
 invoiceTitle   发票抬头
 credit         0.00    开票金额
 invoiceType    发票类型 1增值税普通发票 2增值税专用发票
 bankTaxpay     银行纳税人证明
 bankName       开户行
 bankNumber     银行账户
 bankLicense    银行开户许可证
 identify       纳税人识别号
 registerAddressr       注册地址
 registerPhone          注册电话
 consignee          收件人姓名
 phone              收件人电话
 address            收件人地址
 */
- (void)requestAddInvoice
{
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiInvoiceAdd
                        withParaments:self.formDict
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             LiteAccountInvoiceApplySuccessViewController *vc = [[LiteAccountInvoiceApplySuccessViewController alloc] init];
                             [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - textViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    CGSize constraintSize;
    constraintSize.width = textView.frame.size.width-16;
    constraintSize.height = MAXFLOAT;
    CGSize sizeFrame =[textView.text sizeWithFont:textView.font constrainedToSize:constraintSize];
    
    textView.height = sizeFrame.height + 10;
    self.addressView.height = textView.height + 60;
    NSLog(@"--%@--%f--",textView.text,textView.height);
    
    [self.formDict setObject:textView.text forKey:@"address"];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    
    NSMutableString * str = [NSMutableString stringWithString:textView.text];
    [str replaceCharactersInRange:range withString:text];
    
    if ([text isEqualToString:@" "])
    {
        return NO;
    }
    else if (str.length > 60)
    {
        [ShowHUDTool showBriefAlert:@"您输入的地址过长"];
    }
    return str.length <= 60;    // 最多60位
}

#pragma mark - textfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.phoneView.textField){    //收件人电话
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (str.length > 20) {
            return NO;
        }
        //匹配数字和横线
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9\\-]+$"];
        return [predicate evaluateWithObject:str] ? YES : NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)textFieldDidChange:(UITextField *)textField{
    NSLog(@"%@",textField.text);
    if (textField == self.consigneeView.textField) {    //收件人姓名
        [self.formDict setObject:textField.text forKey:@"consignee"];
    } else if (textField == self.phoneView.textField){  //收件人电话
        [self.formDict setObject:textField.text forKey:@"phone"];
    }
}


#pragma mark - Getter

- (UIView *)progressView{
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColorWhite;
    }
    return _progressView;
}

- (UIImageView *)progressImageView{
    if (!_progressImageView) {
        _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_right"]];
        _progressImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _progressImageView;
}

- (UILabel *)progressLeftLabel{
    if (!_progressLeftLabel) {
        _progressLeftLabel = [[UILabel alloc] init];
        _progressLeftLabel.text = @"发票信息";
        _progressLeftLabel.textColor = UIColorDarkBlack;
        _progressLeftLabel.font = [UIFont systemFontOfSize:12];
        _progressLeftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _progressLeftLabel;
}

- (UILabel *)progressRightLabel{
    if (!_progressRightLabel) {
        _progressRightLabel = [[UILabel alloc] init];
        _progressRightLabel.text = @"收件信息";
        _progressRightLabel.textColor = UIColorDarkBlack;
        _progressRightLabel.font = [UIFont systemFontOfSize:12];
        _progressRightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _progressRightLabel;
}

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
