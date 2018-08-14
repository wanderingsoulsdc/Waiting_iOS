//
//  BHTreasureModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/27.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BHPreAddressModel.h"

typedef enum : NSUInteger {
    BHTreasureStateNormal,              //正常，已联网
    BHTreasureStateWithoutNetwork,      //未联网
    BHTreasureStateExpire,              //到期
} BHTreasureState;

@interface BHTreasureModel : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * mac;
@property (nonatomic, strong) NSString * storeName;
@property (nonatomic, strong) NSString * storeID;
@property (nonatomic, strong) NSString * treasureID;
@property (nonatomic, strong) NSString * wifiName;
@property (nonatomic, strong) NSString * wifiPassword;
@property (nonatomic, strong) NSString * openStatus;    //是否到期停用
@property (nonatomic, assign) BHTreasureState state;

@property (nonatomic, strong) NSMutableArray<BHPreAddressModel *> * addressArray;

@end
