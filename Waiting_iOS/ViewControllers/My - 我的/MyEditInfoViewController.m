//
//  MyEditInfoViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "MyEditInfoViewController.h"

@interface MyEditInfoViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * scrollViewBottomConstraint;

@end

@implementation MyEditInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    self.topViewHeightConstraint.constant = kStatusBarAndNavigationBarHeight;
    self.scrollViewBottomConstraint.constant = SafeAreaBottomHeight;
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
