//
//  BH_ImageMessgeClickView.h
//  BaiHaiChatIMApplication
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 bh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BH_ImageMessgeClickView : UIView

+ (instancetype)imageMessgeClickViewWithImage:(UIImage *)image rect:(CGRect)rect;

- (void)showCoverView;

@end

NS_ASSUME_NONNULL_END
