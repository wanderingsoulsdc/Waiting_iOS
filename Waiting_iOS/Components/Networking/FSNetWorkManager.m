//
//  NetWorkManager.m
//  AFNetWorking再封装
//
//  Created by ChenQiuLiang on 16/5/20.
//  Copyright © 2016年 ChenQiuLiang. All rights reserved.
//

#import "FSNetWorkManager.h"

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

#import "UIImage+compressIMG.h"

#import "BHUserModel.h"

#define apikey  @"4a8c4531acd3ae84ca7190a7398f3fb7" // 类似于自己应用中的tokken 全局参数，每个api都需要带的参数

@implementation FSNetWorkManager



#pragma mark - shareManager
/**
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类的实例
 */

+(instancetype)shareManager
{
    
    static FSNetWorkManager * manager = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        manager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kApiHostPort]];
        
    });
    
    return manager;
}


#pragma mark - 重写initWithBaseURL
/**
 *
 *
 *  @param url baseUrl
 *
 *  @return 通过重写夫类的initWithBaseURL方法,返回网络请求类的实例
 */

-(instancetype)initWithBaseURL:(NSURL *)url
{

    if (self = [super initWithBaseURL:url]) {
        
        NSAssert(url,@"您需要为您的请求设置baseUrl");
        
        /**分别设置请求以及相应的序列化器*/
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        /**设置请求超时时间*/
        
        self.requestSerializer.timeoutInterval = 15;
        
        /**设置请求头的cookie*/
//        NSString * cookie = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCookie];
//        if (kStringNotNull(cookie))
//        {
//            [self.requestSerializer setValue:cookie forHTTPHeaderField:@"Cookie"];
//        }
        
        /**设置相应的缓存策略*/
        
        self.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        AFJSONResponseSerializer * response = [AFJSONResponseSerializer serializer];
    
        response.removesKeysWithNullValues = YES;
        
        self.responseSerializer = response;
        
//        self.responseSerializer =  [AFHTTPResponseSerializer serializer];
        
        /**复杂的参数类型 需要使用json传值-设置请求内容的类型*/
        
//        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        
        /**设置apikey ------类似于自己应用中的tokken---此处仅仅作为测试使用*/
        
//        [self.requestSerializer setValue:apikey forHTTPHeaderField:@"appkey"];
        
        
        /**设置接受的类型*/
        [self.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"text/plain",@"application/json",@"text/json",@"text/javascript",@"text/html", nil]];
        
    }
    
    return self;
}


#pragma mark - 网络请求的类方法---get/post 

