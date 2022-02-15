//
//  WYIMConversationModel.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import "WYIMConversationModel.h"
#import <WCDB/WCDB.h>
@implementation WYIMConversationModel


WCDB_IMPLEMENTATION(WYIMConversationModel)
WCDB_SYNTHESIZE(WYIMConversationModel, idBeDB)
WCDB_SYNTHESIZE(WYIMConversationModel, conversationId)
WCDB_SYNTHESIZE(WYIMConversationModel, nickName)
WCDB_SYNTHESIZE(WYIMConversationModel, msgContentType)
WCDB_SYNTHESIZE(WYIMConversationModel, type)
WCDB_SYNTHESIZE(WYIMConversationModel, recordNum)
WCDB_SYNTHESIZE(WYIMConversationModel, offlineMsg_lastMsg)
WCDB_SYNTHESIZE(WYIMConversationModel, offlineMsg_lastTime)
WCDB_SYNTHESIZE(WYIMConversationModel, offlineMsg_msgContentType)
WCDB_SYNTHESIZE(WYIMConversationModel, remarkName)
WCDB_SYNTHESIZE(WYIMConversationModel, isInDB)
WCDB_SYNTHESIZE_DEFAULT(WYIMConversationModel, isBeTop, NO)
WCDB_SYNTHESIZE(WYIMConversationModel, dealLastTime)

/// 定义主键
WCDB_PRIMARY(WYIMConversationModel, idBeDB)

- (void)updataConversationSelf{
    /// 更新会话自己
    
    
}

/// 会话是否置顶
- (void)updateIsBeTop:(BOOL)isBeTop
{
    self.isBeTop = isBeTop;
    [self updataConversationSelf];
}

+ (WYIMConversationModel *)conversationWithConversationId:(NSString *)conversationId type:(int32_t)type isSaveIntoDB:(BOOL)isSaveIntoDB{
    
    WYIMConversationModel *conversation = [WYIMConversationModel new];
    conversation.conversationId = conversationId;
    conversation.type = type;
    if (isSaveIntoDB) {
        conversation.isInDB = YES;
        [WYAppSingle.shareManager.conversationManager insertOrReplaceConvesations:@[conversation]];
    }
    return conversation;
}
- (void)sendMessageModel:(ZXMessageModel *)messageModel success:(void (^)(ZXMessageModel * _Nonnull))success fail:(void (^)(ZXMessageModel * _Nonnull))fail{
    
    int index = (arc4random() % 2) + 1;
    if (index == 1) {
        messageModel.ownerTyper = ZXMessageOwnerTypeSelf;
    }else{
        messageModel.ownerTyper = ZXMessageOwnerTypeOther;
    }
  
    //插入数据库备份(等待消息发送状态返回)
    [self insertOrReplaceMessageModelToConversation:messageModel];
    //处理消息，如有需要上传文件，必须提交完上传后，在发送消息
    [self chatUploadFileWithMessage:messageModel completeHandle:^(ZXMessageModel *message) {
        //失败，则刷新
        if (message.sendState == ZXMessageSendFail)
        {
            if (fail) fail(message);
        }
        //成功就发送
        else
        {
//            [CPTCPManager.shareManager sendMsd:[message messageModelToMsg:self]];
            message.sendState = ZXMessageSendSuccess;
            SWLog(@"更新数据库插入发送成功的数据");
            [self insertOrReplaceMessageModelToConversation:message];
            if (success) success(message);
        }
        
    }];
 
}
- (void)chatUploadFileWithMessage:(ZXMessageModel *)message completeHandle:(void (^)(ZXMessageModel *message))handle
{
    //没有代码块回调直接报错
    if (!handle) {
        [NSException exceptionWithName:@"必须有回调" reason:@"请添加回调" userInfo:nil];
        return;
    }

    //文本
    if (message.messageType == ZXMessageTypeText ||
        message.messageType == ZXMessageTypeSticker ||
        message.messageType == ZXMessageTypeMessageWithdraw ||
        message.messageType == ZXMessageTypeNameCard) {
        handle(message);
    }
    else
    {
        //图片
        if (message.messageType == ZXMessageTypeImage)
        {
            //判断是否已经提交过
            if (message.imageURL) {
                handle(message);
                return;
            }
            
            WYDataModel *dataModel = [WYDataModel new];
            [dataModel setDataModelWithImage:message.image type:WYDataModelUpload_Image fileName:@"file"];
             //做上传图片接口处理 成功返回block
        }
        //视频
        else if (message.messageType == ZXMessageTypeVideo)
        {
            //判断是否已经提交过
            if (message.videoRemotePath) {
                handle(message);
                return;
            }
            
            @weakify(message)
            [message videoCompressToMP4WithComplete:^{
                @strongify(message)
                
                [self insertOrReplaceMessageModelToConversation:message];
                
                WYDataModel *dataModel = [WYDataModel new];
                [dataModel setDataModelWithVideoPath:message.videLocalSourcePath type:WYDataModelUpload_Video fileName:@"file"];
                //做上传视频接口处理 成功返回block
            }];
        }
        //录音
        else if (message.messageType == ZXMessageTypeVoice)
        {
            //判断是否已经提交过
            if (message.videoRemotePath) {
                handle(message);
                return;
            }
            
            WYDataModel *dataModel = [WYDataModel new];
            [dataModel setDataModelWithAudioPath:message.voiceSourcePath type:WYDataModelUpload_Audio fileName:@"file"];
        }
        //文件
        else if (message.messageType == ZXMessageTypeFile) {
            
            if (message.fileUrl) {
                handle(message);
                return;
            }
            
            WYDataModel *dataModel = [WYDataModel new];
            [dataModel setDataModelWithFilePath:message.fileLocationPath type:WYDataModelUpload_File fileName:message.fileName key:@"file"];
            
        }
    }
}

