//
//  CIMFileMessageCell.h
//  ChatIM
//
//  Created by Mac on 2020/11/16.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "ZXMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface CIMFileMessageCell : ZXMessageCell
@property (nonatomic, strong) UIImageView *card_avatarImgV;
@property (nonatomic, strong) UILabel *card_nameL;
@end

NS_ASSUME_NONNULL_END
