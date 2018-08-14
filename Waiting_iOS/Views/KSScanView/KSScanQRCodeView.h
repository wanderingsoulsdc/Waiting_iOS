//
//  KSScanQRCodeView.h
//  KSPay
//
//  Created by ksjr-zg on 15/12/10.
//  Copyright © 2015年 快刷金融. All rights reserved.
//

#import "LiteDeviceScanQRViewController.h"

@interface KSScanQRCodeView : UIView

/**
 *  透明的区域
 */
@property (nonatomic, assign) CGSize transparentArea;
@property (nonatomic, assign) LiteScanQRCodeType type;
@property (nonatomic, assign) CGFloat topMargin;        // 扫描框距离顶部的距离

@end
