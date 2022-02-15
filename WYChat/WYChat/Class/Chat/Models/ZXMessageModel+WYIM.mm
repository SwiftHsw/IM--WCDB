//
//  ZXMessageModel+WYIM.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "ZXMessageModel+WYIM.h"
#import <WCDB/WCDB.h>

@implementation ZXMessageModel (WYIM)

WCDB_IMPLEMENTATION(ZXMessageModel)
WCDB_SYNTHESIZE(ZXMessageModel, fromId)
WCDB_SYNTHESIZE(ZXMessageModel, msgId)
WCDB_SYNTHESIZE(ZXMessageModel, messageId)

WCDB_SYNTHESIZE(ZXMessageModel, date)
WCDB_SYNTHESIZE(ZXMessageModel, messageType)
WCDB_SYNTHESIZE(ZXMessageModel, ownerTyper)
WCDB_SYNTHESIZE(ZXMessageModel, readState)
WCDB_SYNTHESIZE(ZXMessageModel, sendState)

WCDB_SYNTHESIZE(ZXMessageModel, body)
WCDB_SYNTHESIZE(ZXMessageModel, extend)

WCDB_SYNTHESIZE(ZXMessageModel, text)
WCDB_SYNTHESIZE(ZXMessageModel, translateText)
WCDB_SYNTHESIZE_DEFAULT(ZXMessageModel, isTranslate , NO)
WCDB_SYNTHESIZE_DEFAULT(ZXMessageModel, isShowTranslated , NO)
WCDB_SYNTHESIZE_DEFAULT(ZXMessageModel, translateType , ZXMessageTranslateType_No)


WCDB_SYNTHESIZE(ZXMessageModel, imagePath)
WCDB_SYNTHESIZE(ZXMessageModel, imageURL)

WCDB_SYNTHESIZE(ZXMessageModel, videoCoverLocationPath)
WCDB_SYNTHESIZE(ZXMessageModel, videoRemotePath)
WCDB_SYNTHESIZE(ZXMessageModel, videoLocalPath)
WCDB_SYNTHESIZE(ZXMessageModel, videoDuration)
WCDB_SYNTHESIZE(ZXMessageModel, imageWidth)
WCDB_SYNTHESIZE(ZXMessageModel, imageHeight)

WCDB_SYNTHESIZE(ZXMessageModel, locationImageRemotePath)
WCDB_SYNTHESIZE(ZXMessageModel, locationImagePath)
WCDB_SYNTHESIZE(ZXMessageModel, latitude)
WCDB_SYNTHESIZE(ZXMessageModel, longitude)
WCDB_SYNTHESIZE(ZXMessageModel, address)

WCDB_SYNTHESIZE(ZXMessageModel, voiceSeconds)
WCDB_SYNTHESIZE(ZXMessageModel, voiceUrl)
WCDB_SYNTHESIZE(ZXMessageModel, voicePath)

WCDB_SYNTHESIZE(ZXMessageModel, bcardUrl)
WCDB_SYNTHESIZE(ZXMessageModel, nickName)
WCDB_SYNTHESIZE(ZXMessageModel, friendId)
WCDB_SYNTHESIZE(ZXMessageModel, imgHead)
WCDB_SYNTHESIZE(ZXMessageModel, userType)

WCDB_SYNTHESIZE(ZXMessageModel, fileName)
WCDB_SYNTHESIZE(ZXMessageModel, fileSize)
WCDB_SYNTHESIZE(ZXMessageModel, fileUrl)

WCDB_SYNTHESIZE(ZXMessageModel, note)

//主要的，最主要的
WCDB_PRIMARY(ZXMessageModel, messageId)



+ (ZXMessageModel *)createNoteMessageModelWithType:(ZXMessageType)type
{
    ZXMessageModel *model = [ZXMessageModel new];
    model.messageType = type;
    model.date = [NSDate dateWithTimeIntervalSinceNow:0];
    return model;;
}
@end
