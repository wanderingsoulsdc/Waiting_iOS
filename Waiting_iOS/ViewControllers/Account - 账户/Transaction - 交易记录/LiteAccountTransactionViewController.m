//
//  LiteAccountTransactionViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/15.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountTransactionViewController.h"
#import "LLSegmentBarVC.h"
#import "LiteAccountRechargeReportViewController.h"
#import "LiteAccountExpenseReportViewController.h"

@interface LiteAccountTransactionViewController ()

@property (nonatomic,weak) LLSegmentBarVC * segmentVC; //选项卡视图

@end

@implementation LiteAccountTransactionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"交易记录";
    
    [self initSegment];
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

#pragma mark - private methods

- (void)initSegment{
    // 1 设置segmentBar的frame
    self.segmentVC.segmentBar.frame = CGRectMake(0, 1, kScreenWidth, 47);
    [self.view addSubview:self.segmentVC.segmentBar];
    // 2 添加控制器的View
    self.segmentVC.view.frame = CGRectMake(0, 48, kScreenWidth, kScreenHeight-48);
    [self.view addSubview:self.segmentVC.view];
    NSArray *items = @[@"消费", @"充值"];
    LiteAccountExpenseReportViewController *expense = [[LiteAccountExpenseReportViewController alloc] init];
    LiteAccountRechargeReportViewController *recharge = [[LiteAccountRechargeReportViewController alloc] init];
    // 3 添加标题数组和控住器数组
    [self.segmentVC setUpWithItems:items childVCs:@[expense,recharge]];
    // 4  配置基本设置  可采用链式编程模式进行设置
    [self.segmentVC.segmentBar updateWithConfig:^(LLSegmentBarConfig *config) {
        config.segmentBarBackColor(UIColorWhite).itemNormalColor(UIColorFromRGB(0x797E81)).itemSelectColor(UIColorDarkBlack).itemFont([UIFont systemFontOfSize:14]).indicatorColor(UIColorBlue).indicatorHeight(3).indicatorExtraW(20);
    }];
}

#pragma mark - getter

- (LLSegmentBarVC *)segmentVC{
    if (!_segmentVC) {
        LLSegmentBarVC *vc = [[LLSegmentBarVC alloc]init];
        // 添加到到控制器
        [self addChildViewController:vc];
        _segmentVC = vc;
    }
    return _segmentVC;
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
