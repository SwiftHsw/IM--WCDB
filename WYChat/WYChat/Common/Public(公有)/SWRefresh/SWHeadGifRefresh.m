//
//  SWHeadGifRefresh.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "SWHeadGifRefresh.h"

@interface SWHeadGifRefresh ()
@property (nonatomic , strong) NSMutableArray<UIImage *> *gifImages;
@end

@implementation SWHeadGifRefresh

+(instancetype)sw_HeaderWithRefreshingBlock:(void (^)(void))refreshingBlock{
    SWHeadGifRefresh *headRefresh = [SWHeadGifRefresh headerWithRefreshingBlock:refreshingBlock];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStateIdle];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStateRefreshing];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStatePulling];
//    if (headRefresh.gifImages.count != 0)
//    {
//        headRefresh.stateLabel.hidden = YES;
        headRefresh.lastUpdatedTimeLabel.hidden = YES;
//    }
    headRefresh.stateLabel.font = SWFont_Regular(13);
    headRefresh.stateLabel.textColor = SWColor(@"bdbdbd");
    headRefresh.lastUpdatedTimeLabel.font = SWFont_Regular(13);
    headRefresh.lastUpdatedTimeLabel.textColor = SWColor(@"bdbdbd");
    headRefresh.automaticallyChangeAlpha = YES;
    return headRefresh;
}

+(instancetype)sw_HeaderWithRefreshingTarget:(id)tagert refreshingAction:(SEL)sel{
    SWHeadGifRefresh *headRefresh = [SWHeadGifRefresh headerWithRefreshingTarget:tagert refreshingAction:sel];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStateIdle];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStateRefreshing];
    [headRefresh setImages:headRefresh.gifImages forState:MJRefreshStatePulling];
//    if (headRefresh.gifImages.count != 0)
//    {
//        headRefresh.stateLabel.hidden = YES;
        headRefresh.lastUpdatedTimeLabel.hidden = YES;
//    }
    headRefresh.stateLabel.font = SWFont_Regular(13);
    headRefresh.stateLabel.textColor = SWColor(@"bdbdbd");
    headRefresh.lastUpdatedTimeLabel.font = SWFont_Regular(13);
    headRefresh.lastUpdatedTimeLabel.textColor = SWColor(@"bdbdbd");
    headRefresh.automaticallyChangeAlpha = YES;
    return headRefresh;
}

#pragma mark - get
- (NSMutableArray<UIImage *> *)gifImages{
    if (_gifImages == nil)
        {
        _gifImages = [NSMutableArray array];
        for (NSInteger i = 0; i < 16; i ++)
        {
//            [_gifImages addObject:imageName([NSString stringWithFormat:@"drowdown_refresh%ld",i])];
        }
    }
    return _gifImages;
    
}


@end
