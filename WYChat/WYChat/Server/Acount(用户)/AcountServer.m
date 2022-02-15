//
//  AcountServer.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "AcountServer.h"

@implementation AcountServer

- (RACCommand *)loginCommand{
    if (!_loginCommand) {
        _loginCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                
                [subscriber sendNext:@"登录成功"];
                [subscriber sendCompleted];
                
//                [[MSNetWorkManager sharedClient] postWithURLString:loginUrl parameters:input isNeedSVP:true success:^(NSDictionary * _Nonnull messageDic) {
//                    [subscriber sendNext:messageDic];
//                    [subscriber sendCompleted];
//                }];
                return nil;
            }];
        }];
    }     return _loginCommand;
}
@end
