//
//  ZXMessageModel+WYIM.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "ZXMessageModel.h"
#import <WCDB/WCDB.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZXMessageModel (WYIM)<WCTTableCoding>

WCDB_PROPERTY(fromId)
WCDB_PROPERTY(msgId)
WCDB_PROPERTY(messageId)

WCDB_PROPERTY(date)
WCDB_PROPERTY(messageType)
WCDB_PROPERTY(ownerTyper)
WCDB_PROPERTY(readState)
WCDB_PROPERTY(sendState)

WCDB_PROPERTY(body)
WCDB_PROPERTY(extend)

WCDB_PROPERTY(text)
WCDB_PROPERTY(translateText)
WCDB_PROPERTY(isTranslate)
WCDB_PROPERTY(isShowTranslated)
WCDB_PROPERTY(translateType)

WCDB_PROPERTY(imagePath)
WCDB_PROPERTY(imageURL)

WCDB_PROPERTY(videoCoverLocationPath)
WCDB_PROPERTY(videRemotePath)
WCDB_PROPERTY(videoLocalPath)
WCDB_PROPERTY(videoDuration)
WCDB_PROPERTY(imageWidth)
WCDB_PROPERTY(imageHeight)

WCDB_PROPERTY(locationImageRemotePath)
WCDB_PROPERTY(locationImagePath)
WCDB_PROPERTY(latitude)
WCDB_PROPERTY(longitude)
WCDB_PROPERTY(address)

WCDB_PROPERTY(voiceSeconds)
WCDB_PROPERTY(voiceUrl)
WCDB_PROPERTY(voicePath)

WCDB_PROPERTY(bcardUrl)
WCDB_PROPERTY(nickName)
WCDB_PROPERTY(friendId)
WCDB_PROPERTY(imgHead)
WCDB_PROPERTY(userType)

WCDB_PROPERTY(fileName)
WCDB_PROPERTY(fileSize)
WCDB_PROPERTY(fileUrl)


WCDB_PROPERTY(note)

@end

NS_ASSUME_NONNULL_END
