//
//  ApiHeader.h
//  iGanDong
//
//  Created by qiyun on 16/5/19.
//  Copyright © 2016年 iGanDong. All rights reserved.
//

#ifndef ApiHeader_h
#define ApiHeader_h

#import <UIKit/UIKit.h>

#define kUserDefaultCookie  @"cookie.behe.com"  // 存放在userDefault里的cookie的key,目前存起来没什么用


// APP
#if     TARGET_MODE==2          // 测试环境（TEST_DEBUG）
#define kApiHostPort @"https://tcatapi.behe.com/"
#elif   TARGET_MODE==1          // 开发环境（DEBUG）
#define kApiHostPort @"https://dcatapi.behe.com/"
#else                           // 正式环境（Release）
#define kApiHostPort @"https://catapi.behe.com/"
#endif


#define kApiVersionPort     @"V1/"


//#define kApiLogin                       @"login/loginall"         /* 登录BUG接口 */

// 运营后台
#define kApiManagerHostPort             @"https://mapi.behe.com/v1/"     // 正式环境

#pragma mark - 注册&登录
#define kApiLoginGetToken               @"Token/getAccessToken"     /* 获取用户token */
#define kApiCheckIsRegister             @"User/isRegister"           /* 验证手机号是否注册 */
#define kApiLoginRegister               @"User/register"            /* 注册 */
#define kApiLoginForgetPW               @"User/forgetPwd"           /* 找回密码 */
#define kApiLoginResetPW                @"User/resetPwd"            /* 修改密码 */
#define kApiLoginGetVerCode             @"User/sendSms"             /* 获取验证码 */
#define kApiLoginCheckVerCode           @"User/checkSmsCode"        /* 检测验证码 */
#define kApiLogin                       @"User/login"               /* 登录 */
#define kApiLogout                      @"User/logout"              /* 退出登录 */

#define kApiCheckVersion                @"https://luckycatv1.behe.com/V1/login/versions"      /* 检查版本 */
#define kApiCheckAgreement              @"account/updateAccountUserAgreement"   /* 检查是否有协议更新 */

#pragma mark - 账户
#define kApiAccountAddAptitude          kApiVersionPort @"Aptitude/add"     /* 添加资质 */
#define kApiAccountUploadAptitude       kApiVersionPort @"Aptitude/uploadAptitude"     /* 上传营业执照图片 */
#define kApiAccountTradeList            kApiVersionPort @"Trade/list"        /* 交易管理列表 */

#pragma mark - 发票
#define kApiInvoiceUpdateStatus         kApiVersionPort @"Invoice/updateStatus"         /* 更改发票申请状态 */
#define kApiInvoiceDetail               kApiVersionPort @"Invoice/getInvoiceDetail"     /* 发票详情 */
#define kApiInvoiceUseCredit            kApiVersionPort @"Invoice/getUseCredit"         /* 获取可用开票金额 */
#define kApiInvoiceList                 kApiVersionPort @"Invoice/list"                 /* 发票列表 */
#define kApiInvoiceUpload               kApiVersionPort @"Invoice/uploadInvoice"        /* 发票资质上传 */
#define kApiInvoiceAdd                  kApiVersionPort @"Invoice/add"                  /* 申请发票 */

#pragma mark - 标签 && 设备
#define kApiAddDevice                   kApiVersionPort @"Device/add"           /* 添加设备 */
#define kApiDeviceDetail                kApiVersionPort @"Device/detail"        /* 设备详情 */
#define kApiDeviceGetNetStatus                          @"Industry/getNetStatus"/* 获取设备联网状态 */
#define kApiDeviceCheckMac                              @"Industry/checkMac"    /* 检测设备出库及绑定 */

#define kApiDeviceEdit                  kApiVersionPort @"Device/edit"          /* 设备编辑 */
#define kApiDeviceList                  kApiVersionPort @"Device/list"          /* 设备列表 */
#define kApiDeviceLabelList             kApiVersionPort @"Label/list"           /* 标签列表 */
#define kApiDeviceLabelUpdateDelete     kApiVersionPort @"Label/updateDelete"   /* 标签启用和加回收站 */
#define kApiAddDeviceLabel              kApiVersionPort @"Label/add"            /* 添加标签 */
#define kApiDeleteDeviceLabel           kApiVersionPort @"Label/deleteLabel"    /* 删除标签 */
#define kApiEditDeviceLabel             kApiVersionPort @"Label/edit"           /* 编辑标签 */
#define kApiDeviceLabelDetail           kApiVersionPort @"Label/detailById"     /* 按标签id获取标签详情 */
#define kApiChangeDeviceLabelStatus     kApiVersionPort @"Label/updateStatus"   /* 更改标签工作状态 */


