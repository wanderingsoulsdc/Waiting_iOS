//
//  BHPopMessageManager.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/12.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import "BHPopMessageManager.h"
#import "AFImageDownloader.h"
#import "FSLaunchManager.h"
#import "FSDeviceManager.h"

@interface BHPopMessageManager ()

//@property (nonatomic, strong) UIVisualEffectView * bgView;
@property (nonatomic, strong) UIView             * bgView;
@property (nonatomic, strong) UIImageView        * closeImageView;
@property (nonatomic, strong) UIImageView        * showImageView;

@end

@implementation BHPopMessageManager
{
    NSDictionary     * _dict;
    UIViewController * _viewContoller;
    UIImage          * _image;
    
    BOOL               _isNoviceGuide;
}

+ (instancetype)sharedInstance
{
    static BHPopMessageManager *popMessageManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(self){
            popMessageManager = [[self alloc] init];
        }
    });
    return popMessageManager;
}

#pragma Public Method

- (void)showPopMessageWithData:(NSDictionary *)dict inViewController:(UIViewController *)viewController
{
    NSString * popedMessageID = [[NSUserDefaults standardUserDefaults] objectForKey:kPopMessageIDUserDefault];
    if ([popedMessageID isEqualToString:_dict[@"id"]]) return;
    
    _dict = dict;
    _viewContoller = viewController;
    NSString * urlString = dict[@"imgurl"];
    [self downLoadImageWithURL:[NSURL URLWithString:urlString]];
}

- (void)showPopMessage
{
    if (!_image) return;
    NSString * popedMessageID = [[NSUserDefaults standardUserDefaults] objectForKey:kPopMessageIDUserDefault];
    if ([popedMessageID isEqualToString:_dict[@"id"]]) return;
    
//    if ([[[FSLaunchManager sharedInstance] getCurrentVC] isKindOfClass:[BHMainViewController class]])
//    {
//        UIView * view = [UIApplication sharedApplication].keyWindow;
//        [view addSubview:self.bgView];
//        [view addSubview:self.showImageView];
//        [view addSubview:self.closeImageView];
//        
//        self.showImageView.image = _image;
//        
//        [self layoutSubViewsInView:view];
//    }
}

- (void)showPopMessageNoviceGuide
{
    _image = [UIImage imageNamed:@"guide_main_pop"];
    _isNoviceGuide = YES;
    [self showPopMessage];
}

#pragma mark - Private Method

- (void)downLoadImageWithURL:(NSURL *)url
{
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    AFImageDownloader *downloader = [AFImageDownloader defaultInstance];
    __weak __typeof(self)weakSelf = self;
    NSUUID *downloadID = [NSUUID UUID];
    [downloader downloadImageForURLRequest:urlRequest
                             withReceiptID:downloadID
                                   success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull responseObject) {
                   __strong __typeof(weakSelf)strongSelf = weakSelf;
                   if(responseObject) {
                       //                       strongSelf.image = responseObject;
                       [strongSelf showPopImage:responseObject];
                   }
               }
               failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                   NSLog(@"图片下载失败");
               }];
}

- (void)showPopImage:(UIImage *)image
{
    _image = image;
    [self showPopMessage];
}

- (void)layoutSubViewsInView:(UIView *)view
{
    self.bgView.frame = CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height);
    self.showImageView.frame = CGRectMake(40, view.bounds.size.height/2-(view.bounds.size.width-80)*0.75-25, (view.bounds.size.width-80), (view.bounds.size.width-80)*1.5);
    self.closeImageView.frame = CGRectMake((view.bounds.size.width)/2-25, self.showImageView.origin.y+self.showImageView.size.height+15, 50, 50);
}

#pragma mark - Response Method

- (void)removePopMessageViewFromSuperView
{
    _image = nil;
    [self.closeImageView removeFromSuperview];
    [self.showImageView removeFromSuperview];
    [self.bgView removeFromSuperview];
    
    [[NSUserDefaults standardUserDefaults] setValue:_dict[@"id"] forKey:kPopMessageIDUserDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)popMessageViewAction
{
    NSLog(@"按钮被点击");
    [self removePopMessageViewFromSuperView];
    
    if (_isNoviceGuide == YES)
    {
        NSString * version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString * key = [NSString stringWithFormat:@"%@_%@_%@", kGuideImageHasShow, version, @"noviceGuide"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        
//        BHNoviceGuideViewController * noviceGuideVC = [[BHNoviceGuideViewController alloc] init];
//        noviceGuideVC.hidesBottomBarWhenPushed = YES;
//        [[FSLaunchManager sharedInstance].rootTabBarController pushToViewController:noviceGuideVC animated:YES];
        return;
    }
    
    NSString * jumpString = _dict[@"Jumpurl"];
    NSURL * url = [NSURL URLWithString:jumpString];

    if ([url.host hasSuffix:@"behe.com"])
    {
        if ([url.path hasSuffix:@"/video/videoDetil"])
        {
            // 视频
            
//            NSString * detailURL = [NSString stringWithFormat:@"%@?%@", kApiWebMovieDetail, url.query];
//            BHMovieDetailViewController * movieDetailVC = [[BHMovieDetailViewController alloc] init];
//            movieDetailVC.url = detailURL;
//            movieDetailVC.hidesBottomBarWhenPushed = YES;
//            [_viewContoller.navigationController pushViewController:movieDetailVC animated:YES];
        }
        else
        {
            // 文档 或 消息中心详情页 或 其他
        }
    }
    else
    {
        
    }
}

#pragma mark - Get

// 高斯模糊后的视图
//- (UIVisualEffectView * )bgView
//{
//    if (!_bgView)
//    {
//        /* UIBlurEffectStyle枚举
//         UIBlurEffectStyleRegular
//         UIBlurEffectStyleLight
//         UIBlurEffectStyleDark
//         UIBlurEffectStyleProminent
//         UIBlurEffectStyleExtraLight
//         */
//        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//        _bgView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    }
//    return _bgView;
//}
- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return _bgView;
}
- (UIImageView *)closeImageView
{
    if (!_closeImageView)
    {
        _closeImageView = [[UIImageView alloc] init];
        _closeImageView.image = [UIImage imageNamed:@"close"];
        _closeImageView.contentMode = UIViewContentModeScaleAspectFit;
        _closeImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removePopMessageViewFromSuperView)];
        [_closeImageView addGestureRecognizer:tapGesture];
    }
    return _closeImageView;
}
- (UIImageView *)showImageView
{
    if (!_showImageView)
    {
        _showImageView = [[UIImageView alloc] init];
        _showImageView.contentMode = UIViewContentModeScaleAspectFit;
        _showImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popMessageViewAction)];
        [_showImageView addGestureRecognizer:tapGesture];
    }
    return _showImageView;
}

@end
