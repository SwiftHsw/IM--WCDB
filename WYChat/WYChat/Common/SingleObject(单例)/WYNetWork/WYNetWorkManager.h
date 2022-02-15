//
//  LZNetworkManager.h
//  JYJewelryPeoject
//
//  Created by huangshiwen on 2021/6/3.
//

#import <AFNetworking/AFNetworking.h>
#import "WYDataModel.h"


typedef enum : NSUInteger {
    UploadImageUser,//通告广场显示
    UploadImageModel,// 通告广场点击下拉显示
} UploadModule;


typedef void(^CPNetRequestDownProgress)(CGFloat uploadProgress);
typedef NSURL * _Nonnull(^CPNetRequestDestination)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response);
typedef void(^CPNetRequestDownCompletionHandler)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error);


NS_ASSUME_NONNULL_BEGIN

@interface WYNetWorkManager : AFHTTPSessionManager

+ (instancetype)sharedClient;
 

/// 添加请求头 添加一次就好
- (void)addHeadHTTPHeaderField:(NSDictionary *_Nullable)dic;

/**
 发送post请求
 
 @param URLString 请求的网址字符串
 @param parameters 请求的参数
 @param isNeedSVP 是否需要弹窗
 @param success 请求成功的回调
 */
- (void)postWithURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
                isNeedSVP:(BOOL)isNeedSVP
                  success:(void(^)(NSDictionary *messageDic))success;

/**
 发送get请求
 
 @param URLString 请求的网址字符串
 @param parameters 请求的参数
 @param success 请求成功的回调
 */
- (void)getWithURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
               isNeedSVP:(BOOL)isNeedSVP
                 success:(void(^)(NSDictionary *messageDic))success;
/**
 图片上传请求
 
 @param URLString url
 @param photos 照片
 @param isNeedSVP 是否需要弹窗
 @param success 数据
 */
- (void)uploadWithURLString:(NSString *)URLString
                     photos:(NSArray *)photos
                  isNeedSVP:(BOOL)isNeedSVP
                 parameters:(NSDictionary *)parameters
                    success:(void(^)(NSDictionary *messageDic))success;


/// 获取七牛云token
/// @param module  user=用户模块，model=模特模块
+ (void)getQiniuTokenWithithSend_type:(UploadModule)module
                           success:(void(^)(NSDictionary *messageDic))success;




/******************************************************************
 文件上传
 @param urlStr url地址
 @param dictionary 参数
 @param dataModels 要上传的数据模型数组
 @param progress 进度
 @param success 成功回调
 @param error 失败回调
 ******************************************************************/
- (NSURLSessionDataTask * _Nonnull)uploadFileTo_POST:(NSString *)urlStr
                      parameters:(NSDictionary *)dictionary
                dataModels:(NSArray<WYDataModel *> * _Nonnull)dataModels
                        progress:(CPNetRequestDownProgress _Null_unspecified)progress
                         success:(void(^)(NSDictionary *messageDic))success
                         failure:(NSError *)error;


/******************************************************************
 文件下载
 
 @param urlStr 下载地址
 @param progress 进度
 @param destination 存储目的地
 @param completionHandler 完成操作
 @return 返回类型
 手动开启 关闭  暂停
 
******************************************************************/
- (NSURLSessionDownloadTask * _Nonnull)downGetFileUrl:(NSString *_Nonnull)urlStr
                                            progress:(CPNetRequestDownProgress _Null_unspecified)progress
                                         destination:(CPNetRequestDestination _Nonnull)destination
                                   completionHandler:(CPNetRequestDownCompletionHandler _Nonnull)completionHandler;


/// 全部任务开始请求
- (void)startAllDataTaskRequest;

/// 暂停全部任务
- (void)stopAllDataTaskRequest;

/// 取消全部任务
- (void)cancelAllDataTaskRequest;


@end

NS_ASSUME_NONNULL_END
