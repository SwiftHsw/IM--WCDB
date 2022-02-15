//
//  ZXMessageModel.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXMessageModel.h"
#import "ZXChatHelper.h"
#import "ZXTextMessageCell.h"
#import "ZXImageMessageCell.h"
#import "BH_VideoMessageCell.h"
#import "ZXVoiceMessageCell.h"
#import "CIMNoteContentCell.h"
#import "CIMFileMessageCell.h"
//#import "ffmpeg.h"
#import "ZXNameCardCell.h"
#import <AVFoundation/AVFoundation.h>


@interface ZXMessageModel()
// 图片
@property (nonatomic, strong , readwrite) UIImage *image;
// 视频封面
@property (nonatomic, strong , readwrite) UIImage *videoCoverImage;
@end




@implementation ZXMessageModel

-(id)init
{
    if (self = [super init]) {
        self.messageId = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    }
    return self;
}


+ (ZXMessageModel *)creatMessageModelWithType:(ZXMessageType)type
{
    ZXMessageModel *message = [[ZXMessageModel alloc] init];
    message.messageType = type;
    message.ownerTyper = ZXMessageOwnerTypeSelf;
    message.date = [NSDate date];
    message.sendState = ZXMessageSendIng;
    message.readState = ZXMessageReaded;
    message.fromId = @"userID";
    
    return message;
}



#pragma mark - Getter
- (void) setMessageType:(ZXMessageType)messageType
{
    _messageType = messageType;
    switch (messageType) {
        case ZXMessageTypeText:
            self.cellIndentify = ZXTextMessageCell.identifier;
            break;
        case ZXMessageTypeImage:
        case ZXMessageTypeSticker:
            self.cellIndentify = ZXImageMessageCell.identifier;
            break;
        case ZXMessageTypeVoice:
            self.cellIndentify = ZXVoiceMessageCell.identifier;
            break;
        case ZXMessageTypeVideo:
            self.cellIndentify = BH_VideoMessageCell.identifier;
            break;
        case ZXMessageTypeMessageWithdraw:
            self.cellIndentify = CIMNoteContentCell.identifier;
            break;
        case ZXMessageTypeNameCard:
            self.cellIndentify = ZXNameCardCell.identifier;
            break;
        case ZXMessageTypeFile:
            self.cellIndentify = CIMFileMessageCell.identifier;
            break;
        default:
            self.cellIndentify = CIMNoteContentCell.identifier;
            break;
    }
}


-(CGSize) messageSize
{
    switch (self.messageType) {

        case ZXMessageTypeText:
        {
             NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithAttributedString:self.attrText];
            [att1 addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} range:NSMakeRange(0, att1.length)];
            YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH * 0.58, CGFLOAT_MAX) text:att1];
            _messageSize = layout.textBoundingSize;
            
            if (self.isShowTranslated) {
                NSMutableAttributedString *att11 = [[NSMutableAttributedString alloc] initWithString:self.translateText];
                [att11 addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} range:NSMakeRange(0, att11.length)];
                YYTextLayout *layout1 = [YYTextLayout layoutWithContainerSize:CGSizeMake(SCREEN_WIDTH * 0.58, CGFLOAT_MAX) text:att11];
                _translateMessageSize = layout1.textBoundingSize;
            }
        }
            break;
        case ZXMessageTypeImage:
        {
            if (self.imageWidth > self.imageHeight) {
                _messageSize = CGSizeMake(SCREEN_WIDTH * 0.5 , self.imageHeight / self.imageWidth * (SCREEN_WIDTH * 0.5));
            }
            else {
                _messageSize = CGSizeMake(self.imageWidth / self.imageHeight * (SCREEN_WIDTH * 0.5), SCREEN_WIDTH * 0.5);
            }
        }
            break;
        case ZXMessageTypeVideo:
        {
            if (self.imageWidth > self.imageHeight)
            {
                _messageSize = CGSizeMake(200, self.imageHeight / self.imageWidth * 200);
            }
            else
            {
                _messageSize = CGSizeMake(self.imageWidth / self.imageHeight * 150, 150);
            }
        }
            break;
        case ZXMessageTypeSticker:
        {
            _messageSize = CGSizeMake(150, 150);
        }
            break;
        case ZXMessageTypeVoice:
        {
            _messageSize = CGSizeMake(50, 30);
        }
            break;
        case ZXMessageTypeNameCard:
        {
            _messageSize = CGSizeMake(100, 100);
        }
            break;
        case ZXMessageTypeFile:
        {
            _messageSize = CGSizeMake(100, 80);
        }
            break;
        default:
        {
            NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",self.note]];
            //添加敏感词汇的图标
            if ([self.note containsString:CIMLocalizableStr(@"Sensitive words")]) {
                YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:kImageName(@"yelloowWarning")];
                NSMutableAttributedString *att2 = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(20, 20) alignToFont:[UIFont systemFontOfSize:13] alignment:YYTextVerticalAlignmentCenter];
                [att2 appendString:@" "];
                [att1 insertAttributedString:att2 atIndex:0];
            }
            
            [att1 addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} range:NSMakeRange(0, att1.length)];
            YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake([CIMNoteContentCell CIMNoteContentCellMaxWidth], CGFLOAT_MAX) text:att1];
            _messageSize = layout.textBoundingSize;
        }
            break;
    }
    
    return _messageSize;
}


