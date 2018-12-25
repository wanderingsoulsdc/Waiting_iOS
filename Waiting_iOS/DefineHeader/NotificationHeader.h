//
//  NotificationHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef NotificationHeader_h
#define NotificationHeader_h

static NSString *const kUpdateQualificationNotification = @"kUpdateQualificationNotification";  // 需要上传资质信息
static NSString *const kPhoneMarkOperationNotification  = @"kPhoneMarkOperationNotification"; // 拨打电话标记后需要刷新页面
static NSString *const kRaffleBindChangedNotification   = @"kRaffleBindChangedNotification";   // 抽奖绑定解绑店铺后需要刷新页面
static NSString *const kHeatMapCreateSuccessNotification = @"kHeatMapCreateSuccessNotification";   // 热力图创建成功
static NSString *const kStoreCreateSuccessNotification  = @"kStoreCreateSuccessNotification";   // 店铺创建成功
static NSString *const kConnectNetSuccessNotification   = @"kConnectNetSuccessNotification";   // 探针联网成功
static NSString *const kNoviceGuideSuccessNotification   = @"kNoviceGuideSuccessNotification";   // 新手引导完成
static NSString *const kTabbarCenterButtonClickNotification   = @"kTabbarCenterButtonClickNotification";   // tabbar中间按钮出现后点击通知
static NSString *const kDeviceAddSuccessNotification   = @"kDeviceAddSuccessNotification";   // 设备添加成功通知
static NSString *const kLabelAddSuccessNotification   = @"kLabelAddSuccessNotification";   // 标签创建成功通知
static NSString *const kMessageAddOrEditSuccessNotification   = @"kMessageAddOrEditSuccessNotification";   // 短信创建或编辑成功通知
static NSString *const kInvoiceApplySuccessNotification   = @"kInvoiceApplySuccessNotification";   // 发票申请成功通知


#endif /* NotificationHeader_h */
