//
//  CIMNoteContentCell.m
//  ChatIM
//
//  Created by Mac on 2020/8/21.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "CIMNoteContentCell.h"

@interface CIMNoteContentCell ()
@property (nonatomic , strong) YYLabel *noteLab;
@property (nonatomic , strong) UIView *backView;
@end

@implementation CIMNoteContentCell

+ (CGFloat)CIMNoteContentCellMaxWidth
{
    return SCREEN_WIDTH - 50;
}

#pragma mark - set
- (void)setMessageModel:(ZXMessageModel *)messageModel
{
    NSString *str = messageModel.messageType == ZXMessageTypeMessgeInChatTime ? messageModel.dateStringForCell : messageModel.note;
    NSMutableAttributedString *att1 = [NSString attributedWithString:str color:SWColor(@"B1B1B1") font:[UIFont systemFontOfSize:13]];
    
    //添加敏感词汇的图标
    if ([str containsString:CIMLocalizableStr(@"Sensitive words")]) {
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:kImageName(@"yelloowWarning")];
        NSMutableAttributedString *att2 = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(20, 20) alignToFont:self.noteLab.font alignment:YYTextVerticalAlignmentCenter];
        [att2 appendString:@" "];
        [att1 insertAttributedString:att2 atIndex:0];
    }
    
    //好友验证
    if ([str hasSuffix:CIMLocalizableStr(@"Send friend verification")]) {
        NSRange range = [[NSString getRangeStr:str findText:CIMLocalizableStr(@"Send friend verification")].lastObject rangeValue];
        WeakSelf(self)
        [att1 setTextHighlightRange:range color:SWMainColor backgroundColor:[SWMainColor colorWithAlphaComponent:.3] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            StrongSelf(self)
            if (self.tap_avatarBlock) {
                self.tap_avatarBlock(CellOfClickAreaTypeSendFriendsVerification);
            }
        }];
    }
    
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = NSTextAlignmentCenter;
    [att1 addAttributes:@{NSParagraphStyleAttributeName : style} range:NSMakeRange(0, att1.length)];
    
    self.noteLab.attributedText = att1;
    self.noteLab.sd_layout
    .heightIs(messageModel.messageSize.height);
    [self.noteLab updateLayout];
}

#pragma mark - Life
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.avatarImageView.hidden = YES;
        self.messageBackgroundImageView.hidden = YES;
        self.stateLab.hidden = YES;
        [self.contentView addSubview:self.noteLab];
        
        self.noteLab.sd_layout
        .topSpaceToView(self.contentView, 10)
        .centerXEqualToView(self.contentView)
        .widthIs([CIMNoteContentCell CIMNoteContentCellMaxWidth])
        .heightIs(10);
    }
    return self;
}


#pragma mark - get
+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

- (YYLabel *)noteLab
{
    if (_noteLab == nil) {
        _noteLab = [YYLabel new];
        _noteLab.textColor = SWColor(@"#B1B1B1");
        [_noteLab setFont:[UIFont systemFontOfSize:13]];
        _noteLab.numberOfLines = 0;
        _noteLab.backgroundColor = [UIColor clearColor];
        _noteLab.clearContentsBeforeAsynchronouslyDisplay = NO;
        _noteLab.textContainerInset = UIEdgeInsetsZero;
        _noteLab.textAlignment = NSTextAlignmentCenter;
    }
    return _noteLab;
}

@end
