//
//  FSWebViewController.m
//  yiliDMP
//
//  Created by QiuLiang Chen QQ：1123548362 on 2017/1/16.
//  Copyright © 2017年 BEHE. All rights reserved.
//
//  If the hero never comes to you
//  Keep calm and be a man

#import "FSWebViewController.h"
#import "BHLoadFailedView.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface FSWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, strong) UIWebView              * webView;
@property (nonatomic, strong) UIImageView            * loadFailedImageView;
@property (nonatomic, strong) UILabel                * loadFailedLabel;
@property (nonatomic, strong) BHLoadFailedView       * loadFailedView;

@property (nonatomic, strong) NJKWebViewProgressView * progressView;
@property (nonatomic, strong) NJKWebViewProgress     * progressProxy;

@end

@implementation FSWebViewController


#pragma mark - Life circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // You should add subviews here, just add subviews
    self.view.backgroundColor = [UIColor whiteColor];
    // You should add subviews here, just add subviews
    [self.view addSubview:self.webView];
    [self.view addSubview:self.loadFailedView];
    self.webView.delegate = self.progressProxy;
    
    // You should add notification here
    
    
    // layout subviews
    [self layoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadWebView:self.url];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.progressView removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.webView stopLoading];
}

- (void)layoutSubviews {
    //You should set subviews constrainsts or frame here
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.webView.frame = frame;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView.frame = barFrame;
}

#pragma mark - NJKWebViewProgressDelegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
    
    if (self.title == nil || [self.title isEqualToString:@""])
    {
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
}

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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    hud.activityIndicatorColor = [UIColor whiteColor];
#pragma clang diagnostic pop
    hud.label.font = [UIFont systemFontOfSize:14];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.backgroundView.backgroundColor = [UIColor whiteColor];  // 整个背景色
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4];   // 中间提示框背景色
    hud.tag = 100;
    
    
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

#pragma mark - Event response
// button、gesture, etc

- (void)loadFailedViewAction
{
    self.loadFailedView.hidden = YES;
    [self loadWebView:self.url];
}

#pragma mark - Private methods

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
        else if ([request.URL.path hasSuffix:@"/account/reloadHref"])
        {
            [self loadWebView:self.url];
            return NO;
        }
        return YES;
    }
    return YES;
}

- (void)loadWebView:(NSString *)url
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:encoding];
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
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

- (NJKWebViewProgressView *)progressView
{
    if (_progressView == nil)
    {
        _progressView = [[NJKWebViewProgressView alloc] init];
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}

- (NJKWebViewProgress *)progressProxy
{
    if (_progressProxy == nil)
    {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
    }
    return _progressProxy;
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
