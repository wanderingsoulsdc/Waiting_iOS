//
//  BHUserModel.h
//  Customer
//
//  Created by ChenQiuLiang on 2017/5/11.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHUserModel : NSObject

@property (nonatomic, copy) NSString * userName;            //用户名
@property (nonatomic, copy) NSString * userHeadImageUrl;    //头像(主)
@property (nonatomic, copy) NSString * age;                 //年龄
@property (nonatomic, copy) NSString * gender;              //性别
@property (nonatomic, copy) NSString * photoNum;            //照片数量
@property (nonatomic, retain) NSArray * photoArray;         //照片数组

@property (nonatomic, copy) NSString * mobile;
@property (nonatomic, copy) NSString * passwd;
@property (nonatomic, copy) NSString * userID;              //accountId
@property (nonatomic, copy) NSString * token;               // 自动登录标识
@property (nonatomic, copy) NSString * deviceNum;           // 账号有过的设备数量
@property (nonatomic, copy) NSString * userMobile;          //用户手机号(区别于登录手机号<暂时一样>)
@property (nonatomic, copy) NSString * businessName;        //营业执照主体名称
@property (nonatomic, copy) NSString * businessLicenceImg;  //营业执照图片链接
@property (nonatomic, copy) NSString * auditStatus;         //资质审核状态  -1 未上传 0-审核中 1-审核通过  2-拒绝
@property (nonatomic, copy) NSString * refuseReason;         //资质审核拒绝原因
@property (nonatomic, copy) NSString * aptitudeOneId;       //资质行业一级分类
@property (nonatomic, copy) NSString * aptitudeTwoId;       //资质行业二级分类
@property (nonatomic, copy) NSString * balance;             //账户余额

@property (nonatomic, copy) NSString * isSubAccount;        // 是否是子账号  0 不是  1 是
@property (nonatomic, copy) NSString * agreementUpdate;     // 协议是否有更新 0 无更新  1 有更新
@property (nonatomic, copy) NSString * permissionAll;       // 基础模块权限
@property (nonatomic, copy) NSString * permissionWechat;    // 朋友圈权限 0 隐藏  1 显示
@property (nonatomic, copy) NSString * permissionWcrd;      // 315   0 去掉  1 不去不改
@property (nonatomic, copy) NSString * permissionSMS;       // 短信灰度测试  0 隐藏  1 显示
@property (nonatomic, copy) NSString * permissionWiFiAD;    // WiFi广告  0 隐藏  1 显示
@property (nonatomic, copy) NSString * isNoviceGuide;       // 是否需要新手引导   0 不引导  1 引导
@property (nonatomic, copy) NSString * isFinishGuideStore;  // 是否已完成创建店铺的新手引导  0 未完成  1 已完成
@property (nonatomic, copy) NSString * isFinishGuideMessage;// 是否已完成创建短信的新手引导  0 未完成  1 已完成
@property (nonatomic, copy) NSString * isFinishGuidePhone;  // 是否已完成创建电话的新手引导  0 未完成  1 已完成
@property (nonatomic, copy) NSString * isFinishGuideAD;     // 是否已完成创建广告的新手引导  0 未完成  1 已完成
@property (nonatomic, assign) NSInteger treasureCount;

+ (instancetype)sharedInstance;
- (void)analysisUserInfoWithDictionary:(NSDictionary *)dict;
- (void)analysisUserInfoWithDictionary:(NSDictionary *)dict Mobile:(NSString *)mobile Passwd:(NSString *)password Token:(NSString *)token;
- (void)modifyUserInfoWithDictionary:(NSDictionary *)dict;
+ (void)cleanupCache;
- (void)saveToDisk;

@end
