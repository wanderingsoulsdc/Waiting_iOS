//
//  MyViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyViewController.h"
#import "MyRechargeViewController.h"
#import "MySetViewController.h"
#import "MyEditInfoViewController.h"
#import "TestPayController.h"

@interface MyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView    * headImageView;
@property (weak, nonatomic) IBOutlet UILabel        * idLabel;
@property (weak, nonatomic) IBOutlet UILabel        * userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel        * sexAgeLabel;
@property (weak, nonatomic) IBOutlet UIButton       * editInformationButton;
@property (weak, nonatomic) IBOutlet UILabel        * AccountMoneyLabel;

@end

@implementation MyViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
    
    // You should add subviews here
    // You should add notification here
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
#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.editInformationButton.layer.borderWidth = 1;
    self.editInformationButton.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:@"http://v.behe.com/dsp20/ad/2018/8/14/15342297730008214.jpg"] placeholderImage:[UIImage imageNamed:@"phone_default_head"]];
}

#pragma mark - ******* Action Methods *******
//编辑资料
- (IBAction)editInformationButtonAction:(UIButton *)sender {
    MyEditInfoViewController *vc = [[MyEditInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
//点击账户余额
- (IBAction)accountMoneyAction:(UIButton *)sender {
//    MyRechargeViewController *vc = [[MyRechargeViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
    TestPayController *vc = [[TestPayController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
//点击设置
- (IBAction)AccountSetButtonAction:(UIButton *)sender {
    MySetViewController *vc = [[MySetViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - ******* Other *******

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
