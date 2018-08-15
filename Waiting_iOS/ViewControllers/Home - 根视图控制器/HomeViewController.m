//
//  HomeViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/8/14.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "HomeViewController.h"
#import "MyViewController.h"
#import "MatchListViewController.h"
#import "ChatListViewController.h"
#import "Masonry.h"

@interface HomeViewController ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIView               * topView;
@property (nonatomic , strong) UIButton             * leftButton;
@property (nonatomic , strong) UIButton             * midButton;
@property (nonatomic , strong) UIButton             * rightButton;
@property (nonatomic , strong) UIScrollView         * scrollView;

@end

@implementation HomeViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here
    [self createUI];
    
    [self layoutSubviews];
    
    // You should add notification here
    
    // Do any additional setup after loading the view.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - ******* UI Methods *******

- (void)createUI{
    [self.view addSubview:self.topView];

    [self.topView addSubview:self.leftButton];
    [self.topView addSubview:self.midButton];
    [self.topView addSubview:self.rightButton];
    
    [self.view addSubview:self.scrollView];
    
    [self layoutSubviews];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    MyViewController *myVC = [[MyViewController alloc] init];
    [self addChildViewController:myVC];          //1
    myVC.view.frame = CGRectMake(0, 0, kScreenWidth, self.scrollView.height);
    [self.scrollView addSubview:myVC.view];      //2
    [myVC didMoveToParentViewController:self];   //3
    
    MatchListViewController *matchListVC = [[MatchListViewController alloc] init];
    [self addChildViewController:matchListVC];        //1
    matchListVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.scrollView.height);
    [self.scrollView addSubview:matchListVC.view];    //2
    [matchListVC didMoveToParentViewController:self]; //3
    
    ChatListViewController *chatListVC = [[ChatListViewController alloc] init];
    [self addChildViewController:chatListVC];        //1
    chatListVC.view.frame = CGRectMake(kScreenWidth * 2, 0, kScreenWidth, self.scrollView.height);
    [self.scrollView addSubview:chatListVC.view];    //2
    [chatListVC didMoveToParentViewController:self]; //3
}

- (void)layoutSubviews{
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(kStatusBarAndNavigationBarHeight);
    }];
    
    [self.midButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView.mas_centerX);
        make.bottom.equalTo(self.topView).offset(-5);
        make.height.equalTo(@34);
        make.width.equalTo(@34);
    }];
    
    [self.leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.midButton.mas_centerY);
        make.left.equalTo(self.topView).offset(15);
        make.height.equalTo(@34);
        make.width.equalTo(@34);
    }];
    
    [self.rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.midButton.mas_centerY);
        make.right.equalTo(self.topView).offset(-15);
        make.height.equalTo(@34);
        make.width.equalTo(@34);
    }];
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    
    [self.scrollView.superview layoutIfNeeded];
}

#pragma mark - ******* Scroll Delegate *******

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.scrollView]) {
        return;
    }
    CGFloat OffsetX = scrollView.contentOffset.x;
    if (OffsetX == kScreenWidth) {
        //滑到第二个按钮
        self.midButton.selected = YES;
        self.leftButton.selected = NO;
        self.rightButton.selected = NO;
    }else if (OffsetX == kScreenWidth * 2){
        //滑到第三个按钮
        self.midButton.selected = NO;
        self.leftButton.selected = NO;
        self.rightButton.selected = YES;
    }else{
        //滑到第一个按钮
        self.midButton.selected = NO;
        self.leftButton.selected = YES;
        self.rightButton.selected = NO;
    }
}

#pragma mark - ******* Action Methods *******

//左侧按钮点击
- (void)leftButtonAction{
    self.midButton.selected = NO;
    self.leftButton.selected = YES;
    self.rightButton.selected = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentOffset = CGPointMake(0, 0);
    }];
}
//中间按钮点击
- (void)midButtonAction{
    self.midButton.selected = YES;
    self.leftButton.selected = NO;
    self.rightButton.selected = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
    }];
}
//右侧按钮点击
- (void)rightButtonAction{
    self.midButton.selected = NO;
    self.leftButton.selected = NO;
    self.rightButton.selected = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentOffset = CGPointMake(kScreenWidth * 2, 0);
    }];
}


#pragma mark - ******* Private Methods *******

#pragma mark - ******* Getter *******

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarAndNavigationBarHeight)];
        _topView.backgroundColor = UIColorBlue;
    }
    return _topView;
}

- (UIButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(15, 0, 70, 30);
        
        [_leftButton setImage:[UIImage imageNamed:@"ads_contact_customer_service"] forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"ads_contact_customer_service_red"] forState:UIControlStateSelected];
        
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)midButton{
    if (!_midButton) {
        _midButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _midButton.frame = CGRectMake(15, 0, 70, 30);
        
        [_midButton setImage:[UIImage imageNamed:@"ads_contact_customer_service"] forState:UIControlStateNormal];
        [_midButton setImage:[UIImage imageNamed:@"ads_contact_customer_service_red"] forState:UIControlStateSelected];
        
        [_midButton addTarget:self action:@selector(midButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _midButton;
}

- (UIButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(15, 0, 70, 30);
        
        [_rightButton setImage:[UIImage imageNamed:@"ads_contact_customer_service"] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"ads_contact_customer_service_red"] forState:UIControlStateSelected];
        
        [_rightButton addTarget:self action:@selector(rightButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        // 创建UIScrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kStatusBarAndNavigationBarHeight - 49 - SafeAreaBottomHeight)];
        _scrollView.backgroundColor = UIColorClearColor;
        _scrollView.bounces = NO;
        // 设置scrollView的属性
        _scrollView.pagingEnabled = YES;
        // 设置UIScrollView的滚动范围（内容大小）
        _scrollView.contentSize = CGSizeMake(kScreenWidth*3, 0);
        _scrollView.delegate = self;
        // 隐藏水平滚动条
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
    }
    return _scrollView;
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
