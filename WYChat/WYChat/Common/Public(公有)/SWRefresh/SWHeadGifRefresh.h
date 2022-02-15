//
//  SWHeadGifRefresh.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

@interface SWHeadGifRefresh : MJRefreshGifHeader

+(instancetype)sw_HeaderWithRefreshingBlock:(void (^)(void))refreshingBlock;

+(instancetype)sw_HeaderWithRefreshingTarget:(id)tagert refreshingAction:(SEL)sel;

@end

NS_ASSUME_NONNULL_END
