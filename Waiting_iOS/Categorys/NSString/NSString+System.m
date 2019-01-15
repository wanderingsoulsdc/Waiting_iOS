//
//  NSString+System.m
//  iPresale
//
//  Created by ChenQiuLiang on 15/10/8.
//  Copyright © 2015年 YS. All rights reserved.
//

#import "NSString+System.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>

@implementation NSString (System)

#pragma mark- 得到设备UUID
+ (NSString *)getIOSUUID
{
//    NSDictionary * infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *bundleID = [infoDictionary objectForKey:@"CFBundleIdentifier"];
//    NSString *retrieveuuid = [SSKeychain passwordForService:bundleID account:@"uuid"];
//    NSLog(@"----%@",retrieveuuid);
//    if ( retrieveuuid == nil || [retrieveuuid isEqualToString:@""]){
//        CFUUIDRef uuid = CFUUIDCreate(NULL);
//        assert(uuid != NULL);
//        CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
//        NSLog(@"uuidstr:%@",uuidStr);
//        
//        retrieveuuid = [NSString stringWithFormat:@"uuid:%@", uuidStr];
//        [SSKeychain setPassword:retrieveuuid forService:bundleID account:@"uuid"];
//    }
//    
//    NSArray* arr = [retrieveuuid componentsSeparatedByString:@":"];
//    retrieveuuid = arr[1];
//    NSLog(@"%@",retrieveuuid);
//    return retrieveuuid;
    return nil;
}
+ (NSString *)getAppVersion
{
    //获取APP版本号
    NSString * appVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    
    return appVersion;
}

+ (NSString *)getDeviceSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

/**
 *  手机版本
 *
 *  @return 手机系统版本
 */
+ (NSString *)getIPhoneVersion
{
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    //获取系统信息
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char * machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString * platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    return platform;
}

@end
