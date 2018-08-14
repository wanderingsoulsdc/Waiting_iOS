//
//  BHStoreModel.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/6/27.
//  Copyright © 2017年 BEHE. All rights reserved.
//

#import "BHStoreModel.h"

@implementation BHStoreModel

- (id)copyWithZone:(NSZone *)zone {
    
    BHStoreModel * model = [[BHStoreModel allocWithZone:zone] init];
    
    model.storeID = self.storeID;
    model.name = self.name;
    model.firstLevelTradesID = self.firstLevelTradesID;
    model.firstLelelTradesString = self.firstLelelTradesString;
    model.secondLevelTradesID = self.secondLevelTradesID;
    model.secondLelelTradesString = self.secondLelelTradesString;
    model.addressSting = self.addressSting;
    model.longitude = self.longitude;
    model.latitude = self.latitude;
    model.type = self.type;
    model.treasureArray = self.treasureArray;
    
    return model;
    
}

@end
