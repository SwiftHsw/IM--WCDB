//
//  ZXChatMessageController.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//  https://segmentfault.com/a/1190000002412930

#import "ZXChatMessageController.h"
#import "ZXTextMessageCell.h"
#import "ZXImageMessageCell.h"
#import "ZXVoiceMessageCell.h"
#import "ZXSystemMessageCell.h"
#import "BH_VideoMessageCell.h"
#import "CIMFileMessageCell.h"
#import "ZXMessageModel.h"
#import "ZXNameCardCell.h"
#import "XYDJViewController.h"
#import "CIMNoteContentCell.h"
#import "HDCDDeviceManager.h"
#import <AVKit/AVKit.h>
#import "CIMNoteContentCell.h"
#import "BH_ImageMessgeClickView.h"

@interface ZXChatMessageController ()<
CIMZXMessageCellDelegate>

@property (nonatomic, strong) UITapGestureRecognizer *tapGR;
@property (nonatomic, strong) NSIndexPath *last_indexPath;
@property (nonatomic , assign) BOOL isDragging;
@property (nonatomic , strong) ZXMessageModel *clickImageModel;
@end

@implementation ZXChatMessageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:DEFAULT_CHAT_BACKGROUND_COLOR];
    /**
     *  给tableView添加一个手势，点击手势回收 ChatBoxController 的键盘。。
     */
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addGestureRecognizer:self.tapGR];
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
//    self.tableView.backView.contentLab.text = @"";
//    self.tableView.backView.backgroundColor = UIColor.clearColor;
    
    /**
     *  注册四个 cell
     */
    [self.tableView registerClass:[ZXTextMessageCell class] forCellReuseIdentifier:@"ZXTextMessageCell"];
    [self.tableView registerClass:[ZXImageMessageCell class] forCellReuseIdentifier:@"ZXImageMessageCell"];
    [self.tableView registerClass:[ZXVoiceMessageCell class] forCellReuseIdentifier:@"ZXVoiceMessageCell"];
    [self.tableView registerClass:[ZXNameCardCell class] forCellReuseIdentifier:@"ZXNameCardCell"];
    [self.tableView registerClass:[BH_VideoMessageCell class] forCellReuseIdentifier:BH_VideoMessageCell.identifier];
    [self.tableView registerClass:[CIMNoteContentCell class] forCellReuseIdentifier:CIMNoteContentCell.identifier];
    [self.tableView registerClass:[CIMFileMessageCell class] forCellReuseIdentifier:CIMFileMessageCell.identifier];
    
    
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    //关闭当前语音
    if ([HDCDDeviceManager sharedInstance].isPlaying) {
        [[HDCDDeviceManager sharedInstance] stopPlaying];
    }
}


#pragma mark - Public Methods
- (void) addNewMessage:(ZXMessageModel *)message
{
    //添加时间节点
    //当前没有聊天记录，添加当前时间
    if (self.data.count == 0)
    {
        if (![message.cellIndentify isEqualToString:CIMNoteContentCell.identifier]) {
            ZXMessageModel *model = [ZXMessageModel new];
            model.date = message.date;
            model.messageType = ZXMessageTypeMessgeInChatTime;
            [self.data addObject:model];
        }
    }
    //有聊天记录，和上一条比较时间
    else {
        ZXMessageModel *model = self.data.lastObject;
        
        //过滤最后一条的时间
        if (model.messageType == ZXMessageTypeMessgeInChatTime) {
            [self.data removeLastObject];
            model = self.data.lastObject;
        }
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *result = [calendar components:NSCalendarUnitSecond fromDate:model.date toDate:message.date options:NSCalendarWrapComponents];
        if (result.second > 60)
        {
            if (![message.cellIndentify isEqualToString:CIMNoteContentCell.identifier]) {
                ZXMessageModel *model = [ZXMessageModel new];
                model.date = message.date;
                model.messageType = ZXMessageTypeMessgeInChatTime;
                [self.data addObject:model];
            }
        }
    }
    
    [self.data addObject:message];
    [self.tableView reloadData];
    if ((self.tableView.contentOffset.y > self.tableView.contentSize.height - SCREEN_HEIGHT) &&
        self.isDragging == NO) {
        [self scrollToBottom];
    }
    
}

