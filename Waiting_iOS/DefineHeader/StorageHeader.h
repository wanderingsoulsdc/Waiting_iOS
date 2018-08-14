//
//  StorageHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef StorageHeader_h
#define StorageHeader_h

// 存放到本地的用于拨打电话的本机手机号码
static NSString *const kOwnPhoneNumberUserDefault      = @"kOwnPhoneNumberUserDefault";
// 存放到本地的用于拨打电话的用户名字
static NSString *const kOwnPhoneNameUserDefault        = @"kOwnPhoneNameUserDefault";
// 存放到本地的用于拨打电话的用户身份证号
static NSString *const kOwnPhoneIDCardUserDefault      = @"kOwnPhoneIDCardUserDefault";
// 存放到本地的推送消息
static NSString *const kPushInfoUserDefault            = @"kPushInfoUserDefault";
// 存放到本地的Deeplink消息
static NSString *const kDeepLinkInfoUserDefault        = @"kDeepLinkInfoUserDefault";
// 存放是否需要展示引导页的bool值，后面会拼上版本号和页面类名
static NSString *const kGuideImageHasShow              = @"kGuideImageHasShow";
// 存放家里的WiFi名称，用于盒子联网
static NSString *const kConnectHomeWifiNameUserDefault = @"kConnectHomeWifiNameUserDefault";
// 存放首页弹过的popMessage的ID，如果下次请求一致，则不再弹
static NSString *const kPopMessageIDUserDefault        = @"kPopMessageIDUserDefault";

#endif /* StorageHeader_h */
