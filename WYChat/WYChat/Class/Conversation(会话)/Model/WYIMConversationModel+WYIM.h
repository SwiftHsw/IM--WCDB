//
//  WYIMConversationModel+WYIM.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "WYIMConversationModel.h"
#import <WCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYIMConversationModel (WYIM)<WCTTableCoding>

WCDB_PROPERTY(idBeDB)
WCDB_PROPERTY(conversationId)
WCDB_PROPERTY(nickName)
WCDB_PROPERTY(msgContentType)
WCDB_PROPERTY(type)
WCDB_PROPERTY(recordNum)
WCDB_PROPERTY(offlineMsg_lastMsg)
WCDB_PROPERTY(offlineMsg_lastTime)
WCDB_PROPERTY(offlineMsg_msgContentType)
WCDB_PROPERTY(remarkName)
WCDB_PROPERTY(isInDB)
WCDB_PROPERTY(isBeTop)
WCDB_PROPERTY(dealLastTime)

@end

NS_ASSUME_NONNULL_END
