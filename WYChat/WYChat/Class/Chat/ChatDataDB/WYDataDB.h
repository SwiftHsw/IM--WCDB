//
//  WYDataDB.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import <Foundation/Foundation.h>
///会话模型 ///消息显示模型
#import "WYIMConversationModel.h"

 
NS_ASSUME_NONNULL_BEGIN

@interface WYDataDB : NSObject

///根据用户id创建表
- (void)connectCurrentUserDB:(NSString *)userId;

///关闭数据库
- (void)closeCurrentDB;

///删除某一个表的所有数据
- (void)deleteAllObjectsFromTable:(NSString *)table;

///销毁某一个表
- (void)dropTableFormTable:(NSString *)table;

//清除好友列表，群列表，群成员信息
- (void)clearAllDataDB;

#pragma mark - 通讯录




#pragma mark - 群聊





#pragma mark - 群成员





#pragma mark - 会话
//(查)获取所有会话
- (NSArray<WYIMConversationModel *> *)getAllConversation;

//（增，替换）更新会话
- (void)insertOrReplaceConversation:(NSArray<WYIMConversationModel *> *)conversations;

//（删）删除会话
- (void)deleterConversations:(NSArray<WYIMConversationModel *> *)conversations;

//（删）删除某个会话 ，是保留会话记录
- (void)deleterOneConversation:(WYIMConversationModel *)conversation isDeleterConversationRecord:(BOOL)isDeleterConversationRecord;

/// （删）某个会话的某一条消息
- (void)deleteMessageWithConversation:(WYIMConversationModel *)conversation messageId:(NSString *)messageId;

// （查）获取会话最新一条记录 显示在会话cell
- (ZXMessageModel *)getConversationNewMessageModelWithConversation:(WYIMConversationModel *)conversation;

#pragma mark - 会话对应的聊天记录

// （增、替换）会话对应的聊天记录
- (void)insertOrReplaceMessageModelForConversation:(WYIMConversationModel *)conversation messageModel:(ZXMessageModel *)model;
// （增、替换）会话对应的聊天记录
- (void)insertOrReplaceMessageModelForConversation:(WYIMConversationModel *)conversation messageModels:(NSArray<ZXMessageModel *> *)models;



// （查）获取会话对应的聊天记录
- (NSArray<ZXMessageModel *> *)getConversationForAllMessageModel:(WYIMConversationModel *)conversation;
//  （查）获取会话对应的聊天记录
- (NSArray<ZXMessageModel *> *)getConversationForMessageModel:(WYIMConversationModel *)conversation size:(int32_t)size page:(int32_t)page;
@end

NS_ASSUME_NONNULL_END
