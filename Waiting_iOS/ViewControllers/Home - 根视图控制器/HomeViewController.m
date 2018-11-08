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
#import "NoHighlightButton.h"

#define kscale (kScreenWidth/2 - 15 - 34/2)/kScreenWidth

@interface HomeViewController ()<UIScrollViewDelegate,NIMConversationManagerDelegate>

@property (nonatomic , strong) UIView               * topView;
@property (nonatomic , strong) UIView               * NavButtonBackView;
@property (nonatomic , strong) NoHighlightButton    * leftButton;
@property (nonatomic , strong) NoHighlightButton    * midButton;
@property (nonatomic , strong) NoHighlightButton    * rightButton;
@property (nonatomic , strong) UIScrollView         * scrollView;
@property (nonatomic , strong) UILabel              * unReadCountLabel;  //未读消息数显示

@property (nonatomic , assign) NSInteger            sessionUnreadCount;  //未读消息数

@end

@implementation HomeViewController
{
    CGFloat scrollContentOffsetX;
    CGFloat navButtonBackViewLeft;
}
#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here
    [self createUI];
    
    [self layoutSubviews];
    
    // You should add notification here
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];

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

- (void)dealloc{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}
#pragma mark - ******* UI Methods *******

- (void)createUI{
    [self.view addSubview:self.topView];

    [self.topView addSubview:self.NavButtonBackView];

    [self.NavButtonBackView addSubview:self.leftButton];
    [self.NavButtonBackView addSubview:self.midButton];
    [self.NavButtonBackView addSubview:self.rightButton];
    [self.NavButtonBackView addSubview:self.unReadCountLabel];
//    self.unReadCountLabel.left = self.rightButton.left + 14;
    [self.unReadCountLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.rightButton.mas_right).offset(-5);
        make.top.equalTo(self.NavButtonBackView.mas_top).offset(5);
        make.height.equalTo(@14);
        make.width.greaterThanOrEqualTo(@14);
    }];

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
    
    
    scrollContentOffsetX = kScreenWidth;
    navButtonBackViewLeft = 15;
    
    [self.scrollView setContentOffset:CGPointMake(scrollContentOffsetX, 0)];
    self.midButton.selected = YES;
}

- (void)layoutSubviews{
    
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    
    [self.scrollView.superview layoutIfNeeded];
}

#pragma mark - ******* Scroll Delegate *******

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
    if (![scrollView isEqual:self.scrollView]) {
        return;
    }
    if (scrollView.contentOffset.x - scrollContentOffsetX >= 0) {//画面左移  nav左移
        self.NavButtonBackView.left = navButtonBackViewLeft - (scrollView.contentOffset.x - scrollContentOffsetX)*kscale;
    } else {//画面右移 nav右移
        self.NavButtonBackView.left = navButtonBackViewLeft - (scrollView.contentOffset.x - scrollContentOffsetX)*kscale;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (![scrollView isEqual:self.scrollView]) {
        return;
    }
    CGFloat OffsetX = scrollView.contentOffset.x;
    scrollContentOffsetX = OffsetX;
    if (OffsetX == kScreenWidth) {
        //滑到第二个按钮
        self.midButton.selected = YES;
        self.leftButton.selected = NO;
        self.rightButton.selected = NO;
        navButtonBackViewLeft = 15;

    }else if (OffsetX == kScreenWidth * 2){
        //滑到第三个按钮
        self.midButton.selected = NO;
        self.leftButton.selected = NO;
        self.rightButton.selected = YES;
        navButtonBackViewLeft =  15 - (kScreenWidth/2 - 34/2 -15 /*移动距离*/);

    }else{
        //滑到第一个按钮
        self.midButton.selected = NO;
        self.leftButton.selected = YES;
        self.rightButton.selected = NO;
        navButtonBackViewLeft = kScreenWidth/2 - 34/2;
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
        self.NavButtonBackView.left = kScreenWidth/2 - 34/2;
    }];
    navButtonBackViewLeft = kScreenWidth/2 - 34/2;
    scrollContentOffsetX = 0;
}
//中间按钮点击
- (void)midButtonAction{
    self.midButton.selected = YES;
    self.leftButton.selected = NO;
    self.rightButton.selected = NO;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
        self.NavButtonBackView.left = 15;
    }];
    navButtonBackViewLeft = 15;
    scrollContentOffsetX = kScreenWidth;
}
//右侧按钮点击
- (void)rightButtonAction{
    self.midButton.selected = NO;
    self.leftButton.selected = NO;
    self.rightButton.selected = YES;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentOffset = CGPointMake(kScreenWidth * 2, 0);
        self.NavButtonBackView.right = kScreenWidth/2 + 34/2;
    }];
    scrollContentOffsetX = kScreenWidth * 2;
    navButtonBackViewLeft = kScreenWidth/2 + 34/2;
}

