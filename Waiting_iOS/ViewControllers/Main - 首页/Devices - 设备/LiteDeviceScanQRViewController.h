//
//  LiteDeviceScanQRViewController.h
//  Waiting_iOS
//
//  Created by wander on 2018/6/29.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "LiteBaseViewController.h"

typedef enum : NSUInteger {
    LiteScanQRCodeTypeAddDevice,      // 添加设备
    LiteScanQRCodeTypeCoupon,         // 扫描优惠券
    LiteScanQRCodeTypeRaffle,         // 抽奖绑定
    LiteScanQRCodeTypeRaffleRebind,   // 抽奖重新绑定
} LiteScanQRCodeType;

@protocol LiteScanQRCodeViewControllerDelegate <NSObject>

- (void)scanQRCodeCompletedWithContent:(NSString *)content;

@end

@interface LiteDeviceScanQRViewController : LiteBaseViewController

@property (nonatomic, weak) UIViewController <LiteScanQRCodeViewControllerDelegate> * delegate;
@property (nonatomic, assign) LiteScanQRCodeType type;

// 判断是否有摄像头权限
- (BOOL)checkPermissions;

// 生成二维码
+ (UIImage *)outputQRCodeImgWithText:(NSString *)text size:(CGFloat)size;

@end
