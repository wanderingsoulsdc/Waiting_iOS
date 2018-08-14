//
//  BHAgreementViewController.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/12/6.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    BHAgreementTypeRegister,    // 注册时候查看协议
    BHAgreementTypeNew,         // 协议有新版本更新，必须同意后才可继续使用服务
} BHAgreementType;

@interface BHAgreementViewController : BHWebViewController

@property (nonatomic, strong) NSDictionary           * loginResponseData;
@property (nonatomic, assign) BHAgreementType        type;
@property (nonatomic, copy) NSString * mobile;
@property (nonatomic, copy) NSString * password;

@property (nonatomic, copy) NSString * token;
@end