- (void) scrollToBottom
{
    if (_data.count > 0) {
        // tableView 定位到的cell 滚动到相应的位置，后面的 atScrollPosition 是一个枚举类型
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)updateMessageModelForCell:(ZXMessageModel *)messageModel
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.data indexOfObject:messageModel] inSection:0];
    if (indexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _data.count;
}

 
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZXMessageModel  * messageModel = _data[indexPath.row];
    /**
     *  id类型的cell 通过取出来Model的类型，判断要显示哪一种类型的cell
     */
    ZXMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageModel.cellIndentify forIndexPath:indexPath];
    cell.cpDelegate = self;
    cell.conversationType = [self.delegate getConversationType];
    [cell setMessageModel:messageModel];
    
    WeakSelf(cell)
//    kWeakObject(cell)
    [cell setTap_avatarBlock:^(CellOfClickAreaType clickType) {
        StrongSelf(cell)
//        kStrongObject(cell)
        
        if (clickType == CellOfClickAreaTypeReLoadCurrentCell) {
            [tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
        }
        
        if (clickType == CellOfClickAreaTypeAvatar) {
            NSLog(@"点击头像");
            //别人发的
            if (messageModel.ownerTyper == ZXMessageOwnerTypeOther) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(didClickUserHeadWithModel:)]) {
                    [self.delegate didClickUserHeadWithModel:messageModel];
                }
            }
        }

        if (clickType == CellOfClickAreaTypeImg) {
            NSLog(@"图片放大");
            [[self.delegate getChateMessageController].view endEditing:YES];

            ZXImageMessageCell *cell1 = (ZXImageMessageCell *)cell;
            if (cell1.messageImageView.image) {
                self.clickImageModel = messageModel;
                NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.messageType == 2"];
                NSArray *arr = [self.data filteredArrayUsingPredicate:pre];
                NSInteger index = [arr indexOfObject:self.clickImageModel];
//                CPRotationPictureViewController *imageVC = [CPRotationPictureViewController rotationPictureViewControllerWithInitScrollerIndex:index delegate:self viewController:self.delegate.getChateMessageController.navigationController];
//                [imageVC showRotationPictureViewController];
            }
        }
        
        if (clickType == CellOfClickAreaTypePlayVideo) {
            NSLog(@"播放视频");
            //服务器视频为止
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASEURL,messageModel.videoRemotePath]];

            NSString *videoLocationPath = [[WYIMFileManager.shareManager videosDirectorPath] stringByAppendingPathComponent:messageModel.videoLocalPath];

            //本地存在视频
            if ([[NSFileManager defaultManager] fileExistsAtPath:videoLocationPath] &&
                messageModel.videoLocalPath) {
                url = [NSURL fileURLWithPath:videoLocationPath];
            }
            AVPlayerViewController *vc = [[AVPlayerViewController alloc] init];
            vc.player = [[AVPlayer alloc] initWithURL:url];
            [vc.player play];
            [self presentViewController:vc animated:YES completion:nil];
        }

        if (clickType == CellOfClickAreaTypePlayVoice) {

            NSLog(@"播放语音");
            //当前正在播放
            if ([HDCDDeviceManager sharedInstance].isPlaying) {
                //停止当前播放
                [[HDCDDeviceManager sharedInstance] stopPlaying];
                if (self.last_indexPath) {
                    ZXMessageModel  * last_messageModel = self.data[self.last_indexPath.row];
                    last_messageModel.isPlay = NO;
                    [self.tableView reloadRowsAtIndexPaths:@[self.last_indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }

                self.last_indexPath = indexPath;
                messageModel.isPlay = YES;
                messageModel.readState = ZXMessageReaded;
                [self messageCell:cell updateMessageModel:messageModel];
                [self.tableView reloadRowsAtIndexPaths:@[self.last_indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [[HDCDDeviceManager sharedInstance] asyncPlayingWithPath:[WYIMFileManager.shareManager.voicesDirectorPath stringByAppendingPathComponent:messageModel.voicePath] completion:^(NSError *error) {
                    messageModel.isPlay = NO;
                    [self.tableView reloadRowsAtIndexPaths:@[self.last_indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    self.last_indexPath = nil;

                }];
            }
            //未播放
            else
            {
                //开启播放
                self.last_indexPath = indexPath;
                messageModel.isPlay = YES;
                messageModel.readState = ZXMessageReaded;
                [self messageCell:cell updateMessageModel:messageModel];
                [self.tableView reloadRowsAtIndexPaths:@[self.last_indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [[HDCDDeviceManager sharedInstance] asyncPlayingWithPath:[WYIMFileManager.shareManager.voicesDirectorPath stringByAppendingPathComponent:messageModel.voicePath] completion:^(NSError *error) {
                    messageModel.isPlay = NO; 
                    [self.tableView reloadRowsAtIndexPaths:@[self.last_indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    self.last_indexPath = nil;
                }];
            }
        }
        
        if (clickType == CellOfClickAreaTypePauseVoice) {
            NSLog(@"暂停播放");
            if ([HDCDDeviceManager sharedInstance].isPlaying) {
                [[HDCDDeviceManager sharedInstance] stopPlaying];
                messageModel.isPlay = NO;
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                self.last_indexPath = nil;
            }
        }

        //撤回消息
        if (clickType == CellOfClickAreaTypeWithdrawMessage) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(chehuiSendMessage:)]) {
                [self.delegate chehuiSendMessage:messageModel];
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }

        //删除消息
        if (clickType == CellOfClickAreaTypeDeleteMessage) {
            
            NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
            
            //下一条为时间/下一条没有数据  预备当前消息 flag标记可以删除上一条消息为时间可删除
            BOOL flag = NO;
            //有没有下一条消息
            if (indexPath.row + 1 < self.data.count) {
                
                //是否为时间
                ZXMessageModel *m1 = [self.data objectAtIndex:indexPath.row + 1];
                if (m1.messageType == ZXMessageTypeMessgeInChatTime) {
                    flag = YES;
                }
            }
            //没有下一条
            else
            {
                flag = YES;
            }
            
            //判断上一条消息是否为时间
            //防止越界崩溃
            if (indexPath.row - 1 >= 0) {
                ZXMessageModel *m2 = [self.data objectAtIndex:indexPath.row - 1];
                if (m2.messageType == ZXMessageTypeMessgeInChatTime && flag) {
                    
                    [self.data removeObjectsInArray:@[messageModel,m2]];
                }
                else
                {
                   [self.data removeObjectsInArray:@[messageModel]];
                }
                [self.tableView reloadData];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(deleteMessage:)]) {
                [self.delegate deleteMessage:messageModel];
            }
        }
        
        //重新发送消息
        if (clickType == CellOfClickAreaTypeReSendMessage)
        {
            //移除时间
            if (self.data.count > 1) {
                //最后一条消息
                if ([messageModel isEqual:self.data.lastObject]) {
                    ZXMessageModel *m = self.data[[self.data indexOfObject:messageModel] - 1];
                    if (m.messageType == ZXMessageTypeMessgeInChatTime) {
                        [self.data removeObject:m];
                    }
                }
                //非最后一条消息
                else {
                    ZXMessageModel *m1 = self.data[[self.data indexOfObject:messageModel] - 1];
                    ZXMessageModel *m2 = self.data[[self.data indexOfObject:messageModel] + 1];
                    
                    if (m1.messageType == ZXMessageTypeMessgeInChatTime &&
                        m2.messageType == ZXMessageTypeMessgeInChatTime) {
                        [self.data removeObject:m1];
                    }
                }
            }
            
            [self.data removeObject:messageModel];
            [self.tableView reloadData];
            if (self.delegate && [self.delegate respondsToSelector:@selector(reSendMessage:)]) {
                [self.delegate reSendMessage:messageModel];
            }
        }
        
        //转发消息
        if (clickType == CellOfClickAreaTypeForward) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(forwardMessage:)]) {
                [self.delegate forwardMessage:messageModel];
            }
        }
        
        //点击名片
        if (clickType == CellOfClickAreaTypeNameCard) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didNameCardWithMessageModel:)]) {
                [self.delegate didNameCardWithMessageModel:messageModel];
            }
        }
        
        //发送好友验证
        if (clickType == CellOfClickAreaTypeSendFriendsVerification) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(sendFriendsVerification)]) {
                [self.delegate sendFriendsVerification];
            }
        }
        
        //翻译
        if (clickType == CellOfClickAreaTypeTranslate) {
            
            if (messageModel.isShowTranslated) {
                messageModel.isShowTranslated = NO;
                ZXTextMessageCell *cell1 = (ZXTextMessageCell *)cell;
                cell1.translateBackView.hidden = YES;
            }
            else {
                messageModel.isShowTranslated = YES;
                if (!messageModel.isTranslate) {
                    messageModel.translateType = ZXMessageTranslateType_Ing;
                    messageModel.translateText = CIMLocalizableStr(@"Translating...");
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                }
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(translateMessageModel:)]) {
                [self.delegate translateMessageModel:messageModel];
            }
        }
        
        //文件
        if (clickType == CellOfClickAreaTypeFile) {
            
//            CIMWKWebController *vc = [CIMWKWebController WKWebControllerWithFilePath:messageModel.fileLocationPath];
//            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }];

    return cell;
     
}

