//
//  FSBaseTabBarController.m
//
//
//  Created by QiuLiang Chen QQ：1123548362 on 16/5/23.
//  Copyright © 2016年. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "FSBaseTabBarController.h"
#import "LiteMainViewController.h"
#import "LiteADsManagerViewController.h"
#import "LiteAccountViewController.h"
#import "FSBaseNavigationController.h"
#import "PlusAnimate.h"
#import "BHUserModel.h"

@interface FSBaseTabBarController ()

@property (nonatomic, strong) UIButton *centerButton;

@end

@implementation FSBaseTabBarController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here, just add subviews
    
    //移除顶部线条
    self.tabBar.backgroundImage = [UIImage new];
    self.tabBar.shadowImage = [UIImage new];
    
    //添加阴影
    self.tabBar.layer.shadowColor = UIColorGray.CGColor;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -5);
    self.tabBar.layer.shadowOpacity = 0.3;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // You should add notification here
    
}

#pragma mark - SystemDelegate
//是否支持旋转
- (BOOL)shouldAutorotate{
    return self.selectedViewController.shouldAutorotate;
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return self.selectedViewController.supportedInterfaceOrientations;
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
//}

#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

#pragma mark - Public methods
- (void)pushToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)self.selectedViewController;
        viewController.hidesBottomBarWhenPushed = YES;
        [nav pushViewController:viewController animated:animated];
    }
}

- (void)launchTabbar{
    // 首页
    LiteMainViewController * mainViewController = [[LiteMainViewController alloc] init];
    mainViewController.title = @"首页";
    [mainViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-4)];
    mainViewController.tabBarItem.image = [[UIImage imageNamed:@"tabbar_main_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    mainViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_main_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    FSBaseNavigationController * mainNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:mainViewController];
    
    // 营销
    LiteADsManagerViewController * ADsViewController = [[LiteADsManagerViewController alloc] init];
    ADsViewController.title = @"营销";
    [ADsViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-4)];
    ADsViewController.tabBarItem.image = [[UIImage imageNamed:@"tabbar_manager_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    ADsViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_manager_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    FSBaseNavigationController * ADsNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:ADsViewController];
    
    // 账户
    LiteAccountViewController * accountViewController = [[LiteAccountViewController alloc] init];
    accountViewController.title = @"账户";
    [accountViewController.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0,-4)];
    accountViewController.tabBarItem.image = [[UIImage imageNamed:@"tabbar_account_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    accountViewController.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar_account_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    FSBaseNavigationController * accountNavigationController = [[FSBaseNavigationController alloc] initWithRootViewController:accountViewController];
    
    
    NSMutableArray * viewControllers = [NSMutableArray arrayWithCapacity:0];
    [viewControllers addObject:mainNavigationController];
    [viewControllers addObject:ADsNavigationController];
    [viewControllers addObject:accountNavigationController];
    self.viewControllers = viewControllers;
    
    // 使用颜色创建UIImage
    UIColor * bgColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1];
    CGRect rect = CGRectMake(0.0f, 0.0f, 10.0f, 49.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [bgColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // setup UI Image
    UIColor * color = [UIColor colorWithRed:80.0/255.0 green:244.0/255.0 blue:206.0/255.0 alpha:1];
    //    [self.rootTabBarController.tabBar setShadowImage:[UIImage createImageWithColor:UIColorFromRGB(0xdbdbdb) size:CGSizeMake(kScreenWidth, 1)]];       // tabbar上面的那条线
    [self.tabBar setBackgroundImage:bgImage];
    [self.tabBar setTintColor:color];        // 选中颜色
    
    
    
    //自定义按钮
    _centerButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-52)/2, -6, 52, 52)];
    [_centerButton setImage:[UIImage imageNamed:@"tabbar_center_icon"] forState:UIControlStateNormal];
    [_centerButton setImage:[UIImage imageNamed:@"tabbar_center_icon"] forState:UIControlStateHighlighted];
    [_centerButton addTarget:self action:@selector(tabBarDidCenterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self hideCenterItem];
    [self.tabBar addSubview:_centerButton];
    
    // set TabbarItem title selected color
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xDFDFDF), NSForegroundColorAttributeName, [UIFont fontWithName:@"Helvetica" size:10.0f],NSFontAttributeName,nil] forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0x4895F2), NSForegroundColorAttributeName, [UIFont fontWithName:@"Helvetica" size:10.0f],NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    //默认选择主页
    self.selectedIndex = 0;
    
    SharedApp.window.rootViewController = self;

}

#pragma mark - Private methods

- (void)tabBarDidCenterButton:(UIButton *)button
{
    NSInteger status = [[BHUserModel sharedInstance].auditStatus integerValue];
    //资质审核状态  -1 未上传 0-审核中 1-审核通过  2-拒绝
    switch (status) {
        case 0:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"资质信息审核中" message:@"请等待资质信息审核通过后进行营销活动创建" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alert addAction:cancelButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        case 1:
            {
                [PlusAnimate standardPublishAnimateWithView:button];
            }
            break;
        case 2:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"资质信息审核拒绝" message:@"您当前账户资质信息审核拒绝，所以无法创建营销活动" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"稍后上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alert addAction:cancelButton];
                
                UIAlertAction *button = [UIAlertAction actionWithTitle:@"立即上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //立即上传
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateQualificationNotification object:nil];
                }];
                [alert addAction:button];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        default:
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"未上传资质" message:@"您当前账户未上传资质信息，所以无法创建营销活动" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"稍后上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                }];
                [alert addAction:cancelButton];
                
                UIAlertAction *button = [UIAlertAction actionWithTitle:@"立即上传" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //立即上传
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateQualificationNotification object:nil];
                }];
                [alert addAction:button];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
    }
}

-(void)showCenterItem{
    [_centerButton setHidden:NO];
}

-(void)hideCenterItem{
    [_centerButton setHidden:YES];
}

#pragma mark - Getters and Setters
// initialize views here, etc



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
