//
//  ZXMessageCell.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXMessageCell.h"
#import "ZXChatMessageController.h"

@interface ZXMessageCell ()
@property (nonatomic , strong) NSLayoutConstraint *cons2;
@property (nonatomic , strong) UIActivityIndicatorView *activityView;
@property (nonatomic , strong) UIMenuController *menuController;
@end

@implementation ZXMessageCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.messageBackgroundImageView];
        [self.contentView addSubview:self.activityView];
        [self.contentView addSubview:self.stateLab];
        [self.contentView addSubview:self.avatarImageView];
        [self.contentView addSubview:self.nicknameLab];
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        NSLayoutConstraint *cons1 = [NSLayoutConstraint constraintWithItem:self.stateLab attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.messageBackgroundImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cons3 = [NSLayoutConstraint constraintWithItem:self.stateLab attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25];
        NSLayoutConstraint *cons4 = [NSLayoutConstraint constraintWithItem:self.stateLab attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25];
        
        NSLayoutConstraint *cons5 = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.messageBackgroundImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cons6 = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25];
        NSLayoutConstraint *cons7 = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:25];
        NSLayoutConstraint *cons8 = [NSLayoutConstraint constraintWithItem:self.activityView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.messageBackgroundImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:-10];
        
        [self.contentView addConstraints:@[cons1,cons3,cons4,cons5,cons6,cons7,cons8]];
        
        self.nicknameLab.sd_layout
        .topEqualToView(self.avatarImageView)
        .leftSpaceToView(self.avatarImageView, 10)
        .heightIs(13);
        [self.nicknameLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
        
        [self.menuController setTargetRect:CGRectMake(100, 100, 100, 100) inView:self.messageBackgroundImageView];
        self.longes = [UILongPressGestureRecognizer new];
        [self addGestureRecognizer:self.longes];
        WeakSelf(self)
        [[self.longes rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
            StrongSelf(self)
            if (x.state == UIGestureRecognizerStateBegan) {
#warning  - 弹出长按
//                if (CIMUISIngle.shareManager.popupMenu) {
//                    [CIMUISIngle.shareManager.popupMenu dissPopupMenu];
//                    CIMUISIngle.shareManager.popupMenu = nil;
//                }
                
                if (self.messageModel.messageType == ZXMessageTypeFile ||
                    self.messageModel.messageType == ZXMessageTypeText ||
                    self.messageModel.messageType == ZXMessageTypeImage ||
                    self.messageModel.messageType == ZXMessageTypeVideo ||
                    self.messageModel.messageType == ZXMessageTypeVoice ||
                    self.messageModel.messageType == ZXMessageTypeNameCard ||
                    self.messageModel.messageType == ZXMessageTypeLocation ||
                    self.messageModel.messageType == ZXMessageTypeSticker
                    ) {
                    
                    ZXChatMessageController *chatVC = (ZXChatMessageController *)self.viewController;
                    [[chatVC.delegate getChateMessageController].view endEditing:YES];
//                    CIMPopupMenuOption *option = [CIMPopupMenuOption popupMenuOptionWithClipView:self.messageBackgroundImageView viewController:[chatVC.delegate getChateMessageController].navigationController];
//                    option.itemSize = CGSizeMake(SWAuto(40), SWAuto(60));
//                    option.insets = UIEdgeInsetsMake(15, 25, 15, 25);
//                    CIMPopupMenu *view = [CIMPopupMenu popupMenuWithOption:option];
//                    [view addItems:[self menuItemsForIm]];
//                    [view showPopipMenu];
//                    CIMUISIngle.shareManager.popupMenu = view;
                }
            }
        }];
    }
    
    return  self;
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_messageModel.ownerTyper == ZXMessageOwnerTypeSelf)
    {
        [self.avatarImageView setOrigin:CGPointMake(self.width - 10 - self.avatarImageView.width, 10)];
    }
    else if (_messageModel.ownerTyper == ZXMessageOwnerTypeOther)
    {
        [self.avatarImageView setOrigin:CGPointMake(10, 10)];
    }
}

