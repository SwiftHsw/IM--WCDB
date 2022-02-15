//
//  WYDataDB.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "WYDataDB.h"
#import <WCDB/WCDB.h>
#import "WYIMConversationModel+WYIM.h"
#import "ZXMessageModel+WYIM.h"

@interface WYDataDB ()

@property (nonatomic , strong) WCTDatabase *database;

@end

@implementation WYDataDB


- (void)connectCurrentUserDB:(NSString *)userId{
    
    NSString *directoryPath = [SWDocumentPath stringByAppendingPathComponent:userId];
    
    [self createDirectoryAtPath:directoryPath];
    
    NSString *dbPath = [directoryPath stringByAppendingPathComponent:userId];

    BOOL isSuccess = [self creatDatabase:dbPath];
    
    if (isSuccess) {
        SWLog(@"*****************数据库创建/打开成功");
    }else{
        SWLog(@"=================数据库创建/打开成功失败");
    }
}

- (BOOL)creatDatabase:(NSString *)dbPath{
    
    if ([self.database isOpened]) {
        SWLog(@"当前数据库打开，正在关闭当前数据库");
        [self.database close:^{
            SWLog(@"数据库关闭成功");
        }];
    }
    self.database = [[WCTDatabase alloc]initWithPath:dbPath];
    self.database.tag = 0;
    return [self.database canOpen];
}

/// 创建文件夹
- (void)createDirectoryAtPath:(NSString *)directoryPath
{
    //判断当前是否存在文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = YES;
    BOOL isExists = [fileManager fileExistsAtPath:directoryPath isDirectory:&flag];
    //不存在，则创建
    if (!isExists) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (!error) {
            NSLog(@"*****************文件夹创建成功");
        }
        else
        {
            NSLog(@"=================文件夹创建失败:%@",error.description);
        }
    }
}

- (void)closeCurrentDB{
   ///清除所有的数组内容
    [self.database close];
}

//清除好友列表，群列表，群成员信息
- (void)clearAllDataDB{
    [self.database dropTableOfName:@""];
}

//删除某个表的所有数据
- (void)deleteAllObjectsFromTable:(NSString *)table
{
    BOOL ret = [self.database deleteAllObjectsFromTable:table];
    if (ret) {
        SWLog(@"*****************删除完成");
    }
    else {
        SWLog(@"=================删除失败");
    }
}

//销毁某个表
- (void)dropTableFormTable:(NSString *)table
{
    BOOL ret = [self.database dropTableOfName:table];
    if (ret) {
        SWLog(@"*****************销毁完成");
    }
    else {
        SWLog(@"=================销毁失败");
    }
}

- (void)connectTableAndIndexesOfName:(NSString *)name withClass:(Class)class_
{
    BOOL ret = [self.database createTableAndIndexesOfName:name withClass:class_];
    if (ret) {
        NSLog(@"*****************建表/连接表成功");
    }
    else {
        NSLog(@"=================建表/连接表失败");
    }
}




#pragma mark - 会话
//(查)获取通讯录
- (NSArray<WYIMConversationModel *> *)getAllConversation;
{
    [self connectTableAndIndexesOfName:WYIMConversationModel.className withClass:WYIMConversationModel.class];
    
    return [self.database getAllObjectsOfClass:WYIMConversationModel.class
                                     fromTable:WYIMConversationModel.className];
}
//（增，替换）更新会话
- (void)insertOrReplaceConversation:(NSArray<WYIMConversationModel *> *)conversations{
    [self connectTableAndIndexesOfName:WYIMConversationModel.className withClass:WYIMConversationModel.class];
    
    [self.database insertOrReplaceObjects:conversations
                                     into:WYIMConversationModel.className];
  
}
//（删）删除会话
- (void)deleterConversations:(NSArray<WYIMConversationModel *> *)conversations{
    
    [self connectTableAndIndexesOfName:WYIMConversationModel.className withClass:WYIMConversationModel.class];
    
    [conversations.rac_sequence.signal subscribeNext:^(WYIMConversationModel * _Nullable x) {
        
        [self.database deleteObjectsFromTable:WYIMConversationModel.className
                                        where:WYIMConversationModel.conversationId == x.conversationId];
    }];
    
  
}

//（删）删除某个会话 ，是保留会话记录
- (void)deleterOneConversation:(WYIMConversationModel *)conversation isDeleterConversationRecord:(BOOL)isDeleterConversationRecord{
    
    //删除会话表中对应的会话内容
    [self deleterConversations:@[conversation]];
    //对聊天记录处理地方，删除表
    if (isDeleterConversationRecord) {
        [self.database dropTableOfName:conversation.conversationRecordTableName];
    }
    
}


#pragma mark - 会话对应的聊天记录
// （增、替换）会话对应的聊天记录
- (void)insertOrReplaceMessageModelForConversation:(WYIMConversationModel *)conversation messageModel:(ZXMessageModel *)model
{
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    [self.database insertOrReplaceObject:model
                                    into:conversation.conversationRecordTableName];
}

// （增、替换）会话对应的聊天记录
- (void)insertOrReplaceMessageModelForConversation:(WYIMConversationModel *)conversation messageModels:(NSArray<ZXMessageModel *> *)models{
    
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    [self.database insertOrReplaceObjects:models
                                     into:conversation.conversationRecordTableName];
    
}

// （查）获取会话对应的聊天记录

- (NSArray<ZXMessageModel *> *)getConversationForAllMessageModel:(WYIMConversationModel *)conversation
{
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    return [self.database getAllObjectsOfClass:ZXMessageModel.class
                                     fromTable:conversation.conversationRecordTableName];
}
////  （查）获取会话对应的聊天记录
///
- (NSArray<ZXMessageModel *> *)getConversationForMessageModel:(WYIMConversationModel *)conversation size:(int32_t)size page:(int32_t)page{
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    return [self.database getObjectsOfClass:ZXMessageModel.class
                                  fromTable:conversation.conversationRecordTableName
                                    orderBy:ZXMessageModel.date.order(WCTOrderedDescending)
                                      limit:size
                                     offset:page];
}

/// 删除某个会话的某一条消息
- (void)deleteMessageWithConversation:(WYIMConversationModel *)conversation messageId:(NSString *)messageId
{
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    BOOL flag = [self.database deleteObjectsFromTable:conversation.conversationRecordTableName
                                                where:ZXMessageModel.messageId == messageId];
    if (flag) {
        SWLog(@"删除成功");
    }
    else {
        SWLog(@"删除失败");
    }
}

// （查）获取会话最新一条记录
- (ZXMessageModel *)getConversationNewMessageModelWithConversation:(WYIMConversationModel *)conversation
{
    [self connectTableAndIndexesOfName:conversation.conversationRecordTableName withClass:ZXMessageModel.class];
    
    return [self.database getOneObjectOfClass:ZXMessageModel.class
                                    fromTable:conversation.conversationRecordTableName
                                      orderBy:ZXMessageModel.date.order(WCTOrderedDescending)];
}


@end
