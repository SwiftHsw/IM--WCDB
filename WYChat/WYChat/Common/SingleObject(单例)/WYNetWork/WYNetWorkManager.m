//
//  LZNetworkManager.m
//  JYJewelryPeoject
//
//  Created by huangshiwen on 2021/6/3.
//

#import "WYNetWorkManager.h"
#import "UIViewController+MBExtension.h"
#import "MBProgressHUD+Extension.h"
#import "NSObject+SWNetManager.h"
#import "RACCommand+SWExtension.h"

@interface WYNetWorkManager()

/// 请求头内容
@property (nonatomic , strong) NSDictionary *headHTTPHeaderField;

/// 下载文件记录
@property (nonatomic , strong) NSMutableDictionary<NSString * , NSData *> *downFileDataSource;
/// 下载任务数组
@property (nonatomic , strong) NSMutableArray<NSURLSessionDownloadTask *> *downTaskArr;

/// 请求任务数组
@property (nonatomic , strong) NSMutableArray<RACCommand *> *commandArr;

@end
@implementation WYNetWorkManager

static AFURLSessionManager *cpURLSessionManager;
static WYNetWorkManager *manager = nil;

+ (instancetype)sharedClient {
   
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[WYNetWorkManager alloc]init];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
        manager.requestSerializer.timeoutInterval = 20;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        cpURLSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        
    });
    return manager;
}


#pragma mark - Publick
- (void)addHeadHTTPHeaderField:(NSDictionary *_Nullable)dic
{
    self.headHTTPHeaderField = dic;
    [self.headHTTPHeaderField enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}


#pragma mark - 三种请求
- (void)postWithURLString:(NSString *)URLString
               parameters:(NSDictionary *)parameters
                isNeedSVP:(BOOL)isNeedSVP
                  success:(void(^)(NSDictionary *messageDic))success{
    @weakify(self);
    [self prepareRequestNeedSVP:isNeedSVP];
    [self POST:URLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self  handleResponse:(NSDictionary *)responseObject url:URLString parameters:parameters isNeedSVP:isNeedSVP success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self handleFailure:error task:task url:URLString parameters:parameters];
    }];
}

- (void) getWithURLString:(NSString *)URLString
              parameters:(NSDictionary *)parameters
               isNeedSVP:(BOOL)isNeedSVP
                 success:(void(^)(NSDictionary *messageDic))success{
    @weakify(self);
    [self prepareRequestNeedSVP:isNeedSVP];
    [self GET:URLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self handleResponse:(NSDictionary *)responseObject url:URLString parameters:parameters isNeedSVP:isNeedSVP success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self handleFailure:error task:task url:URLString parameters:parameters];
    }];
}

- (void)uploadWithURLString:(NSString *)URLString
                     photos:(NSArray *)photos
                  isNeedSVP:(BOOL)isNeedSVP
                 parameters:(NSDictionary *)parameters
                    success:(void(^)(NSDictionary *messageDic))success{
    @weakify(self);
    [self prepareRequestNeedSVP:isNeedSVP];
  
    [self POST:URLString parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i=0; i<photos.count; i++) {
            NSData *imageData = UIImagePNGRepresentation(photos[i]);
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
            NSLog(@"%@",fileName);
            [formData appendPartWithFileData:imageData name:@"file[]" fileName:fileName mimeType:@"image/png"];
        }
    } progress:nil
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        [self handleResponse:(NSDictionary *)responseObject url:URLString parameters:parameters isNeedSVP:isNeedSVP success:success];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self handleFailure:error task:task url:URLString parameters:parameters];
    }];
}


#pragma mark - 请求和结果处理
- (void)prepareRequestNeedSVP:(BOOL)needSVP {
    NSString *authorization = @"token";
 
    [self.requestSerializer setValue:authorization forHTTPHeaderField:@"token"];
    [self.requestSerializer setValue:GETSYSTEM forHTTPHeaderField:@"version-code"];
    [self.requestSerializer setValue:@"2" forHTTPHeaderField:@"deviceid"];
    [self.requestSerializer setValue:@"zh-cn" forHTTPHeaderField:@"Accept-Language"];
    if (needSVP)   [[UIView getCurrentVC].progressHUD showHUD];
}

//处理结果 并且回掉
- (void)handleResponse:(NSDictionary *)response
                   url:(NSString *)url
            parameters:(NSDictionary *)parameters
             isNeedSVP:(BOOL)isNeedSVP
               success:(void(^)(NSDictionary *messageDic))success {
    NSLog(@"\n\n<<<<< 请求地址:%@ >>>>> 请求参数: %@\n\n<<<<< 响应数据: >>>>> %@\n\n", url, parameters, response);
    if  (isNeedSVP)  [[UIView getCurrentVC].progressHUD dissmissHUD];
    NSInteger code = [response[@"code"] integerValue];
    
    if (code == 2000) {//成功
        success(response);
    } else if (code == 6002 || code == 6001 || code == 4006) {//重新登录
        if ([[UIView getCurrentVC] isKindOfClass:[UIAlertController class]]) {
            //只弹出一次
            return;
        }
    } else {
        //错误
        [MBProgressHUD showErrorHUD:response[@"msg"] completeBlock:nil];
        
    }
}