#pragma mark - CPRotationPictureViewControllerDelegate
//- (NSArray *)rotationPictureViewControllerOfNumberOfItems:(CPRotationPictureViewController *)viewController
//{
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.messageType == 2"];
//    NSArray *arr = [self.data filteredArrayUsingPredicate:pre];
//    return arr;
//}
//
//- (id)rotationPictureViewController:(CPRotationPictureViewController *)viewController objectAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"self.messageType == 2"];
//    NSArray *arr = [self.data filteredArrayUsingPredicate:pre];
//    ZXMessageModel *model = arr[indexPath.row];
//    return CIMRequstUrl(model.imageURL).absoluteString;
//}
//
//#pragma mark - CIMZXMessageCellDelegate
//- (void)messageCell:(ZXMessageCell *)cell friendId:(NSString *)friendId completeHandle:(void (^)(CIMAddressBookFriendModel *))completeHandle
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(chatMessageController:friendId:completeHandle:)]) {
//        [self.delegate chatMessageController:self friendId:friendId completeHandle:^(CIMAddressBookFriendModel *friendModel) {
//            if (completeHandle) completeHandle(friendModel);
//        }];
//    }
//}

- (void)messageCell:(ZXMessageCell *)cell updateMessageModel:(ZXMessageModel *)messageModel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatMessageController:updateMessageModel:)]) {
        [self.delegate chatMessageController:self updateMessageModel:messageModel];
    }
}

