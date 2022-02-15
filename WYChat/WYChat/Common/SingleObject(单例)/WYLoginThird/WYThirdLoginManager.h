//
//  MSThirdLoginManager.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYThirdLoginManager : NSObject

+ (instancetype)sharedManager;

- (void)openWechatLoginSuccess:(void(^)(NSString *identity))success;

- (void)openAppleLoginSuccess:(void(^)(NSString *identity))success;
 

@end

NS_ASSUME_NONNULL_END
