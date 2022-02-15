//
//  ZXTextMessageCell.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXTextMessageCell.h"

@implementation ZXTextMessageCell


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.messageTextLabel];
        [self addSubview:self.translateBackView];
        [self.translateBackView addSubview:self.translateLab];
        [self.translateBackView addSubview:self.transleteReslutBtn];
        [self.transleteReslutBtn sizeToFit];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    /**
     *  Label 的位置根据头像的位置来确定
     */
    float y = self.avatarImageView.y + 13 ;
    //+ (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
    float x = self.avatarImageView.x + (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? - self.messageTextLabel.width - 27 : self.avatarImageView.width + 23);
    [self.messageTextLabel setOrigin:CGPointMake(x, y)];
    
    x -= 18;                                    // 左边距离头像 5
    y = self.avatarImageView.y ;
    //+ (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));       // 上边与头像对齐 (北京图像有5个像素偏差)
    float h = MAX(self.messageTextLabel.height + 30, self.avatarImageView.height + 10);
    [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.messageTextLabel.width + 40, h)];
    
    self.translateBackView.y = self.messageBackgroundImageView.bottom + 5;
    
    if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
        self.translateBackView.right = self.messageBackgroundImageView.right - 5;
    }
    else {
        self.translateBackView.x = self.messageBackgroundImageView.x + 5;
    }
    
    if (self.messageModel.isShowTranslated) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.translateBackView.bounds cornerRadius:10];
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.translateBackView.bounds;
        layer.path = path.CGPath;
        self.translateBackView.layer.mask = layer;
//        [self.translateBackView addShadowWithOffset:CGSizeMake(0, 0) color:[UIColor.blackColor colorWithAlphaComponent:.7] radius:3 opacity:1];
    }
}

#pragma mark - Getter and Setter
-(void)setMessageModel:(ZXMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    
    self.translateBackView.hidden = !messageModel.isShowTranslated;
    
    NSMutableAttributedString *att1 = [[NSMutableAttributedString alloc] initWithAttributedString:messageModel.attrText];
    if (messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
        [att1 addAttributes:@{NSForegroundColorAttributeName : UIColor.blackColor} range:NSMakeRange(0, messageModel.attrText.length)];
        _messageTextLabel.tintColor = [UIColor colorWithHexString:@"ffffff"];
    }else{

        [att1 addAttributes:@{NSForegroundColorAttributeName : SWColor(@"2a2a2a")} range:NSMakeRange(0, messageModel.attrText.length)];
        _messageTextLabel.tintColor = UIColor.blueColor;
    }
    
    
    NSArray *matches = [NSString findAllGroupUrlWithString:messageModel.attrText.string];
    for (NSTextCheckingResult *match in matches)
    {
        //下划线 匹配连接
        [att1 addAttributes:@{NSUnderlineStyleAttributeName:@1} range:NSMakeRange(match.range.location, match.range.length)];
        WeakSelf(self)
        
        [att1 setTextHighlightRange:NSMakeRange(match.range.location, match.range.length)
                              color:messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? UIColor.whiteColor : SWMainColor
                    backgroundColor:messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? [UIColor.whiteColor colorWithAlphaComponent:.3] : [SWMainColor colorWithAlphaComponent:.3]
                          tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            StrongSelf(self)
            if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:clickUrl:)]) {
                [self.cpDelegate messageCell:self clickUrl:[text.string substringWithRange:range]];
            }
        }];
        
    }
    
    [att1 addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0]} range:NSMakeRange(0, att1.length)];
    [_messageTextLabel setAttributedText:att1];
    
    if (messageModel.isShowTranslated) {
        
        NSMutableAttributedString *att11 = [[NSMutableAttributedString alloc] initWithString:SWString(messageModel.translateText)];
        [att11 addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16.0] , NSForegroundColorAttributeName : SWColor(@"2a2a2a")}   range:NSMakeRange(0, att11.length)];
        
        NSArray *matches1 = [NSString findAllGroupUrlWithString:messageModel.translateText];
        for (NSTextCheckingResult *match in matches1)
        {
            //下划线
            [att11 addAttributes:@{NSUnderlineStyleAttributeName:@1} range:NSMakeRange(match.range.location, match.range.length)];
            WeakSelf(self)
            [att11 setTextHighlightRange:NSMakeRange(match.range.location, match.range.length) color:SWMainColor backgroundColor:[SWMainColor colorWithAlphaComponent:.3] tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                StrongSelf(self)
                if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:clickUrl:)]) {
                    [self.cpDelegate messageCell:self clickUrl:[text.string substringWithRange:range]];
                }
            }];
        }
        
        
        [_translateLab setAttributedText:att11];
        
        CGSize size = CGSizeMake(messageModel.translateMessageSize.width + 30, messageModel.translateMessageSize.height + 20);
        
        [self.transleteReslutBtn sizeToFit];
        self.transleteReslutBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        
        if (size.width < (self.transleteReslutBtn.width + 30)) {
            size.width = (self.transleteReslutBtn.width + 30);
        }
        
        _translateBackView.size = size;
        _translateLab.size = messageModel.translateMessageSize;
        _translateLab.x = 15;
        _translateLab.y = 10;
        
        if (messageModel.isTranslate) {
            size.height += 20;
            _translateBackView.size = size;
        }
        
        self.transleteReslutBtn.y = _translateLab.bottom + 5;
        self.transleteReslutBtn.x = 15;
    }
    _messageTextLabel.size = messageModel.messageSize;
    
    if (messageModel.isTranslate && messageModel.isShowTranslated) {
        self.transleteReslutBtn.hidden = NO;
    }
    else {
        self.transleteReslutBtn.hidden = YES;
    }
}

