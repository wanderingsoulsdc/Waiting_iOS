//
//  NSArray+JSONString.m
//  haiTaoGuest
//
//  Created by 龚丹丹 on 15/9/17.
//  Copyright (c) 2015年 HT. All rights reserved.
//

#import "NSArray+JSONString.h"

@implementation NSArray (JSONString)

- (NSString *)JsonString {
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString * jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

@end
