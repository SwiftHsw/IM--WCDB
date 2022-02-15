//
//  XYDJViewController.m
//  StoryboardTest
//
//  Created by mxsm on 16/4/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "XYDJViewController.h"
#import "ZXChatBoxController.h"
#import "ZXChatMessageController.h"
#import "ZXMessageModel.h"
//#import "CIMGroupChatDetailsController.h"
//#import "CIMSingleChatDetailsController.h"
//#import "CIMChooseConversationController.h"
//#import "CIMFriendDetailsInfoController.h"
#import "CIMNoteContentCell.h"
//#import "CIMInviteIntoGroupController.h"

@interface XYDJViewController ()<ZXChatMessageControllerDelegate,ZXChatBoxViewControllerDelegate>
{
    CGFloat viewHeight;
}
@property (nonatomic , strong , readwrite) WYIMConversationModel *conversation;
@property(nonatomic,strong)ZXChatMessageController * chatMessageVC;
@property(nonatomic,strong)ZXChatBoxController * chatBoxVC;
@property (nonatomic , assign) int32_t page;
@property (nonatomic , assign) int32_t size;
@property (nonatomic , strong) RACDisposable *receiveSelfNeedUpdateMessageSinalDisposable;
@property (nonatomic , strong) RACDisposable *receiveSinalDisposable;
@end

@implementation XYDJViewController


#pragma mark - Life
+ (instancetype)chatControllerWithConversationModel:(WYIMConversationModel *)conversation
{
    XYDJViewController *vc = [XYDJViewController new];
    vc.conversation = conversation;
    vc.conversation.priority = 1;
    return vc;
}

