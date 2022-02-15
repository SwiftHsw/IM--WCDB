//
//  BaseViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (SWHeadGifRefresh *)headRefresh
{
    if (_headRefresh == nil) {
        @weakify(self)
        _headRefresh = [SWHeadGifRefresh sw_HeaderWithRefreshingBlock:^{
            @strongify(self)
            [self refreshForHeader];
        }];
    }
    return _headRefresh;
}

- (SWFootRefresh *)footRefresh
{
    if (_footRefresh == nil) {
        @weakify(self)
        _footRefresh = [SWFootRefresh cpFooterWithRefreshingBlock:^{
            @strongify(self)
            [self refresgForFooter];
        } showStatusPage:1 currentPage:^NSInteger{
            @strongify(self)
            return [self refresgForFooterPage];
        }];
    }
    return _footRefresh;
}

- (void)refreshForHeader
{
    
}

- (void)refresgForFooter
{
    
}
- (NSInteger)refresgForFooterPage
{
    return self.refreshPage;
}

@end