#pragma mark 报错信息
- (void)handleFailure:(NSError * _Nonnull)error task:(NSURLSessionDataTask * _Nullable)task url:(NSString *)url
           parameters:(NSDictionary *)parameters {
    [[UIView getCurrentVC].progressHUD dissmissHUD];
    NSString *error1 = [self failHandleWithErrorResponse:error task:task url:url parameters:parameters];
    [MBProgressHUD showErrorHUD:error1 completeBlock:nil];
    
}

- (NSString *)failHandleWithErrorResponse:( NSError * _Nullable )error task:( NSURLSessionDataTask * _Nullable )task url:(NSString *)url
           parameters:(NSDictionary *)parameters {
    __block NSString *message = nil;
    // 这里可以直接设定错误反馈，也可以利用AFN 的error信息直接解析展示
    NSData *afNetworking_errorMsg = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseDataErrorKey];
    NSLog(@"afNetworking_errorMsg == %@",[[NSString alloc]initWithData:afNetworking_errorMsg encoding:NSUTF8StringEncoding]);
    if (!afNetworking_errorMsg) {
        message = @"网络连接失败";
    }
    else{
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSInteger responseStatue = response.statusCode;
        if (responseStatue >= 500) {  // 网络错误
            message = @"服务器维护升级中,请耐心等待";
        } else if (responseStatue >= 400) {
            
            // 错误信息
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:afNetworking_errorMsg options:NSJSONReadingAllowFragments error:nil];
            message = responseObject[@"error"];
        }
    }
    
    NSLog(@"\n\n<<<<< %@ >>>>> %@\n\n<<<<< The error responsed >>>>> %@\n\n", url, parameters, error);
    return message;
}


+ (void)getQiniuTokenWithithSend_type:(UploadModule)module
                              success:(void(^)(NSDictionary *messageDic))success{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"module"] = module == UploadImageUser?@"user":@"model";
    [[self sharedClient] getWithURLString:@"/common/uploadToken"
                               parameters:parameters
                                isNeedSVP:NO
                                  success:success];
    
}




/******************************************************************
 文件上传
 ******************************************************************/
- (NSURLSessionDataTask * _Nonnull)uploadFileTo_POST:(NSString *)urlStr
                      parameters:(NSDictionary *)dictionary
                dataModels:(NSArray<WYDataModel *> * _Nonnull)dataModels
                        progress:(CPNetRequestDownProgress _Null_unspecified)progress
                         success:(void(^)(NSDictionary *messageDic))success
                         failure:(NSError *)error

{
    
    return [self manager:manager
                     url:urlStr
              parameters:dictionary
              dataModels:dataModels
                progress:progress
                 success:success
                 failure:error];
}

- (NSURLSessionDataTask *)manager:(AFHTTPSessionManager *)manager
                              url:(NSString *)urlStr
                       parameters:(NSDictionary *)dictionary
                       dataModels:(NSArray<WYDataModel *> *)dataModels
                         progress:(CPNetRequestDownProgress)progress
                          success:(void(^)(NSDictionary *messageDic))success
                          failure:(NSError *)error
{
    __weak WYNetWorkManager *weakSelf = self;
    [self prepareRequestNeedSVP:NO];
    NSURLSessionDataTask *task = nil;
    task = [manager POST:urlStr parameters:dictionary headers:self.headHTTPHeaderField constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
            {
                for (WYDataModel *dataModel in dataModels)
                {
                    //图片上传
                    if (dataModel.type == WYDataModelUpload_Image)
                    {
                        [formData appendPartWithFileData:dataModel.image_data name:dataModel.image_name fileName:dataModel.image_fileName mimeType:dataModel.image_mimeType];
                    }
                    //视频上传
                    else if (dataModel.type == WYDataModelUpload_Video){
                        [formData appendPartWithFileData:dataModel.video_data name:dataModel.video_Name fileName:dataModel.video_fileName mimeType:dataModel.video_mimeType];
                    }
                    //语音上传
                    else if (dataModel.type == WYDataModelUpload_Audio){
                        [formData appendPartWithFileData:dataModel.audio_data name:dataModel.audio_name fileName:dataModel.audio_fileName mimeType:dataModel.audio_mimeType];
                    }
                    //文件上传
                    else if (dataModel.type == WYDataModelUpload_File){
                        [formData appendPartWithFileData:dataModel.file_data name:dataModel.file_name fileName:dataModel.file_fileName mimeType:dataModel.file_mimeType];
                    }
                }
            } progress:^(NSProgress * _Nonnull uploadProgress)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (progress)
                    {
                        progress(1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
                    }
                });
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
            {
                __strong WYNetWorkManager *strongSelf = weakSelf;
              [strongSelf handleResponse:responseObject url:urlStr parameters:dictionary isNeedSVP:NO success:success];
        
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
            {
             __strong WYNetWorkManager *strongSelf = weakSelf;
              [strongSelf handleFailure:error task:task url:urlStr parameters:dictionary];
                SWLog(@"====上传失败");
            }];
    return task;
}
  
