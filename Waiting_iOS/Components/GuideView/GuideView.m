//
//  GuideView.m
//  iGanDong
//
//  Created by ChenQiuLiang on 16/8/30.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#import "GuideView.h"

@interface GuideView () <UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray    *imageArray;
@end

#define FS_ButtonBGColor   0x2ab6f6
#define FS_ButtonTitleColor 0xFFFFFF
static NSString *const GuideViewEnterButtonTitle = @"点击进入";  /* 按钮的文字标题 */
static BOOL GuideViewAutoHidden = NO;                           /* 是否自动进入APP首页 */
static NSString *const GuideVersionKey = @"GuideVersionKey";

@implementation GuideView
{
    UIColor *buttonBgColor;
    UIColor *buttonTitleColor;
    UIColor *pageControlNormalColor;
    UIColor *pageControlSelectedColor;
    int pageDotsGapWidth;
    CGRect buttonFrame;
}

#pragma mark - 

+ (BOOL)isNeedShowGuideView
{
    //系统直接读取的版本号
    NSString *versionValueStringForSystemNow = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //读取引导过的版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *guidedVersion = [defaults objectForKey:GuideVersionKey];
    if(guidedVersion != nil && [versionValueStringForSystemNow isEqualToString:guidedVersion]){//说明有本地版本记录，且和当前系统版本一致
        return NO;
        
    }else{ // 无本地版本记录或本地版本记录与当前系统版本不一致
        return YES;
    }
}

#pragma mark -

- (instancetype)fs_initWithImageArray:(NSArray *)imageArray
{
    if ([super init]) {
        
        // 处理传递过来的数组
        [self dealWithImageArray:imageArray];
        buttonBgColor = [UIColor clearColor];
        buttonTitleColor = [UIColor whiteColor];
        pageControlNormalColor = [UIColor whiteColor];
        pageDotsGapWidth = 15;
        buttonFrame = CGRectMake([UIScreen  mainScreen].bounds.size.width*0.25, [UIScreen mainScreen].bounds.size.height*0.85, [UIScreen  mainScreen].bounds.size.width*0.5, [UIScreen mainScreen].bounds.size.height*0.06);
        
        self.frame = [UIScreen mainScreen].bounds;
        
        // 设置引导视图的scrollview
        UIScrollView *guidePageView = [[UIScrollView alloc]initWithFrame:self.frame];
        [guidePageView setBackgroundColor:[UIColor lightGrayColor]];
        [guidePageView setContentSize:CGSizeMake([UIScreen  mainScreen].bounds.size.width * self.imageArray.count, [UIScreen mainScreen].bounds.size.height)];
        [guidePageView setBounces:NO];
        [guidePageView setPagingEnabled:YES];
        [guidePageView setShowsHorizontalScrollIndicator:NO];
        [guidePageView setDelegate:self];
        [self addSubview:guidePageView];
        
        // 添加在引导视图上的多张引导图片
        for (int i=0; i<self.imageArray.count; i++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen  mainScreen].bounds.size.width*i, 0, [UIScreen  mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
            imageView.image = self.imageArray[i];
            [guidePageView addSubview:imageView];
            
            // 设置在最后一张图片上显示进入体验按钮
            if (i == self.imageArray.count-1 && GuideViewAutoHidden == NO) {
                [imageView setUserInteractionEnabled:YES];
//                UIButton *startButton = [[UIButton alloc]initWithFrame:buttonFrame];
//                startButton.layer.cornerRadius = startButton.frame.size.height/2;
//                startButton.clipsToBounds = YES;
//                [startButton setTitleColor:buttonTitleColor forState:UIControlStateNormal];
//                startButton.titleLabel.font = [UIFont systemFontOfSize:16];
//                startButton.backgroundColor = buttonBgColor;
//                [startButton.titleLabel setFont:[UIFont systemFontOfSize:21]];
//                [startButton addTarget:self action:@selector(hiddenGuideView) forControlEvents:UIControlEventTouchUpInside];
//                [imageView addSubview:startButton];
                
                UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenGuideView)];
                [imageView addGestureRecognizer:tapGesture];
                
            }
        }
    }
    return self;
}

#pragma mark - 

- (void)dealWithImageArray:(NSArray *)imaegArray;
{
    for (NSInteger i = 0 ; i < imaegArray.count ; i++)
    {
        id imageSource = [imaegArray objectAtIndex:i];
        if ([imageSource isKindOfClass:[UIImage class]])
        {
            [self.imageArray addObject:imageSource];
        }
        else if ([imageSource isKindOfClass:[NSString class]])
        {
            UIImage * image = [UIImage imageNamed:imageSource];
            if (image)  // 获取到了图片
            {
                [self.imageArray addObject:image];
            }
            else
            {
                // 没有获取到图片，可能imageSource为图片的url，使用SD下载image
                NSAssert(image != nil, @"image must not be nil");
            }
        }
        else if ([imageSource isKindOfClass:[NSURL class]])
        {
            // imageSource为图片的url，使用SD下载image
            NSAssert(NO, @"image must not be nil");
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollview {
    int page = scrollview.contentOffset.x / scrollview.frame.size.width;
    if ( page == self.imageArray.count-1 && GuideViewAutoHidden) {
        [self performSelector:@selector(hiddenGuideView) withObject:nil afterDelay:1.0f];
    }
}

- (void)hiddenGuideView
{
    // 保存当前引导的版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *versionValueStringForSystemNow = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [defaults setObject:versionValueStringForSystemNow forKey:GuideVersionKey];
    [defaults synchronize];
    
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }];
}

- (NSMutableArray *)imageArray
{
    if (!_imageArray)
    {
        _imageArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _imageArray;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