#pragma mark - 首页
#define kApiMainIndex                   @"account/newIndex"  /* 首页 */
#define kApiGetPopMessage               @"account/GetSystemMessageTop"   /* 获取首页弹窗信息 */
#define kApiUpdateTask                  @"account/updateaccounttask"     /* 完成新手任务上报给服务器 */

#pragma mark - 电话营销

#define kApiReportPhoneList             kApiVersionPort @"Phone/reportPhoneList"     /* 电话营销列表 */
#define kApiReportGetMacLabel           kApiVersionPort @"Label/getMacLabel"         /* 营销-选择标签列表 */
#define kApiPhoneGetLabelPerson         kApiVersionPort @"Phone/getCoverPerson"      /* 电话选择标签统计人数 */

#define kApiPhoneList                   kApiVersionPort @"Phone/phoneList"           /* 选择客户电话列表 */
#define kApiPhoneMarkInfo               kApiVersionPort @"Phone/markInfo"            /* 电话详情 - 标记详情 */
#define kApiPhoneCallHistory            kApiVersionPort @"Phone/callHistory"         /* 电话详情 - 通话历史 */
#define kApiPhoneCallOut                kApiVersionPort @"Phone/callOut"             /* 拨打电话 */
#define kApiPhoneAddMark                kApiVersionPort @"Phone/addMark"             /* 添加电话标记 */



#pragma mark - 短信营销

#define kApiReportMessageList           kApiVersionPort @"Sms/list"                  /* 短信营销列表 */
#define kApiMessageDetail               kApiVersionPort @"Sms/detail"                /* 短信详情 */
#define kApiMessageReminder             kApiVersionPort @"Sms/remindersSms"          /* 短信催审 */
#define kApiMessageConfig               kApiVersionPort @"sms/getSmsConf"            /* 短信配置 */
#define kApiMessageAdd                  kApiVersionPort @"Sms/add"                   /* 添加/编辑短信 */
#define kApiMessageGetHistory           kApiVersionPort @"Sms/getHistorySms"         /* 历史短信记录 */
#define kApiMessageGetLabelPerson       kApiVersionPort @"Label/getLabelPerson"      /* 短信选择标签统计人数 */
#define kApiMessageGetSendDetail        kApiVersionPort @"Sms/getSendDetail"         /* 短信发送明细 */


#pragma mark - 学习中心
#define kApiMovieIndex                 @"learn/index"    /* 学习中心首页 */
#define kApiMovieCycleList             @"learn/carouselList"    /* 轮播图列表 */
#define kApiMovieCateList              @"learn/videoList" /* 视频分类列表 */
#define kApiDocumentList               @"learn/documentList"   /* 文档列表 */


#pragma mark - 权限判断
#define kApiQualificationAudit         @"account/audit"  /* 资质审核状态判断 */
#define kApiCheckWechatPermissions     @"wechat/index"   /* 判断微信朋友圈广告是否授权 */
#define KApiCheckWechatADPermissions   @"Wechat/return"  /* 扫码后跳转拦截，请求是否在系统内开通广告主功能 */
#define kApiGetRaffle                  @"account/getRaffle" /* 抽奖管理 */


#pragma mark - 订单
#define kApiGetOrderId                 @"order/createOrderSpaceApi"  /* 获取orderID */
#define kApiCreatePreOrder             @"order/saveOrderTempApi"  /* 把预订单保存到redis里面 */


#pragma mark - 店铺管理
#define kApiBindTradesLevel             @"Industry/getIndustry"  /* 店铺行业分类 */
#define kApiBindGetInOperationShopInfo  @"shop/listInfoApi"        /* 已开商铺详情 */
#define kApiBindGetPlanShopInfo         @"shop/getShopAddrInfo"        /* 准备开店商铺详情 */
#define kApiBindStoreEdit               @"shop/updateApi"  /* 商铺编辑 */
#define kApiBindAddShopAddressPre       @"shop/addShopAddr"    /* 添加未开店铺的预选址 */
#define kApiBindUpdateShopAddressPre    @"shop/updateAddress"  /* 修改未开店铺的预选址 */


