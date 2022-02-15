//
//  RACCommand+HBExtension.m
//  HBNovel
//
//  Created by Mac on 2019/12/5.
//  Copyright © 2019 MAC. All rights reserved.
//

#import "RACCommand+SWExtension.h"
#import <Objc/runtime.h>

@implementation RACCommand (SWExtension)

+ (void)load
{
    [super load];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method executeMethod = class_getInstanceMethod(self, @selector(execute:));
        Method cp_executeMethod = class_getInstanceMethod(self, @selector(cp_execute:));
        method_exchangeImplementations(executeMethod, cp_executeMethod);
    });
}

- (RACSignal *)cp_execute:(id)input
{
    self.netExtension = input;
    return [self cp_execute:input];
}

- (void)setNetExtension:(id)netExtension
{
    objc_setAssociatedObject(self, @selector(netExtension), netExtension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)netExtension
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTask:(NSURLSessionTask *)task
{
    objc_setAssociatedObject(self, @selector(task), task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURLSessionTask *)task
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setPriority:(NSInteger)priority
{
    objc_setAssociatedObject(self, @selector(priority), @(priority), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)priority
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
