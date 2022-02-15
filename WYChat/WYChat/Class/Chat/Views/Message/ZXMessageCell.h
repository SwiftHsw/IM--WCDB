//
//  ZXMessageCell.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXMessageModel.h"
//#import "CIMAddressBookFriendModel.h"

@protocol ZXMessageCellDelegate;

typedef NS_ENUM(NSUInteger, CellOfClickAreaType) {
    CellOfClickAreaTypeAvatar,          // 点击头像的事件
    CellOfClickAreaTypeText,            // 点击文件的事件
    CellOfClickAreaTypeImg,             // 点击图片的事件
    CellOfClickAreaTypeFile,            // 点击文件的事件
    CellOfClickAreaTypePlayVoice,       // 点击播放语音的事件
    CellOfClickAreaTypePauseVoice,       // 点击暂停语音的事件
    CellOfClickAreaTypeNameCard,        // 点击名片的事件
    CellOfClickAreaTypePlayVideo,       // 点击播放视频
    CellOfClickAreaTypeWithdrawMessage, //撤回消息
    CellOfClickAreaTypeDeleteMessage,   //删除消息
    CellOfClickAreaTypeForward,         //转发消息
    CellOfClickAreaTypeTranslate,       //翻译消息
    CellOfClickAreaTypeReSendMessage,   //点击消息状态，失败的情况下重新发送
    CellOfClickAreaTypeSendFriendsVerification,     // 发送好友验证
    CellOfClickAreaTypeReLoadCurrentCell,     // 发送好友验证
};

typedef void(^ClickAvatarClick)(CellOfClickAreaType clickType);

@protocol CIMZXMessageCellDelegate;

@interface ZXMessageCell : UITableViewCell<ZXMessageCellDelegate>

@property(nonatomic,strong) ZXMessageModel * messageModel;
@property (nonatomic , assign) CIMConversationType conversationType;    //会话类型
@property (nonatomic , weak) id<CIMZXMessageCellDelegate> cpDelegate;

@property (nonatomic, strong) UIImageView *avatarImageView;                 // 头像
@property (nonatomic, strong) UILabel *nicknameLab;                         // 用户昵称
@property (nonatomic, strong) UIImageView *messageBackgroundImageView;      // 消息背景
@property (nonatomic , strong) UIButton *stateLab;                          //消息状态
@property (nonatomic, copy) ClickAvatarClick tap_avatarBlock;
@property (nonatomic, strong) UILongPressGestureRecognizer *longes;

/// 标识
+ (NSString *)identifier;

@end

@protocol CIMZXMessageCellDelegate <NSObject>

@required

/// cell主动向conversation获取用户信息
//- (void)messageCell:(ZXMessageCell *)cell friendId:(NSString *)friendId completeHandle:(void(^)(CIMAddressBookFriendModel *friendModel))completeHandle;

/// 加载对方发送的视频时，更新封面
- (void)messageCell:(ZXMessageCell *)cell updateMessageModel:(ZXMessageModel *)messageModel;

/// 点击url
- (void)messageCell:(ZXMessageCell *)cell clickUrl:(NSString *)urlString;

@end


@protocol ZXMessageCellDelegate <NSObject>

- (void)copyForIm:(id)sender;
- (void)chehuiForIm:(id)sender;
- (void)deleteForIm:(id)sender;
- (void)zhuanfaForIm:(id)sender;



@end