- (void)dealloc
{
    [self.receiveSelfNeedUpdateMessageSinalDisposable dispose];
    [self.receiveSinalDisposable dispose];
    self.conversation.receiveBlock = nil;
    self.conversation.receiveSelfNeedUpdateMessageBlock = nil;
    
    if (!self.conversation.isDelForConversation) {
        self.conversation.recordNum = 0;
        self.conversation.priority = 0;
        self.conversation.knewMessageModel = self.chatMessageVC.data.lastObject;
        [self.conversation updataConversationSelf];
        if (self.wyDelegate && [self.wyDelegate respondsToSelector:@selector(chatViewControllerRetrunNeedReloadConversation:conversation:)]) {
            [self.wyDelegate chatViewControllerRetrunNeedReloadConversation:self conversation:self.conversation];
        }
    }
    [IQKeyboardManager sharedManager].enable = YES;
    [self.chatBoxVC removeFromParentViewController];
    [self.chatMessageVC removeFromParentViewController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
//    [CIMUISIngle.shareManager dissPopupMenu];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f5f6f7"];
    self.size = 30;
    // Do any additional setup after loading the view.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view setBackgroundColor:DEFAULT_BACKGROUND_COLOR];
    [self setHidesBottomBarWhenPushed:YES];
    
    // 主屏幕的高度减去导航的高度，减去状态栏的高度。在PCH头文件
    viewHeight = SCREEN_HEIGHT - NAVBAR_HEIGHT -SAFEBOTTOM_HEIGHT;
    
    [self.view  addSubview:self.chatMessageVC.view];
    [self addChildViewController:self.chatMessageVC];
    
    [self.view  addSubview:self.chatBoxVC.view];
    [self addChildViewController:self.chatBoxVC];
    
    self.conversation.offlineMsg_lastMsg = @"";
    self.conversation.offlineMsg_lastTime = 0;
    self.conversation.offlineMsg_msgContentType = 1;
    self.conversation.dealLastTime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    [self.conversation updataConversationSelf];
    
    WeakSelf(self)
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonTitle:nil image:kImageName(@"省略号") button:^(UIButton *btn) {
        StrongSelf(self)
        WeakSelf(self)
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            StrongSelf(self)
            //单聊
            if (self.conversation.conversationType == CIMConversationType_Single) {
//                CIMSingleChatDetailsController *vc = [CIMSingleChatDetailsController SingleChatDetailsControllerWithConversation:self.conversation];
//                [self.navigationController pushViewController:vc animated:YES];
            }
            //群聊
            else {
//                CIMGroupChatDetailsController *vc = [CIMGroupChatDetailsController groupChatDetailsControllerWithConversation:self.conversation];
//                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }];
    
    //设置名称
    self.title = self.conversation.nickName;
    [self getConversationInfomationFromNet];
    
    //加载数据
    NSArray *arr = [self.conversation getConversationForMessageModelsWithSize:self.size page:self.page];
    NSArray *arr1 = [self carryDateTimeForData:arr];
    [self.chatMessageVC.data insertObjects:arr1 atIndex:0];
    [self.chatMessageVC.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.chatMessageVC scrollToBottom];
    });
    
    if (self.chatMessageVC.data.count >= self.size) {
        self.chatMessageVC.tableView.mj_header = self.headRefresh;
    }
    
    self.conversation.receiveBlock = ^(ZXMessageModel * _Nonnull messageModel) {
        StrongSelf(self)
        //消息撤回
        if (messageModel.messageType == ZXMessageTypeMessageWithdraw) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.msgId == %@",messageModel.msgId];
            NSArray *arr = [self.chatMessageVC.data filteredArrayUsingPredicate:pre];
            if (arr.count != 0) {
                [self.chatMessageVC.data replaceObjectAtIndex:[self.chatMessageVC.data indexOfObject:arr.lastObject] withObject:messageModel];
                [self.chatMessageVC.tableView reloadData];
            }
        }
        //双向删除
        else if (messageModel.messageType == ZXMessageTypeDropMessage) {
            [self.chatMessageVC.data removeAllObjects];
            ZXMessageModel *model = [ZXMessageModel createNoteMessageModelWithType:ZXMessageTypeSafeContentNotify];
            model.date = [NSDate dateWithTimeIntervalSince1970:0];
            [self.chatMessageVC addNewMessage:model];
            [self.chatMessageVC.tableView reloadData];
        }
        //正常消息
        else{
            //需要更新群信息的类型
            if (messageModel.messageType == ZXMessageTypeGoupNickname_change ||     //群昵称变更
                messageModel.messageType == ZXMessageTypeNewMemberIntoGroup ||      //群新将入提示信息
                messageModel.messageType == ZXMessageTypeMemberGoOutGroup ||        //群成员退群
                messageModel.messageType == ZXMessageTypeGroupJinyan ||             //群禁言
                messageModel.messageType == ZXMessageTypeGroupJinAddFriends ||      //群禁止加好友
                messageModel.messageType == ZXMessageTypeGroupOwnChange ||          //群主转让
                messageModel.messageType == ZXMessageTypeGroupOwnTiMembers          //群踢成员
                ) {
                [self getConversationInfomationFromNet];
            }
            
            [self.chatMessageVC addNewMessage:messageModel];
        }
    };
    
    self.conversation.receiveSelfNeedUpdateMessageBlock = ^(ZXMessageModel * _Nonnull messageModel) {
        StrongSelf(self)
        if (messageModel) {
            //消息双向删除
            if (messageModel.messageType == ZXMessageTypeDropMessage) {
                [self.chatMessageVC.data removeAllObjects];
                ZXMessageModel *model = [ZXMessageModel createNoteMessageModelWithType:ZXMessageTypeSafeContentNotify];
                model.date = [NSDate dateWithTimeIntervalSince1970:0];
                [self.chatMessageVC addNewMessage:model];
                [self.chatMessageVC.tableView reloadData];
            }
            else {

                NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.messageId == %@",messageModel.messageId];
                NSArray *arr = [self.chatMessageVC.data filteredArrayUsingPredicate:pre];
                if (arr.count != 0) {
                    [self.chatMessageVC.data replaceObjectAtIndex:[self.chatMessageVC.data indexOfObject:arr.lastObject] withObject:messageModel];
                    [self.chatMessageVC.tableView reloadData];
                }
                else{
                    
                    //需要更新群信息的类型
                    if (messageModel.messageType == ZXMessageTypeGoupNickname_change ||     //群昵称变更
                        messageModel.messageType == ZXMessageTypeNewMemberIntoGroup ||      //群新将入提示信息
                        messageModel.messageType == ZXMessageTypeMemberGoOutGroup ||        //群成员退群
                        messageModel.messageType == ZXMessageTypeGroupJinyan ||             //群禁言
                        messageModel.messageType == ZXMessageTypeGroupJinAddFriends ||      //群禁止加好友
                        messageModel.messageType == ZXMessageTypeGroupOwnChange ||          //群主转让
                        messageModel.messageType == ZXMessageTypeGroupOwnTiMembers          //群踢成员
                        ) {
                        [self getConversationInfomationFromNet];
                    }
                    
                    [self.chatMessageVC addNewMessage:messageModel];
                }
            }
        }
    };

//    //显示最新的离线消息
//    [self.conversation.newOfflineMessageSingal subscribeNext:^(id  _Nullable x) {
//        StrongSelf(self)
//        //加载数据
//        [self.chatMessageVC.data removeAllObjects];
//        NSArray *arr = [self carryDateTimeForData:[self.conversation getConversationForMessageModelsWithSize:self.size page:self.page]];
//        [self.chatMessageVC.data insertObjects:arr atIndex:0];
//        [self.chatMessageVC.tableView reloadData];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self.chatMessageVC scrollToBottom];
//        });
//        if (self.chatMessageVC.data.count >= self.size) {
//            self.chatMessageVC.tableView.mj_header = self.headRefresh;
//        }
//    }];

}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

