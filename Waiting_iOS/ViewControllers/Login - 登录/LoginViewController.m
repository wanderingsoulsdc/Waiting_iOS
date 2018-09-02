//
//  LoginViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/28.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * bottomViewHeightConstraint;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bottomViewHeightConstraint.constant = SafeAreaBottomHeight;
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - ******* Action *******

//注册协议
- (IBAction)agreementAction:(UIButton *)sender {
}
//twitter
- (IBAction)twitterAction:(UIButton *)sender {
}
//facebook
- (IBAction)facebookAction:(UIButton *)sender {
}
//google
- (IBAction)googleAction:(UIButton *)sender {
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