-(void)setMessageModel:(ZXMessageModel *)messageModel
{
    _messageModel = messageModel;
    [self.contentView removeConstraint:self.cons2];
    
    //正在发送中，消息中断处理
    if (messageModel.sendState == ZXMessageSendIng) {
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp = [calendar components:NSCalendarUnitSecond fromDate:messageModel.date toDate:[NSDate dateWithTimeIntervalSinceNow:0] options:NSCalendarWrapComponents];
        if (comp.second > 20) {
            messageModel.sendState = ZXMessageSendFail;
            if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:updateMessageModel:)]) {
                [self.cpDelegate messageCell:self updateMessageModel:messageModel];
            }
        }
    }
    
    switch (_messageModel.ownerTyper) {
            
        //自己发的消息
        case ZXMessageOwnerTypeSelf:
        {
            [self.avatarImageView setHidden:NO];
            [self.messageBackgroundImageView setHidden:NO];
            self.nicknameLab.hidden = YES;
            //头像
            self.avatarImageView.backgroundColor = UIColor.clearColor;
            //模拟头像
            [self.avatarImageView setImage:[UIImage createImageWithString:@"帅哥"]];
            
//            if (CPKitManager.shareManager.userInfoModel.imgHead.length != 0) {
//                [self.avatarImageView.headImageView setImageWithURL:CIMRequstUrl(CPKitManager.shareManager.userInfoModel.imgHead) placeholder:[UIImage createImageWithString:CPKitManager.shareManager.userInfoModel.nickName] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
//                self.avatarImageView.isCustomer = CPKitManager.shareManager.userInfoModel.isCustomer;
//            }
//            else
//            {
//                self.avatarImageView.headImageView.image = [UIImage createImageWithString:CPKitManager.shareManager.userInfoModel.nickName];
//                self.avatarImageView.isCustomer = CPKitManager.shareManager.userInfoModel.isCustomer;
//            }


            //发送状态
            if (messageModel.sendState == ZXMessageSendIng)
            {
                [self.activityView startAnimating];
            }
            else {
                [self.activityView stopAnimating];
            }
            
            //发送结果状态
            self.stateLab.hidden = messageModel.sendState == ZXMessageSendFail ? NO : YES;
            
            
            // 设置高亮图片
//            self.messageBackgroundImageView.image = [UIImage imageNamed:@"message_sender_background_normal"];

            self.messageBackgroundImageView.image = [[UIImage imageNamed:@"message_sender_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
           
            // 设置高亮图片
            self.messageBackgroundImageView.highlightedImage = [[UIImage imageNamed:@"message_sender_background_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
            
            //重置状态布局
            self.cons2 = [NSLayoutConstraint constraintWithItem:self.stateLab attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.messageBackgroundImageView attribute:NSLayoutAttributeLeft multiplier:1 constant:-10];
            [self.contentView addConstraint:self.cons2];
        }
            break;
            
        //接收到的消息
        case ZXMessageOwnerTypeOther:
        {
            [self.avatarImageView setHidden:NO];
            self.nicknameLab.hidden = self.conversationType == CIMConversationType_Single;
            [self.activityView stopAnimating];
            [self.messageBackgroundImageView setHidden:NO];
            self.stateLab.hidden = YES;
            //模拟头像
            [self.avatarImageView setImage:[UIImage createImageWithString:@"哥"]];
            
            if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:friendId:completeHandle:)]) {
                WeakSelf(self)
//                [self.cpDelegate messageCell:self friendId:messageModel.fromId completeHandle:^(CIMAddressBookFriendModel *friendModel) {
//                    StrongSelf(self)
//                    //头像
////                    if (friendModel.imgHead.length != 0) {
////                        [self.avatarImageView.headImageView setImageWithURL:CIMRequstUrl(friendModel.imgHead) placeholder:[UIImage createImageWithString:friendModel.nickName] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
               
             
////                    }
////                    else
////                    {
////                        self.avatarImageView.headImageView.image = [UIImage createImageWithString:friendModel.nickName];
////                    }
//                    self.avatarImageView.isCustomer = friendModel.memberType == 2;
//                    self.nicknameLab.text = friendModel.name;
//                }];
            }
            
            // 设置高亮图片
//            [self.messageBackgroundImageView setImage:[UIImage imageNamed:@"message_receiver_background_normal"]];
            
            [self.messageBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch]];
            self.messageBackgroundImageView.highlightedImage = [[UIImage imageNamed:@"message_receiver_background_highlight"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];

            
            //重置布局
            self.cons2 = [NSLayoutConstraint constraintWithItem:self.stateLab attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.messageBackgroundImageView attribute:NSLayoutAttributeRight multiplier:1 constant:10];
            [self.contentView addConstraints:@[self.cons2]];
            
        }
            break;
        default:
        {
            [self.avatarImageView setHidden:YES];
            [self.messageBackgroundImageView setHidden:YES];
        }
            break;
    }
}

/**
 * avatarImageView 头像
 */

