//
//  BHDataReprotManager.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/10.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "BHDataReportManager.h"
#import "FSNetWorkManager.h"


@implementation BHDataReportManager

+ (void)uploadDataWithParams:(NSDictionary *)params
{
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiDataReport
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus)
                         {
                             NSLog(@"上报成功");
                         }
                         else
                         {
                             NSLog(@"上报失败");
                         }
                         
                     } withFailureBlock:^(NSError *error) {
                         
                         NSLog(@"数据上报接口请求失败");
                     }];
}

//获取当前时间戳  （以毫秒为单位）

+ (NSString *)getNowTimeTimestamp
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date]; //现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
    
}

@end
