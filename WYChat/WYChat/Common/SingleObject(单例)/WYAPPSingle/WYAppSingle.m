//
//  MSAppSingle.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "WYAppSingle.h"

@implementation WYAppSingle
 
static WYAppSingle *instance = nil;

+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[WYAppSingle alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self)
    {
//        NSDictionary *dic = [AppUserCache getUserInfo];
//        if (dic)  {
//             SWLog(@"**************用户数据存在************** \n ====%@",dic)
//            self.userModel = [NSObject mj_objectWithKeyValues:dic];
//        } else  {
//            SWLog(@"**************用户数据不存在**************")
//        }
    }
    return self;
}
- (BOOL)isLogin
{
    return self.userModel;
}

#pragma mark - get

- (AcountServer *)userServer
{
    if (_userServer == nil) {
        _userServer = [AcountServer new];
    }
    return _userServer;
}


- (WYIMConversationManager *)conversationManager
{
    if (_conversationManager == nil) {
        _conversationManager = [WYIMConversationManager new];
    }
    return _conversationManager;;
}

- (WYDataDB *)dataManager
{
    if (_dataManager == nil) {
        _dataManager = [WYDataDB new];
        [_dataManager connectCurrentUserDB:@"15080163676"];
    }
    return _dataManager;
}

- (NSObject *)clientManager
{
    if (_clientManager == nil) {
//        _tcpManager = [CPTCPManager shareManager];
//        _tcpManager.cpDelegate = self;
    }
    return _clientManager;
}


@end