#pragma mark - 探针管理
#define kApiBindCheckMac                @"radar/checkMacApi"       /* 校验mac地址是否已被绑定 */
#define kApiBindAddTrades               @"radar/addAllApi"         /* 批量添加探针 */
#define kApiBindCreateShop              @"shop/addApi"            /* 创建店铺，同时绑定多个探针 */
#define kApiBindGetTreasureStatus       @"radar/getStatusByMacApi"     /* 获取探针状态 */
#define kApiUnbindSendMessage           @"shop/sendCode"    /* 发送探针解绑短信 */
#define kApiBindTreasure                @"shop/relateRadarApi"  /* 绑定或解绑探针 */
#define kApiBindAddSingleTreasure       @"radar/addApi"    /* 添加单个探针 */
#define kApiBindTreasuerList            @"radar/listApi"  /* 获取店铺下的探针列表 */
#define kApiBindChangeTreasureName      @"radar/updateApi"    /* 修改招财喵的名称 */
#define kApiGetTreasureStatus           @"radar/getRadarStatus"    /* 选址地址更换探针查看探针状态 */
#define kApiBindGetTreasureDeadline     @"radar/radarStatus"    /* 获取探针的过期时间 */


#pragma mark - 消息中心
#define kApiNotificationCenter          @"account/GetSystemMessage" /* 消息中心首页 */
#define kApiNotificationCenterUnRead    @"account/GetSystemMessageNum"  /* 获取消息中心未读消息数 */
#define kApiNotificationMarkRead        @"account/UpSystemMessageRead"  /* 标记消息中心的消息为已读 */
#define kApiNotificationSysUnread       @"account/GetMessageNum"    /* 获取激励消息、充值消息未读数 */
#define kApiNotificationSysMarkRead     @"account/UpdateMessageRead"    /* 标记激励消息、充值消息为已读 */


#pragma mark - 广告

#define kApiADListQuaStatus            @"account/ListQuaStatus"      /* 资质页面，获取当前资质解锁百分比 */

#pragma mark - Pay

#define kApiWechatGetSign               @"Awxpay/makeOrder"       /* 微信支付签名 */
#define kApiAlipayGetSign               @"Alipay/makeOrder"         /* 支付宝支付签名 */
#define kApiWechatCheckStatus           @"Awxpay/checkOrder"      /* 微信支付状态校验 */
#define kApiAlipayCheckStatus           @"Alipay/checkOrder"        /* 支付宝支付状态校验 */

#pragma mark - 客流分析

#define kApiCouponCheckIsValid          @"account/couponCheck"    /* 校验优惠券是否为当前用户下的 */
#define kApiReportTotalStoreInfo        @"shop/getTotalOfShopInfoApi" /* 店铺运营首页3个数据 */


#pragma mark    -   Account

#define kApiAccountGetQualification     @"account/qualificationsInfo" /* 获取资质 */
#define kApiAccountUploadQualification  @"account/fileUpNew"   /* 上传资质 */
#define kApiAccountNoticeList           @"account/noticeList"  /* 系统通知 */
#define kApiRaffleUnbind                @"shop/LuckCheckApi"      /* 抽奖解绑 */


#pragma mark    -  盒子联网

#define kApiConnectGetDeviceInfo        @"radar/getRadarDeviceInfoApi" /* 获取盒子的WiFi名称和密码 */
#define kApiConnectSetTreasureInfo      @"http://192.168.8.8" /* 给盒子设置WiFi名称和密码 */
#define kApiConnectCheckUploadData      @"radar/getStatusByMacApi"  /* 检查盒子是否上报数据 */


#pragma mark - 热力图

#define kApiGetHeatMapInfo              @"radar/getshopmac"    /* 编辑热力图 - 获取热力图信息 */


#pragma mark - Public API

#define kApiGetUserInfo                  @"User/getUserInfo"           /* 获取用户信息 && 校验token */
#define kApiUploadImage                  @"upload/upload_base"         /* 图片素材上传 */
#define kApiWechatUploadImage            @"wechatupload/upload_base"   /* 朋友圈图片素材上传 */
#define kApiOrderPicPreview              @"order/orderPicPreviewApi"   /* 广告素材预览 */
#define kApiPushOrderPicPreView          @"order/pushOrderPicPreviewApi"  /*Push广告素材预览 */
#define kApiWechatOrderPicPreview        @"order/saveOrderTempApi"     /* 朋友圈素材预览 */
#define kApiDataReport                   @"report/adduserbehavior"     /* 数据分析统计上报 */


#pragma mark - Manager API

#define kApiCheckAgentArea          kApiManagerHostPort @"InterfaceApi/getAreaShow"    /* 校验盒子归属地 */





#endif /* ApiHeader_h */
