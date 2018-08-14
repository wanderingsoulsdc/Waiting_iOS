//
//  LiteShowBorderCardsCell.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/2.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteDeviceModel.h"

typedef NS_ENUM(NSUInteger, ShowBorderCardsCellType) {
    typeDeviceExist,    //设备存在
    typeAddNewDevice,   //添加一个新设备
};

typedef NS_ENUM(NSUInteger, CardsCellActionType) {
    ActionTypeAddDevice,    //添加设备按钮点击
    ActionTypeDeviceName,   //设备名称按钮点击
    ActionTypeLabelNum,     //标签数量按钮点击
    ActionTypeBottom,       //底部按钮点击
};

@protocol LiteShowBorderCardsCellDelegate <NSObject>

- (void)buttonAction:(CardsCellActionType)type deviceModel:(LiteDeviceModel *)deviceModel;

@end

@interface LiteShowBorderCardsCell : UICollectionViewCell

@property(nonatomic , assign) ShowBorderCardsCellType type;

@property(nonatomic , assign) id <LiteShowBorderCardsCellDelegate> delegate;

- (void)configWithData:(LiteDeviceModel *)model;

@end
