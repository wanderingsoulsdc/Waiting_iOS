//
//  BHQualificationListModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/23.
//  Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHQualificationListModel : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * textFieldText;
@property (nonatomic, strong) NSString * originalTextFieldText; // 下载的原始数据

@property (nonatomic, strong) NSString * firstLevelTradesID;
@property (nonatomic, strong) NSString * firstLelelTradesString;
@property (nonatomic, strong) NSString * secondLevelTradesID;
@property (nonatomic, strong) NSString * secondLelelTradesString;

@property (nonatomic, strong) NSString * wechatURL; // 绑定公众号的链接

@property (nonatomic, strong) NSString * imagePath;
@property (nonatomic, strong) NSArray  * otherImageArray;    // 请求获取到其他资质
@property (nonatomic, strong) NSArray  * otherCacheDataArray;     // 其他资质编辑后缓存，用于下次进入页面
@property (nonatomic, strong) NSArray  * otherCacheDeleteArray;   // 其他资质编辑后缓存，用于下次进入页面
@property (nonatomic, strong) NSDictionary * uploadParams;  // 修改后需要上传的参数

@property (nonatomic, strong) UITableViewCell * cell;

@end