/******************************************************************
 文件下载
 ******************************************************************/
- (NSURLSessionDownloadTask *)downGetFileUrl:(NSString *)urlStr
                                   progress:(CPNetRequestDownProgress)progress
                                destination:(CPNetRequestDestination)destination
                          completionHandler:(CPNetRequestDownCompletionHandler)completionHandler
{
    [self prepareRequestNeedSVP:NO];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    __weak WYNetWorkManager *weakSelf = self;
    if ([self.downFileDataSource.allKeys containsObject:urlStr.lastPathComponent]) {
        NSURLSessionDownloadTask *downloadTask = [cpURLSessionManager downloadTaskWithResumeData:self.downFileDataSource[urlStr.lastPathComponent] progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress)
                {
                    progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                }
            });
        } destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error){
            
            if (!error) {
                __strong WYNetWorkManager *strongSelf = weakSelf;
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.SWNetRequestUrl contains %@",urlStr.lastPathComponent];
                [strongSelf.downTaskArr removeObjectsInArray:[strongSelf.downTaskArr filteredArrayUsingPredicate:pre]];
                [strongSelf.downFileDataSource removeObjectForKey:filePath.absoluteString.lastPathComponent];
                [strongSelf updataDownFileDataSourceToLocation];
            }
            
            if (completionHandler)
            {
                completionHandler(response,filePath,error);
            }
        }];
        downloadTask.SWNetRequestUrl = urlStr;
        [self.downTaskArr addObject:downloadTask];
        return downloadTask;
    }
    else {
        NSURLSessionDownloadTask *downloadTask = [cpURLSessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress)
                {
                    progress(1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                }
            });
        } destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error){
            
            if (!error) {
                __strong WYNetWorkManager *strongSelf = weakSelf;
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.SWNetRequestUrl contains %@",urlStr.lastPathComponent];
                [strongSelf.downTaskArr removeObjectsInArray:[strongSelf.downTaskArr filteredArrayUsingPredicate:pre]];
                [strongSelf.downFileDataSource removeObjectForKey:filePath.absoluteString.lastPathComponent];
                [strongSelf updataDownFileDataSourceToLocation];
            }
            
            if (completionHandler)
            {
                completionHandler(response,filePath,error);
            }
        }];
        downloadTask.SWNetRequestUrl = urlStr;
        [self.downTaskArr addObject:downloadTask];
        return downloadTask;
    }
}
//开始/恢复下载
- (void)startAllDataTaskRequest
{
    NSMutableArray<RACCommand *> *arr = self.commandArr.mutableCopy;
    SWLog(@"唤起所有请求:%@",self.headHTTPHeaderField)
    for (RACCommand *command in arr)
    {
        SWLog(@"cancel:%@",command.task.originalRequest)
        [command.task cancel];
        [self.commandArr removeObject:command];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [command execute:command.netExtension];
        });
    }
    SWLog(@"唤起所有请求后:%@",self.commandArr)
}


//暂停任务
- (void)stopAllDataTaskRequest
{
    [self.commandArr enumerateObjectsUsingBlock:^(RACCommand * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.task suspend];
    }];
}

//取消任务
- (void)cancelAllDataTaskRequest
{
    [self.commandArr enumerateObjectsUsingBlock:^(RACCommand * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.task cancel];
    }];
    [self.commandArr removeAllObjects];
}

- (void)updataDownFileDataSourceToLocation
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"downRecordDataSource"];
    [self.downFileDataSource writeToFile:path atomically:NO];
}


- (NSMutableDictionary<NSString *,NSData *> *)downFileDataSource
{
    if (_downFileDataSource == nil) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"downRecordDataSource"];
        _downFileDataSource = [NSDictionary dictionaryWithContentsOfFile:path].mutableCopy;
        if (_downFileDataSource == nil) {
            _downFileDataSource = [NSMutableDictionary dictionary];
        }
    }
    return _downFileDataSource;
}

- (NSMutableArray<RACCommand *> *)commandArr
{
    if (_commandArr == nil) {
        _commandArr = [NSMutableArray array];
    }
    return _commandArr;
}

- (NSMutableArray<NSURLSessionDownloadTask *> *)downTaskArr
{
    if (_downTaskArr == nil) {
        _downTaskArr = [NSMutableArray array];
    }
    return _downTaskArr;
}

@end