//加载聊天记录添加时间分界线
- (NSArray<ZXMessageModel *> *)carryDateTimeForData:(NSArray<ZXMessageModel *> *)models
{
    __block NSMutableArray<ZXMessageModel *> *new_models = [NSMutableArray array];
    @weakify(models)
    if (models.count != 0) {
        [models enumerateObjectsUsingBlock:^(ZXMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(models)
            //第一条消息内容前加时间
            if (idx == 0) {
                if (![obj.cellIndentify isEqualToString:CIMNoteContentCell.identifier]) {
                    ZXMessageModel *model = [ZXMessageModel new];
                    model.date = obj.date;
                    model.messageType = ZXMessageTypeMessgeInChatTime;
                    [new_models addObject:model];
                }
                [new_models addObject:obj];
            }
            //后续的聊天都和前一条对比是否超过1分钟
            else
            {
                ZXMessageModel *perModel = models[idx - 1];
                NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *result = [calendar components:NSCalendarUnitSecond fromDate:perModel.date toDate:obj.date options:NSCalendarWrapComponents];
                if (result.second > 60)
                {
                    if (![obj.cellIndentify isEqualToString:CIMNoteContentCell.identifier]) {
                        ZXMessageModel *model = [ZXMessageModel new];
                        model.date = obj.date;
                        model.messageType = ZXMessageTypeMessgeInChatTime;
                        [new_models addObject:model];
                    }
                    [new_models addObject:obj];
                }
                else
                {
                    [new_models addObject:obj];
                }
            }
        }];
    }
    
    return new_models;
}

- (void)getConversationInfomationFromNet
{
    WeakSelf(self)
    //单聊
    if (self.conversation.conversationType == CIMConversationType_Single) {
        
//        [self.conversation getAddressBookFriendModelByNetForConversation:^(CIMAddressBookFriendModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
//            self.conversation.nickName = model.name;
//            [self setViewControllerTitle:model.name color:SWColor(@"222222")];
//        }];
    }
    //群聊
    else {
//        [self.conversation getGroupInfoByNetForConversation:^(CIMGroupInfoModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
//            //非群成员
//            if (model.isNotGroupMembers) {
//                self.conversation.nickName = model.groupName.length != 0 ? model.groupName : [CPKitManager.shareManager.userInfoModel nickName];
//                self.chatBoxVC.view.hidden = YES;
//                self.navigationItem.rightBarButtonItem = nil;
//                ZXMessageModel *model = [ZXMessageModel createNoteMessageModelWithType:ZXMessageTypeNoGroupMembers];
//                [self.chatMessageVC addNewMessage:model];
//            }
//            //是群成员
//            else
//            {
//                //群主不禁言
//                self.chatBoxVC.chatBox.isJinYan = [model.memberId isEqualToString:[CPKitManager.shareManager.userModel memberId]] ? NO : [model.forbidden integerValue] == 1 ? YES : NO;
//                self.chatBoxVC.chatBox.userInteractionEnabled = !self.chatBoxVC.chatBox.isJinYan;
//                [self.view endEditing:self.chatBoxVC.chatBox.isJinYan];
//                self.chatBoxVC.view.hidden = NO;
//                self.conversation.nickName = model.groupName;
//            }
//            [self setViewControllerTitle:self.conversation.nickName color:SWColor(@"222222")];
//        }];
    }
}

