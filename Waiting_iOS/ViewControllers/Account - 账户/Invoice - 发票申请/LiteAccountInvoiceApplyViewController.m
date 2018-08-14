//
//  LiteAccountInvoiceApplyViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceApplyViewController.h"
#import "Masonry/Masonry.h"
#import "LiteAlertLabel.h"
#import "LiteAccountInvoiceModel.h"
#import "LiteAccountInvoiceReceiverViewController.h"
#import "LiteAccountInvoiceView.h"
#import "FSNetWorkManager.h"
#import "LiteAccountInvoiceModel.h"
#import "LiteAccountQualificationICPViewController.h"
#import "BHUserModel.h"

@interface LiteAccountInvoiceApplyViewController ()<UIScrollViewDelegate,UITextFieldDelegate,LiteAccountInvoiceViewDelegate,LiteAccountQualificationICPViewControllerDelegate>

@property (nonatomic , strong) UIView           * progressView;
@property (nonatomic , strong) UIImageView      * progressImageView;
@property (nonatomic , strong) UILabel          * progressLeftLabel;
@property (nonatomic , strong) UILabel          * progressRightLabel;

@property (nonatomic , strong) LiteAlertLabel   * alertLabel;

@property (nonatomic , strong) UIView           * segmentView;   //选项卡视图
@property (nonatomic , strong) UIButton         * companyButton;
@property (nonatomic , strong) UIButton         * personButton;
@property (nonatomic , strong) UIView           * indicatorView; //指示器

@property (nonatomic , strong) UIScrollView     * scrollView;

@property (nonatomic , strong) LiteAlertLabel   * companyWarningLabel;
@property (nonatomic , strong) UIScrollView     * companyScrollView;
@property (nonatomic , strong) UIScrollView     * personScrollView;

@property (nonatomic , strong) UIButton         * nextButton;

// type = 1 公司发票 type = 2 个人发票  默认：1
@property (nonatomic , strong) NSString         * type;
@property (nonatomic , strong) NSMutableDictionary * companyFormDict; //需要提交的参数字典
@property (nonatomic , strong) NSMutableDictionary * personFormDict; //需要提交的参数字典
@property (nonatomic , strong) NSString         * taxpayerProveImg; //纳税人证明图片链接
@property (nonatomic , strong) NSString         * bankLicenseImg; //银行开户许可证图片链接

@property (nonatomic , strong) NSString         * credit; //可开发票金额
@property (nonatomic , strong) NSString         * replaceMoney; //不可开发票金额

@property (nonatomic , strong) LiteAccountInvoiceView * companyInvoiceTitleView; //公司发票抬头
@property (nonatomic , strong) LiteAccountInvoiceView * companyTotalCreditView; //公司可开票总金额
@property (nonatomic , strong) LiteAccountInvoiceView * companyInvoiceProjectView; //公司发票项目
@property (nonatomic , strong) LiteAccountInvoiceView * companyCreditView;      //公司填写开票金额
@property (nonatomic , strong) LiteAccountInvoiceView * companyInvoiceTypeView; //公司发票类型
@property (nonatomic , strong) LiteAccountInvoiceView * bankNameView;      //开户行
@property (nonatomic , strong) LiteAccountInvoiceView * bankNumberView;    //银行账户
@property (nonatomic , strong) LiteAccountInvoiceView * identifyView;      //纳税人识别号
@property (nonatomic , strong) LiteAccountInvoiceView * registerAddressrView;//注册地址
@property (nonatomic , strong) LiteAccountInvoiceView * registerPhoneView;  //注册电话
@property (nonatomic , strong) LiteAccountInvoiceView * taxpayerProveView;  //纳税人证明
@property (nonatomic , strong) LiteAccountInvoiceView * bankLicenseView;  //银行开户许可证

@property (nonatomic , strong) LiteAccountInvoiceView * personInvoiceTitleView;//个人发票抬头
@property (nonatomic , strong) LiteAccountInvoiceView * personInvoiceProjectView; //个人发票项目
@property (nonatomic , strong) LiteAccountInvoiceView * personTotalCreditView; //个人可开票总金额
@property (nonatomic , strong) LiteAccountInvoiceView * personCreditView;   //个人填写开票金额


@property (nonatomic , assign) CGRect                   isEditingTextFieldFrame; //正在编辑的输入框在self.view中的frame
@property (nonatomic , assign) int                      textFieldBottmToKeyBoard; //正在编辑的输入框底部 到 键盘最上部 的 距离
@end

@implementation LiteAccountInvoiceApplyViewController


