//
//  FSDeviceManager.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/9/13.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "FSDeviceManager.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "AFNetworkReachabilityManager.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface FSDeviceManager () <CLLocationManagerDelegate>

@property (nonatomic, assign) BOOL isFirstLocationUpdate;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic, strong) NSString * appId;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, strong) NSString * eventKey;
@property (nonatomic, strong) NSString * eventValue;
@property (nonatomic, strong) NSString * province;
@property (nonatomic, strong) NSString * city;

@end

@implementation FSDeviceManager
{
    NSString * currentCity; //当前城市
}

+ (instancetype)sharedInstance
{
    static FSDeviceManager * manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return self;
}

#pragma mark -


/** App名称 */
- (NSString *)getAppName {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return appName;
}

/** BundleID */
- (NSString *)getBundleID {
    NSString * bundleID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return bundleID;
}

/** 应用版本号 */
- (NSString *)getAppVersion {
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return appVersion;
}

/** 渠道号 */
- (NSString *)getChannel {
    return @"appStore";
}

/** 上传时间 */
- (NSString *)getLocalTime {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a = [date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒,13位
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a]; //转为字符型
    return timeString;
}

/** SDK版本号 */
- (NSString *)getSDKVersion {
    return @"1.0.0";
}

/** 屏幕分辨率 */
- (NSString *)getDeviceResolution {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
    NSString * resolution = [NSString stringWithFormat:@"%.0f*%.0f", result.width, result.height];
    return resolution;
}

/** 屏幕宽度 */
- (NSString *)getDeviceWidth {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
    NSString * width = [NSString stringWithFormat:@"%.0f", result.width];
    return width;
}

/** 屏幕高度 */
- (NSString *)getDeviceHeight {
    CGSize result = [[UIScreen mainScreen] bounds].size;
    result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
    NSString * height = [NSString stringWithFormat:@"%.0f", result.height];
    return height;
}

/** 屏幕密度 */
- (NSString *)getDeviceDensity {
    NSString * density = [NSString stringWithFormat:@"%f", [[UIScreen mainScreen] scale]];
    return density;
}

/** 系统名称 */
- (NSString *)getSystemName {
    NSString * systemName = [[UIDevice currentDevice] systemName];
    return systemName;
}

/** 系统版本 */
- (NSString *)getSystemVersion {
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    return systemVersion;
}

/** 设备厂商 */
- (NSString *)getDeviceManufact {
    return @"Apple";
}

/** 设备型号 */
- (NSString *)getDeviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return deviceModel;
}

/** 位置获取时间 */
- (NSString *)getGpsTime {
    // 始终为当前时间
    NSDate* date = self.currentLocation.timestamp;
    NSTimeInterval a = [date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒,13位
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a]; //转为字符型
    return timeString;
}

/** 网络类型 */
- (NSString *)getNetType {
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    // 提示：要监控网络连接状态，必须要先调用单例的startMonitoring方法
    [manager startMonitoring];
    
    __block NSString * returnStr = @"";
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == -1) {
            NSLog(@"未识别网络");
            returnStr = @"unknown";
        }
        if (status == 0) {
            NSLog(@"未连接网络");
            returnStr = @"unknown";
        }
        if (status == 1) {
            NSLog(@"3G/4G网络");
            returnStr = @"4G";
        }
        if (status == 2) {
            NSLog(@"WiFi网络");
            returnStr = @"WiFi";
        }
    }];
    return returnStr;
}

/** 运营商 */
- (NSString *)getServiceCompany {
    NSArray *infoArray = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    
    for (id info in infoArray) {
        if ([info isKindOfClass:NSClassFromString(@"UIStatusBarServiceItemView")]) {
            NSString *serviceString = [info valueForKey:@"serviceString"];
            return serviceString;
        }
    }
    return @"";
}
/** 运营商 */
- (NSString *)getCarrierName {
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    NSString *currentCountry = [carrier carrierName];
    if (!currentCountry)
    {
        currentCountry = @"";
    }
    return currentCountry;
}

/** 是否越狱 0未越狱  1已越狱 */
- (NSString *)getSystemBroke {
    if ([self isJailBreak])
    {
        return @"1";
    }
    return @"0";
}

/** 获取当前WiFi名称 */
- (NSString *)getWifiName {
    
    id info = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSString *str = info[@"SSID"];
//        NSString *str2 = info[@"BSSID"];
//        NSString *str3 = [[ NSString alloc] initWithData:info[@"SSIDDATA"] encoding:NSUTF8StringEncoding];
        NSLog(@"ssidName:%@", str);
        return str;
    }
    return @"";
}

#define BH_ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

const char* bh_jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

- (BOOL)isJailBreak
{
    for (int i=0; i<BH_ARRAY_SIZE(bh_jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:bh_jailbreak_tool_pathes[i]]]) {
            //            NSLog(@"The device is jail broken!");
            return YES;
        }
    }
    //    NSLog(@"The device is NOT jail broken!");
    return NO;
}

- (NSString*)getUUID
{
    CFUUIDRef uuid_ref = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuid_string_ref= CFUUIDCreateString(kCFAllocatorDefault, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    if (!(uuid && uuid!=NULL && uuid.length>0))
    {
        uuid = @"";
    }
    CFRelease(uuid_string_ref);
    return [uuid lowercaseString];
}

#pragma mark - KeychainHelper

- (id)load:(NSString *)service
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id<NSCopying>)(kSecReturnData)];
    [keychainQuery setObject:(__bridge id)(kSecMatchLimitOne) forKey:(__bridge id<NSCopying>)(kSecMatchLimit)];
    
    CFTypeRef result = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, &result) == noErr)
    {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData*)result];
    }
    return ret;
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)(kSecClassGenericPassword),kSecClass,
            service, kSecAttrService,
            service, kSecAttrAccount,
            kSecAttrAccessibleAfterFirstUnlock,kSecAttrAccessible,nil];
}

- (void)save:(NSString *)service data:(id)data
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data]
                      forKey:(__bridge id<NSCopying>)(kSecValueData)];
    SecItemAdd((__bridge CFDictionaryRef)(keychainQuery), NULL);
}

- (void)delete:(NSString *)service
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
}

@end
