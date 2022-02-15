//
//  BaseViewController.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/21.
//

#import <SWKit/SWKit.h>
#import "SWHeadGifRefresh.h"
#import "SWFootRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : SWSuperViewContoller
/// 当前刷新是否为顶部下拉刷新
@property (nonatomic , assign) BOOL isRefreshForHead;

/// 下拉刷新控件
@property (nonatomic , strong) SWHeadGifRefresh *headRefresh;

/// 上拉刷新控件
@property (nonatomic , strong) SWFootRefresh *footRefresh;

///刷新页数
@property (nonatomic , assign) int32_t refreshPage;
@end

NS_ASSUME_NONNULL_END