#pragma mark - action method
- (void)nextButtonAction:(UIButton *)button{
    if (![self checkTextFieldStatus]) {
        return;
    }
    NSLog(@"下一步");
    LiteAccountInvoiceReceiverViewController *vc = [[LiteAccountInvoiceReceiverViewController alloc] init];
    if ([self.type integerValue] == 1) { //公司
        vc.formDict = self.companyFormDict;
    } else {
        vc.formDict = self.personFormDict;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)checkTextFieldStatus{
    if ([self.type integerValue] == 1) { //企业
        if (!kStringNotNull(self.companyCreditView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写发票金额"];
            return NO;
        }else{
            if ([self.companyCreditView.textField.text floatValue] < 100) {
                [ShowHUDTool showBriefAlert:@"发票金额不得低于100元"];
                return NO;
            }
            if ([self.companyCreditView.textField.text floatValue] > [self.credit floatValue]) {
                [ShowHUDTool showBriefAlert:@"发票金额不得大于可开发票余额"];
                return NO;
            }
        }
        if (!kStringNotNull(self.bankNameView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写开户银行"];
            return NO;
        }else{
            //匹配数字,字母和中文
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9\\u4E00-\\u9FA5]+$"];
            if (![predicate evaluateWithObject:self.bankNameView.textField.text]) {
                [ShowHUDTool showBriefAlert:@"开户银行不允许输入特殊字符"];
                return NO;
            };
        }
        if (!kStringNotNull(self.bankNumberView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写银行账户"];
            return NO;
        }
        if (!kStringNotNull(self.registerAddressrView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写注册地址"];
            return NO;
        }else{
            //匹配数字,字母和中文
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9\\u4E00-\\u9FA5]+$"];
            if (![predicate evaluateWithObject:self.registerAddressrView.textField.text]) {
                [ShowHUDTool showBriefAlert:@"注册地址不允许输入特殊字符"];
                return NO;
            };
        }
        
        if (!kStringNotNull(self.registerPhoneView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写注册电话"];
            return NO;
        }else{
            if (self.registerPhoneView.textField.text.length < 11) {
                [ShowHUDTool showBriefAlert:@"注册电话输入错误"];
                return NO;
            }
        }
        if (!kStringNotNull(self.identifyView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写纳税人识别号"];
            return NO;
        }else{
            //匹配数字,字母和中文
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9]+$"];
            if (![predicate evaluateWithObject:self.identifyView.textField.text]) {
                [ShowHUDTool showBriefAlert:@"纳税人识别只允许输入字母和数字"];
                return NO;
            };
        }
        
        
        if ([[self.companyFormDict objectForKey:@"invoiceType"] isEqualToString:@"2"]) {
            //专用发票才需要银行纳税人证明
            if (!kStringNotNull(self.taxpayerProveImg)) {
                [ShowHUDTool showBriefAlert:@"请上传银行纳税人证明"];
                return NO;
            }
        } ;
        
        if (!kStringNotNull(self.bankLicenseImg)) {
            [ShowHUDTool showBriefAlert:@"请上传银行开户许可证"];
            return NO;
        }
        return YES;
    } else {    //个人
        if (!kStringNotNull(self.personCreditView.textField.text)) {
            [ShowHUDTool showBriefAlert:@"请填写发票金额"];
            return NO;
        }else{
            if ([self.personCreditView.textField.text floatValue] < 100) {
                [ShowHUDTool showBriefAlert:@"发票金额不得低于100元"];
                return NO;
            }
            if ([self.personCreditView.textField.text floatValue] > [self.credit floatValue]) {
                [ShowHUDTool showBriefAlert:@"发票金额不得大于可开发票余额"];
                return NO;
            }
        }
        return YES;
    }
}

- (void)segmentButtonAction:(UIButton *)button{
    button.highlighted = NO;
    if ([button isEqual:self.companyButton]) {      //点击公司
        self.companyButton.selected = YES;
        self.personButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.companyButton.width - self.indicatorView.width)/2];
            self.scrollView.contentOffset =CGPointMake(0, 0);
        }];
        self.type = @"1";
    } else if ([button isEqual:self.personButton]){ //点击个人
        self.companyButton.selected = NO;
        self.personButton.selected = YES;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.personButton.width - self.indicatorView.width)/2+self.personButton.left];
            self.scrollView.contentOffset =CGPointMake(kScreenWidth, 0);
        }];
        self.type = @"2";
    }
}
//银行纳税人证明
- (void)taxpayerProveAction:(UIButton *)button{
    NSLog(@"点击银行纳税人证明");
    LiteAccountQualificationICPViewController *ICP = [[LiteAccountQualificationICPViewController alloc] init];
    ICP.delegate =self;
    ICP.type = ICPCellTypeTaxpayerCertify;
    ICP.qualificationICPUrl = self.taxpayerProveImg;
    [self.navigationController pushViewController:ICP animated:YES];
}

