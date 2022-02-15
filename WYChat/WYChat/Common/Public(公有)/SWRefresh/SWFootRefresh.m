//
//  SWFootRefresh.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "SWFootRefresh.h"

@interface SWFootRefresh ()
@property (nonatomic , assign) NSInteger                    showStatusPage;
@property (nonatomic , copy) SWFootRefreshCurrentPageBlock  currentPageBlock;
@end

@implementation SWFootRefresh

+(instancetype)cpFooterWithRefreshingBlock:(SWBaseBlock)refreshBolck
                            showStatusPage:(NSInteger)showStatusPage
                               currentPage:(SWFootRefreshCurrentPageBlock)currentPageBlock
{
    SWFootRefresh *footRefresh = [SWFootRefresh footerWithRefreshingBlock:refreshBolck];
    footRefresh.showStatusPage = showStatusPage;
    footRefresh.currentPageBlock = currentPageBlock;
    footRefresh.automaticallyChangeAlpha = YES;
    return footRefresh;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        @weakify(self)
        self.stateLabel.textColor = SWColor(@"bdbdbd");
        self.stateLabel.font = SWFont_Regular(13);
        [[RACObserve(self, state) skip:1] subscribeNext:^(id  _Nullable x) {
            
           @strongify(self)
//            /** 普通闲置状态 */
//            MJRefreshStateIdle = 1,
//            /** 松开就可以进行刷新的状态 */
//            MJRefreshStatePulling,
//            /** 正在刷新中的状态 */
//            MJRefreshStateRefreshing,
//            /** 即将刷新的状态 */
//            MJRefreshStateWillRefresh,
//            /** 所有数据加载完毕，没有更多的数据了 */
//            MJRefreshStateNoMoreData
            
//            SWLog(@"%@",x)
            
            NSInteger currentPage = self.currentPageBlock();
            //没有更多数据
            if (self.state == MJRefreshStateNoMoreData)
            {
                self.scrollView.mj_footer = nil;
                if (currentPage >= self.showStatusPage)
                {
                    self.scrollView.mj_footer = self;
                }
            }
            //其他
            else
            {
                self.scrollView.mj_footer = self;
            }
            
            
        }];
    }
    return self;
}

#pragma mark - get

@end
