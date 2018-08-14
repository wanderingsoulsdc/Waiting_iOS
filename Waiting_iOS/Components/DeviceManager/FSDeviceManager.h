//
//  FSDeviceManager.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/9/13.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDeviceManager : NSObject

+ (instancetype)sharedInstance;


- (NSString *)getAppName;
- (NSString *)getBundleID;
- (NSString *)getAppVersion;
- (NSString *)getChannel;
- (NSString *)getLocalTime;
- (NSString *)getSDKVersion;
- (NSString *)getDeviceResolution;
- (NSString *)getDeviceWidth;
- (NSString *)getDeviceHeight;
- (NSString *)getDeviceDensity;
- (NSString *)getSystemName;
- (NSString *)getSystemVersion;
- (NSString *)getDeviceManufact;
- (NSString *)getDeviceModel;
- (NSString *)getUserLatitude;
- (NSString *)getUserLongitude;
- (NSString *)getLoactionProvince;  // 省
- (NSString *)getLoactionCity;  // 市
- (NSString *)getGpsTime;
- (NSString *)getNetType;
- (NSString *)getServiceCompany;
- (NSString *)getCarrierName;
- (NSString *)getDeviceID;
- (NSString *)getSystemBroke;
- (NSString *)getWifiName;

@end
