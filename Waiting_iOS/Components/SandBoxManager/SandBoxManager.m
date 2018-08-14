//
//  SandBoxManager.m
//  Waiting_iOS
//
//  Created by ChenQiuLiang on 2018/4/17.
//Copyright © 2018年 BEHE. All rights reserved.
//

#import "SandBoxManager.h"
#import "BHUserModel.h"

//沙盒文件夹名称
#define Image_Original   @"image_original"    //原始图片
#define Image_Thumbnail  @"image_thumbnail"   //缩略图
#define Voice            @"voice"             //语音

@implementation SandBoxManager

#pragma mark - 公共方法

/** 获取沙盒里 Home 目录 */
+ (NSString *)home
{
    return NSHomeDirectory();
}

/** 获取 Document 目录 */
/** 只有用户生成的文件、应用程序不能重新创建的文件存放在这里，会通过iCloud备份 */
+ (NSString *)document
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/** 获取 Cache 目录 */
/** location of discardable cache files */
+ (NSString *)cache
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/** 获取 Library 目录 */
/** 可以从服务器重新下载的文件、various documentation, support, and configuration files, resources (Library) */
+ (NSString *)library
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/** 获取 Tmp 目录 */
+ (NSString *)tmp
{
    return NSTemporaryDirectory();
}

/**
 * @brief   新建一个文件夹（包含判断文件夹是否存在）
 * @param   path 文件夹所在路径
 * @param   name 文件夹名称
 * @return  成功/失败
 */
+ (BOOL)creatDirectoryAtPath:(NSString *)path name:(NSString *)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newDirectory = [path stringByAppendingPathComponent:name];
    
    //创建目录
    if ([fileManager fileExistsAtPath:newDirectory]) {
        //NSLog(@"该路径的文件夹已经存在：%@",newDirectory);
        return YES;
    }
    BOOL isSuccess = [fileManager createDirectoryAtPath:newDirectory
                            withIntermediateDirectories:YES
                                             attributes:nil
                                                  error:nil];
    if (isSuccess) {
        NSLog(@"文件夹创建成功：%@",newDirectory);
    }
    return isSuccess;
}

#pragma mark - 本工程方法
/** 创建用户文件夹 */
+ (BOOL)creatUserDirectorty
{
    BOOL isSuccess = [self creatDirectoryAtPath:[self document] name:[BHUserModel sharedInstance].userID];
    return isSuccess;
}

/** 获取用户文件夹 */
+ (NSString *)userDirectory
{
    return [[SandBoxManager document] stringByAppendingPathComponent:[BHUserModel sharedInstance].userID];
}

/** @brief 新建（原始图片）、（缩略图）、（语音）文件夹 */
+ (BOOL)creatFilesDirectorys
{
    BOOL isSucces_O = [self creatDirectoryAtPath:[self userDirectory] name:Image_Original];
    BOOL isSucces_T = [self creatDirectoryAtPath:[self userDirectory] name:Image_Thumbnail];
    BOOL isSucces_V = [self creatDirectoryAtPath:[self userDirectory] name:Voice];
    
    if (isSucces_O && isSucces_T && isSucces_V) {
        return YES;
    } else if (!isSucces_O) {
        NSLog(@"原始图片文件夹创建失败！");
    } else if (!isSucces_T) {
        NSLog(@"缩略图文件夹创建失败！");
    } else if (!isSucces_V) {
        NSLog(@"语音文件夹创建失败！");
    }
    return NO;
}

/** 原始图片文件夹 */
+ (NSString *)originalImageDirectory
{
    return [[SandBoxManager userDirectory] stringByAppendingPathComponent:Image_Original];
}

/** 缩略图文件夹 */
+ (NSString *)thumbnailImageDirectory
{
    return [[SandBoxManager userDirectory] stringByAppendingPathComponent:Image_Thumbnail];
}

/** 语音文件夹 */
+ (NSString *)voiceDirectory
{
    return [[SandBoxManager userDirectory] stringByAppendingPathComponent:Voice];;
}

/** 写入原图文件,返回图片路径 */
+ (NSString *)writeToDirectoryOriginalImage:(UIImage *)image from:(PhotoType)photoType path:(NSString *)path_Original
{
    NSLog(@"生成大图路径");
    
    BOOL isSuccess;
    if (photoType == PhotoTypeFromCamera)
    {
        NSLog(@"大图压缩开始！");
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
        isSuccess = [imageData writeToFile:path_Original atomically:NO];
    }
    else
    {
        NSData *data_Original = UIImageJPEGRepresentation(image, 0.5);
        isSuccess = [data_Original writeToFile:path_Original atomically:YES];
    }
    
    if (isSuccess) {
        NSLog(@"大图压缩结束！");
        return path_Original;
    } else {
        NSLog(@"%s,%@,写入文件失败！",__FUNCTION__,path_Original);
        return nil;
    }
}

/** 写入缩略图文件 ,返回图片路径 */
+ (NSString *)writeToDirectoryThumbnailImagePath:(NSString *)imagePath from:(PhotoType)photoType path:(NSString *)path_Thumbnail
{
    NSLog(@"小图压缩开始！");
    BOOL isSuccess;
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:imagePath];
    NSData *imageData = UIImageJPEGRepresentation(image, 0);
    
    isSuccess = [imageData writeToFile:path_Thumbnail atomically:YES];
    
    if (isSuccess) {
        NSLog(@"小图压缩结束！");
        return path_Thumbnail;
    } else {
        NSLog(@"%s,%@,写入文件失败！",__FUNCTION__,path_Thumbnail);
        return nil;
    }
}

/** 写入要发布的活动通知的图片 */
+ (NSString *)writeToDirectoryActivityImage:(UIImage *)image from:(PhotoType)photoType
{
    
    NSLog(@"生成大图路径(活动通知)");
    NSString *imageName = @"toAddActivity.png";
    NSString *path = [[self tmp] stringByAppendingPathComponent:imageName];
    
    BOOL isSuccess;
    if (photoType == PhotoTypeFromCamera)
    {
        NSLog(@"大图压缩开始！(活动通知)");
        NSData *imageData = UIImageJPEGRepresentation(image, 0);
        isSuccess = [imageData writeToFile:path atomically:NO];
    }
    else
    {
        NSData *data_Original = UIImageJPEGRepresentation(image, 0.5);
        isSuccess = [data_Original writeToFile:path atomically:YES];
    }
    
    if (isSuccess) {
        NSLog(@"大图压缩结束！(活动通知)");
        return path;
    } else {
        NSLog(@"%s,%@,写入文件失败！(活动通知)",__FUNCTION__,path);
        return nil;
    }
}

@end
