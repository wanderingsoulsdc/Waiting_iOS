//
//  SandBoxManager.h
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/4/17.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PhotoTypeFromCamera,
    PhotoTypeFromLibary
} PhotoType;

@interface SandBoxManager : NSObject

#pragma mark - 公共方法
/** 获取沙盒里 Home 目录 */
+ (NSString *)home;

/** 获取 Document 目录 */
+ (NSString *)document;

/** 获取 Cache 目录 */
+ (NSString *)cache;

/** 获取 Library 目录 */
+ (NSString *)library;

/** 获取 Tmp 目录 */
+ (NSString *)tmp;

/**
 * @brief   新建一个文件夹
 * @param   path 文件夹所在路径
 * @param   name 文件夹名称
 * @return  成功/失败
 */
+ (BOOL)creatDirectoryAtPath:(NSString *)path name:(NSString *)name;

#pragma mark - 本工程方法

/** 创建用户文件夹 */
+ (BOOL)creatUserDirectorty;
/** 获取用户文件夹 */
+ (NSString *)userDirectory;


/** 新建（原始图片）、（缩略图）、（语音）文件夹 */
+ (BOOL)creatFilesDirectorys;
/** 原始图片文件夹 */
+ (NSString *)originalImageDirectory;
/** 缩略图文件夹 */
+ (NSString *)thumbnailImageDirectory;
/** 语音文件夹 */
+ (NSString *)voiceDirectory;


/** 写入原图文件 */
+ (NSString *)writeToDirectoryOriginalImage:(UIImage *)image from:(PhotoType)photoType path:(NSString *)path_Original;
/** 写入缩略图文件 */
+ (NSString *)writeToDirectoryThumbnailImagePath:(NSString *)imagePath from:(PhotoType)photoType path:(NSString *)path_Thumbnail;

/** 写入要发布的活动通知的图片 */
+ (NSString *)writeToDirectoryActivityImage:(UIImage *)image from:(PhotoType)photoType;

@end
