//
//  AcountServer.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AcountServer : BaseModel
 
/**
 登录
 */
@property (nonatomic , strong) RACCommand *loginCommand;

/**
 注册
 */
@property (nonatomic , strong) RACCommand *registCommand;

/**
 忘记密码
 */
@property (nonatomic , strong) RACCommand *editPassWhenForgetCommand;

/**
 退出登录
 */
@property (nonatomic , strong) RACCommand *logoutCommand;

/**
 token出错
 */
@property (nonatomic , strong) RACCommand *tokenErrorCommand;




@end

NS_ASSUME_NONNULL_END
