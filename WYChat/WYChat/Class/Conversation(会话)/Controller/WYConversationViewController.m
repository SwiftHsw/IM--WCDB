//
//  WYConversationViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/27.
//

#import "WYConversationViewController.h"
#import "SWPrompt.h"
#import "WYIMConversationViewModel.h"
#import "WYIMConversationCell.h"
#import "XYDJViewController.h"

@interface WYConversationViewController ()<XYDJViewControllerDelegate>
@property (nonatomic,strong) WYIMConversationViewModel *viewModel;
@end

@implementation WYConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setItemAndBindingForWYConversationViewController];
    [self.viewModel setupInitForWYIMConversationViewModel];
    
}


- (void)setItemAndBindingForWYConversationViewController{
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barButtonTitle:nil image:kImageName(@"添加 (1)") button:^(UIButton *btn) {
        [btn addCallBackAction:^(UIButton *button) {
            SWPromptBoxOption *option = [SWPromptBoxOption promptBoxOptionWithClipView:button];
            option.radiu = 10;
            option.textFont = SWFont_Regular(15);
            option.selectorTextColor = SWColor(@"666666");
            option.backgroundColor = SWColor(@"636164");
            option.coverViewBackgroundColor = [SWColor(@"111111") colorWithAlphaComponent:.2];
            option.width = SWAuto(130);
            SWPromptBoxView *PromptBoxView = [SWPromptBoxView promptBoxViewWithOption:option];
            [PromptBoxView addTitles:@[@"创建群聊",@"添加好友",@"扫一扫"] images:@[@"home_add_group",@"home_add_friend",@"home_add_scan",] didSelector:^(NSIndexPath *indexPath) {
            } cancleSelector:nil];
            [PromptBoxView showPrompt];
        }];
    }];
    
    //监听列表变化
    [WYAppSingle.shareManager.conversationManager conversationsList:self.viewModel.tableView messageChangeWithComplete:^{
        SWLog(@"列表发生改变====****");
    }];
    
    
    //更新离线消息
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return WYAppSingle.shareManager.conversationManager.conversations.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //过滤，防止崩溃
    NSMutableOrderedSet *dataList = WYAppSingle.shareManager.conversationManager.conversations;
    int32_t count = (int32_t)dataList.count;
    if (indexPath.row < count) {
        WYIMConversationModel *conversation = dataList[indexPath.row];
        WYIMConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:WYIMConversationCell.identifier];
        cell.conversation = conversation;
        return cell;
    }
    return [BaseTableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SWAuto(60);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYIMConversationModel *conversation = [WYAppSingle.shareManager.conversationManager getOneConversationWithDidSelectorIndex:indexPath.row moveFirst:YES];
    XYDJViewController *vc = [XYDJViewController chatControllerWithConversationModel:conversation];
    vc.wyDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WYIMConversationModel *conversation = WYAppSingle.shareManager.conversationManager.conversations[indexPath.row];
    UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [WYAppSingle.shareManager.conversationManager deleterConversation:conversation isDeleterConversationRecord:YES];
//        [self reloadConversationListUnReadNum];
    }];
    UITableViewRowAction *topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [WYAppSingle.shareManager.conversationManager updateConversation:conversation isBeTop:YES];
    }];
    if (conversation.isBeTop) {
        topAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [WYAppSingle.shareManager.conversationManager updateConversation:conversation isBeTop:NO];
        }];
    }
    return @[delAction,topAction];
}
- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (@available(iOS 11.0, *)) {
        WYIMConversationModel *conversation = WYAppSingle.shareManager.conversationManager.conversations[indexPath.row];
        UIContextualAction *delAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [WYAppSingle.shareManager.conversationManager deleterConversation:conversation isDeleterConversationRecord:YES];
        }];
        
        UIContextualAction *topAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            [WYAppSingle.shareManager.conversationManager updateConversation:conversation isBeTop:YES];
        }];
        if (conversation.isBeTop) {
            topAction  = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"取消置顶" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
                [WYAppSingle.shareManager.conversationManager updateConversation:conversation isBeTop:NO];
            }];
            
        }
        
        return [UISwipeActionsConfiguration configurationWithActions:@[delAction,topAction]];
    } else {
        // Fallback on earlier versions
    }
    return [UISwipeActionsConfiguration configurationWithActions:@[]];
}

- (void)chatViewControllerRetrunNeedReloadConversation:(XYDJViewController *)chatVC conversation:(WYIMConversationModel *)conversation{
    
//    [CIMAPPSingle.shareManager.conversationManager updateConversationsForUnReadNum];;
    ///// 主动更新会话首页未读消息数量展示
    [self.viewModel.tableView reloadData];
    
}
#pragma mark - get

- (WYIMConversationViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [WYIMConversationViewModel new];
        _viewModel.viewController = self;
    }
    return _viewModel;
}

@end
