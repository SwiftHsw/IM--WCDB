//
//  CIMDownProgressView.h
//  ChatIM
//
//  Created by Mac on 2020/11/18.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIMDownProgressView : UIView

/// 0-1
@property (nonatomic , assign) CGFloat progress;

+ (instancetype)downProgressViewWithCenterRadiu:(CGFloat)radiu;

@end

NS_ASSUME_NONNULL_END