//银行开户许可证
- (void)bankLicenseAction:(UIButton *)button{
    NSLog(@"点击银行开户许可证");
    LiteAccountQualificationICPViewController *ICP = [[LiteAccountQualificationICPViewController alloc] init];
    ICP.delegate =self;
    ICP.type = ICPCellTypeBankLicense;
    ICP.qualificationICPUrl = self.bankLicenseImg;
    [self.navigationController pushViewController:ICP animated:YES];
}

#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.scrollView]) {
        return;
    }
    CGFloat OffsetX = scrollView.contentOffset.x;
    if (OffsetX == kScreenWidth) {
        //滑到第二个按钮
        self.companyButton.selected = NO;
        self.personButton.selected = YES;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.personButton.width - self.indicatorView.width)/2+self.personButton.left];
        }];
        self.type = @"2";
    }else{
        //滑到第一个按钮
        self.companyButton.selected = YES;
        self.personButton.selected = NO;
        [UIView animateWithDuration:0.1f animations:^{
            [self.indicatorView setLeft:(self.companyButton.width - self.indicatorView.width)/2];
        }];
        self.type = @"1";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票申请";
    self.type = @"1";
    
    [self createUI];
    [self layoutSubviews];
    
    [self requestCredit];

    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invoiceTypeSelectResult:) name:@"invoiceTypeSelectResult" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightDetailReasonAction) name:@"rightDetailReasonButtonAction" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createUI{
    [self.view addSubview:self.progressView];
    [self.progressView addSubview:self.progressImageView];
    [self.progressView addSubview:self.progressLeftLabel];
    [self.progressView addSubview:self.progressRightLabel];
    [self.view addSubview:self.alertLabel];
    [self.view addSubview:self.segmentView];
    [self.segmentView addSubview:self.companyButton];
    [self.segmentView addSubview:self.personButton];
    [self.segmentView addSubview:self.indicatorView];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.companyWarningLabel];
    [self.scrollView addSubview:self.companyScrollView];
    [self.scrollView addSubview:self.personScrollView];
    
    [self companyScrollViewAddSubviews];
    [self personScrollViewAddSubviews];
    
    [self.view addSubview:self.nextButton];
}

