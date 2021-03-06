//
//  BHWebViewController.m
//  Waiting_iOS
//
//  Created by QiuLiang Chen QQ：1123548362 on 2018/3/22.
//  Copyright © 2018年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "BHWebViewController.h"
#import <Masonry/Masonry.h>

@interface BHWebViewController () <UIWebViewDelegate>

@property (nonatomic , strong) UIView       * statusView;
@property (nonatomic , strong) UIView       * naviView;
@property (nonatomic , strong) UIButton     * backButton;
@property (nonatomic , strong) UILabel      * titleLabel;

@end

@implementation BHWebViewController

#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    // You should add subviews here, just add subviews
    [self.view addSubview:self.statusView];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadFailedView];
    
    [self loadWebView:self.url];
    
    // You should add notification here
    
    
    // layout subviews
    [self layoutSubviews];
    
    if (@available(iOS 11.0, *))
    {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    if (self.isHideNavi) { //隐藏自定义导航条
        
    }else{//默认不隐藏自定义导航条
        
    }
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    if (self.isHideNavi) { //隐藏导航条
        [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(kStatusBarHeight);
        }];
        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.statusView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        }];
    } else { //默认不隐藏导航条
        [self.statusView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.height.mas_equalTo(0);
        }];
        [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(0 - SafeAreaBottomHeight);
        }];
    }
}

#pragma mark - Public Method

#pragma mark - SystemDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self shouldStartLoadWithRequest:request];
    return resultBOOL;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.removeFromSuperViewOnHide = YES;
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.label.text = @"正在加载...";
    hud.label.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.backgroundView.backgroundColor = [UIColor whiteColor];  // 整个背景色
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4];   // 中间提示框背景色
    hud.tag = 100;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    hud.activityIndicatorColor = [UIColor whiteColor];
#pragma clang diagnostic pop
    
    NSLog(@"webView开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    MBProgressHUD * hud = (MBProgressHUD *)[self.view viewWithTag:100];
    [hud hideAnimated:NO];
    self.loadFailedView.hidden = YES;
    NSLog(@"webView完成加载");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    MBProgressHUD * hud = (MBProgressHUD *)[self.view viewWithTag:100];
    [hud hideAnimated:YES];
    self.loadFailedView.hidden = NO;
    NSLog(@"webView开始加载数据时失败");
}

#pragma mark - CustomDelegate

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Event response
// button、gesture, etc

- (void)loadFailedViewAction
{
    self.loadFailedView.hidden = YES;
    [self loadWebView:self.url];
}

#pragma mark - Private methods

- (void)loadWebView:(NSString *)url
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:encoding];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
}

// 判断是否允许跳转页面，即是否要进行拦截
- (BOOL)shouldStartLoadWithRequest:(NSURLRequest *)request
{
    if ([request.URL.host hasSuffix:@"behe.com"])
    {
        if ([request.URL.path hasSuffix:@"/login"])
        {
            [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
            return NO;
        }
        return YES;
    }
    return YES;
}

#pragma mark - Getters and Setters
// initialize views here, etc

- (UIWebView *)webView
{
    if (_webView == nil)
    {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
        _webView.scalesPageToFit = YES;
        _webView.scrollView.bounces = NO;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;    // 禁止自动检测手机号
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _webView;
}

- (BHLoadFailedView *)loadFailedView
{
    if (!_loadFailedView)
    {
        _loadFailedView = [[BHLoadFailedView alloc] init];
        _loadFailedView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadFailedViewAction)];
        [_loadFailedView addGestureRecognizer:tap];
        _loadFailedView.hidden = YES;
        
        _loadFailedView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        _loadFailedView.backgroundColor = [UIColor whiteColor];
    }
    return _loadFailedView;
}

- (UIView *)statusView{
    if (!_statusView) {
        _statusView = [[UIView alloc] init];
        _statusView.backgroundColor = UIColorWhite;
    }
    return _statusView;
}

- (UIView *)naviView{
    if (!_naviView) {
        _naviView = [[UIView alloc] init];
        _naviView.backgroundColor = UIColorWhite;
    }
    return _naviView;
}

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
