//
//  XYDJViewController.h
//  StoryboardTest
//
//  Created by mxsm on 16/4/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol XYDJViewControllerDelegate;

@interface XYDJViewController : BaseViewController

@property (nonatomic , weak) id<XYDJViewControllerDelegate> wyDelegate;

/// 会话
@property (nonatomic , strong , readonly) WYIMConversationModel *conversation;

/// 创建会话
+ (instancetype)chatControllerWithConversationModel:(WYIMConversationModel *)conversation;

@end

@protocol XYDJViewControllerDelegate <NSObject>

@optional

/// 聊天页返回的时候需要刷新响应的会话
- (void)chatViewControllerRetrunNeedReloadConversation:(XYDJViewController *)chatVC conversation:(WYIMConversationModel *)conversation;

@end