-(UIImageView *)avatarImageView
{
    if (_avatarImageView == nil) {
        float imageWidth = 40;
//        _avatarImageView = [CIMSingleUserHeadImageView singleUserHeadImageView];
        _avatarImageView = [UIImageView new];
        _avatarImageView.width = imageWidth;
        _avatarImageView.height = imageWidth;
        [_avatarImageView setHidden:YES];
        [_avatarImageView setSd_cornerRadius:@5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAvatarImgAction)];
        tap.delegate = self;
        _avatarImageView.userInteractionEnabled = YES;
        [_avatarImageView addGestureRecognizer:tap];
        
    }
    return _avatarImageView;
}

- (void)tapAvatarImgAction
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeAvatar);
    }
}

- (void)reSendMessage
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeReSendMessage);
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {//判断如果点击的是tableView的cell，就把手势给关闭了
        NSLog(@"1111");
//        if (CIMUISIngle.shareManager.popupMenu) {
//            [CIMUISIngle.shareManager.popupMenu dissPopupMenu];
//            CIMUISIngle.shareManager.popupMenu = nil;
//        }
        return NO;
    }
    NSLog(@"2222");
    return YES;
}

#pragma mark - get
//- (NSArray<CIMPopupMenuItem *> *)menuItemsForIm
//{
//    NSMutableArray<CIMPopupMenuItem *> *menus = [NSMutableArray array];
//
//    //文字类型有复制操作
//    if (self.messageModel.messageType == ZXMessageTypeText) {
//        CIMPopupMenuItem *item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"copy") image:kImageName(@"复制") action:@selector(copyForIm) target:self];
//        [menus addObject:item];
//    }
//
//    CIMPopupMenuItem *item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"Forward") image:kImageName(@"转发") action:@selector(zhuanfaForIm:) target:self];
//    [menus addObject:item];
//
//
//    item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"Delete") image:kImageName(@"删除") action:@selector(deleteForIm:) target:self];
//    [menus addObject:item];
//
//    //文字类型有复制操作
//    if (self.messageModel.messageType == ZXMessageTypeText) {
//        if (self.messageModel.isShowTranslated) {
//            CIMPopupMenuItem *item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"Translate") image:kImageName(@"翻译") action:@selector(translate:) target:self];
//            [menus addObject:item];
//        }
//        else {
//            CIMPopupMenuItem *item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"Translation") image:kImageName(@"翻译") action:@selector(translate:) target:self];
//            [menus addObject:item];
//        }
//    }
//
//    if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
//        CIMPopupMenuItem *item = [CIMPopupMenuItem popupMenuItemWithName:CIMLocalizableStr(@"Recall") image:kImageName(@"撤回色块") action:@selector(chehuiForIm:) target:self];
//        [menus addObject:item];
//    }
//    return menus;
//}

/**
 *  聊天背景图
 */
- (UIImageView *) messageBackgroundImageView
{
    if (_messageBackgroundImageView == nil) {
        _messageBackgroundImageView = [[UIImageView alloc] init];
        [_messageBackgroundImageView setHidden:YES];
        _messageBackgroundImageView.userInteractionEnabled = YES;
    }
    return _messageBackgroundImageView;
}

- (UIButton *)stateLab
{
    if (_stateLab == nil) {
        _stateLab = [UIButton buttonWithType:UIButtonTypeCustom];
        [_stateLab setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _stateLab.titleLabel.font = [UIFont systemFontOfSize:18];
        [_stateLab setTitle:@"!" forState:UIControlStateNormal];
        _stateLab.titleLabel.textAlignment = NSTextAlignmentCenter;
        _stateLab.backgroundColor = UIColor.redColor;
        _stateLab.layer.cornerRadius = 25 * 0.5;
        _stateLab.clipsToBounds = YES;
        _stateLab.translatesAutoresizingMaskIntoConstraints = NO;
        _stateLab.hidden = YES;
        [_stateLab addTarget:self action:@selector(reSendMessage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stateLab;
}

- (UIActivityIndicatorView *)activityView
{
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.backgroundColor = UIColor.clearColor;
        _activityView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _activityView;
}

- (UIMenuController *)menuController
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    return _menuController;
}

- (UILabel *)nicknameLab
{
    if (_nicknameLab == nil) {
        _nicknameLab = [UILabel new];
        _nicknameLab.textColor = SWColor(@"222222");
        _nicknameLab.font = SWFont_Regular(11);
    }
    return _nicknameLab;
}

- (void)copyForIm
{
    [UIPasteboard generalPasteboard].string = self.messageModel.text;
}

- (void)chehuiForIm:(id)sender
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeWithdrawMessage);
    }
}

- (void)translate:(id)sender
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeTranslate);
    }
}

- (void)deleteForIm:(id)sender
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeDeleteMessage);
    }
}

- (void)zhuanfaForIm:(id)sender
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeForward);
    }
}

+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

@end