- (void)companyScrollViewAddSubviews{
    //发票抬头
    self.companyInvoiceTitleView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60) withType:typeTextField];
    self.companyInvoiceTitleView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入发票抬头" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    
    self.companyInvoiceTitleView.textField.text = [BHUserModel sharedInstance].businessName;
    self.companyInvoiceTitleView.textField.userInteractionEnabled = NO;
    [self.companyFormDict setObject:[BHUserModel sharedInstance].businessName forKey:@"invoiceTitle"];

    self.companyInvoiceTitleView.textField.delegate = self;
    [self.companyInvoiceTitleView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.companyInvoiceTitleView.leftTitleLabel.text = @"发票抬头";
    [self.companyScrollView addSubview:self.companyInvoiceTitleView];
    
    //发票项目
    self.companyInvoiceProjectView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, self.companyInvoiceTitleView.bottom, kScreenWidth, 60) withType:typeLabel];
    self.companyInvoiceProjectView.leftTitleLabel.text = @"发票项目";
    self.companyInvoiceProjectView.rightTitleLabel.text = @"信息服务费";
    [self.companyScrollView addSubview:self.companyInvoiceProjectView];
    
    //可开发票总金额
    self.companyTotalCreditView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, self.companyInvoiceProjectView.bottom, kScreenWidth, 60) withType:typeLabel];
    self.companyTotalCreditView.leftTitleLabel.text = @"可开发票余额";
    self.companyTotalCreditView.rightTitleLabel.text = [NSString stringWithFormat:@"%@元",@"0.00"]; //接口取
    [self.companyScrollView addSubview:self.companyTotalCreditView];
    
    //发票开票金额
    self.companyCreditView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, self.companyTotalCreditView.bottom , kScreenWidth, 60) withType:typeTextField];
    self.companyCreditView.lineView.hidden = YES;
    self.companyCreditView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入发票金额" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.companyCreditView.textField.delegate = self;
    self.companyCreditView.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.companyCreditView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.companyCreditView.leftTitleLabel.text = @"发票金额（元）";
    [self.companyScrollView addSubview:self.companyCreditView];
    
    //发票类型
    self.companyInvoiceTypeView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, self.companyCreditView.bottom + 15, kScreenWidth, 60) withType:typeButton];
    self.companyInvoiceTypeView.leftTitleLabel.text = @"发票类型";
    [self.companyScrollView addSubview:self.companyInvoiceTypeView];
    
    //开户银行
    self.bankNameView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, self.companyInvoiceTypeView.bottom, kScreenWidth, 60) withType:typeTextField];
    self.bankNameView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入开户银行" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.bankNameView.textField.delegate = self;
    [self.bankNameView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.bankNameView.leftTitleLabel.text = @"开户银行";
    [self.companyScrollView addSubview:self.bankNameView];
    
    //银行账户
    self.bankNumberView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 6 + 15, kScreenWidth, 60) withType:typeTextField];
    self.bankNumberView.textField.keyboardType = UIKeyboardTypeNumberPad;
    self.bankNumberView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入银行账户" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.bankNumberView.textField.delegate = self;
    [self.bankNumberView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.bankNumberView.leftTitleLabel.text = @"银行账户";
    [self.companyScrollView addSubview:self.bankNumberView];
    
    //注册地址
    self.registerAddressrView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 7 + 15, kScreenWidth, 60) withType:typeTextField];
    self.registerAddressrView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入注册地址" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.registerAddressrView.textField.delegate = self;
    [self.registerAddressrView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.registerAddressrView.leftTitleLabel.text = @"注册地址";
    [self.companyScrollView addSubview:self.registerAddressrView];
    
    //注册电话
    self.registerPhoneView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 8 + 15, kScreenWidth, 60) withType:typeTextField];
    self.registerPhoneView.textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.registerPhoneView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入注册电话" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.registerPhoneView.textField.delegate = self;
    [self.registerPhoneView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.registerPhoneView.leftTitleLabel.text = @"注册电话";
    [self.companyScrollView addSubview:self.registerPhoneView];
    
    //纳税人识别号
    self.identifyView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 9 + 15, kScreenWidth, 60) withType:typeTextField];
    self.identifyView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入纳税人识别号" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.identifyView.textField.delegate = self;
    [self.identifyView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.identifyView.leftTitleLabel.text = @"纳税人识别号";
    [self.companyScrollView addSubview:self.identifyView];
    
    //银行开户许可证
    self.bankLicenseView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 10 + 15, kScreenWidth, 60) withType:typeStatus];
    self.bankLicenseView.delegate = self;
    self.bankLicenseView.lineView.hidden = YES;
    UIButton *bankLicenseButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, kScreenWidth- 100, 60)];
    bankLicenseButton.backgroundColor = UIColorClearColor;
    [bankLicenseButton addTarget:self action:@selector(bankLicenseAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bankLicenseView addSubview:bankLicenseButton];
    self.bankLicenseView.leftTitleLabel.text = @"银行开户许可证";
    self.bankLicenseView.markLabel.text = @"未上传";
    self.bankLicenseView.markLabel.textColor = UIColorDrakBlackText;
    [self.companyScrollView addSubview:self.bankLicenseView];
    
    //银行纳税人证明
    self.taxpayerProveView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 11 + 15, kScreenWidth, 60) withType:typeStatus];
    self.taxpayerProveView.delegate = self;
    self.taxpayerProveView.lineView.hidden = YES;
    self.taxpayerProveView.hidden = YES;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, kScreenWidth- 100, 60)];
    button.backgroundColor = UIColorClearColor;
    [button addTarget:self action:@selector(taxpayerProveAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.taxpayerProveView addSubview:button];
    self.taxpayerProveView.leftTitleLabel.text = @"银行纳税人证明";
    self.taxpayerProveView.markLabel.text = @"未上传";
    self.taxpayerProveView.markLabel.textColor = UIColorDrakBlackText;
    [self.companyScrollView addSubview:self.taxpayerProveView];
    
    [self setCompanyScrollSubViewsFrame];
}
//对公司发票布局统一管理
- (void)setCompanyScrollSubViewsFrame{
    //发票抬头
    self.companyInvoiceTitleView.top = 0;
    //发票项目
    self.companyInvoiceProjectView.top = self.companyInvoiceTitleView.bottom;
    //可开发票总金额
    self.companyTotalCreditView.top = self.companyInvoiceProjectView.bottom;
    //发票开票金额
    self.companyCreditView.top = self.companyTotalCreditView.bottom;
    
    //发票类型
    self.companyInvoiceTypeView.top = self.companyCreditView.bottom + 15;
    //开户银行
    self.bankNameView.top = self.companyInvoiceTypeView.bottom;
    //银行账户
    self.bankNumberView.top = self.bankNameView.bottom;
    //注册地址
    self.registerAddressrView.top = self.bankNumberView.bottom;
    //注册电话
    self.registerPhoneView.top = self.registerAddressrView.bottom;
    //纳税人识别号
    self.identifyView.top = self.registerPhoneView.bottom;
    //银行开户许可证
    self.bankLicenseView.top = self.identifyView.bottom;
    //银行纳税人证明
    self.taxpayerProveView.top = self.bankLicenseView.bottom;
    
    //普通发票 银行纳税人证明 不出现
    self.companyScrollView.contentSize = CGSizeMake(kScreenWidth, self.bankLicenseView.bottom + 15);
}

