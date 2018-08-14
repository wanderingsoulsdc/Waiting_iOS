//
//  BHStoreModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/27.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHTreasureModel.h"

/** 已有店铺/准备开店 */
typedef enum : NSUInteger {
    BHBindStoreInOperation,   // 营业中
    BHBindStorePlan,  // 计划开店
} BHBindStoreType;

@interface BHStoreModel : NSObject

@property (nonatomic, strong) NSString * storeID;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * firstLevelTradesID;
@property (nonatomic, strong) NSString * firstLelelTradesString;
@property (nonatomic, strong) NSString * secondLevelTradesID;
@property (nonatomic, strong) NSString * secondLelelTradesString;
@property (nonatomic, strong) NSString * addressSting;
@property (nonatomic, strong) NSString * longitude; // 经度
@property (nonatomic, strong) NSString * latitude;  // 纬度
@property (nonatomic, strong) NSString * cine;      // 详细地址
@property (nonatomic, assign) BHBindStoreType type; // 店铺类型

@property (nonatomic, strong) NSMutableArray<BHTreasureModel *> * treasureArray;

@end