#pragma mark - NIMConversationManagerDelegate
- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}


- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession totalUnreadCount:(NSInteger)totalUnreadCount{
    self.sessionUnreadCount = totalUnreadCount;
    [self refreshSessionBadge];
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    self.sessionUnreadCount = [NIMSDK sharedSDK].conversationManager.allUnreadCount;
    [self refreshSessionBadge];
}

- (void)allMessagesDeleted{
    self.sessionUnreadCount = 0;
    [self refreshSessionBadge];
}

- (void)allMessagesRead
{
    self.sessionUnreadCount = 0;
    [self refreshSessionBadge];
}
#pragma mark - ******* Private Methods *******
- (void)refreshSessionBadge{
    if (self.sessionUnreadCount) {
        self.unReadCountLabel.hidden = NO;
        self.unReadCountLabel.text = @(self.sessionUnreadCount).stringValue;
    }else{
        self.unReadCountLabel.hidden = YES;
    }
}
#pragma mark - ******* Getter *******

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kStatusBarAndNavigationBarHeight)];
        _topView.backgroundColor = UIColorWhite;
    }
    return _topView;
}

- (UIView *)NavButtonBackView{
    if (!_NavButtonBackView) {
        _NavButtonBackView = [[UIView alloc] initWithFrame:CGRectMake(15, kStatusBarHeight, kScreenWidth-30, 44)];
        _NavButtonBackView.backgroundColor = UIColorClearColor;
    }
    return _NavButtonBackView;
}

- (UILabel *)unReadCountLabel{
    if (!_unReadCountLabel) {
        _unReadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 22, 14)];
        _unReadCountLabel.textAlignment = NSTextAlignmentCenter;
        _unReadCountLabel.font = [UIFont systemFontOfSize:10];
        _unReadCountLabel.textColor = UIColorWhite;
        _unReadCountLabel.backgroundColor = [UIColor redColor];
        _unReadCountLabel.layer.cornerRadius = 7;
        _unReadCountLabel.layer.masksToBounds = YES;
        _unReadCountLabel.hidden = YES;
    }
    return _unReadCountLabel;
}

- (NoHighlightButton *)leftButton{
    if (!_leftButton) {
        _leftButton = [NoHighlightButton buttonWithType:UIButtonTypeCustom];
        _leftButton.frame = CGRectMake(0, 5, 34, 34);
        _leftButton.adjustsImageWhenHighlighted = NO;
        [_leftButton setImage:[UIImage imageNamed:@"nav_my_icon_unselected"] forState:UIControlStateNormal];
        [_leftButton setImage:[UIImage imageNamed:@"nav_my_icon_selected"] forState:UIControlStateSelected];
        
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (NoHighlightButton *)midButton{
    if (!_midButton) {
        _midButton = [NoHighlightButton buttonWithType:UIButtonTypeCustom];
        _midButton.frame = CGRectMake(kScreenWidth/2 - 15 - 34/2, 5, 34, 34);
        _midButton.adjustsImageWhenHighlighted = NO;
        [_midButton setImage:[UIImage imageNamed:@"nav_match_icon_unselected"] forState:UIControlStateNormal];
        [_midButton setImage:[UIImage imageNamed:@"nav_match_icon_selected"] forState:UIControlStateSelected];
        
        [_midButton addTarget:self action:@selector(midButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _midButton;
}

- (NoHighlightButton *)rightButton{
    if (!_rightButton) {
        _rightButton = [NoHighlightButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(kScreenWidth-15*2-34, 5, 34, 34);
        _rightButton.adjustsImageWhenHighlighted = NO;
        [_rightButton setImage:[UIImage imageNamed:@"nav_chat_icon_unselected"] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"nav_chat_icon_selected"] forState:UIControlStateSelected];
        
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