- (void)personScrollViewAddSubviews{
    self.personInvoiceTitleView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60) withType:typeTextField];
    self.personInvoiceTitleView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入发票抬头" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    
    self.personInvoiceTitleView.textField.text = [BHUserModel sharedInstance].businessName;
    self.personInvoiceTitleView.textField.userInteractionEnabled = NO;
    [self.personFormDict setObject:[BHUserModel sharedInstance].businessName forKey:@"invoiceTitle"];
    
    self.personInvoiceTitleView.textField.delegate = self;
    [self.personInvoiceTitleView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.personInvoiceTitleView.leftTitleLabel.text = @"发票抬头";
    [self.personScrollView addSubview:self.personInvoiceTitleView];
    
    self.personInvoiceProjectView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 1, kScreenWidth, 60) withType:typeLabel];
    self.personInvoiceProjectView.leftTitleLabel.text = @"发票项目";
    self.personInvoiceProjectView.rightTitleLabel.text = @"信息服务费";
    [self.personScrollView addSubview:self.personInvoiceProjectView];
    
    self.personTotalCreditView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 2, kScreenWidth, 60) withType:typeLabel];
    self.personTotalCreditView.leftTitleLabel.text = @"可开发票余额";
    self.personTotalCreditView.rightTitleLabel.text = [NSString stringWithFormat:@"%@元",@"0.00"]; //接口取
    [self.personScrollView addSubview:self.personTotalCreditView];
    
    self.personCreditView = [[LiteAccountInvoiceView alloc] initWithFrame:CGRectMake(0, 60 * 3, kScreenWidth, 60) withType:typeTextField];
    self.personCreditView.lineView.hidden = YES;
    self.personCreditView.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入发票金额" attributes:@{NSForegroundColorAttributeName: UIColorlightGray}];
    self.personCreditView.textField.delegate = self;
    self.personCreditView.textField.keyboardType = UIKeyboardTypeDecimalPad;
    [self.personCreditView.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.personCreditView.leftTitleLabel.text = @"发票金额（元）";
    [self.personScrollView addSubview:self.personCreditView];
    
    [self setPersonScrollSubViewsFrame];
}
//对个人发票布局统一管理
- (void)setPersonScrollSubViewsFrame{
    self.personInvoiceTitleView.top = 0;
    self.personInvoiceProjectView.top = self.personInvoiceTitleView.bottom;
    self.personTotalCreditView.top = self.personInvoiceProjectView.bottom;
    self.personCreditView.top = self.personTotalCreditView.bottom;
    
    self.personScrollView.contentSize = CGSizeMake(kScreenWidth, self.personCreditView.bottom + 15);
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
    
    [self.alertLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressView.mas_bottom).offset(10);
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.height.equalTo(@32);
    }];
    
    [self.segmentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertLabel.mas_bottom).offset(10);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@36);
    }];
    
    [self.companyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(self.segmentView);
        make.width.equalTo(self.segmentView.mas_width).multipliedBy(1.0f/2.0f);
    }];
    
    [self.personButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(self.segmentView);
        make.width.equalTo(self.segmentView.mas_width).multipliedBy(1.0f/2.0f);
    }];
    
    [self.indicatorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.segmentView.mas_bottom);
        make.centerX.equalTo(self.companyButton.mas_centerX);
        make.height.equalTo(@3);
        make.width.equalTo(@12);
    }];
    
    [self.nextButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        make.height.equalTo(@48);
    }];
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segmentView.mas_bottom).offset(1);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.nextButton.mas_top);
    }];
    //约束转化成frame,需要一个过程
    [self.scrollView.superview layoutIfNeeded];
    [self performSelector:@selector(setScrollSubViewsHeight) withObject:nil afterDelay:0.1];
}

- (void)setScrollSubViewsHeight{
    self.companyScrollView.height = self.scrollView.height - 34;
    self.personScrollView.height = self.scrollView.height;
}


