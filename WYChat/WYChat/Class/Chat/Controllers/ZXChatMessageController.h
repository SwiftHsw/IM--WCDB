//
//  ZXChatMessageController.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXMessageModel.h"
//#import "CIMAddressBookFriendModel.h"

@class ZXChatMessageController;
@protocol ZXChatMessageControllerDelegate <NSObject>

- (void) didTapChatMessageView:(ZXChatMessageController *)chatMessageViewController;

/// 重新发送
- (void) reSendMessage:(ZXMessageModel *)message;

/// 撤回消息
- (void) chehuiSendMessage:(ZXMessageModel *)message;

/// 删除消息
- (void) deleteMessage:(ZXMessageModel *)message;

/// 转发消息
- (void) forwardMessage:(ZXMessageModel *)message;

/// 主动向conversation获取用户信息
- (void)chatMessageController:(ZXChatMessageController *)chetMessageVC friendId:(NSString *)friendId completeHandle:(void (^)(NSObject *friendModel))completeHandle;

/// 主动向conversation更新messageModel
- (void)chatMessageController:(ZXChatMessageController *)chetMessageVC updateMessageModel:(ZXMessageModel *)messageModel;

/// 点击用户头像
- (void)didClickUserHeadWithModel:(ZXMessageModel *)messageModel;

/// 点击消息
- (void)didNameCardWithMessageModel:(ZXMessageModel *)messageModel;

- (CIMConversationType)getConversationType;

- (void)clickUrl:(NSString *)urlString;

/// 发送好友验证
- (void)sendFriendsVerification;

/// 翻译消息
- (void)translateMessageModel:(ZXMessageModel *)messageModel;

/// 获取控制器
- (UIViewController *)getChateMessageController;

/// 当前会话
- (WYIMConversationModel *)currentConversationModel;

@end

@interface ZXChatMessageController : UITableViewController

@property (nonatomic , weak) id <ZXChatMessageControllerDelegate> delegate;

@property (nonatomic , strong) NSMutableArray *data;

/**
 *  改变数据源方法，添加一条消息，刷新数据
 *
 *  @param message 添加的消息
 */
- (void) addNewMessage:(ZXMessageModel *)message;

/**
 *   添加一条消息就让tableView滑动
 */
- (void) scrollToBottom;


- (void)updateMessageModelForCell:(ZXMessageModel *)messageModel;

@end
