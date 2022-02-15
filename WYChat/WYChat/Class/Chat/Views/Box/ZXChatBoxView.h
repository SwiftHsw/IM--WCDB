//
//  ZXChatBoxView.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/19.
//  Copyright © 2016年 mxsm. All rights reserved.
//

/**
 *   这个View就是最开始显示的输入部分的View，按输入部分的构造写就OK
 */
#import <UIKit/UIKit.h>
#import "ChatFace.h"
/**
 *  枚举的一种定义形式,和基本的枚举定义类型一样，只是结构更加清晰点；
 */
typedef NS_ENUM(NSInteger, ZXChatBoxStatus) {
    /**
     *  无状态
     */
    TLChatBoxStatusNothing,
    /**
     *  声音
     */
    TLChatBoxStatusShowVoice,
    /**
     *  表情
     */
    TLChatBoxStatusShowFace,
    /**
     *  更多
     */
    TLChatBoxStatusShowMore,
    /**
     *  键盘
     */
    TLChatBoxStatusShowKeyboard,
};
/**
*  点击Speak按钮的不同事件
*/
typedef void(^SpeakTouchDown)(UIControlEvents control_event);

///  ZXChatBoxView 的代理，里面有发送消息，改变高度，从一种状态改变到另一种状态的方法；
@class ZXChatBoxView;

@protocol ZXChatBoxDelegate <NSObject>

/// 切换输入框样式
- (void)chatBox:(ZXChatBoxView *)chatBox changeStatusForm:(ZXChatBoxStatus)fromStatus to:(ZXChatBoxStatus)toStatus;

/// 发送文本消息
- (void)chatBox:(ZXChatBoxView *)chatBox sendTextMessage:(NSString *)textMessage;

/// 变更高度
- (void)chatBox:(ZXChatBoxView *)chatBox changeChatBoxHeight:(CGFloat)height;

@end

@interface ZXChatBoxView : UIView

@property (nonatomic, weak) id<ZXChatBoxDelegate>delegate;
@property (nonatomic, assign) ZXChatBoxStatus status;
@property (nonatomic, assign) CGFloat curHeight;
@property (nonatomic, copy) SpeakTouchDown speak_touch_block;
@property (nonatomic , assign) BOOL isJinYan;   //是否禁言

- (void) addEmojiFace:(ChatFace *)face;
- (void) sendCurrentMessage;
- (void) deleteButtonDown;

@end
