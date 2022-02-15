//
//  WYIMConversationManager.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "WYIMConversationManager.h"


@interface WYIMConversationManager ()
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , copy) WYIMConversationManagerComplete updateUnReadNumBlock;
@end


@implementation WYIMConversationManager



/// 实时监听消息收发回调
- (void)conversationsList:(UITableView *)tableView messageChangeWithComplete:(WYIMConversationManagerComplete)complete{
    self.tableView = tableView;
    self.updateUnReadNumBlock = complete;
}

/// 会话是否置顶
- (void)updateConversation:(WYIMConversationModel *)conversation isBeTop:(BOOL)isBeTop{
    
    [conversation updateIsBeTop:isBeTop];
    //重新排序刷新表
    NSSortDescriptor *sortDes1 = [NSSortDescriptor sortDescriptorWithKey:@"needLastTime" ascending:NO];
    NSSortDescriptor *sortDes2 = [NSSortDescriptor sortDescriptorWithKey:@"isBeTop" ascending:NO];
    [self.conversations sortUsingDescriptors:@[sortDes2,sortDes1]];
    [self.tableView reloadData];
    
}

/// 更新会话
/// @param arr 更新或者插入
- (void)insertOrReplaceConvesations:(NSArray<WYIMConversationModel *> *)arr{

    [WYAppSingle.shareManager.dataManager insertOrReplaceConversation:arr];
    
}


/// 供消息首页使用的方法，提取会话
- (WYIMConversationModel *)getOneConversationWithDidSelectorIndex:(NSInteger)index moveFirst:(BOOL)moveFirst
{
    WYIMConversationModel *conversation = [self.conversations objectAtIndex:index];
    if (moveFirst) {
        conversation.dealLastTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        conversation.recordNum = 0;
        [conversation updataConversationSelf];
        [self moveConversationToFirst:conversation];
    }
    self.inConversation = conversation;
    return conversation;
}

- (void)moveConversationToFirst:(WYIMConversationModel *)conversation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.conversations containsObject:conversation]) {
            
            NSInteger idex = [self.conversations indexOfObject:conversation];
            //置顶
            if (conversation.isBeTop) {
                [self.conversations moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idex] toIndex:0];
                [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:idex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [self.tableView reloadRow:0 inSection:0 withRowAnimation:idex == 0 ? UITableViewRowAnimationNone : UITableViewRowAnimationAutomatic];
            }
            //非置顶
            else {
                
//                __block NSUInteger to_index = 0;
//                [self.conversations enumerateObjectsUsingBlock:^(WYIMConversationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if (!obj.isBeTop) {
//                        to_index = idx;
//                        *stop = YES;
//                    }
//                }];
//                [self.conversations moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:idex] toIndex:to_index];
//                [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:idex inSection:0] toIndexPath:[NSIndexPath indexPathForRow:to_index inSection:0]];
//                [self.tableView reloadRow:to_index inSection:0 withRowAnimation:idex == to_index ? UITableViewRowAnimationNone : UITableViewRowAnimationAutomatic];
            }
        }
    });
}

- (WYIMConversationModel *)getOneConversationWithConversationId:(NSString *)conversationId type:(int32_t)type isSavaIntoDB:(BOOL)isSaveIntoDB
{
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.conversationId == %@ AND SELF.type == %d",conversationId,type];
    NSOrderedSet<WYIMConversationModel *> *arr = [self.conversations filteredOrderedSetUsingPredicate:pre];
    
    //不存在会话时，生成一个会话
    if (arr == nil || arr.count == 0) {
        WYIMConversationModel *conversation = [WYIMConversationModel conversationWithConversationId:conversationId type:type isSaveIntoDB:isSaveIntoDB];
        ZXMessageModel *model = [ZXMessageModel createNoteMessageModelWithType:ZXMessageTypeAddNewFriendSuccess];
        model.date = [NSDate dateWithTimeIntervalSince1970:0];
        //会话对应的聊天记录
        [WYAppSingle.shareManager.dataManager insertOrReplaceMessageModelForConversation:conversation messageModel:model];
        conversation.nickName = conversationId;
        conversation.knewMessageModel = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.conversations insertObject:conversation atIndex:0];
            [self.tableView insertRow:0 inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
        });
        return conversation;
    }
    //存在
    else {
        WYIMConversationModel *conversation = arr.lastObject;
        //不存在数据库中，则插入
        if (!conversation.isInDB) {
            conversation.isInDB = YES;
            [self insertOrReplaceConvesations:@[conversation]];
        }
        return conversation;
    }
}

- (void)deleterConversation:(WYIMConversationModel *)conversation isDeleterConversationRecord:(BOOL)isDeleterConversationRecord{
    
    [WYAppSingle.shareManager.dataManager deleterOneConversation:conversation isDeleterConversationRecord:isDeleterConversationRecord];
    dispatch_async(dispatch_get_main_queue(), ^{
        //删除数据源并且刷新
        if ([self.conversations containsObject:conversation]) {
            NSInteger idex = [self.conversations indexOfObject:conversation];
            [self.conversations removeObject:conversation];
            [self.tableView deleteRow:idex inSection:0 withRowAnimation:idex == 0 ? UITableViewRowAnimationNone :UITableViewRowAnimationAutomatic];
        }
    });
}
#pragma mark - get
- (NSMutableOrderedSet<WYIMConversationModel *> *)conversations{
    
    if (!_conversations) {
        _conversations = [[NSMutableOrderedSet alloc]initWithArray:[WYAppSingle.shareManager.dataManager getAllConversation]];
        NSSortDescriptor *sortDes1 = [NSSortDescriptor sortDescriptorWithKey:@"needLastTime" ascending:NO];
        NSSortDescriptor *sortDes2 = [NSSortDescriptor sortDescriptorWithKey:@"isBeTop" ascending:NO];
        [_conversations sortUsingDescriptors:@[sortDes2,sortDes1]];
    }
    SWLog(@"*********************会话列表====%@",_conversations);
    
    return _conversations;
}

@end
