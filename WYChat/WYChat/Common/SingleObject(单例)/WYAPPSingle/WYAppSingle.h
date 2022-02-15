//
//  MSAppSingle.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "BaseModel.h" 
 
#import "WYIMConversationManager.h"
#import "AcountServer.h"
#import "WYDataDB.h"
#import "AppDelegate.h"


NS_ASSUME_NONNULL_BEGIN

@interface WYAppSingle : BaseModel


/// 会话管理者
@property (nonatomic,strong) WYIMConversationManager *conversationManager;

/// 数据库管理者
@property (nonatomic,strong) WYDataDB *dataManager;

/// TCP管理者
@property (nonatomic,strong) NSObject *clientManager;

/// 是否有新朋友添加
@property (nonatomic , assign) int32_t newAddFriendCount;

/**
 初始化
 */
+(instancetype)shareManager;

/**
 用户服务
 */
@property (nonatomic , strong) AcountServer *userServer;

/**
 用户数据
 */
@property (nonatomic , strong) NSObject *userModel;

/**
 系统配置
 */
@property (nonatomic , strong) NSObject *systemModel;

/**
 推送通知是否打开
 */
@property (nonatomic , assign) BOOL isNotificationAuthorized;

/**
 是否登录
 */
@property (nonatomic , assign) BOOL isLogin;

/**
 appdelegate
 */
@property (nonatomic,strong) AppDelegate *appdelegae;



@end

NS_ASSUME_NONNULL_END
