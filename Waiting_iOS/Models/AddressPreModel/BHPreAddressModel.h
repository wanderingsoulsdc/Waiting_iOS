//
//  BHAddressPreModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/7/11.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHPreAddressModel : NSObject

@property (nonatomic, strong) NSString * name;  // 预选址名称
@property (nonatomic, strong) NSString * address;
@property (nonatomic, strong) NSString * addressPreID;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * radius;
@property (nonatomic, strong) NSString * treasureID;
@property (nonatomic, strong) NSString * treasureName;
@property (nonatomic, strong) NSString * storeID;
@property (nonatomic, strong) NSString * storeName;
@property (nonatomic, strong) NSString * treasureMac;
@property (nonatomic, strong) NSString * collectStatus; // 探针是否在该地址下采集

@end
