//
//  LiteShowBorderCardsView.h
//  Waiting_iOS
//
//  Created by wander on 2018/7/2.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiteDeviceModel.h"
#import "LiteShowBorderCardsCell.h"

@protocol LiteShowBorderCardsViewDelegate <NSObject>
/**
 点击的是哪个设备的哪个按钮
 @param type 按钮事件类型
 @param deviceModel 设备model
 */
- (void)CardsViewAction:(CardsCellActionType)type deviceModel:(LiteDeviceModel *)deviceModel;
//当前展示的item是第几个
- (void)CardsViewCurrentItem:(NSInteger)index;

@end

@interface LiteShowBorderCardsView : UIView

@property(nonatomic, copy) NSArray *dataArr;

@property(nonatomic, assign) id <LiteShowBorderCardsViewDelegate> delegate;

@end