/**
 *  网络请求的实例方法
 *
 *  @param type         get / post
 *  @param urlString    请求的地址
 *  @param paraments    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:( requestSuccess)successBlock withFailureBlock:( requestFailure)failureBlock
{
    if ([urlString hasSuffix:kApiLogin])
    {
        [[FSNetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
        [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyAlways;
    }
    
    //统一添加Api请求头,必须项。
    NSDictionary *paramentDic = (NSDictionary *)paraments;
    if([[paramentDic allKeys] containsObject:@"token"]){
        [[FSNetWorkManager shareManager].requestSerializer setValue:[paramentDic objectForKey:@"token"] forHTTPHeaderField:@"token"];
    }else{
        if (kStringNotNull([BHUserModel sharedInstance].token)) {
            [[FSNetWorkManager shareManager].requestSerializer setValue:[BHUserModel sharedInstance].token forHTTPHeaderField:@"token"];
        }
    }
    
    [FSNetWorkManager requestWithType:type withUrlString:urlString withParaments:paraments withSuccessBlock:successBlock withFailureBlock:failureBlock progress:^(float progress){}];
}

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

+(void)requestWithType:(HttpRequestType)type withUrlString:(NSString *)urlString withParaments:(id)paraments withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock progress:(downloadProgress)progress
{
    
    
    switch (type) {
            
        case HttpRequestTypeGet:
        {
              
            
            [[FSNetWorkManager shareManager] GET:urlString parameters:paraments progress:^(NSProgress * _Nonnull downloadProgress) {
                
                progress(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (NetResponseTokenInvalid) {
                    [ShowHUDTool showBriefAlert:NSLocalizedString(@"登录信息已失效，请重新登录", nil)];
                    [FSNetWorkManager clearCookies];
                    [BHUserModel cleanupCache];
                    [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                    NSLog(@"token失效");
                    return;
                }
                
                successBlock(responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"url is %@", task.currentRequest.URL);
                       failureBlock(error);
            }];
            
            break;
        }
            
        case HttpRequestTypePost:
            
        {
            
            [[FSNetWorkManager shareManager] POST:urlString parameters:paraments progress:^(NSProgress * _Nonnull uploadProgress) {
                
                progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);

                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (NetResponseTokenInvalid) {
                    [ShowHUDTool showBriefAlert:NSLocalizedString(@"登录信息已失效，请重新登录", nil)];
                    [FSNetWorkManager clearCookies];
                    [BHUserModel cleanupCache];
                    [[FSLaunchManager sharedInstance] launchWindowWithType:LaunchWindowTypeLogin];
                    NSLog(@"token失效");
                    return;
                }
                
                if ([task.originalRequest.URL.path hasSuffix:kApiLogin])
                {
                    NSHTTPURLResponse * response = (NSHTTPURLResponse* )task.response;
                    NSString * dataCookie = @"";
                    NSArray * cookiesArray = [response.allHeaderFields[@"Set-Cookie"] componentsSeparatedByString:@","];
                    
                    for (NSString * cookiesString in cookiesArray)
                    {
                        NSArray * cookieArr = [cookiesString componentsSeparatedByString:@";"];
                        for (NSString * cookieStr in cookieArr)
                        {
                            NSString * whiteCookieStr = [cookieStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([whiteCookieStr hasPrefix:@"zcb"])
                            {
                                dataCookie = whiteCookieStr;
                                break;
                            }
                        }
                    }
                    
                    if (kStringNotNull(dataCookie))
                    {
                        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                        [defaults setObject:dataCookie forKey:kUserDefaultCookie];
                        [defaults synchronize];
                        
                        [[FSNetWorkManager shareManager].requestSerializer setValue:dataCookie forHTTPHeaderField:@"Cookie"];
                        
                        NSMutableDictionary * properties = [NSMutableDictionary dictionary];
                        [properties setObject:@"zcb" forKey:NSHTTPCookieName];
                        [properties setObject:[[dataCookie componentsSeparatedByString:@"="] lastObject] forKey:NSHTTPCookieValue];
                        [properties setObject:task.originalRequest.URL.host forKey:NSHTTPCookieDomain];
                        [properties setObject:@"/" forKey:NSHTTPCookiePath];
                        // 过期时间一年。cookies的保存时间默认是app退出后就会被清,无论是直接杀死还是后台杀死。
                        [properties setObject:[NSDate dateWithTimeIntervalSinceNow:3600*24*30*12] forKey:NSHTTPCookieExpires];
                        //下面一行是关键,删除Cookies的discard字段，应用退出，会话结束的时候继续保留Cookies
                        [properties removeObjectForKey:NSHTTPCookieDiscard];
                        NSHTTPCookie * cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
                        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                    }
                    [NSHTTPCookieStorage sharedHTTPCookieStorage].cookieAcceptPolicy = NSHTTPCookieAcceptPolicyNever;
                }
                
                    successBlock(responseObject);
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"url is %@", task.currentRequest.URL);
                     failureBlock(error);
            }];
        }
    }
}


#pragma mark - 多图上传
/**
 *  上传图片
 *
 *  @param operations   上传图片等预留参数---视具体情况而定 可移除
 *  @param imageArray   上传的图片数组
 *  @parm width      图片要被压缩到的宽度
 *  @param urlString    上传的url---请填写完整的url
 *  @param successBlock 上传成功的回调
 *  @param failureBlock 上传失败的回调
 *  @param progress     上传进度
 *
 */
+(void)uploadImageWithOperations:(NSDictionary *)operations withImageArray:(NSArray *)imageArray withtargetWidth:(CGFloat )width withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress
{

    
    //1.创建管理者对象

//      AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
     [[FSNetWorkManager shareManager] POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSUInteger i = 0 ;
        
        /**出于性能考虑,将上传图片进行压缩*/
        for (UIImage * image in imageArray) {
            
            //image的分类方法
            UIImage *  resizedImage =  [UIImage IMGCompressed:image targetWidth:width];
            
            NSData * imgData = UIImageJPEGRepresentation(resizedImage, .5);
            
            //拼接data  name为图片的字段键名
            [formData appendPartWithFileData:imgData name:@"caseimg" fileName:@"image.png" mimeType:@"image/jpeg"];
            
            i++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       
        failureBlock(error);
        
    }];
}

#pragma mark - 单图上传

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
+(void)uploadSingleImageWithOperations:(NSDictionary *)operations withUrlString:(NSString *)urlString withImage:(UIImage *)image withImageKey:(NSString *)imageKey  withSuccessBlock:(requestSuccess)successBlock withFailurBlock:(requestFailure)failureBlock withUpLoadProgress:(uploadProgress)progress
{
    
    
    //1.创建管理者对象
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    
    [[FSNetWorkManager shareManager] POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        /**出于性能考虑,将上传图片进行压缩，默认压缩宽度*/
        NSData * imgData;
        if (image.size.width > 750)
        {
            UIImage * resizedImage =  [UIImage IMGCompressed:image targetWidth:750];
            imgData = UIImageJPEGRepresentation(resizedImage, 0.5);
        }
        else
        {
            imgData = UIImageJPEGRepresentation(image, 0.5);
        }
        
        //拼接data  name为图片的字段键名
        [formData appendPartWithFileData:imgData name:imageKey fileName:@"image.png" mimeType:@"image/jpeg"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
        
        successBlock(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failureBlock(error);
        
    }];
}


#pragma mark - 视频上传

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

+(void)uploadVideoWithOperaitons:(NSDictionary *)operations withVideoPath:(NSString *)videoPath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withUploadProgress:(uploadProgress)progress
{
    
    
    /**获得视频资源*/
    
    AVURLAsset * avAsset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoPath]];

    /**压缩*/
    