- (void)getConversationInfomationFromLocation
{
    WeakSelf(self)
    //单聊
    if (self.conversation.conversationType == CIMConversationType_Single) {
        
//        [self.conversation getAddressBookFriendModelForConversation:^(CIMAddressBookFriendModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
//            self.conversation.nickName = model.name;
//            [self setViewControllerTitle:model.name color:SWColor(@"222222")];
//        }];
    }
    //群聊
    else {
//        [self.conversation getGroupInfoForConversation:^(CIMGroupInfoModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
//            //非群成员
//            if (model.isNotGroupMembers) {
//                self.conversation.nickName = model.groupName.length != 0 ? model.groupName : [CPKitManager.shareManager.userInfoModel nickName];
//                self.chatBoxVC.chatBox.userInteractionEnabled = !self.chatBoxVC.chatBox.isJinYan;
//                [self.view endEditing:self.chatBoxVC.chatBox.isJinYan];
//                self.chatBoxVC.view.hidden = YES;
//                ZXMessageModel *model = [ZXMessageModel createNoteMessageModelWithType:ZXMessageTypeNoGroupMembers];
//                [self.chatMessageVC addNewMessage:model];
//            }
//            //是群成员
//            else
//            {
//                //群主不禁言
//                self.chatBoxVC.chatBox.isJinYan = [model.memberId isEqualToString:[CPKitManager.shareManager.userModel memberId]] ? NO : [model.forbidden integerValue] == 1 ? YES : NO;
//                self.chatBoxVC.view.hidden = NO;
//                self.conversation.nickName = model.groupName;
//            }
//            [self setViewControllerTitle:self.conversation.nickName color:SWColor(@"222222")];
//        }];
    }
}

/**
 * TLChatMessageViewControllerDelegate 的代理方法
 */
#pragma mark - TLChatMessageViewControllerDelegate
- (void)chatMessageController:(ZXChatMessageController *)chetMessageVC friendId:(NSString *)friendId completeHandle:(void (^)(NSObject *))completeHandle
{
    //单聊
    if (self.conversation.conversationType == CIMConversationType_Single) {
//        [self.conversation getOneAddressBookFriendModelForConversation:^(CIMAddressBookFriendModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            if (completeHandle) completeHandle(model);
//        }];
    }
    //群聊
    else {
//        [self.conversation getGroupMemberInConversationWithFriendID:friendId handle:^(CIMAddressBookFriendModel * _Nonnull model, WYIMConversationModel * _Nonnull conversation) {
//            if (completeHandle) completeHandle(model);
//        }];
    }
}

- (void)chatMessageController:(ZXChatMessageController *)chetMessageVC updateMessageModel:(ZXMessageModel *)messageModel
{
//    [self.conversation insertOrReplaceMessageModelToConversation:messageModel];
}

- (void) didTapChatMessageView:(ZXChatMessageController *)chatMessageViewController
{
    [self.chatBoxVC resignFirstResponder];
}

- (void)reSendMessage:(ZXMessageModel *)message
{
    message.sendState = ZXMessageSendIng;
    message.date = [NSDate dateWithTimeIntervalSinceNow:0];
    self.conversation.knewMessageModel = message;
    [self chatBoxViewController:self.chatBoxVC sendMessage:message];
}

- (void)forwardMessage:(ZXMessageModel *)message
{
    NSDictionary *dic = [message modelToJSONObject];
    ZXMessageModel *model = [ZXMessageModel modelWithJSON:dic];
    model.ownerTyper = ZXMessageOwnerTypeSelf;
    model.sendState = ZXMessageSendIng;
    model.date = [NSDate dateWithTimeIntervalSinceNow:0];
    //重新定义
    model.messageId = [NSString stringWithFormat:@"%u%lld%u%u",arc4random_uniform(10000),(long long)[NSDate dateWithTimeIntervalSinceNow:0].timeIntervalSince1970,arc4random_uniform(10),arc4random_uniform(99)];
    
    //转发消息
//    CPNavgationController *nav = [CPNavgationController rootViewController:[CIMChooseConversationController chooseConversationControllerWithMessageModels:@[model]]];
//    nav.backButtonImage = kImageName(@"left_back");
//    nav.modalPresentationStyle = UIModalPresentationFullScreen;
//    [self presentViewController:nav animated:YES completion:nil];
}