- (void)messageCell:(ZXMessageCell *)cell clickUrl:(NSString *)urlString
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickUrl:)]) {
        [self.delegate clickUrl:urlString];
    }
}

#pragma mark - UITableViewCellDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZXMessageModel *message = [_data objectAtIndex:indexPath.row];
//    if (message.ownerTyper == ZXMessageOwnerTypeOther &&
//        [self.delegate getConversationType] == CIMConversationType_Single &&
//        message.messageType <= 8) {
//        return message.cellHeight;
//    }
    return message.cellHeight;
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (_delegate && [_delegate respondsToSelector:@selector(didTapChatMessageView:)]) {   
//        [_delegate didTapChatMessageView:self];
//    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isDragging = YES;
//    [CIMUISIngle.shareManager dissPopupMenu];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isDragging = NO;
}

#pragma mark - Event Response
- (void) didTapView
{
//    [CIMUISIngle.shareManager dissPopupMenu];
    [self.view endEditing:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(didTapChatMessageView:)]) {
       
        [_delegate didTapChatMessageView:self];
    }
}

- (void)gotoCardNameWithFriendId:(NSString *)friendId
{
//    //添加请求头
//    [CPNetManager addHeadHTTPHeaderField:@{@"Authorization":[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"Authorization"]]}];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/api-member/um/umMember/findInfo/%@",BASE_URL(),friendId];
//    [CPNetManager GET:urlStr parameters:nil success:^(NSDictionary * _Nullable responseObject, NSURLSessionDataTask * _Nonnull task) {
//        NSLog(@"%@",responseObject);
//        BH_AddressBookModel *model = [BH_AddressBookModel yy_modelWithJSON:responseObject[@"data"]];
//        
//        if (model.state == 1) {
//            BH_FriendDataViewController *friend_dataVC = [BH_FriendDataViewController new];
//            friend_dataVC.friend_model = model;
//            [self.navigationController pushViewController:friend_dataVC animated:YES];
//        }
//        else {
//            BH_ResulitNewFriendViewController *result_newVC = [BH_ResulitNewFriendViewController new];
//            result_newVC.friendModel = model;
//            [self.navigationController pushViewController:result_newVC animated:YES];
//        }
//        
//        
//    } failure:^(NSDictionary * _Nullable responseObject, NSString * _Nullable message, NSString * _Nullable code, NSURLSessionDataTask * _Nonnull task) {
//        NSLog(@"%@",responseObject);
//        [SVProgressHUD showInfoWithStatus:@"没有找到他的信息"];
//    }];
//    
}

#pragma mark - Getter
- (UITapGestureRecognizer *) tapGR
{
    if (_tapGR == nil) {
        _tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView)];
        _tapGR.cancelsTouchesInView = NO; // 不加此句tableviewcell不能点击
    }
    return _tapGR;
}

- (NSMutableArray *) data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", indexPath.row);
//    [CIMUISIngle.shareManager dissPopupMenu];
}

    

@end
