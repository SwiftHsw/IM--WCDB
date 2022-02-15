//
//  WYIMConversationManager.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import <Foundation/Foundation.h>
#import "WYIMConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^WYIMConversationManagerComplete)(void);


@interface WYIMConversationManager : NSObject

/// 当前是所在的会话聊天页
@property (nonatomic , strong , nullable) WYIMConversationModel *inConversation;

/// 当前拥有的会话
@property (nonatomic , strong) NSMutableOrderedSet<WYIMConversationModel *> *conversations;

/// 会话是否置顶
- (void)updateConversation:(WYIMConversationModel *)conversation isBeTop:(BOOL)isBeTop;

/// 更新会话
/// @param arr 更新或者插入
- (void)insertOrReplaceConvesations:(NSArray<WYIMConversationModel *> *)arr;


/// 实时监听消息收发回调
- (void)conversationsList:(UITableView *)tableView messageChangeWithComplete:(WYIMConversationManagerComplete)complete;


/// 供消息首页使用的方法，提取会话
/// @param index 当前会话列表被点击的位置
/// @param moveFirst 是否移到第一个
- (WYIMConversationModel *)getOneConversationWithDidSelectorIndex:(NSInteger)index moveFirst:(BOOL)moveFirst;


/// 提取会话
/// @param conversationId  会话Id
/// @param isSaveIntoDB  是否保存到DB
- (WYIMConversationModel *)getOneConversationWithConversationId:(NSString *)conversationId type:(int32_t)type isSavaIntoDB:(BOOL)isSaveIntoDB;


/// 删除会话
/// @param conversation 会话
/// @param isDeleterConversationRecord 是否删除会话记录
- (void)deleterConversation:(WYIMConversationModel *)conversation isDeleterConversationRecord:(BOOL)isDeleterConversationRecord;


@end

NS_ASSUME_NONNULL_END
