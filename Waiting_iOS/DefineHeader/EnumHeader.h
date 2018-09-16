//
//  EnumHeader.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/3/19.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#ifndef EnumHeader_h
#define EnumHeader_h

/** 注册/找回密码 */
typedef enum : NSUInteger {
    ResetPassWordTypeRegister,
    ResetPassWordTypeForget,
    ResetPassWordTypeReset
} BHResetPassWordType;

typedef NS_ENUM(NSUInteger, ICPCellType) {
    ICPCellTypeBusinessLicense,     //营业执照
    ICPCellTypeTaxpayerCertify,     //银行纳税人证明
    ICPCellTypeBankLicense,         //银行开户许可证
};

typedef NS_ENUM(NSUInteger, MessageContentType) {
    MessageContentTypeAdd,    //添加短信
    MessageContentTypeEdit,   //编辑短信
};

typedef NS_ENUM(NSUInteger, SelectLabelType) {
    SelectLabelTypePhone,       //电话选择标签
    SelectLabelTypeMessage,     //短信选择标签
};

typedef NS_ENUM(NSUInteger, AdsCustomType) {  //投放客户类型
    AdsCustomTypeOnlyNew,   //只针对新增客户投放
    AdsCustomTypeAll,       //所有客户投放
};


typedef enum : NSUInteger {
    BHBindStoreChannelTypeMain, // 首页 - 选址分析
    BHBindStoreChannelTypeCustomer, // 第二模块 客流分析
    BHBindStoreChannelTypeLogin,
    BHBindStoreChannelTypeAccount,  // 从第四个模块的店铺管理进入
} BHBindStoreChannelType;

/** 创建活动、短信、push广告的入口 */
typedef enum : NSUInteger {
    BHCreadADsTypeMain,     // 从首页进入
    BHCreadADsTypeMainPassengerAys, // 从首页的客流统计进入
    BHCreadADsTypeCustom, // 从第二模块客流分析进入
    BHCreadADsTypeEdit,     // 从第三个模块营销管理  - 详情 - 编辑
    BHCreadADsTypeMovie,    // 从学习中心进入
    BHCreadADsTypeSubAccount,   // 电话 - 从子账号模块进入
} BHCreadADsType;

/** 绑定微信公众号入口 */
typedef enum : NSUInteger {
    BHQualificationWechatTypeMain,  // 首页点击按钮进入
    BHQualificationWechatTypeMarketingScene,    // 选择营销方式进入
    BHQualificationWechatTypeQua,      // 资质信息页面进入
    
} BHQualificationWechatType;

/** 绑定微信公众号类型 */
typedef enum : NSUInteger {
    BHBindWechatTypeWechat,     // 朋友圈广告
    BHBindWechatTypeWiFiAD,     // WiFi广告
} BHBindWechatType;

typedef enum : NSUInteger {
    BHConnectNetTypeCreateStore,
    BHConnectNetTypeStoreManager,
} BHConnectNetType;

typedef NS_ENUM(NSUInteger, MyInputType) {
    MyInputTypeTextField,     //一行输入框
    MyInputTypeTextView,     //多行文本输入框
    MyInputTypeGender,       //性别选择
    MyInputTypeInterest,     //爱好选择
};

#endif /* EnumHeader_h */
