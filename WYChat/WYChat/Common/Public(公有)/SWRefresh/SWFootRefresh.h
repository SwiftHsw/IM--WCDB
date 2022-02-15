//
//  SWFootRefresh.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger(^SWFootRefreshCurrentPageBlock)(void);
typedef void(^SWBaseBlock)(void);


@interface SWFootRefresh : MJRefreshAutoStateFooter
+(instancetype)cpFooterWithRefreshingBlock:(SWBaseBlock)refreshBolck
                            showStatusPage:(NSInteger)showStatusPage
                               currentPage:(SWFootRefreshCurrentPageBlock)currentPageBlock;
@end

NS_ASSUME_NONNULL_END