- (void)chehuiSendMessage:(ZXMessageModel *)message
{
    message.messageType = ZXMessageTypeMessageWithdraw;
//    [CPTCPManager.shareManager sendMsd:[message messageModelToMsg:self.conversation]];
    ///撤回
}

- (void)deleteMessage:(ZXMessageModel *)message
{
    //删除数据库
    [self.conversation deleteOneMessageWithMessageID:message.messageId];
    
    //更新最后一条消息内容
    [self.conversation updateLastNewMessage];
}

- (void)didClickUserHeadWithModel:(ZXMessageModel *)messageModel
{
    //单聊
    if (self.conversation.conversationType == CIMConversationType_Single) {
        WeakSelf(self)
//        [self.conversation getOneAddressBookFriendModelForConversation:^(CIMAddressBookFriendModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
////            CIMFriendDetailsInfoController *vc = [CIMFriendDetailsInfoController friendDetailsInfoControllerWithFriendId:model.friendId friendModel:model source:model.source byNetRequst:YES];
////            [self.navigationController pushViewController:vc animated:YES];
//        }];
    }
    //群聊
    else {
        WeakSelf(self)
        //获取群详情，判断是否可互添加好友
//        [self.conversation getOneGroupInfoForConversation:^(CIMGroupInfoModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
//            //可添加好友、自己是群主
//            if ([model.addFriend integerValue] == 1 ||
//                [model.memberId isEqualToString:[CPKitManager.shareManager.userModel memberId]]) {
//                WeakSelf(self)
//                [self.conversation getGroupMemberInConversationWithFriendID:messageModel.fromId handle:^(CIMAddressBookFriendModel * _Nonnull model, WYIMConversationModel * _Nonnull conversation) {
//                    StrongSelf(self)
////                    CIMFriendDetailsInfoController *vc = [CIMFriendDetailsInfoController friendDetailsInfoControllerWithFriendId:model.friendId friendModel:model source:CIMFriendSource_Group byNetRequst:YES];
////                    [self.navigationController pushViewController:vc animated:YES];
//                }];
//            }
//        }];
    }
}

- (void)didNameCardWithMessageModel:(ZXMessageModel *)messageModel
{
//    if (messageModel.bcardUrl.length) {
//
//    }
//    else {
        WeakSelf(self)
//        [self.conversation getAddressFriendModelInConversationWithFriendID:messageModel.friendId handle:^(CIMAddressBookFriendModel * _Nonnull model, WYIMConversationModel * _Nonnull conversation) {
//            StrongSelf(self)
////            CIMFriendDetailsInfoController *vc = [CIMFriendDetailsInfoController friendDetailsInfoControllerWithFriendId:model.friendId friendModel:model source:CIMFriendSource_NameCard byNetRequst:YES];
////            [self.navigationController pushViewController:vc animated:YES];
//        }];
//    }
}

- (CIMConversationType)getConversationType
{
    return self.conversation.conversationType;
}

