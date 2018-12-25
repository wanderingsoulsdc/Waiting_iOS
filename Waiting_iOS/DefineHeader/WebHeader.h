//
//  WebHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef WebHeader_h
#define WebHeader_h

#define kApiWebLabel                kApiHostPort @"label"          /* 首页 - 我的客户 */
#define kApiWebMovieDetail          kApiHostPort @"video/videoDetil"     /* 学习中心 - 视频播放详情页 */

#define kApiWebBindLocation         kApiHostPort @"shop/location"          /* 绑定店铺选择地址 */

#define kApiWebCustomMain           kApiHostPort @"client/radarReport"   /* 客流分析 - 看客流 */
#define kApiWebCustomerList         kApiHostPort @"client/clientList"   /* 客户列表 */
#define kApiWebCustomerMyOrderList  kApiHostPort @"order/myList"   /* 广告投放-广告-我的名单 */

#define kApiWebAccountMain          kApiHostPort @"account/index"        /* 账户首页 */
#define kApiWebAccountRecharge      kApiHostPort @"account/recharge"       /* 充值 */
#define kApiWebAccountRechargeRecord    kApiHostPort @"account/rechargeLog"       /* 充值记录 */
#define kApiWebAccountInvoice       kApiHostPort @"account/invoice"       /* 申请开票 */
#define kApiWebAccountShopManager   kApiHostPort @"shop/shopManage"       /* 店铺列表 */
#define kApiWebAccountQualification kApiHostPort @"account/qualifications" /* 资质认证 */
#define kApiWebAccountShopDetail    kApiHostPort @"account/shopInfo"   /* 店铺管理 - 店铺详情 */
#define kApiWebAccountOrderMacList  kApiHostPort @"order/macorder"     /* 探针详情 - 探针获取到的mac列表 */
#define kApiWebAccountRaffleRecord  kApiHostPort @"account/raffleRecord"     /* 抽奖管理 - 中奖纪录 */
#define kApiWebAccountRaffleDownload    kApiHostPort @"account/LotteryMaterial"     /* 抽奖管理 - 下载物料 */

#define kApiWebReportAddress        kApiHostPort @"business/addShopMap"      /* 地点分析-地点位置 */
#define kApiWebReportPassengerAys   kApiHostPort @"business/passengerAys"      /* 客流统计 */
#define kApiWebReportCouponManager  kApiHostPort @"account/coupon"      /* 用券管理 */
#define kApiWebReportAddressAys     kApiHostPort @"business/siteAys"      /* 选址分析 */
#define kApiWebReportIndustryAys    kApiHostPort @"business/industryAys"      /* 行业分析 */

#define kApiWebManagerChooseScene   kApiHostPort @"order/choseType"        /* 创建广告 */
#define kApiWebManagerADs           kApiHostPort @"manage/category"        /* 营销管理 */
#define kApiWebManagerMediaData     kApiHostPort @"manage/mediaList"        /* 媒体数据 */
#define kApiWebManagerADReport      kApiHostPort @"manage/orderReport"      /* 广告 - 数据报表 */

#define kApiWebCouponUsed           kApiHostPort @"account/addConsumption"        /* 添加优惠券消费 */

#define kApiWebRegisterAgreement    kApiHostPort kApiVersionPort @"protocol.html"           /* 璧合注册协议 */

#define kApiWebVersionInfo          kApiHostPort kApiVersionPort @"ios.html" /*版本信息*/
#define kApiWebMessageInfo          kApiHostPort kApiVersionPort @"msgTips.html" /* 短信内容说明 */


#define kApiOrderPhone              kApiHostPort @"order/teleTime"         /* 投放电话营销 */
#define kApiOrderPhoneList          kApiHostPort @"order/telephone"         /* 投放电话营销-电话列表 */
#define kApiOrderMessage            kApiHostPort @"order/sendType"         /* 投放短信营销 */
#define kApiOrderMessageSet         kApiHostPort @"order/messageSet"         /* 投放短信营销 - 短信设置 */
#define kApiOrderAD                 kApiHostPort @"order/crowd"         /* 投放广告营销 */
#define kApiOrderADNew              kApiHostPort @"ad/crowd"            /* 新的投放广告营销流程 */
#define kApiOrderPush               kApiHostPort @"order/pushCrowd"         /* 投放Push营销 */
#define kApiOrderWiFiAD             kApiHostPort @"order/choseStore"         /* 投放WiFi广告 */
#define kApiWebWiFiIntroduce        kApiHostPort @"order/Introduction"      /* 投放WiFi广告 - 功能说明 */

#define kApiWebHeatMapBindShop      kApiHostPort @"heat/bindShop"         /* 热力图 - 绑定店铺 */


#define kApiWebRaffle               kApiHostPort @"account/raffle"         /* 抽奖管理 */
#define kApiWebNotification         kApiHostPort @"account/mesDetile"         /* 抽奖管理 */

#define kApiWebADQuaInfo            kApiHostPort @"account/quaInfo"         /* 当前资质已解锁媒体列表 */

#define kApiWebCalendar             kApiHostPort @"calendarSubmit"            /* 自定义日历 */

#define kApiWebNoviceGuide          kApiHostPort @"novice/index"            /* 首页新手引导 */
#define kApiWebGuidePhone           kApiHostPort @"novice/addTel"           /* 新手引导电话 */
#define kApiWebGuideMessage         kApiHostPort @"novice/mesStep"          /* 首页新手短信 */
#define kApiWebGuidePhoneDetail     kApiHostPort @"novice/makeTel"          /* 引导电话详情 */
#define kApiWebGuideMesSuccess      kApiHostPort @"novice/mesSuc"           /* 引导短信成功 */
#define kApiWebGuidePhoneSuccess    kApiHostPort @"novice/telConfirm"       /* 引导电话成功 */


#define kApiWebSubAccount           kApiHostPort @"staff/staHome"       /* 子账号 */


#endif /* WebHeader_h */
