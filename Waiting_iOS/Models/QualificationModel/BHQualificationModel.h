//
//  BHQualificationModel.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/1/11.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    BHQualificationModelTypeCustom,
    BHQualificationModelTypeOther,
} BHQualificationModelType;

@interface BHQualificationModel : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) BHQualificationModelType type;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * qualificationName;
@property (nonatomic, strong) NSString * originalQualificationName; // 记录原始的资质名,用于删除逻辑
@property (nonatomic, strong) UIImage  * image;
@property (nonatomic, strong) NSString * imageURL;  // 用于展示

@end