-(CGFloat) cellHeight
{
    switch (self.messageType){
        case ZXMessageTypeText:
            
            //15 背景虚化
            return (self.messageSize.height + 40 > 60 ? self.messageSize.height + 40 : 60) + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 0) + (self.isShowTranslated ? (self.translateMessageSize.height + 35) : 0) + ((self.isTranslate && self.isShowTranslated) ? 20 : 0);
            break;
        case ZXMessageTypeImage:
            return self.messageSize.height + 30 + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15);
            break;
        case ZXMessageTypeVoice:
            return 60 + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15);
            break;
        case ZXMessageTypeVideo:
            return self.messageSize.height + 30 + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15);
            break;
        case ZXMessageTypeNameCard:
            return 122 + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15);
            break;
        case ZXMessageTypeFile:
            return self.messageSize.height + 40;
            break;
        case ZXMessageTypeSticker:
            return self.messageSize.height + 20 + (self.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15);
            break;
        case ZXMessageTypeNoteContent:
            return self.messageSize.height + 20;
            break;
        default:
        {
            return self.messageSize.height + 20;
        }
            break;
    }
}

- (void)videoCompressToMP4WithComplete:(void (^)(void))complete
{
    NSString *videoName = [NSString stringWithFormat:@"video_%u%u%ld%u%u.mp4",arc4random_uniform(9999),arc4random_uniform(100),(long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(9)];
    
    NSString *newVideoPath = [[WYIMFileManager.shareManager videosDirectorPath] stringByAppendingPathComponent:videoName];

    NSString *cmd = [NSString stringWithFormat:@"ffmpeg!#$-ss!#$00:00:00!#$-i!#$%@!#$-b:v!#$3000K!#$-vf!#$scale=720:-2!#$-y!#$%@",self.videLocalSourcePath,newVideoPath];
    if (self.imageWidth < self.imageHeight) {
        cmd = [NSString stringWithFormat:@"ffmpeg!#$-ss!#$00:00:00!#$-i!#$%@!#$-b:v!#$3000K!#$-vf!#$scale=-2:720!#$-y!#$%@",self.videLocalSourcePath,newVideoPath];
    }
    
    self.videoLocalPath = videoName;
    self.videLocalSourcePath = newVideoPath;
    
    [self runCmd:cmd completeHandle:^{
        if (complete) complete();
    }];
}

- (void)runCmd:(NSString *)command_str completeHandle:(void (^)(void))handle{

    //根据!#$将指令分割为指令数组
    NSArray *argv_array=[command_str componentsSeparatedByString:(@"!#$")];
    //将OC对象转换为对应的C对象
    int argc=(int)argv_array.count;
    char** argv=(char**)malloc(sizeof(char*)*argc);
    for(int i=0;i<argc;i++)
    {
        argv[i]=(char*)malloc(sizeof(char)*1024);
        strcpy(argv[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
    NSString *finalCommand = @"运行参数:";
    for (NSString *temp in argv_array) {
        finalCommand = [finalCommand stringByAppendingFormat:@"%@",temp];
    }
    //传入指令数及指令数组
//    int result = ffmpeg_main(argc,argv);
    //线程已杀死,下方的代码不会执行
    dispatch_async(dispatch_get_main_queue(), ^{
        if (handle) handle();
    });
}

//下载语音回调
- (void)downVoiceCompleteHandle:(void(^)(void))handle
{
    
    NSString *voicePath = [WYIMFileManager.shareManager.voicesDirectorPath stringByAppendingPathComponent:self.voiceUrl.lastPathComponent];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",BASEURL,self.voiceUrl];
    @weakify(self)
    NSURLSessionDownloadTask *task = [WYNetWorkManager.sharedClient downGetFileUrl:urlStr progress:^(CGFloat uploadProgress) {
        
        NSLog(@"==***********:%lf",uploadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:voicePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        @strongify(self)
        self.voicePath = self.voiceUrl.lastPathComponent;

        AVAudioPlayer* player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:voicePath] error:nil];
        self.voiceSeconds = (NSUInteger)player.duration;

        if (error) {
            self.sendState = ZXMessageSendFail;
        }
        if (handle) handle();
    }];
    
 
 
    [task resume];
}

#pragma mark - get
- (UIImage *)image
{
    if (_image == nil) {
        if (self.imagePath != nil) {
            NSString *imgPath = [WYIMFileManager.shareManager.imagesDirectorPath stringByAppendingPathComponent:self.imagePath];
            UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
            _image = image;
        }
    }
    return _image;
}

- (UIImage *)videoCoverImage
{
    if (_videoCoverImage == nil) {
        if (self.videoCoverLocationPath != nil) {
            NSString *imgPath = [WYIMFileManager.shareManager.imagesDirectorPath stringByAppendingPathComponent:self.videoCoverLocationPath];
            UIImage *image = [UIImage imageWithContentsOfFile:imgPath];
            _videoCoverImage = image;
        }
    }
    return _videoCoverImage;
}

- (NSString *)dateString
{
    if (!_dateString) {
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp = [calendar components:NSCalendarUnitSecond fromDate:self.date toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:NSCalendarWrapComponents];
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
            _dateString = [formetter stringFromDate:self.date];
        }
    }
    return _dateString;
}

- (NSString *)dateStringForCell
{
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [calendar components:NSCalendarUnitSecond fromDate:self.date toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:NSCalendarWrapComponents];
    if (comp.second < 60) {
        return  @"刚刚";;
    }
    else if (comp.second < 60 * 60) {
        return [NSString stringWithFormat:@"%ld %@",comp.second / 60,@"分钟前"];
    }
    else if (comp.second < 60 * 60 * 24) {
        return [NSString stringWithFormat:@"%ld %@",comp.second / 60 / 60,@"小时前"];
    }
    else if (comp.second < 60 * 60 * 24 * 30) {
        NSDateFormatter *formetter = [NSDateFormatter new];
        [formetter setDateFormat:@"MM-dd"];
        return [formetter stringFromDate:self.date];
    }
    else {
        NSDateFormatter *formetter = [NSDateFormatter new];
        [formetter setDateFormat:@"yyyy-MM-dd"];
        return [formetter stringFromDate:self.date];
    }
}

- (NSMutableAttributedString *)attrText
{
    if (_attrText == nil) {
        NSString *str = [NSString replaceUnicode:self.text];
        _attrText = [NSString textToEmojiText:[[NSMutableAttributedString alloc] initWithString:str ? str : @""]];
        
        NSMutableParagraphStyle *pa = [NSMutableParagraphStyle new];
        pa.lineSpacing = 5;
        [_attrText addAttributes:@{NSParagraphStyleAttributeName : pa} range:NSMakeRange(0, _attrText.length)];
    }
    return _attrText;
}
 
- (NSString *)text
{
    if (self.extend) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if (dic[@"memberType"]) {
                if ([dic[@"memberType"] intValue] == 2) {
                    return  @"您好，我是SPAN-V客户服务助理，您可以告诉我您的问题~";
                }
            }
        }
    }
    
    //加密安全提示
    if (self.messageType == ZXMessageTypeSafeContentNotify ||
        self.messageType == ZXMessageTypeDropMessage) {
        return  @"“所有信息都已在聊天结束加密中执行。”" ;
    }
    //撤回
    else if (self.messageType == ZXMessageTypeMessageWithdraw) {
        if (self.ownerTyper == ZXMessageOwnerTypeSelf) {
            return @"你撤回了一条消息";
        }
        else {
            return @"对方撤回了一条消息";
        }
    }
    //禁言
    else if (self.messageType == ZXMessageTypeGroupJinyan) {
        return [_text integerValue] == 2 ?  @"群主已开启禁言" : @"群主已开启静音";
    }
    //成功添加好友
    else if (self.messageType == ZXMessageTypeAddNewFriendSuccess) {
        return @"对方已将你添加为好友，开始聊天";
    }
    //敏感词
    else if (self.messageType == ZXMessageTypeSensitiveWordsExist) {
        return @"存在敏感词，请不要再发送！";
    }
    //黑名单
    else if (self.messageType == ZXMessageTypeBlackList) {
        return  @"消息已发送，但被对方拒绝";
    }
    //发送好友验证
    else if (self.messageType == ZXMessageTypeSendFriendVerification) {
        return @"对方已开启好友验证，您不是TA好友，请先发送好友验证请求，对方通过后才能聊天。发送朋友验证";
    }
    //非群成员
    else if (self.messageType == ZXMessageTypeNoGroupMembers) {
        return @"您不再是此组的成员。";
    }
    //发送的消息属于禁言
    else if (self.messageType == ZXMessageTypeSendMessageBeJinYan) {
        return @"禁止当前组讲话，消息发送无效。";
    }
    //未添加对方好友
    else if (self.messageType == ZXMessageTypeIsNotFriends) {
        return @"尚未添加对方的好友，请先添加对方的好友。";
    }
    //群内禁止加好友
    else if (self.messageType == ZXMessageTypeGroupJinAddFriends) {
        return [_text integerValue] == 2 ? @"群主已打开会话以在群中添加朋友" : @"群主已关闭会话以在群中添加朋友";
    }
    //群新加入
    else if (self.messageType == ZXMessageTypeNewMemberIntoGroup) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //执行者
        NSString *Executor = dic[@"Executor"];
        //被执行者
        NSString *Executee = dic[@"Executee"];
        return [NSString stringWithFormat:@"%@ %@ %@ %@",Executor,  @"邀请" ,Executee, @"组队"];
    }
    //群主转让
    else if (self.messageType == ZXMessageTypeGroupOwnChange) {
        if (self.body) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            //执行者
            NSString *Executor = dic[@"Executor"];
            //被执行者
            NSString *Executee = dic[@"Executee"];
            return [NSString stringWithFormat:@"%@ %@ %@",Executor,@"将群主转移给",Executee];
        }
        return @"";
    }
    //群踢人
    else if (self.messageType == ZXMessageTypeGroupOwnTiMembers) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //执行者
        NSString *Executor = dic[@"Executor"];
        //被执行者
        NSString *Executee = dic[@"Executee"];
        //英文
        if (![CIMCurrentLanguageStr() containsString:@"en"]) {
            return [NSString stringWithFormat:@"%@ 被 %@ 请出该群",Executee,Executor];
        }
        else {
            return [NSString stringWithFormat:@"%@ 被邀请离开小组 %@",Executee,Executor];
        }
    }
    //群名更改
    else if (self.messageType == ZXMessageTypeGoupNickname_change) {
        return [NSString stringWithFormat:@"%@%@",@"组名更改为",self.body];
    }
    //群成员退群
    else if (self.messageType == ZXMessageTypeMemberGoOutGroup) {
        return [NSString stringWithFormat:@"%@ 退出群",self.body];
    }
    return _text;
}