- (void)clickUrl:(NSString *)urlString
{
//    NSString *str = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
//    CIMInviteIntoGroupController *vc = [CIMInviteIntoGroupController inviteIntoGroupControllerWithGroupUrl:str];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sendFriendsVerification
{
    WeakSelf(self)
//    [self.conversation getOneAddressBookFriendModelForConversation:^(CIMAddressBookFriendModel * _Nullable model, WYIMConversationModel * _Nonnull conversation) {
//        StrongSelf(self)
////        CIMFriendDetailsInfoController *vc = [CIMFriendDetailsInfoController friendDetailsInfoControllerWithFriendId:model.friendId friendModel:model source:model.source byNetRequst:YES];
////        [self.navigationController pushViewController:vc animated:YES];
//    }];
}

/// 获取控制器
- (UIViewController *)getChateMessageController
{
    return self;
}

- (WYIMConversationModel *)currentConversationModel
{
    return self.conversation;
}

- (void)translateMessageModel:(ZXMessageModel *)messageModel
{
    //收起翻译
    if (!messageModel.isShowTranslated) {
//        [self.conversation insertOrReplaceMessageModelToConversation:messageModel];
        [self.chatMessageVC updateMessageModelForCell:messageModel];
    }
    //翻译
    else {
        //已翻译
        if (messageModel.isTranslate) {
//            [self.conversation insertOrReplaceMessageModelToConversation:messageModel];
            [self.chatMessageVC updateMessageModelForCell:messageModel];
        }
        else {
            WeakSelf(self)
//            CIMBusinessServer *businessServer = [CIMBusinessServer new];
//            [businessServer.omTranslationggTransCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
//                StrongSelf(self)
//                if ([x[0] boolValue]) {
//                    messageModel.translateText = x[1][@"data"];
//                    messageModel.translateType = ZXMessageTranslateType_SUCCESS;
//                    messageModel.isTranslate = YES;
//                }
//                else {
//                    messageModel.translateText = CIMLocalizableStr(@"Translation failure");
//                    messageModel.translateType = ZXMessageTranslateType_FAIL;
//                    messageModel.isTranslate = NO;
//                }
//                [self.conversation insertOrReplaceMessageModelToConversation:messageModel];
//                [self.chatMessageVC updateMessageModelForCell:messageModel];
//            }];
//            [businessServer.omTranslationggTransCommand execute:@{@"content":SWString(messageModel.text),@"target":[[CPUserDefaultTool appLanguage] substringToIndex:2]}];
        }
    }
    
}

/**
 * TLChatBoxViewControllerDelegate 的代理方法 ------ 发送
 */
#pragma mark - TLChatBoxViewControllerDelegate
- (void)chatBoxViewController:(ZXChatBoxController *)chatboxViewController sendMessage:(ZXMessageModel *)message
{
    //添加展示
    [self.chatMessageVC addNewMessage:message];
    
    //模拟发送成功
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        message.sendState = ZXMessageSendSuccess;
        [self.chatMessageVC.tableView reloadData];
    });
    WeakSelf(self)
    //通过会话发送消息
    [self.conversation sendMessageModel:message success:^(ZXMessageModel * _Nonnull messageModel) {

        //可写入发送成功的操作

    } fail:^(ZXMessageModel * _Nonnull messageModel) {

        StrongSelf(self)
        [self.chatMessageVC.tableView reloadData];
    }];
    
    [self.chatMessageVC scrollToBottom];
}


-(void)chatBoxViewController:(ZXChatBoxController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height
{
    
    /**
     *   改变BoxController .view 的高度 ，这采取的是重新设置 Frame 值！！
     */
    self.chatMessageVC.view.height = viewHeight - height;
//    self.chatBoxVC.view.y = self.chatMessageVC.view.y + self.chatMessageVC.view.height;
    self.chatBoxVC.view.y = self.chatMessageVC.view.maxY;
    [self.chatMessageVC scrollToBottom];
    
}
 
/**
 *  两个聊天界面控制器
 */

-(ZXChatMessageController *)chatMessageVC
{
    if (_chatMessageVC == nil) {
        _chatMessageVC = [[ZXChatMessageController  alloc] init];
        [_chatMessageVC.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, viewHeight+SAFEBOTTOM_HEIGHT+5)];// 0  状态 + 导航 宽 viweH - tabbarH
        [_chatMessageVC setDelegate:self];// 代理
        
    }
    return _chatMessageVC;
}


-(ZXChatBoxController *) chatBoxVC
{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[ZXChatBoxController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0, viewHeight - HEIGHT_TABBAR, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshForHeader
{
    [self.headRefresh endRefreshing];
    self.page ++;
    NSArray *arr = [self carryDateTimeForData:[self.conversation getConversationForMessageModelsWithSize:self.size page:self.page * self.size]];
    [self.chatMessageVC.data insertObjects:arr atIndex:0];
    [self.chatMessageVC.tableView reloadData];
    [self.chatMessageVC.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:arr.count inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    if (arr.count < self.size) self.chatMessageVC.tableView.mj_header = nil;
}

 


@end
