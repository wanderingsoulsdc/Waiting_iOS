//
//  FSPushManager.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/10/23.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import "FSPushManager.h"
#import "FSLaunchManager.h"
#import "FSNetWorkManager.h"

@interface FSPushManager () <UIAlertViewDelegate>

@end

@implementation FSPushManager

+ (instancetype)sharedInstance
{
    static FSPushManager *pushManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(self){
            pushManager = [[self alloc] init];
        }
    });
    return pushManager;
}

- (void)handingPushNotificationDictionary:(NSDictionary *)userInfo
{
    NSString * type = userInfo[@"type"];
    
    switch ([type integerValue]) {
        case 1:
        {
            NSLog(@"余额不足提示充值消息");
            [[FSLaunchManager sharedInstance].rootTabBarController setSelectedIndex:3];
        }
            break;
        case 2:
        {
            NSLog(@"招财喵插电消息");
//            NSString * shopStatus = userInfo[@"shopStatus"];
//            NSString * shopId = userInfo[@"shopId"];
//            // http://d.luckycat.behe.com/account/shopInfo?type=1&sId=593
//            NSString * url = [NSString stringWithFormat:@"%@?type=%@&sId=%@",kApiWebAccountShopDetail, shopStatus, shopId];
        }
            break;
        case 3:
        {
            NSLog(@"版本更新");
            [self checkVersion];
        }
            break;
        case 4:
        {
            NSLog(@"新版本更新内容");
        
        }
            break;
        case 5:
        case 6:
        case 7:
        case 8:
        {
            
        }
            break;
        case 9:
        {
            // 消息通知
            NSLog(@"点击查看详情");
//            NSString * mId = userInfo[@"mId"];
//            NSString * title = userInfo[@"title"];
//            BHNotificationDetailViewController * detailVC = [[BHNotificationDetailViewController alloc] init];
//            detailVC.title = kStringNotNull(title) ? title : @"消息详情";
//            detailVC.url = [NSString stringWithFormat:@"%@?id=%@", kApiWebNotification, mId];
//            [[FSLaunchManager sharedInstance].rootTabBarController pushToViewController:detailVC animated:YES];
        }
            break;
        case 99:
        {
            NSLog(@"任意url的推送");
//            NSString * url = userInfo[@"url"];
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - 检查更新

- (void)checkVersion
{
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary * params = @{@"versionName":localVersion, @"type":@"1"};
    [FSNetWorkManager requestWithType:HttpRequestTypePost
                        withUrlString:kApiCheckVersion
                        withParaments:params
                     withSuccessBlock:^(NSDictionary *object) {
                         // 请求成功
                         if (NetResponseCheckStaus)
                         {
                             // #1 不用更新 #2 选择更新 #3 强制更新
                             NSString * status = object[@"data"][@"status"];
                             if ([status integerValue] == 2)
                             {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                                                     message:@"发现新版本！\n是否立即更新？"
                                                                                    delegate:self
                                                                           cancelButtonTitle:@"稍后更新"
                                                                           otherButtonTitles:@"立即更新", nil];
                                 [alertView setTag:1234];
                                 [alertView show];
                             }
                             else if ([status integerValue] == 3)
                             {
                                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                                                     message:@"应用版本有重大升级，请立即更新"
                                                                                    delegate:self
                                                                           cancelButtonTitle:nil
                                                                           otherButtonTitles:@"立即更新", nil];
                                 [alertView setTag:12345];
                                 [alertView show];
                             }
                         }
                     } withFailureBlock:^(NSError *error) {
                         //
                     }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1234) {
        if (buttonIndex == 0) {
            
        } else if (buttonIndex == 1) {
            NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kAPPID];
            NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
            [[UIApplication sharedApplication] openURL:iTunesURL];
        }
    }
    else if (alertView.tag == 12345)
    {
        NSString *iTunesString = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@", kAPPID];
        NSURL *iTunesURL = [NSURL URLWithString:iTunesString];
        [[UIApplication sharedApplication] openURL:iTunesURL];
        
        sleep(1);
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"新版本提示"
                                                            message:@"应用版本有重大升级，请立即更新"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"立即更新", nil];
        [alertView setTag:12345];
        [alertView show];
    }
}

@end
