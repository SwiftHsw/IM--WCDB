//
//  CIMNoteContentCell.h
//  ChatIM
//
//  Created by Mac on 2020/8/21.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "ZXMessageCell.h" 

NS_ASSUME_NONNULL_BEGIN

@interface CIMNoteContentCell : ZXMessageCell

+ (NSString *)identifier;

+ (CGFloat)CIMNoteContentCellMaxWidth;

@end

NS_ASSUME_NONNULL_END
