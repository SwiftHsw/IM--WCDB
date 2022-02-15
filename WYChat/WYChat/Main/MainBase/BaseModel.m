//
//  BaseModel.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "BaseModel.h"

@implementation BaseModel
 
- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        NSString *stringClass = NSStringFromClass(self.class);
        self = [NSClassFromString(stringClass) mj_objectWithKeyValues:dic];
    }
    return self;
}

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{@"ID" : @"id"};
}

@end
