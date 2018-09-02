//
//  MyRechargeViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyRechargeViewController.h"

@interface MyRechargeViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewTopConstraint; //顶部视图 距上约束
@property (weak, nonatomic) IBOutlet UILabel * diamondLabel; //钻石
@property (weak, nonatomic) IBOutlet UIButton * MoneyOneButton;
@property (weak, nonatomic) IBOutlet UIButton * MoneyTwoButton;
@property (weak, nonatomic) IBOutlet UIButton * MoneyThreeButton;
@property (weak, nonatomic) IBOutlet UIButton * MoneyFourButton;
@property (weak, nonatomic) IBOutlet UIButton * MoneyFiveButton;
@property (weak, nonatomic) IBOutlet UIButton * MoneySixButton;

@property (nonatomic , strong) UIButton * currentSelectButton;
@property (nonatomic , strong) NSString * currentSelectMoney;
@property (nonatomic , strong) NSString * currentSelectDiamond;

@end

@implementation MyRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self createUI];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewTopConstraint.constant = kStatusBarHeight;
    
    //设置金额
    [self setDiamond:@"42" Money:@"6" ForButton:self.MoneyOneButton];
    [self setDiamond:@"210" Money:@"30" ForButton:self.MoneyTwoButton];
    [self setDiamond:@"3500" Money:@"50" ForButton:self.MoneyThreeButton];
    [self setDiamond:@"8960" Money:@"128" ForButton:self.MoneyFourButton];
    [self setDiamond:@"22960" Money:@"328" ForButton:self.MoneyFiveButton];
    [self setDiamond:@"43210" Money:@"618" ForButton:self.MoneySixButton];
    
}

#pragma mark - ******* Action Methods *******

- (IBAction)moneySelectAction:(UIButton *)sender {

    if (sender == self.currentSelectButton) {
        return;
    }
    
    sender.layer.borderWidth = 1.5f;
    sender.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
    
    switch (sender.tag) {
        case 100:{
            self.currentSelectDiamond = @"42";
            self.currentSelectMoney = @"6";
        }
            break;
        case 101:{
            self.currentSelectDiamond = @"210";
            self.currentSelectMoney = @"30";
        }
            break;
        case 102:{
            self.currentSelectDiamond = @"3500";
            self.currentSelectMoney = @"50";
        }
            break;
        case 103:{
            self.currentSelectDiamond = @"8960";
            self.currentSelectMoney = @"128";
        }
            break;
        case 104:{
            self.currentSelectDiamond = @"22960";
            self.currentSelectMoney = @"328";
        }
            break;
        case 105:{
            self.currentSelectDiamond = @"43210";
            self.currentSelectMoney = @"618";
        }
            break;
            
        default:
            break;
    }
    
    self.currentSelectButton.layer.borderWidth = 0.5f;
    self.currentSelectButton.layer.borderColor = UIColorFromRGB(0xE0E0E0).CGColor;
    
    self.currentSelectButton = sender;
}
- (IBAction)confirmButtonAction:(UIButton *)sender {
    NSLog(@"充值金额-> %@   得到钻石-> %@",self.currentSelectMoney,self.currentSelectDiamond);
    self.diamondLabel.text = [NSString stringWithFormat:@"%ld",[self.currentSelectDiamond integerValue]+[self.diamondLabel.text integerValue]];
}
- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ******* Pravite *******

- (void)setDiamond:(NSString *)diamond Money:(NSString *)money ForButton:(UIButton *)button{
    //第一行
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@\n",diamond,@"钻石"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:UIColorFromRGB(0x9014FC)}];
    //第二行
    NSAttributedString *time = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",money,@"元"] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0x666666)}];
    
    [title appendAttributedString:time];
    //段落设置
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setLineSpacing:8]; //行距
    paraStyle.alignment = NSTextAlignmentCenter;
    [title addAttributes:@{NSParagraphStyleAttributeName:paraStyle} range:NSMakeRange(0, title.length)];
    
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [button setAttributedTitle:title forState:UIControlStateNormal];
    [button setAttributedTitle:title forState:UIControlStateSelected];
    
    button.layer.borderWidth = 0.5f;
    button.layer.borderColor = UIColorFromRGB(0xE0E0E0).CGColor;
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
