//
//  WTWebViewController.m
//  Waiting_iOS
//
//  Created by wander on 2018/10/22.
//  Copyright © 2018 BEHE. All rights reserved.
//

#import "WTWebViewController.h"

@interface WTWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint * statusViewHeightConstraint; //状态栏高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * naviViewHeightConstraint; //自定义导航栏高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * webViewBackViewBottomConstraint; //webview背景图距下约束
@property (weak, nonatomic) IBOutlet UIView * webViewBackView; //webview背景图

@end

@implementation WTWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
    
    [self loadWebView:self.url];

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
        self.naviViewHeightConstraint.constant = 0;
    }else{//默认不隐藏自定义导航条
        self.naviViewHeightConstraint.constant = 44;
    }
}

#pragma mark - ******* UI *******
- (void)createUI{
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.scrollView.bounces = NO;
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;    // 禁止自动检测手机号
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.loadFailedView];
    
    self.statusViewHeightConstraint.constant = kStatusBarHeight;
    self.webViewBackViewBottomConstraint.constant = SafeAreaBottomHeight;
    
    
}
#pragma mark - ******* Action Methods *******
//返回
- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webViewBackView animated:NO];
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
    //获取当前页面的title
    self.titleLabel.text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
