//
//  ZXNameCardCell.h
//  BaiHaiChatIMApplication
//
//  Created by mac on 2020/7/16.
//  Copyright © 2020 bh. All rights reserved.
//

#import "ZXMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXNameCardCell : ZXMessageCell
@property (nonatomic, strong) UIImageView *card_avatarImgV;
@property (nonatomic, strong) UILabel *card_nameL;

@end

NS_ASSUME_NONNULL_END
