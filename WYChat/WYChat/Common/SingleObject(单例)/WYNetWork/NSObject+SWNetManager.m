//
//  NSObject+CPNetManager.m
//  ChatIM
//
//  Created by Mac on 2020/11/20.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "NSObject+SWNetManager.h"
#import <objc/message.h>

@implementation NSObject (SWNetManager)

- (void)setSWNetRequestUrl:(NSString *)SWNetRequestUrl
{
    objc_setAssociatedObject(self, @selector(SWNetRequestUrl), SWNetRequestUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)SWNetRequestUrl
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
