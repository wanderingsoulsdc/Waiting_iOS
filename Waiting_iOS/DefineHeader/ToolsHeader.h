//
//  ToolsHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef ToolsHeader_h
#define ToolsHeader_h

// block self
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;

// ScreenSize
#define kScreenSize (((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) ? CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) : [UIScreen mainScreen].bounds.size)
//屏幕宽度
#define kScreenWidth (kScreenSize.width)
//屏幕高度
#define kScreenHeight (kScreenSize.height)
//屏幕比例尺寸
#define kScreenScale(__PARA)      (((__PARA)/320.0f)*(kScreenWidth))

//iOS版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height == 568) ? YES : NO)
#define IS_IPhone6 (667 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)
#define IS_IPhone6plus (736 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)
#define IS_IPhoneX (812 == [[UIScreen mainScreen] bounds].size.height ? YES : NO)

// 状态栏+导航栏高度
#define kStatusBarAndNavigationBarHeight (IS_IPhoneX ? 88.f : 64.f)
// 状态栏高度
#define kStatusBarHeight (IS_IPhoneX ? 44.f : 20.f)

#define SafeAreaBottomHeight (IS_IPhoneX ? 34 : 0)

#define kGetImageFromName(name) [UIImage imageNamed:name]

//GCD
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

// 存储UserDefault
#define kApiToken ([[NSUserDefaults standardUserDefaults] objectForKey:@"request_token"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"request_token"]:@"")
#define kApiSetToken(token) [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"request_token"]

// 重写NSLog,Debug模式下打印日志，当前行数，当前方法名
#ifdef RELEASE

#define NSLog(...)

#else  //DEBUG || TEST_DEBUG

#define NSLog(format, ...) do {     \
fprintf(stderr, "<%s : %d> %s\n",   \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)

#endif

/* 打印Rect  Size Point */
#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)


// 字符串判断是否为空

#define kStringNotNull(_OBJ) ([_OBJ isKindOfClass:[NSNull class]] == NO &&  (_OBJ != nil) &&  (_OBJ != NULL) && ([[_OBJ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] !=0))
#define kArrayNotNull(_OBJ) ([_OBJ isKindOfClass:[NSArray class]] != NO && [_OBJ isKindOfClass:[NSNull class]] == NO && _OBJ.count != 0 && _OBJ != nil)
#define kDictNotNull(_OBJ) ([_OBJ isKindOfClass:[NSDictionary class]] != NO && [_OBJ isKindOfClass:[NSNull class]] == NO && _OBJ.count != 0 && _OBJ != nil)

//单例
#define DEFINE_SINGLETON_FOR_HEADER(className) \
\
+(className* )shared##className;

#define DEFINE_SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
@synchronized(self){ \
shared##className = [[self alloc] init]; \
} \
}); \
return shared##className; \
}


#define KDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define kStringFromInteger(value) [NSString stringWithFormat:@"%ld",(long)value]

#endif /* ToolsHeader_h */
