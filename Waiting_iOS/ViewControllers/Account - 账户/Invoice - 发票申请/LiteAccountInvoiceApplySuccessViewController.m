//
//  LiteAccountInvoiceApplySuccessViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/25.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteAccountInvoiceApplySuccessViewController.h"
#import <Masonry/Masonry.h>
#import "LiteAccountInvoiceReportViewController.h"
#import "UIViewController+NavigationItem.h"

@interface LiteAccountInvoiceApplySuccessViewController ()
@property (nonatomic, strong) UIImageView * checkSuccessImageView;
@property (nonatomic, strong) UILabel     * successLabel;
@property (nonatomic, strong) UIButton    * confirmButton;
@end

@implementation LiteAccountInvoiceApplySuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发票申请提交成功";
    self.view.backgroundColor = UIColorFromRGB(0xFAFAFA);
    
    // You should add subviews here, just add subviews
    [self.view addSubview:self.checkSuccessImageView];
    [self.view addSubview:self.successLabel];
    [self.view addSubview:self.confirmButton];
    
    // You should add notification here
    
    
    // layout subviews
    [self layoutSubviews];
    
    [self setLeftBarButtonTarget:self Action:@selector(leftBarButtonAction:) Image:@""];
    // Do any additional setup after loading the view.
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    [self.checkSuccessImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
        make.width.height.equalTo(@120);
    }];
    [self.successLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.checkSuccessImageView.mas_bottom).offset(15);
        make.height.equalTo(@20);
    }];
    [self.confirmButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.successLabel.mas_bottom).offset(80);
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.height.equalTo(@40);
    }];
}

#pragma mark - SystemDelegate



#pragma mark - CustomDelegate



#pragma mark - Event response
// button、gesture, etc

- (void)confirmButtonAction:(UIButton *)sender
{
    NSLog(@"确定");
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[LiteAccountInvoiceReportViewController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kInvoiceApplySuccessNotification object:nil];
            LiteAccountInvoiceReportViewController *vc =(LiteAccountInvoiceReportViewController *)controller;
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

- (void)leftBarButtonAction:(UIButton *)sender
{
    NSLog(@"取消掉返回按钮");
}

#pragma mark - Private methods


#pragma mark - Getters and Setters
// initialize views here, etc

- (UIImageView *)checkSuccessImageView
{
    if (!_checkSuccessImageView)
    {
        _checkSuccessImageView = [[UIImageView alloc] init];
        _checkSuccessImageView.contentMode = UIViewContentModeScaleAspectFit;
        _checkSuccessImageView.image = [UIImage imageNamed:@"login_register_success"];
    }
    return _checkSuccessImageView;
}
- (UILabel *)successLabel
{
    if (!_successLabel)
    {
        _successLabel = [[UILabel alloc] init];
        _successLabel.text = @"发票申请已提交";
        _successLabel.textColor = UIColorFromRGB(0x797E81);
        _successLabel.font = [UIFont systemFontOfSize:16];
        _successLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _successLabel;
}
- (UIButton *)confirmButton
{
    if (!_confirmButton)
    {
        _confirmButton = [[UIButton alloc] init];
        _confirmButton.backgroundColor = UIColorBlue;
        [_confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _confirmButton.layer.cornerRadius = 2;
        _confirmButton.clipsToBounds = YES;
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
