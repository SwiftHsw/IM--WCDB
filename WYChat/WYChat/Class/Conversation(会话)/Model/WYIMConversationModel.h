//
//  WYIMConversationModel.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import <Foundation/Foundation.h>
#import "ZXMessageModel.h"
 
NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    //其他
    CIMConversationType_Other = 0,
    //私聊
    CIMConversationType_Single = 2001,
    //群聊
    CIMConversationType_Group = 2002,
} CIMConversationType;

typedef void (^WYIMConversationModelReceiveBlock)(ZXMessageModel *messageModel);


@interface WYIMConversationModel : NSObject


/// 会话ID(私聊：用户ID ,群聊：群ID)
@property (nonatomic , copy) NSString *conversationId;

/// 数据库中对应的ID
@property (nonatomic , copy) NSString *idBeDB;

/// 昵称
@property (nonatomic , copy) NSString *nickName;

/// 消息类型
@property (nonatomic , assign) int32_t msgContentType;

/// 2001 : 私聊    2002：群聊
@property (nonatomic , assign) int32_t type;
/// 单聊/群聊
@property (nonatomic , assign) CIMConversationType conversationType;

/// 未读消息数
@property (nonatomic , assign) int64_t recordNum;

/// 最新一条消息的时间（和离线消息一起做过处理，使用它）
@property (nonatomic , assign) long long needLastTime;

/// 最新一条消息的时间
@property (nonatomic , assign) long long lastTime;

/// 最后操作时间
@property (nonatomic , assign) long long dealLastTime;

/// 最新的消息
@property (nonatomic , strong) ZXMessageModel *knewMessageModel;
/// 最新消息的内容
@property (nonatomic , copy) NSString *lastMsgString;


/// 最新消息是否为离线消息 （做展示处理）
@property (nonatomic , assign) BOOL isNewOfflineMsg;
/// 离线消息_内容
@property (nonatomic , copy) NSString *offlineMsg_lastMsg;
/// 离线消息_最新一条消息的时间
@property (nonatomic , assign) long long offlineMsg_lastTime;
/// 离线消息_消息类型
@property (nonatomic , assign) int32_t offlineMsg_msgContentType;
/// 离线消息用户的备注昵称
@property (nonatomic , copy) NSString *remarkName;

/// 离线网络请求 优先级
@property (nonatomic , assign) NSInteger priority;

/// 是否在DB里
@property (nonatomic , assign) BOOL isInDB;
/// 是否置顶聊天
@property (nonatomic , assign) BOOL isBeTop;

/// 是否删除
@property (nonatomic , assign) BOOL isDelForConversation;

/// 会话对应的记录表名
@property (nonatomic , copy) NSString *conversationRecordTableName;
/// 通过传递方式接收别人发送的消息
@property (nonatomic , copy , nullable) WYIMConversationModelReceiveBlock receiveBlock;
/// 通过传递方式接收自己发送后需要更新状态的消息
@property (nonatomic , copy , nullable) WYIMConversationModelReceiveBlock receiveSelfNeedUpdateMessageBlock;

/// 通过传递方式接收别人发送的消息
@property (nonatomic , strong) RACSubject *receiveSinal;

/// 通过传递方式接收自己发送后需要更新状态的消息
@property (nonatomic , strong) RACSubject *receiveSelfNeedUpdateMessageSinal;

/// 聊天页  离线消息展示最新
@property (nonatomic , strong) RACSubject *knewOfflineMessageSingal;

@property (nonatomic , assign) BOOL loadOfflineMessageFirst;

/// 最新操作时间
@property (nonatomic , copy) NSString *dateString;


///
/// @param conversationId 会话ID
/// @param type  2001（单聊） / 2002（群聊）
/// @param isSaveIntoDB 是否保存到DB
+ (WYIMConversationModel *)conversationWithConversationId:(NSString *)conversationId type:(int32_t)type isSaveIntoDB:(BOOL)isSaveIntoDB;

/// 最后一条消息(处理过的，仅会话首页使用)
- (void)getLastString:(void (^)(NSAttributedString *lastString))block;

/// 发送消息
/// @param messageModel 消息
- (void)sendMessageModel:(ZXMessageModel *)messageModel success:(void (^)(ZXMessageModel *messageModel))success fail:(void (^)(ZXMessageModel *messageModel))fail;

/// 更新会话自己
- (void)updataConversationSelf;

/// 更新会话最后一条信息(会重新查找最后一条消息)
- (void)updateLastNewMessage;

/// 会话是否置顶
- (void)updateIsBeTop:(BOOL)isBeTop;


/// （更新/插入 ）消息到对应的conversation聊天记录表中
- (void)insertOrReplaceMessageModelToConversation:(ZXMessageModel *)messageModel;


/// 获取规定大小，哪个位置开始的消息
- (NSArray<ZXMessageModel *> *)getConversationForMessageModelsWithSize:(int32_t)size page:(int32_t)page;

/// 删除一条消息
- (void)deleteOneMessageWithMessageID:(NSString *)messageId;

@end

NS_ASSUME_NONNULL_END

@class WYIMOfflineMessageDetailModel;

@interface WYIMOfflineMessageModel : NSObject

@property (nonatomic , strong) NSArray<WYIMOfflineMessageDetailModel *> *list;

@end

@interface WYIMOfflineMessageDetailModel : NSObject
/// 消息记录id
@property (nonatomic , copy) NSString *id;
/// Description
@property (nonatomic , copy) NSString *sessionId;
/// 消息ID
@property (nonatomic , copy) NSString *msgId;
/// 消息类型（2001：私聊，2002：群聊）
@property (nonatomic , copy) NSString *msgType;
/// 消息内容类型（1：文字，2：图片，3：音文件，4：短视频文件，5：个人名片，6：消息撤回，7：位子消息，8：文件）
@property (nonatomic , copy) NSString *msgContentType;
/// 消息内容
@property (nonatomic , copy) NSString *msgContent;
/// 发送者id
@property (nonatomic , copy) NSString *fromId;
/// 接受者id
@property (nonatomic , copy) NSString *toId;
/// 时间
@property (nonatomic , assign) int64_t createTime;
/// 扩展
@property (nonatomic , copy) NSString *extend;

- (ZXMessageModel *)offlineMessageDetailModelToMessageModel;

@end
