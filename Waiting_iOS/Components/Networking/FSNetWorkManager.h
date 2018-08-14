//
//  FSNetWorkManager.h
//  AFNetWorking再封装
//
//  Created by ChenQiuLiang on 16/5/20.
//  Copyright © 2016年 ChenQiuLiang. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "FSNetWorkError.h"

/**定义方便处理请求结果的宏*/
//#define NetResponseCheckStaus       ([[object objectForKey:@"code"] integerValue] == 0)
#define NetResponseCheckStaus       ([[NSString stringWithFormat:@"%@",[object objectForKey:@"code"]] isEqualToString:@"200"])
#define NetResponseMessage          ([object objectForKey:@"msg"])
#define NetResponseReason           ([object objectForKey:@"reason"])
#define NetResponseForKey(key)      ([[object objectForKey:@"data"] objectForKey:key])
//特殊：token失效
#define NetResponseTokenInvalid     ([[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]] isEqualToString:@"14"] || [[NSString stringWithFormat:@"%@",[responseObject objectForKey:@"code"]] isEqualToString:@"901030013"])

/**定义请求失败的提示*/
#define NetRequestFailed    @"请求失败，请检查网络重试"

/**定义请求类型的枚举*/

typedef NS_ENUM(NSUInteger,HttpRequestType)
{
    HttpRequestTypeGet = 0,
    HttpRequestTypePost
};


/**定义请求成功的block*/
typedef void(^requestSuccess)(NSDictionary * object);

/**定义请求失败的block*/
typedef void(^requestFailure)(NSError *error);

/**定义上传进度block*/
typedef void(^uploadProgress)(float progress);

/**定义下载进度block*/
typedef void(^downloadProgress)(float progress);

/**定义网络状态block*/
typedef void(^CurrentStatus)(AFNetworkReachabilityStatus currentStatus);

@interface FSNetWorkManager : AFHTTPSessionManager


/**
 *  单利方法
 *
 *  @return 实例对象
 */
+(instancetype)shareManager;

/**
 *  网络请求的实例方法
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param paraments    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock;


/**
 *  网络请求的实例方法
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param paraments    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 *  @param progress     请求进度
 */
+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:(requestSuccess)successBlock withFailureBlock:( requestFailure)failureBlock progress:(downloadProgress)progress;

/**
 *  上传多张图片
 *
 *  @param operations   上传图片预留参数---视具体情况而定 可移除
 *  @param imageArray   上传的图片数组
 *  @parm width      图片要被压缩到的宽度
 *  @param urlString    上传的url
 *  @param successBlock 上传成功的回调
 *  @param failureBlock 上传失败的回调
 *  @param progress     上传进度
 */

+(void)uploadImageWithOperations:(NSDictionary *)operations withImageArray:(NSArray *)imageArray withtargetWidth:(CGFloat )width withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress;


/**
 *  上传单张图片
 *
 *  @param operations   上传图片预留参数---视具体情况而定 可移除
 *  @param urlString    上传的图片
 *  @param image        图片实例
 *  @param imageKey     图片参数的键名
 *  @param successBlock 上传成功的回调
 *  @param failureBlock 上传失败的回调
 *  @param progress     上传进度
 */
+(void)uploadSingleImageWithOperations:(NSDictionary *)operations withUrlString:(NSString *)urlString withImage:(UIImage *)image withImageKey:(NSString *)imageKey  withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress;


/**
 *  视频上传
 *
 *  @param operations   上传视频预留参数---视具体情况而定 可移除
 *  @param videoPath    上传视频的本地沙河路径
 *  @param urlString     上传的url
 *  @param successBlock 成功的回调
 *  @param failureBlock 失败的回调
 *  @param progress     上传的进度
 */
+(void)uploadVideoWithOperaitons:(NSDictionary *)operations withVideoPath:(NSString *)videoPath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withUploadProgress:(uploadProgress)progress;


/**
 *  文件下载
 *
 *  @param operations   文件下载预留参数---视具体情况而定 可移除
 *  @param savePath     下载文件保存路径
 *  @param urlString        请求的url
 *  @param successBlock 下载文件成功的回调
 *  @param failureBlock 下载文件失败的回调
 *  @param progress     下载文件的进度显示
 */


+(void)downLoadFileWithOperations:(NSDictionary *)operations withSavaPath:(NSString *)savePath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withDownLoadProgress:(downloadProgress)progress;

/**
 *  取消所有的网络请求
 */


+(void)cancelAllRequest;
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的url
 */

+(void)cancelHttpRequestWithRequestType:(NSString *)requestType requestUrlString:(NSString *)string;


/**
 *  网络状况变化后的回调
 *
 *  @param currentStatus 网络状况变化后的网络状态
 */
+ (void)networkStatusHasChanged:(CurrentStatus)currentStatus;


/**
 *   清除登录接口的cookies
 */
+ (void)clearCookies;

@end