- (NSString *)note
{
   
    if (self.extend) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.extend dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        if (dic) {
            if (dic[@"memberType"]) {
                if ([dic[@"memberType"] intValue] == 2) {
                    return  @"您好，我是SPAN-V客户服务助理，您可以告诉我您的问题~";
                }
            }
        }
    }
    
    //加密安全提示
    if (self.messageType == ZXMessageTypeSafeContentNotify ||
        self.messageType == ZXMessageTypeDropMessage) {
        return  @"“所有信息都已在聊天结束加密中执行。”" ;
    }
    //撤回
    else if (self.messageType == ZXMessageTypeMessageWithdraw) {
        if (self.ownerTyper == ZXMessageOwnerTypeSelf) {
            return @"你撤回了一条消息";
        }
        else {
            return @"对方撤回了一条消息";
        }
    }
    //禁言
    else if (self.messageType == ZXMessageTypeGroupJinyan) {
        return [_text integerValue] == 2 ?  @"群主已开启禁言" : @"群主已开启静音";
    }
    //成功添加好友
    else if (self.messageType == ZXMessageTypeAddNewFriendSuccess) {
        return @"对方已将你添加为好友，开始聊天";
    }
    //敏感词
    else if (self.messageType == ZXMessageTypeSensitiveWordsExist) {
        return @"存在敏感词，请不要再发送！";
    }
    //黑名单
    else if (self.messageType == ZXMessageTypeBlackList) {
        return  @"消息已发送，但被对方拒绝";
    }
    //发送好友验证
    else if (self.messageType == ZXMessageTypeSendFriendVerification) {
        return @"对方已开启好友验证，您不是TA好友，请先发送好友验证请求，对方通过后才能聊天。发送朋友验证";
    }
    //非群成员
    else if (self.messageType == ZXMessageTypeNoGroupMembers) {
        return @"您不再是此组的成员。";
    }
    //发送的消息属于禁言
    else if (self.messageType == ZXMessageTypeSendMessageBeJinYan) {
        return @"禁止当前组讲话，消息发送无效。";
    }
    //未添加对方好友
    else if (self.messageType == ZXMessageTypeIsNotFriends) {
        return @"尚未添加对方的好友，请先添加对方的好友。";
    }
    //群内禁止加好友
    else if (self.messageType == ZXMessageTypeGroupJinAddFriends) {
        return [_text integerValue] == 2 ? @"群主已打开会话以在群中添加朋友" : @"群主已关闭会话以在群中添加朋友";
    }
    //群新加入
    else if (self.messageType == ZXMessageTypeNewMemberIntoGroup) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //执行者
        NSString *Executor = dic[@"Executor"];
        //被执行者
        NSString *Executee = dic[@"Executee"];
        return [NSString stringWithFormat:@"%@ %@ %@ %@",Executor,  @"邀请" ,Executee, @"组队"];
    }
    //群主转让
    else if (self.messageType == ZXMessageTypeGroupOwnChange) {
        if (self.body) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            //执行者
            NSString *Executor = dic[@"Executor"];
            //被执行者
            NSString *Executee = dic[@"Executee"];
            return [NSString stringWithFormat:@"%@ %@ %@",Executor,@"将群主转移给",Executee];
        }
        return @"";
    }
    //群踢人
    else if (self.messageType == ZXMessageTypeGroupOwnTiMembers) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[self.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //执行者
        NSString *Executor = dic[@"Executor"];
        //被执行者
        NSString *Executee = dic[@"Executee"];
        //英文
        if (![CIMCurrentLanguageStr() containsString:@"en"]) {
            return [NSString stringWithFormat:@"%@ 被 %@ 请出该群",Executee,Executor];
        }
        else {
            return [NSString stringWithFormat:@"%@ 被邀请离开小组 %@",Executee,Executor];
        }
    }
    //群名更改
    else if (self.messageType == ZXMessageTypeGoupNickname_change) {
        return [NSString stringWithFormat:@"%@%@",@"组名更改为",self.body];
    }
    //群成员退群
    else if (self.messageType == ZXMessageTypeMemberGoOutGroup) {
        return [NSString stringWithFormat:@"%@ 退出群",self.body];
    }
    return _note;
}

- (NSString *)fileLocationPath
{
    if (_fileLocationPath == nil) {
        _fileLocationPath = [WYIMFileManager.shareManager.fileDirectorPath stringByAppendingPathComponent:self.fileName];
    }
    return _fileLocationPath;
}

@end
