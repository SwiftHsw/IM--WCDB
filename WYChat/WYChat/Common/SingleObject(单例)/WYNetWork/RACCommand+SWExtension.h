//
//  RACCommand+HBExtension.h
//  HBNovel
//
//  Created by Mac on 2019/12/5.
//  Copyright © 2019 MAC. All rights reserved.
//

#import <ReactiveObjC/ReactiveObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface RACCommand (SWExtension)

/// 网络请求保留字段
@property (nonatomic , strong) id netExtension;

/// 任务
@property (nonatomic , strong) NSURLSessionTask *task;

/// 优先级
@property (nonatomic , assign) NSInteger priority;

@end

NS_ASSUME_NONNULL_END
