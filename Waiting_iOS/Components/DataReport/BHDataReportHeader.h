//
//  BHDataReportHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/10.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef BHDataReportHeader_h
#define BHDataReportHeader_h

#pragma mark - 广告

static NSString *const sDataReportAdCrowd            = @"ad_crowd";              // 设置人群
static NSString *const sDataReportAdCrowdShop        = @"ad_crowd_shop";         // 设置人群 - 覆盖店铺
static NSString *const sDataReportAdTime             = @"ad_time";               // 设置时间
static NSString *const sDataReportAdCreative         = @"ad_creative";           // 设置创意
static NSString *const sDataReportAdCreativeTemplate = @"ad_creative_template";  // 设置创意 - 更换模板
static NSString *const sDataReportAdCreativeMaterial = @"ad_creative_material";  // 设置创意 - 更换素材
static NSString *const sDataReportAdCreativeDetails  = @"ad_creative_details";   // 设置创意 - 详情页
static NSString *const sDataReportAdSucceed          = @"ad_succeed";            // 创建成功

#pragma mark - 通知

static NSString *const sDataPushCrowd            = @"push_crowd";               // 设置人群
static NSString *const sDataPushCrowdShop        = @"push_crowd_shop";          // 设置人群 - 覆盖店铺
static NSString *const sDataPushTime             = @"push_time";                // 设置时间
static NSString *const sDataPushCreative         = @"push_creative";            // 设置创意
static NSString *const sDataPushCreativeMaterial = @"push_creative_material";   // 设置创意 - 更换素材
static NSString *const sDataPushCreativeDetails  = @"push_creative_details";    // 设置创意 - 详情页
static NSString *const sDataPushSucceed          = @"push_succeed";             // 创建成功

#pragma mark - 短信

static NSString *const sDataMessageChoiceTemplate = @"message_choice_template";    // 行业模板-选择短信模板
static NSString *const sDataMessageContent        = @"message_content";            // 设置内容
static NSString *const sDataMessageTips           = @"message_tips";               // 设置内容 - 短信内容说明
static NSString *const sDataMessageCrowd          = @"message_crowd";              // 设置人群
static NSString *const sDataMessageCrowdShop      = @"message_crowd_shop";         // 设置人群 - 覆盖店铺
static NSString *const sDataMessageSucceed        = @"message_succeed";            // 创建成功

#pragma mark - 电话

static NSString *const sDataPhoneTime        = @"phone_time";        // 设置时间
static NSString *const sDataPhoneList        = @"phone_list";        // 列表页
static NSString *const sDataPhoneMarkRecord  = @"phone_mark_record"; // 列表页 - 标注记录
static NSString *const sDataPhoneDetails     = @"phone_details";     // 详情页
static NSString *const sDataPhoneMark        = @"phone_mark";        // 通话标记

#endif /* BHDataReportHeader_h */