//    NSString *const AVAssetExportPreset640x480;
//    NSString *const AVAssetExportPreset960x540;
//    NSString *const AVAssetExportPreset1280x720;
//    NSString *const AVAssetExportPreset1920x1080;
//    NSString *const AVAssetExportPreset3840x2160;
    
    AVAssetExportSession  *  avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPreset640x480];
    
    /**创建日期格式化器*/
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /**转化后直接写入Library---caches*/
    
    NSString *  videoWritePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:[NSString stringWithFormat:@"/output-%@.mp4",[formatter stringFromDate:[NSDate date]]]];
    
    
    avAssetExport.outputURL = [NSURL URLWithString:videoWritePath];
    
    
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
    
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
       
        
        switch ([avAssetExport status]) {
                
                
            case AVAssetExportSessionStatusCompleted:
            {
                
                
                
//                AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
                
                [[FSNetWorkManager shareManager] POST:urlString parameters:operations constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    //获得沙盒中的视频内容
                    
                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:videoWritePath] name:@"write you want to writre" fileName:videoWritePath mimeType:@"video/mpeg4" error:nil];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                       progress(uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    
                    successBlock(responseObject);
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    
                    failureBlock(error);
                    
                }];
                
                break;
            }
            default:
                break;
        }
        
        
    }];

}

#pragma mark - 文件下载


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

+(void)downLoadFileWithOperations:(NSDictionary *)operations withSavaPath:(NSString *)savePath withUrlString:(NSString *)urlString withSuccessBlock:(requestSuccess)successBlock withFailureBlock:(requestFailure)failureBlock withDownLoadProgress:(downloadProgress)progress
{
    
    
//    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    
    [[FSNetWorkManager shareManager] downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress(downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);

        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
                return  [NSURL URLWithString:savePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (error) {
            
            failureBlock(error);
        }
        
    }];
    
}


#pragma mark -  取消所有的网络请求

/**
 *  取消所有的网络请求
 *  a finished (or canceled) operation is still given a chance to execute its completion block before it iremoved from the queue.
 */

+(void)cancelAllRequest
{
    
    [[FSNetWorkManager shareManager].operationQueue cancelAllOperations];
    
}



#pragma mark -   取消指定的url请求/
/**
 *  取消指定的url请求
 *
 *  @param requestType 该请求的请求类型
 *  @param string      该请求的完整url
 */

+(void)cancelHttpRequestWithRequestType:(NSString *)requestType requestUrlString:(NSString *)string
{
    
    NSError * error;
    
    /**根据请求的类型 以及 请求的url创建一个NSMutableURLRequest---通过该url去匹配请求队列中是否有该url,如果有的话 那么就取消该请求*/
    
    NSString * urlToPeCanced = [[[[FSNetWorkManager shareManager].requestSerializer requestWithMethod:requestType URLString:string parameters:nil error:&error] URL] path];
    
    
    for (NSOperation * operation in [FSNetWorkManager shareManager].operationQueue.operations) {
        
        //如果是请求队列
        if ([operation isKindOfClass:[NSURLSessionTask class]]) {
            
            //请求的类型匹配
            BOOL hasMatchRequestType = [requestType isEqualToString:[[(NSURLSessionTask *)operation currentRequest] HTTPMethod]];
            
            //请求的url匹配
            
            BOOL hasMatchRequestUrlString = [urlToPeCanced isEqualToString:[[[(NSURLSessionTask *)operation currentRequest] URL] path]];
            
            //两项都匹配的话  取消该请求
            if (hasMatchRequestType&&hasMatchRequestUrlString) {
                
                [operation cancel];
                
            }
        }
        
    }
}

/**
 *  网络状况变化后的回调
 *
 *  @param currentStatus 网络状况变化后的网络状态
 */
+ (void)networkStatusHasChanged:(CurrentStatus)currentStatus
{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        
        currentStatus(status);
        
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


/**
 *   清除登录接口的cookies
 */
+ (void)clearCookies
{
    //获取所有cookies
    NSArray*array =  [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kApiHostPort,kApiLogin]]];
    // NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];

    //删除
    for(NSHTTPCookie*cookie in array)
    {
        if ([cookie.name isEqualToString:@"zcb"])
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            break;
        }
    }
    
    [[FSNetWorkManager shareManager].requestSerializer setValue:@"" forHTTPHeaderField:@"Cookie"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kUserDefaultCookie];
    [defaults synchronize];
}

@end
