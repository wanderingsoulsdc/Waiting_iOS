//
//  FSBaseNavigationController.m
//
//
//  Created by QiuLiang Chen QQ：1123548362 on 16/5/23.
//  Copyright © 2016年. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "FSBaseNavigationController.h"

@interface FSBaseNavigationController ()


@end

@implementation FSBaseNavigationController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here, just add subviews
    
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                UIColorDrakBlackText,
                                                NSForegroundColorAttributeName,
                                                [UIFont systemFontOfSize:17],
                                                NSFontAttributeName,
                                                nil]];

    [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];

    //让导航控制器不透明
    self.navigationBar.translucent = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // You should add notification here
    
}

#pragma mark - SystemDelegate


- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

#pragma mark - CustomDelegate

#pragma mark - Event response
// button、gesture, etc


#pragma mark - Private methods



#pragma mark - Getters and Setters
// initialize views here, etc


#pragma mark - rewrite method

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (self.viewControllers.count != 0) {
//        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
//    }
//
    [super pushViewController:viewController animated:animated];
}

//- (void)back
//{
//    [self popViewControllerAnimated:YES];
//}

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
