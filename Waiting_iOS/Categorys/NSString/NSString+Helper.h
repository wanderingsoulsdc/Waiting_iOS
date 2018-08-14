//
//  NSString+Helper.h
//  iPresale
//
//  Created by ChenQiuLiang on 15/8/18.
//  Copyright (c) 2015年 YS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Helper)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)toSize;

/**
 *  判断字符串是否为空
 *
 *  @return 字符串是否有内容
 */
- (BOOL)isBlankString;

/**
 *  截断收尾空白字符
 *
 *  @return 截断结果
 */
- (NSString *)trimString;

/**
 *  为指定文件名添加沙盒文档路径
 *
 *  @return 添加沙盒文档路径的完整路径字符串
 */
- (NSString *)appendToDocumentDir;

/**
 *  为指定文件名添加沙盒文档路径
 *
 *  @return 添加沙盒文档路径的完整路径字符串
 */
- (NSURL *)appendToDocumentURL;

/**
 *  对指定字符串进行BASE64编码
 *
 *  @return BASE64编码后的字符串
 */
- (NSString *)base64EncodedString;

/**
 *  对指定BASE64编码的字符串进行解码
 *
 *  @return 解码后的字符串
 */
- (NSString *)base64DecodeString;

/**
 *  在字符串末尾添加日期及时间
 *
 *  @return 添加日期及时间之后的字符串
 */
- (NSString *)appendDateTime;
/**
 *  将字符串日期转成NSDate self:2010-08-04
 *
 *  @return 当前日期
 */
- (NSDate *)formatterDateTime;

/**
 *  将时间戳转换成日期格式
 *
 *  @param format 日期格式
 *
 *  @return 时间戳对应的日期
 */
- (NSString *)formatterDateTimeWithFormat:(NSString *)format;

- (BOOL)stringLength:(NSInteger)length;

- (BOOL)isTelephoneNumber;

- (BOOL)isMobileFormatter;

// 身份证的正则表达式
- (BOOL)checkPersonCard;
// 身份证的算法校验，比上面的正则更严格
- (BOOL)checkIDCardNumber;
// 邮箱的正则
- (BOOL)checkEmail;
// 姓名的正则 中英文 0-20位
- (BOOL)checkName;
// 手机号的正则
- (BOOL)checkMobileNumber;
// 是否包含中文的正则
- (BOOL)includeChinese;

// 截取URL中的参数
- (NSMutableDictionary *)getURLParameters;

/**
 *  md5
 *
 *  @return md5
 */
- (NSString *)MD5Hash;

- (NSString *) URLEncodedString;
- (NSString*) URLDecodedString;
- (NSString *) utf8ToUnicode:(NSString *)string;
- (NSString *) unicodeToUtf8:(NSString *)string;

/**
 *  json字符串转化为字典
 */
- (NSDictionary *)dictionaryWithJsonString;

@end
