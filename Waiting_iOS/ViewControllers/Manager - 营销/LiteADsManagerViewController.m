//
//  LiteADsManagerViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/6/13.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteADsManagerViewController.h"
#import "Masonry/Masonry.h"
#import "FSNetWorkManager.h"
#import "LiteADsPhoneListViewController.h"
#import "LiteADsMessageListViewController.h"
#import "LitePhoneSelectLabelViewController.h"
 
#import "LiteADsMessageContentViewController.h"
#import "LiteAccountQualificationViewController.h"

@interface LiteADsManagerViewController ()<UIScrollViewDelegate>

@property (nonatomic , strong) UIView               * topView;
@property (nonatomic , strong) UIButton             * leftButton;
@property (nonatomic , strong) UISegmentedControl   * segmentedControl;
@property (nonatomic , strong) UIScrollView         * scrollView;
@end

@implementation LiteADsManagerViewController

#pragma mark - ******* Life Cycle *******

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here
    [self createUI];
    
    [self layoutSubviews];
    
    // You should add notification here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabbarSelectBtnWithBtnTag:) name:kTabbarCenterButtonClickNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQualification:) name:kUpdateQualificationNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAddOrEditSuccess:) name:kMessageAddOrEditSuccessNotification object:nil];
    
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
    //联系客服
    [self.topView addSubview:self.leftButton];
    //导航条选项卡
    [self.topView addSubview:self.segmentedControl];
    
    [self.view addSubview:self.scrollView];
    
    [self layoutSubviews];
    
    [self.childViewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    LiteADsPhoneListViewController *phoneListVC = [[LiteADsPhoneListViewController alloc] init];
    [self addChildViewController:phoneListVC];          //1
    phoneListVC.view.frame = CGRectMake(0, 0, kScreenWidth, self.scrollView.height);
    [self.scrollView addSubview:phoneListVC.view];      //2
    [phoneListVC didMoveToParentViewController:self];   //3
    
    LiteADsMessageListViewController *messageListVC = [[LiteADsMessageListViewController alloc] init];
    [self addChildViewController:messageListVC];        //1
    messageListVC.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, self.scrollView.height);
    [self.scrollView addSubview:messageListVC.view];    //2
    [messageListVC didMoveToParentViewController:self]; //3
}

- (void)layoutSubviews{
    [self.topView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(kStatusBarAndNavigationBarHeight);
    }];
    
    [self.segmentedControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topView.mas_centerX);
        make.bottom.equalTo(self.topView).offset(-5);
        make.height.equalTo(@34);
        make.width.equalTo(@160);
    }];
    
    [self.leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.segmentedControl.mas_centerY);
        make.left.equalTo(self.topView).offset(15);
        make.height.equalTo(@30);
        make.width.equalTo(@70);
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
        self.segmentedControl.selectedSegmentIndex = 1;
    }else{
        //滑到第一个按钮
        self.segmentedControl.selectedSegmentIndex = 0;
    }
}

#pragma mark - ******* Action Methods *******
//分段控制器点击事件
-(void)segChange:(UISegmentedControl *)sender{
    
    switch (sender.selectedSegmentIndex) {
        case 0:{
            [UIView animateWithDuration:0.2f animations:^{
                self.scrollView.contentOffset = CGPointMake(0, 0);
            }];
            break;
        }
        case 1:{
            [UIView animateWithDuration:0.2f animations:^{
                self.scrollView.contentOffset = CGPointMake(kScreenWidth, 0);
            }];
            break;
        }
        default:
            break;
    }
    
}

//左侧按钮点击
- (void)leftButtonAction{
    NSLog(@"联系客服");
      
}

#pragma mark - ******* Private Methods *******

//颜色转图片
- (UIImage*)createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return theImage;
}
#pragma mark - ******* Notification *******
//加号按钮点击
- (void)tabbarSelectBtnWithBtnTag:(NSNotification *)noti{
    NSString *notiStr = noti.object;
    if ([notiStr isEqualToString:@"0"]) {
        NSLog(@"选择的是%@ 电话",notiStr);
        LitePhoneSelectLabelViewController *phoneSelectLabelVC = [[LitePhoneSelectLabelViewController alloc] init];
        phoneSelectLabelVC.selectLabelType = SelectLabelTypePhone;
        phoneSelectLabelVC.customType = AdsCustomTypeAll;
        phoneSelectLabelVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:phoneSelectLabelVC animated:YES];
    }else{
        NSLog(@"选择的是%@ 短信",notiStr);
        LiteADsMessageContentViewController *setMessageContentVC = [[LiteADsMessageContentViewController alloc] init];
        setMessageContentVC.type = MessageContentTypeAdd;
        setMessageContentVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:setMessageContentVC animated:YES];
    }
}
//资质弹窗选择上传通知
- (void)updateQualification:(NSNotification *)noti{
    LiteAccountQualificationViewController *qualificationVC = [[LiteAccountQualificationViewController alloc] init];
    qualificationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qualificationVC animated:YES];
}

//短信创建和编辑成功
- (void)messageAddOrEditSuccess:(NSNotification *)noti{
    //切换到短信营销列表页
    self.segmentedControl.selectedSegmentIndex = 1;
    [self segChange:self.segmentedControl];
}

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
        [_leftButton setImage:[UIImage imageNamed:@"ads_contact_customer_service"] forState:UIControlStateHighlighted];
        if (IS_IPHONE5) {
            [_leftButton setTitle:@"客服" forState:UIControlStateNormal];
        } else {
            [_leftButton setTitle:@"咨询客服" forState:UIControlStateNormal];
        }
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:12];
        
        [_leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    }
    return _leftButton;
}

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc]initWithItems:@[@"电话营销",@"短信营销"]];
        _segmentedControl.frame = CGRectMake(0, 0, 160.0, 34.0);
        _segmentedControl.center=CGPointMake(kScreenWidth/2, 22);
        _segmentedControl.tintColor = UIColorWhite;
        
        //背景 点击或未点击
        [_segmentedControl setBackgroundImage:[self createImageWithColor:UIColorFromRGB(0x5DA0F0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[self createImageWithColor:UIColorFromRGB(0x5DA0F0)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
        [_segmentedControl setBackgroundImage:[self createImageWithColor:UIColorWhite] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        //中间的分割线
        //    [segmentedControl setDividerImage:[UIImage imageNamed:@"shuxian"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        //文字 点击或未点击
        NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName ,nil];
        [_segmentedControl setTitleTextAttributes:dic1 forState:UIControlStateNormal];
        
        NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0x4895F2),NSForegroundColorAttributeName ,nil];
        [_segmentedControl setTitleTextAttributes:dic2 forState:UIControlStateSelected];
        
        _segmentedControl.backgroundColor = [UIColor clearColor];
        _segmentedControl.layer.borderWidth = 0.5;
        _segmentedControl.layer.borderColor = [[UIColor whiteColor] CGColor];
        _segmentedControl.layer.masksToBounds = YES;
        _segmentedControl.layer.cornerRadius = 16.5;
        _segmentedControl.selectedSegmentIndex = 0;
        [_segmentedControl addTarget:self action:@selector(segChange:) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentedControl;
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
        _scrollView.contentSize = CGSizeMake(kScreenWidth*2, 0);
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