- (void)insertOrReplaceMessageModelToConversation:(ZXMessageModel *)messageModel{
    
    [WYAppSingle.shareManager.dataManager insertOrReplaceMessageModelForConversation:self
                                                                        messageModel:messageModel];
}


/// 获取规定大小，哪个位置开始的消息
- (NSArray<ZXMessageModel *> *)getConversationForMessageModelsWithSize:(int32_t)size page:(int32_t)page;
{
    NSArray *arr = [WYAppSingle.shareManager.dataManager getConversationForMessageModel:self size:size page:page];
    //数据库中的顺序是倒叙
    return [[arr reverseObjectEnumerator] allObjects];
}


/// 删除一条消息
- (void)deleteOneMessageWithMessageID:(NSString *)messageId
{
    [WYAppSingle.shareManager.dataManager deleteMessageWithConversation:self messageId:messageId];
}
/// 更新会话最后一条信息
- (void)updateLastNewMessage
{
    self.knewMessageModel = [WYAppSingle.shareManager.dataManager getConversationNewMessageModelWithConversation:self];
}

- (void)getLastString:(void (^)(NSAttributedString *lastString))block
{
    /**   消息内容类型
    1 文字
    2 图片
    3 音文件
    4 短视频文件
    5 个人明信片
    6 消息撤回
    7  位置消息
    8 文件
    9 贴图
    10 消息双向删除
    11 变更群名称
    12群新加入提示信息
    13 群成员退出提示信息
    14 群禁言
    15 群禁止加好友
    16 群主转让
    17群踢成员
    18 新好友提示信息
    */
    
    ZXMessageModel *model =  self.knewMessageModel;
    
    //是离线消息
    if (self.isNewOfflineMsg) {
        if (!model) {
            self.knewMessageModel = [[ZXMessageModel alloc] init];
            model = self.knewMessageModel;
        }
        model.ownerTyper = ZXMessageOwnerTypeOther;
        model.messageType = [ZXMessageModel messageModelTypeWith:self.offlineMsg_msgContentType];
        model.date = [NSDate dateWithTimeIntervalSince1970:self.offlineMsg_lastTime / 1000];
        model.text = self.offlineMsg_lastMsg;
    }
    
    if (!model) {
        if (block) block(nil);
        return;
    }
    
    if (model.messageType == ZXMessageTypeImage)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[图片]" block:block];
    }
    else if (model.messageType == ZXMessageTypeVoice)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[语音]" block:block];
    }
    else if (model.messageType == ZXMessageTypeVideo)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[视频]" block:block];
    }
    else if (model.messageType == ZXMessageTypeNameCard)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[名片]" block:block];
    }
    else if (model.messageType == ZXMessageTypeMessageWithdraw)
    {
        [self getMessageModelUserWithMessageModel:model lastString:model.text block:block];
    }
    else if (model.messageType == ZXMessageTypeLocation)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[位置]" block:block];
    }
    else if (model.messageType == ZXMessageTypeFile)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[文件]" block:block];
    }
    else if (model.messageType == ZXMessageTypeSticker)
    {
        [self getMessageModelUserWithMessageModel:model lastString:@"[贴纸]" block:block];
    }
    else {
        [self getMessageModelUserWithMessageModel:model lastString:model.text block:block];
    }
}
- (void)getMessageModelUserWithMessageModel:(ZXMessageModel *)messageModel lastString:(NSString *)lastString block:(void (^)(NSAttributedString *lastString))block
{
    //单聊
    if (self.conversationType == CIMConversationType_Single) {
        if (messageModel.messageType == ZXMessageTypeVoice && messageModel.ownerTyper == ZXMessageOwnerTypeOther) {
            NSAttributedString *att = [NSString attributedWithString:lastString color:messageModel.readState ? SWColor(@"#B1B1B1") : UIColor.redColor font:SWFont_Regular(14)];
            if (block) block(att);
        }
        else {
            NSAttributedString *att = [NSString attributedWithString:lastString color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
            if (block) block(att);
        }
    }
    //群聊
    else {
        if (messageModel.messageType == ZXMessageTypeText ||
            messageModel.messageType == ZXMessageTypeImage ||
            messageModel.messageType == ZXMessageTypeVideo ||
            messageModel.messageType == ZXMessageTypeVoice ||
            messageModel.messageType == ZXMessageTypeFile ||
            messageModel.messageType == ZXMessageTypeLocation ||
            messageModel.messageType == ZXMessageTypeSticker ||
            messageModel.messageType == ZXMessageTypeNameCard ) {
            
            //别人发的
            //[WYAppSingle.shareManager.userModel memberId]
            
            if (![messageModel.fromId isEqualToString:@"12345"]) {
                if (self.isNewOfflineMsg) {
                    //语音特别处理
                    if (messageModel.messageType == ZXMessageTypeVoice && messageModel.ownerTyper == ZXMessageOwnerTypeOther) {
                        NSMutableAttributedString *att1 = [NSString attributedWithString:[NSString stringWithFormat:@"%@：",self.remarkName] color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
                        NSAttributedString *att2 = [NSString attributedWithString:lastString color:messageModel.readState ? SWColor(@"#B1B1B1") : UIColor.redColor font:SWFont_Regular(14)];
                        [att1 appendAttributedString:att2];
                        if (block) block(att1);
                    }
                    else {
                        NSAttributedString *att = [NSString attributedWithString:[NSString stringWithFormat:@"%@：%@",self.remarkName,lastString] color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
                        if (block) block(att);
                    }
                }
                else {
                    //群时获取群内某一个成员信息
//                    [self getGroupMemberInConversationWithFriendID:messageModel.fromId handle:^(CIMAddressBookFriendModel * _Nonnull model, CIMConversationModel * _Nonnull conversation) {
//                        //语音特别处理
//                        if (messageModel.messageType == ZXMessageTypeVoice && messageModel.ownerTyper == ZXMessageOwnerTypeOther) {
//                            NSMutableAttributedString *att1 = [NSString attributedWithString:[NSString stringWithFormat:@"%@：",model.name] color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
//                            NSAttributedString *att2 = [NSString attributedWithString:lastString color:messageModel.readState ? SWColor(@"#B1B1B1") : UIColor.redColor font:SWFont_Regular(14)];
//                            [att1 appendAttributedString:att2];
//                            if (block) block(att1);
//                        }
//                        else {
//                            NSAttributedString *att = [NSString attributedWithString:[NSString stringWithFormat:@"%@：%@",model.name,lastString] color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
//                            if (block) block(att);
//                        }
//                    }];
                    
                    NSAttributedString *att = [NSString attributedWithString:[NSString stringWithFormat:@"%@：%@",@"测试model。name",lastString] color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
                    if (block) block(att);
                    
                }
            }
            //我发的
            else {
                NSAttributedString *att = [NSString attributedWithString:lastString color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
                if (block) block(att);
            }
            
        }
        else {
            NSAttributedString *att = [NSString attributedWithString:lastString color:SWColor(@"#B1B1B1") font:SWFont_Regular(14)];
                if (block) block(att);
        }
    }
}
#pragma mark - get
- (NSString *)idBeDB
{
    if (_idBeDB == nil) {
        _idBeDB = [NSString stringWithFormat:@"%@%d",self.conversationId,self.type];
    }
    return _idBeDB;
}
- (CIMConversationType)conversationType
{
    if (self.type == 3001) return CIMConversationType_Other;
    return self.type == 2001 ? CIMConversationType_Single : CIMConversationType_Group;
}

- (NSString *)conversationRecordTableName{
    if (!_conversationRecordTableName) {
        _conversationRecordTableName = [NSString stringWithFormat:@"conversation_%@_record",self.idBeDB];
    }
    SWLog(@"会话对应的记录表名===>%@",_conversationRecordTableName);
    return _conversationRecordTableName;
}

-(ZXMessageModel *)knewMessageModel{
    if (!_knewMessageModel) {
//        if (CPKitManager.shareManager.isLogin) {
        _knewMessageModel = [WYAppSingle.shareManager.dataManager getConversationNewMessageModelWithConversation:self];
    }
    return _knewMessageModel;
}

- (long long)lastTime
{
    return [self.knewMessageModel.date timeIntervalSince1970] * 1000;
}

- (BOOL)isNewOfflineMsg
{
    return self.offlineMsg_lastTime > self.lastTime ? YES : NO;
}

- (long long)needLastTime
{
    if (self.isNewOfflineMsg) {
        return self.dealLastTime > self.offlineMsg_lastTime ? self.dealLastTime : self.offlineMsg_lastTime;
    }
    else {
        return self.dealLastTime > self.lastTime ? self.dealLastTime : self.lastTime;
    }
}
  
- (NSString *)dateString
{
    if (!_dateString) {
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp = [calendar components:NSCalendarUnitSecond fromDate:[NSDate dateWithTimeIntervalSince1970:self.needLastTime / 1000] toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:NSCalendarWrapComponents];
        if (comp.second < 60) {
            _dateString = @"刚刚";
        }
        else if (comp.second < 60 * 60) {
            _dateString = [NSString stringWithFormat:@"%ld %@",comp.second / 60,@"分钟前"];
        }
        else if (comp.second < 60 * 60 * 24) {
            _dateString = [NSString stringWithFormat:@"%ld %@",comp.second / 60 / 60,@"小时前"];
        }
        else if (comp.second < 60 * 60 * 24 * 2) {
            _dateString = @"昨天";
        }
        else if (comp.second < 60 * 60 * 24 * 3) {
            _dateString = @"前天";
        }
        else {
            NSDateFormatter *formetter = [NSDateFormatter new];
            [formetter setDateFormat:@"yyyy-MM-dd"];
            _dateString = [formetter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.needLastTime / 1000]];
        }
    }
    return _dateString;
}

- (RACSubject *)knewOfflineMessageSingal{
    if (!_knewOfflineMessageSingal) {
        _knewOfflineMessageSingal = [RACSubject subject];
    }
    return _knewOfflineMessageSingal;
}
@end


@implementation WYIMOfflineMessageModel


+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"list":[WYIMOfflineMessageDetailModel class],
    };
}

@end


@implementation WYIMOfflineMessageDetailModel

- (ZXMessageModel *)offlineMessageDetailModelToMessageModel
{
//    Msg *msg = [Msg message];
//    Head *head = [Head modelWithJSON:[self modelToJSONObject]];
//    head.timestamp = self.createTime;
//    msg.head = head;
//    msg.body = self.msgContent;
//
//    return [msg msgToMessageModel];
    
    return [ZXMessageModel new];
    
}

@end
