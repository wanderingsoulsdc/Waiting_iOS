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
#import "FSNetWorkManager.h"
#import "BHUserModel.h"

@interface MyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView    * headImageView;
@property (weak, nonatomic) IBOutlet UILabel        * idLabel;
@property (weak, nonatomic) IBOutlet UILabel        * userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel        * sexAgeLabel;
@property (weak, nonatomic) IBOutlet UIButton       * editInformationButton;
@property (weak, nonatomic) IBOutlet UILabel        * AccountMoneyLabel;

@property (nonatomic , strong) NSString                 * headUrlStr;   //头像图片链接
@property (nonatomic , strong) NSString                 * idStr;        //uid
@property (nonatomic , strong) NSString                 * userNameStr;  //用户名
@property (nonatomic , strong) NSString                 * genderStr;    //性别
@property (nonatomic , strong) NSString                 * ageStr;       //年龄

@property (nonatomic , strong) NSString                 * diamond;       //钻石

@property (nonatomic , assign) BOOL                 isRequestingUserInfo;   //是否正在请求用户信息
@property (nonatomic , assign) BOOL                 isRequestingAccountData;//是否正在请求账户余额

@end

@implementation MyViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createUI];
    [self requestUserInfo];
    [self requestAccountData];
    
    // You should add subviews here
    // You should add notification here
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self requestUserInfo];
    [self requestAccountData];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.editInformationButton.layer.borderWidth = 1;
    self.editInformationButton.layer.borderColor = UIColorFromRGB(0x9014FC).CGColor;
    [self refreshData];
}

- (void)refreshData{
    self.headUrlStr = [BHUserModel sharedInstance].userHeadImageUrl;
    self.userNameStr = [BHUserModel sharedInstance].userName;
    self.idStr = [BHUserModel sharedInstance].userID;
    self.genderStr = [BHUserModel sharedInstance].gender_txt;
    self.ageStr = [BHUserModel sharedInstance].age;
    self.diamond = [BHUserModel sharedInstance].diamond;

    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.headUrlStr] placeholderImage:[UIImage imageNamed:@"phone_default_head"]];

    self.idLabel.text = [NSString stringWithFormat:@"ID : %@",self.idStr];
    self.userNameLabel.text = self.userNameStr;
    self.sexAgeLabel.text = [NSString stringWithFormat:@"%@ · %@",self.genderStr,self.ageStr];
    self.AccountMoneyLabel.text = self.diamond;
}

#pragma mark - ******* Request *******
//请求用户信息
- (void)requestUserInfo{
    if (self.isRequestingUserInfo) return;
    self.isRequestingUserInfo = YES;
    WEAKSELF
    NSDictionary * params = @{};
    
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountGetUserInfo
                        withParaments:params withSuccessBlock:^(NSDictionary *object) {
                            NSLog(@"请求成功");
                            weakSelf.isRequestingUserInfo = NO;
                            if (NetResponseCheckStaus){
                                [[BHUserModel sharedInstance] analysisUserInfoWithDictionary:object];
                                [weakSelf refreshData];
                            }else{
                                [ShowHUDTool showBriefAlert:NetResponseMessage];
                            }
                        } withFailureBlock:^(NSError *error) {
                            weakSelf.isRequestingUserInfo = NO;
                            [ShowHUDTool showBriefAlert:NetRequestFailed];
                        }];
}

//请求账户数据获得钻石数量
- (void)requestAccountData
{
    if (self.isRequestingAccountData) return;
    self.isRequestingAccountData = YES;
    WEAKSELF
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiAccountGetAccountData
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         weakSelf.isRequestingAccountData = NO;
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"请求成功");
                             NSDictionary *dic = object[@"data"][@"account"];
                             [BHUserModel sharedInstance].diamond = [dic stringValueForKey:@"usable" default:@"0"];
                             [weakSelf refreshData];
                         }
                         else
                         {
                             [ShowHUDTool showBriefAlert:NetResponseMessage];
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is:%@", error);
                         weakSelf.isRequestingAccountData = NO;
                         [ShowHUDTool showBriefAlert:NetRequestFailed];
                     }];
}


#pragma mark - ******* Action Methods *******
//编辑资料
- (IBAction)editInformationButtonAction:(UIButton *)sender {
    MyEditInfoViewController *vc = [[MyEditInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
//点击账户余额
- (IBAction)accountMoneyAction:(UIButton *)sender {
    MyRechargeViewController *vc = [[MyRechargeViewController alloc] init];
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