#pragma mark - Notification Events
- (void)keyboardWillShow:(NSNotification *)notification
{   NSLog(@"键盘出现");
    //创建自带来获取穿过来的对象的info配置信息
    NSDictionary *userInfo = [notification userInfo];
    //创建value来获取 userinfo里的键盘frame大小
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    //创建cgrect 来获取键盘的值
    CGRect keyboardRect = [aValue CGRectValue];
    //最后获取高度 宽度也是同理可以获取
    int keyboardHeight = keyboardRect.size.height;
    
    //算出正在编辑的输入框底部 到 屏幕底部 的 距离
    int lengthToScreenBottom = kScreenHeight - kStatusBarAndNavigationBarHeight - (self.isEditingTextFieldFrame.origin.y + self.isEditingTextFieldFrame.size.height);
    
    //算出正在编辑的输入框底部 到 键盘最上部 的 距离
    self.textFieldBottmToKeyBoard = lengthToScreenBottom - keyboardHeight;
    
    if (self.textFieldBottmToKeyBoard < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.frame = CGRectMake(0, kStatusBarAndNavigationBarHeight + self.textFieldBottmToKeyBoard - 15, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{   NSLog(@"键盘消失");
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, kStatusBarAndNavigationBarHeight, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
#pragma mark - Request

//请求开票金额
- (void)requestCredit
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiInvoiceUseCredit
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         if (NetResponseCheckStaus)
                         {  NSLog(@"请求成功");
                             NSDictionary *dataDic = object[@"data"];
                             self.credit = [dataDic stringValueForKey:@"credit" default:@""];
                             self.replaceMoney = [dataDic stringValueForKey:@"replaceMoney" default:@""];
                             //公司页面
                             self.companyTotalCreditView.rightTitleLabel.text = [NSString stringWithFormat:@"%@元",self.credit];
                             //个人页面
                             self.personTotalCreditView.rightTitleLabel.text = [NSString stringWithFormat:@"%@元",self.credit];
                             
                             if ([self.replaceMoney floatValue] > 0 ) {
                                 self.companyTotalCreditView.replaceMoney = self.replaceMoney;
                                 self.companyTotalCreditView.height = self.companyTotalCreditView.height + 20 ;
                                 [self setCompanyScrollSubViewsFrame];
                                 
                                 self.personTotalCreditView.replaceMoney = self.replaceMoney;
                                 self.personTotalCreditView.height = self.personTotalCreditView.height + 20 ;
                                 [self setPersonScrollSubViewsFrame];
                                 
                             }
                         }else{
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}

#pragma mark - common delegate
//专票,普票点击结果
- (void)invoiceTypeSelectResult:(NSNotification *)noti{
    NSString *type = noti.object;
    if ([type integerValue] == 1) {   //专票
        self.taxpayerProveView.hidden = NO;
        self.bankLicenseView.lineView.hidden = NO;
        
        CGSize size = self.companyScrollView.contentSize;
        [self.companyScrollView setContentSize:CGSizeMake(size.width, size.height + 60)];
        [self.companyFormDict setObject:@"2" forKey:@"invoiceType"];

    }else{  //普票
        self.taxpayerProveView.hidden = YES;
        self.bankLicenseView.lineView.hidden = YES;
        
        CGSize size = self.companyScrollView.contentSize;
        [self.companyScrollView setContentSize:CGSizeMake(size.width, size.height - 60)];
        [self.companyFormDict setObject:@"1" forKey:@"invoiceType"];
    }
}

//不可开票查看原因
- (void)rightDetailReasonAction{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"您当前账户存在平台代充金额%@元，该金额无法开具发票。",self.replaceMoney] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

//证明上传回调
- (void)changeQualificationFinish:(NSString *)url Type:(ICPCellType)type{
    if (type == ICPCellTypeTaxpayerCertify) { //纳税人证明
        self.taxpayerProveImg = url;
        self.taxpayerProveView.markLabel.text = @"已上传";
        self.taxpayerProveView.markLabel.textColor = UIColorDrakBlackText;
        [self.companyFormDict setObject:self.taxpayerProveImg forKey:@"bankTaxpay"];
    }else if(type == ICPCellTypeBankLicense){ //银行开户许可证
        self.bankLicenseImg = url;
        self.bankLicenseView.markLabel.text = @"已上传";
        self.bankLicenseView.markLabel.textColor = UIColorDrakBlackText;
        [self.companyFormDict setObject:self.bankLicenseImg forKey:@"bankLicense"];
    }
    
}

#pragma mark - textfieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
   // A 是View 添加在 B 上
   // B 也是View 添加在 C上
   // 此时算出 A 在 C 中的 frame :
   // CGRect frame = [B convertRect:A.frame toView:C];
    
    CGRect frame = [textField.superview convertRect:textField.frame toView:self.companyScrollView];
    CGRect frame1 = [self.companyScrollView convertRect:frame toView:self.scrollView];
    CGRect frame2 = [self.scrollView convertRect:frame1 toView:self.view];
    self.isEditingTextFieldFrame = frame2;
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.companyCreditView.textField || textField == self.personCreditView.textField) { //发票金额
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        
        if (str.length > 12) {
            return NO;          // 100000000.00 最多9位字符
        }
        //匹配两位小数
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^(([1-9]{1}\\d*)|([0]{1}))(\\.(\\d){0,2})?$"];
        
        return [predicate evaluateWithObject:str] ? YES : NO;
    }else if (textField == self.registerPhoneView.textField){    //注册手机号
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (str.length > 20) {
            return NO;
        }
        //匹配数字和横线
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9\\-]+$"];
        return [predicate evaluateWithObject:str] ? YES : NO;
    }else if (textField == self.identifyView.textField){    //纳税人识别号
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        //匹配数字,字母
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[a-zA-Z0-9]+$"];
        return [predicate evaluateWithObject:str] ? YES : NO;
    }else if (textField == self.bankNumberView.textField){    //银行账号
        NSString * str = [NSString stringWithFormat:@"%@%@",textField.text,string];
        //匹配数字
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^[0-9]+$"];
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
    if (textField == self.companyInvoiceTitleView.textField) {  //发票抬头
        [self.companyFormDict setObject:textField.text forKey:@"invoiceTitle"];
    } else if (textField == self.companyCreditView.textField){  //发票金额
        [self.companyFormDict setObject:textField.text forKey:@"credit"];
    } else if (textField == self.bankNameView.textField){       //开户银行
        [self.companyFormDict setObject:textField.text forKey:@"bankName"];
    } else if (textField == self.bankNumberView.textField){     //银行账户
        [self.companyFormDict setObject:textField.text forKey:@"bankNumber"];
    } else if (textField == self.registerAddressrView.textField){  //注册地址
        [self.companyFormDict setObject:textField.text forKey:@"registerAddress"];
    } else if (textField == self.registerPhoneView.textField){  //注册电话
        [self.companyFormDict setObject:textField.text forKey:@"registerPhone"];
    } else if (textField == self.identifyView.textField){  //纳税人识别号
        [self.companyFormDict setObject:textField.text forKey:@"identify"];
    } else if (textField == self.personInvoiceTitleView.textField){  //个人发票抬头
        [self.personFormDict setObject:textField.text forKey:@"invoiceTitle"];
    } else if (textField == self.personCreditView.textField){  //个人发票金额
        [self.personFormDict setObject:textField.text forKey:@"credit"];
    }
}



#pragma mark - Getter


- (NSMutableDictionary *)companyFormDict{
    if (!_companyFormDict) {
        _companyFormDict = [[NSMutableDictionary alloc] init];
        [_companyFormDict setObject:@"1" forKey:@"type"];
        [_companyFormDict setObject:@"1" forKey:@"invoiceType"];
    }
    return _companyFormDict;
}

- (NSMutableDictionary *)personFormDict{
    if (!_personFormDict) {
        _personFormDict = [[NSMutableDictionary alloc] init];
        [_personFormDict setObject:@"2" forKey:@"type"];
    }
    return _personFormDict;
}

- (UIView *)progressView{
    if (!_progressView) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = UIColorWhite;
    }
    return _progressView;
}

- (UIImageView *)progressImageView{
    if (!_progressImageView) {
        _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_left"]];
        _progressImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _progressImageView;
}

- (UILabel *)progressLeftLabel{
    if (!_progressLeftLabel) {
        _progressLeftLabel = [[UILabel alloc] init];
        _progressLeftLabel.text = @"发票信息";
        _progressLeftLabel.textColor = UIColorDrakBlackText;
        _progressLeftLabel.font = [UIFont systemFontOfSize:12];
        _progressLeftLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _progressLeftLabel;
}

- (UILabel *)progressRightLabel{
    if (!_progressRightLabel) {
        _progressRightLabel = [[UILabel alloc] init];
        _progressRightLabel.text = @"收件信息";
        _progressRightLabel.textColor = UIColorlightGray;
        _progressRightLabel.font = [UIFont systemFontOfSize:12];
        _progressRightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _progressRightLabel;
}

- (LiteAlertLabel *)alertLabel{
    if (!_alertLabel) {
        _alertLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectZero];
        [_alertLabel setAlertImageHidden:YES];
        _alertLabel.titleLabel.text = @"不足1000元的开票会自动扣取15元邮费";
        _alertLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _alertLabel;
}

- (UIView *)segmentView{
    if (!_segmentView) {
        _segmentView = [[UIView alloc] init];
        _segmentView.backgroundColor = UIColorWhite;
    }
    return _segmentView;
}

- (UIView *)indicatorView{
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.backgroundColor = UIColorBlue;
    }
    return _indicatorView;
}

- (UIButton *)companyButton{
    if (!_companyButton) {
        _companyButton = [[UIButton alloc] init];
        [_companyButton setTitle:@"企业" forState:UIControlStateNormal];
        [_companyButton setTitle:@"企业" forState:UIControlStateSelected];
        [_companyButton setTitleColor:UIColorlightGray forState:UIControlStateNormal];
        [_companyButton setTitleColor:UIColorBlue forState:UIControlStateSelected];
        [_companyButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        _companyButton.selected = YES;
        [_companyButton addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventAllTouchEvents];
    }
    return _companyButton;
}

- (UIButton *)personButton{
    if (!_personButton) {
        _personButton = [[UIButton alloc] init];
        [_personButton setTitle:@"个人" forState:UIControlStateNormal];
        [_personButton setTitle:@"个人" forState:UIControlStateSelected];
        [_personButton setTitleColor:UIColorlightGray forState:UIControlStateNormal];
        [_personButton setTitleColor:UIColorBlue forState:UIControlStateSelected];
        [_personButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_personButton addTarget:self action:@selector(segmentButtonAction:) forControlEvents:UIControlEventTouchUpInside | UIControlEventAllTouchEvents];
        
    }
    return _personButton;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        // 创建UIScrollView
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = UIColorClearColor;
        _scrollView.bounces = NO;
        // 设置scrollView的属性
        _scrollView.pagingEnabled = YES;
        // 设置UIScrollView的滚动范围（内容大小）
        _scrollView.contentSize = CGSizeMake(kScreenWidth*2, 300);
        _scrollView.delegate = self;
        // 隐藏水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
    }
    return _scrollView;
}

- (LiteAlertLabel *)companyWarningLabel{
    if (!_companyWarningLabel) {
        _companyWarningLabel = [[LiteAlertLabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 34)];
        _companyWarningLabel.alertImageView.image = [UIImage imageNamed:@"account_warning_tips"];
        _companyWarningLabel.titleLabel.text = @"发票抬头默认资质信息内的公司主体名称。";
        _companyWarningLabel.titleLabel.textAlignment = NSTextAlignmentLeft;
        _companyWarningLabel.titleLabel.textColor = UIColorDrakBlackText;
        _companyWarningLabel.titleLabel.font = [UIFont systemFontOfSize:14];
        _companyWarningLabel.layer.masksToBounds = NO;
        _companyWarningLabel.backgroundColor = UIColorClearColor;
        [_companyWarningLabel.layer setCornerRadius:0];          //设置那个圆角
        [_companyWarningLabel.layer setBorderWidth:0];         //设置边框线的宽
        [_companyWarningLabel.layer setBorderColor:[UIColorClearColor CGColor]];   //设置边框线的颜色
        [_companyWarningLabel.layer setMasksToBounds:YES];       //是否设置边框以及是否可见
    }
    return _companyWarningLabel;
}

- (UIScrollView *)companyScrollView
{
    if (!_companyScrollView)
    {
        // 创建UIScrollView
        _companyScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 34, kScreenWidth, 200)];
        _companyScrollView.backgroundColor = UIColorClearColor;
        _companyScrollView.bounces = NO;
        // 设置scrollView的属性
        _companyScrollView.pagingEnabled = NO;
        // 设置UIScrollView的滚动范围（内容大小）
        if (IS_IPhoneX) {
            _companyScrollView.contentSize = CGSizeMake(kScreenWidth, 60 * 13);
        } else {
            _companyScrollView.contentSize = CGSizeMake(kScreenWidth, 60 * 12.5);
        }
        _companyScrollView.delegate = self;
        // 隐藏水平滚动条
        _companyScrollView.showsHorizontalScrollIndicator = NO;
        _companyScrollView.showsVerticalScrollIndicator = NO;
    
    }
    return _companyScrollView;
}

- (UIScrollView *)personScrollView
{
    if (!_personScrollView)
    {
        // 创建UIScrollView
        _personScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kScreenWidth, 0, kScreenWidth, 200)];
        _personScrollView.backgroundColor = UIColorClearColor;
        _personScrollView.bounces = NO;
        // 设置scrollView的属性
        _personScrollView.pagingEnabled = NO;
        // 设置UIScrollView的滚动范围（内容大小）
        _personScrollView.contentSize = CGSizeMake(kScreenWidth, 60 * 4);
        _personScrollView.delegate = self;
        // 隐藏水平滚动条
        _personScrollView.showsHorizontalScrollIndicator = NO;
        _personScrollView.showsVerticalScrollIndicator = NO;
    }
    return _personScrollView;
}

- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
        [_nextButton setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [_nextButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_nextButton setBackgroundColor:UIColorBlue];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
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
