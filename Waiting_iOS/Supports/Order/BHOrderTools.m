//
//  BHOrderTools.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/4/3.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import "BHOrderTools.h"
#import "FSLaunchManager.h"

@interface BHOrderTools ()

@end

@implementation BHOrderTools
{
    BHOrderType _type;
    requestSuccessOrderID _successBlock;
    requestFailureOrderID _failureBlock;
}

#pragma mark - shareManager

/**
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类的实例
 */

+(instancetype)shareManager
{
    static BHOrderTools * tools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tools = [[self alloc] init];
    });
    return tools;
}

#pragma mark - Public Method

- (void)requestOrderIdWithOrderType:(BHOrderType)type withSuccessBlock:(requestSuccessOrderID)successBlock withFailureBlock:(requestFailureOrderID)failureBlock
{
    _type = type;
    _successBlock = successBlock;
    _failureBlock = failureBlock;
    
    [self checkUserQualificationAudit];
}

#pragma mark - Privite Method

- (void)checkUserQualificationAudit
{
    [FSNetWorkManager requestWithType:HttpRequestTypeGet
                        withUrlString:kApiQualificationAudit
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus)
                         {
                             NSString * auditStatus = object[@"data"][@"audit"];
                             NSString * uploadStatus = object[@"data"][@"uploadStatus"];
                             
                             if ([uploadStatus integerValue] == 1)
                             {
                                 if ([auditStatus integerValue] == 1)
                                 {
                                     [self getOrderID];
                                 }
                                 else
                                 {
                                     // 未审核
                                     _failureBlock(@"资质未审核");
                                 }
                             }
                             else
                             {
                                 // 未上传
                                 _failureBlock(@"资质未上传");
                             }
                         }
                         else
                         {
                             _failureBlock(NetResponseMessage);
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         _failureBlock(NetRequestFailed);
                     }];
}

- (void)getOrderID
{
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiGetOrderId
                        withParaments:nil
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus)
                         {
                             NSString * orderID = object[@"data"];
                             [self dealWithADsPushViewControllerWithOrderID:orderID];
                         }
                         else
                         {
                             _failureBlock(NetResponseMessage);
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         _failureBlock(NetRequestFailed);
                     }];
}

- (void)dealWithADsPushViewControllerWithOrderID:(NSString *)orderID
{
    switch (_type) {
        case BHOrderTypeAD:
        {
            // 网络营销
            [self createPreOrderWithOrderID:orderID withType:@"1"];
        }
            break;
        case BHOrderTypePhone:
        {
            // 电话营销
            [self createPreOrderWithOrderID:orderID withType:@"0"];
        }
            break;
        case BHOrderTypeMessage:
        {
            // 短信营销
            [self createPreOrderWithOrderID:orderID withType:@"0"];
        }
            break;
        case BHOrderTypeWiFiAD:
        {
            // WiFi广告
            [self createPreOrderWithOrderID:orderID withType:@"0"];
        }
        default:
            break;
    }
}

- (void)createPreOrderWithOrderID:(NSString *)orderID withType:(NSString *)type
{
    NSDictionary * params = @{@"id":@"", @"type":type, @"typeId":@"1", @"orderHash":orderID};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiCreatePreOrder
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         
                         NSLog(@"请求成功");
                         if (NetResponseCheckStaus)
                         {
                             if ( _type == BHOrderTypeWiFiAD)
                             {
                                 NSLog(@"朋友圈");
                             }
                             else
                             {
                                 _successBlock(orderID, object);
                             }
                         }
                         else
                         {
                             _failureBlock(NetResponseMessage);
                         }
                     } withFailureBlock:^(NSError *error) {
                         NSLog(@"error is %@", error);
                         _failureBlock(NetRequestFailed);
                     }];
}

@end
