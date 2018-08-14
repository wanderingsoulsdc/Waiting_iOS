//
//  BHNotificationModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2017/11/30.
//Copyright © 2017年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHNotificationModel : NSObject

@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * ctime;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * notificationID;
@property (nonatomic, assign) CGFloat cellHeight;

@end
