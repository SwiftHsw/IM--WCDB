//
//  WYIMConversationViewModel.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/27.
//

#import "WYIMConversationViewModel.h"
#import "WYIMConversationCell.h"


@interface WYIMConversationViewModel ()
@property (nonatomic,strong) UIView *netWorkStatsuView;
@end


@implementation WYIMConversationViewModel


#pragma mark - Public
- (void)setupInitForWYIMConversationViewModel{
    
    UIView *view = self.viewController.view;
    
    [view sd_addSubviews:@[self.netWorkStatsuView,self.tableView]];
    self.netWorkStatsuView.sd_layout
    .topSpaceToView(view, 0)
    .leftEqualToView(view)
    .rightEqualToView(view);
    
    self.tableView.sd_layout
    .topSpaceToView(self.netWorkStatsuView, 0)
    .leftEqualToView(view)
    .rightEqualToView(view)
    .bottomEqualToView(view);
    
    
//    @weakify(self)
//    RACObserve(WYAppSingle.shareManager, c)
    //监听tcp的链接状态
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isSucess = 1;
        //链接成功
        if (isSucess) {
            self.netWorkStatsuView.hidden = YES;
            self.tableView.sd_layout
            .topSpaceToView(view, 0);
        }
        //链接失败
        else {
            self.netWorkStatsuView.hidden = NO;
            self.tableView.sd_layout
            .topSpaceToView(self.netWorkStatsuView, 0);
        }
        [self.tableView updateLayout];
    });
}

#pragma mark - get
-(UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.viewController.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self.viewController;
        _tableView.dataSource = self.viewController;
        _tableView.separatorColor = SWLineColor();
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[WYIMConversationCell class] forCellReuseIdentifier:[WYIMConversationCell identifier]];
        if (@available(ios 11.0, *))
        {
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
        }
//        _tableView.tableHeaderView = self.searchController.searchBar;
    }
    return _tableView;
}
- (UIView *)netWorkStatsuView
{
    if (_netWorkStatsuView == nil) {
        _netWorkStatsuView = [UIView new];
    }
    return _netWorkStatsuView;
}


@end