- (void)copyForIm:(id)sender
{
    [UIPasteboard generalPasteboard].string = self.messageTextLabel.text;
}

- (YYLabel *) messageTextLabel
{
    if (_messageTextLabel == nil) {
        _messageTextLabel = [YYLabel new];
        _messageTextLabel.numberOfLines = 0;
        _messageTextLabel.textColor = SWColor(@"414140");
        _messageTextLabel.backgroundColor = [UIColor clearColor];
        _messageTextLabel.clearContentsBeforeAsynchronouslyDisplay = NO;
        _messageTextLabel.textContainerInset = UIEdgeInsetsZero;
        
        UILongPressGestureRecognizer *tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapTextAction:)];
        tap.delegate = self;
        tap.minimumPressDuration = 1.5;
        tap.allowableMovement = 20;
        _messageTextLabel.userInteractionEnabled = YES;
        [_messageTextLabel addGestureRecognizer:tap];
    }
    return _messageTextLabel;
}

- (void)tapTextAction:(UILongPressGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.tap_avatarBlock) {
            self.tap_avatarBlock(CellOfClickAreaTypeText);
        }
    }
}

- (UIView *)translateBackView
{
    if (_translateBackView == nil) {
        _translateBackView = [UIView new];
        _translateBackView.backgroundColor = UIColor.whiteColor;
    }
    return _translateBackView;
}

- (YYLabel *) translateLab
{
    if (_translateLab == nil) {
        _translateLab = [YYLabel new];
        _translateLab.numberOfLines = 0;
        _translateLab.textColor = SWColor(@"414140");
        _translateLab.backgroundColor = [UIColor clearColor];
        _translateLab.clearContentsBeforeAsynchronouslyDisplay = NO;
        _translateLab.textContainerInset = UIEdgeInsetsZero;
    }
    return _translateLab;
}

- (UIButton *)transleteReslutBtn
{
    if (_transleteReslutBtn == nil) {
        _transleteReslutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _transleteReslutBtn.userInteractionEnabled = NO;
        [_transleteReslutBtn setImage:kImageName(@"transleteSuc") forState:UIControlStateNormal];
        [_transleteReslutBtn setTitle:[NSString stringWithFormat:@" %@",CIMLocalizableStr(@"Translation success")] forState:UIControlStateNormal];
        [_transleteReslutBtn setTitleColor:SWColor(@"#B1B1B1") forState:UIControlStateNormal];
        _transleteReslutBtn.titleLabel.font = SWFont_Medium(12);
    }
    return _transleteReslutBtn;
}

@end
