//
//  LiteReadyStartViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/7/9.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteReadyStartViewController.h"
#import "CircleSpreadTransition.h"
#import "Masonry.h"

@interface LiteReadyStartViewController ()<UIViewControllerTransitioningDelegate>

@property (nonatomic , strong) UILabel *zhLabel;
@property (nonatomic , strong) UILabel *enLabel;

@end

@implementation LiteReadyStartViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorBlue;
    
    [self.view addSubview:self.zhLabel];
    [self.view addSubview:self.enLabel];
    
    [self layoutSubviews];
    // Do any additional setup after loading the view.
}

//视图布局
- (void)layoutSubviews{
    [self.zhLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_centerY).offset(-30);
        make.height.equalTo(@125);
    }];
    
    [self.enLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.zhLabel.mas_bottom);
        make.height.equalTo(@45);
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    self.zhLabel.text = @"开始";
    self.enLabel.text = @"GO";
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [CircleSpreadTransition transitionWithTransitionType:CircleSpreadTransitionTypePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return [CircleSpreadTransition transitionWithTransitionType:CircleSpreadTransitionTypeDismiss];
}

#pragma mark - ******* Getter *******

- (UILabel *)zhLabel{
    if (!_zhLabel) {
        _zhLabel = [[UILabel alloc] init];
        _zhLabel.text = @"准备";
        _zhLabel.textAlignment = NSTextAlignmentCenter;
        _zhLabel.font = [UIFont systemFontOfSize:96];
        _zhLabel.textColor = UIColorWhite;
    }
    return _zhLabel;
}

- (UILabel *)enLabel{
    if (!_enLabel) {
        _enLabel = [[UILabel alloc] init];
        _enLabel.text = @"READY";
        _enLabel.textColor = UIColorWhite;
        _enLabel.textAlignment = NSTextAlignmentCenter;
        _enLabel.font = [UIFont systemFontOfSize:36];
    }
    return _enLabel;
}


- (void)dealloc{
    NSLog(@"ReadyStart页面销毁了");
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
