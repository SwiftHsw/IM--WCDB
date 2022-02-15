//
//  ZXNameCardCell.m
//  BaiHaiChatIMApplication
//
//  Created by mac on 2020/7/16.
//  Copyright © 2020 bh. All rights reserved.
//

#import "ZXNameCardCell.h"

@interface ZXNameCardCell ()
@property (nonatomic, strong) UIView *containV;
@property (nonatomic, strong) UIView *line_view;
@property (nonatomic, strong) UILabel *desL;
@end

@implementation ZXNameCardCell
 
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       
        [self.contentView addSubview:self.containV];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.messageBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch]];
    /**
    *  控件的位置根据头像的位置来确定
    */
    float y = self.avatarImageView.y + 9 + (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
    
    //自己发的
    if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
        
        float x = self.avatarImageView.x - 258;
        [self.containV setOrigin:CGPointMake(x, y)];
        y = self.avatarImageView.y ;
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.containV.width + 20, 110)];
    }
    //别人发的
    else{
        float x = self.avatarImageView.right + 5;
        [self.containV setOrigin:CGPointMake(x, y)];
        y = self.avatarImageView.y + (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.containV.width + 20, 110)];
    }
    
    
}

- (void)setMessageModel:(ZXMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    
    if (messageModel.imgHead.length) {
        [self.card_avatarImgV setImageWithURL:CIMRequstUrl(messageModel.imgHead) placeholder:[UIImage createImageWithString:messageModel.nickName] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
    }
    else {
        self.card_avatarImgV.image = [UIImage createImageWithString:messageModel.nickName];
    }
//    self.card_avatarImgV.isCustomer = [messageModel.userType intValue] == 2;
    
    self.card_nameL.text = messageModel.nickName;
}

- (UIView *)containV
{
    if (!_containV) {
        _containV = [[UIView alloc] init];
        _containV.frame = CGRectMake(20, 20, 238, 94);
        [_containV addSubview:self.card_avatarImgV];
        [_containV addSubview:self.card_nameL];
        [_containV addSubview:self.line_view];
        [_containV addSubview:self.desL];
        _containV.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNameCardAction)];
        tap.delegate = self;
        [_containV addGestureRecognizer:tap];
    }
    return _containV;
}


- (void)tapNameCardAction
{
    if (self.tap_avatarBlock) {
        self.tap_avatarBlock(CellOfClickAreaTypeNameCard);
    }
}

- (UIImageView *)card_avatarImgV
{
    if (!_card_avatarImgV) {
//        _card_avatarImgV = [CIMSingleUserHeadImageView singleUserHeadImageView];
        _card_avatarImgV = [UIImageView new];
        _card_avatarImgV.frame = CGRectMake(15, 10, 44, 44);
        [_card_avatarImgV setSd_cornerRadius:@5];
    }
    return _card_avatarImgV;
}

- (UILabel *)card_nameL
{
    if (!_card_nameL) {
        _card_nameL = [[UILabel alloc] init];
        _card_nameL.textColor = [UIColor colorWithHexString:@"#2A2A2A"];
        _card_nameL.font = [UIFont systemFontOfSize:16.0 weight:(UIFontWeightMedium)];
        _card_nameL.frame = CGRectMake(CGRectGetMaxX(_card_avatarImgV.frame) + 10, CGRectGetMidY(_card_avatarImgV.frame)-10, 100, 20);
    }
    
    return _card_nameL;;
}

- (UIView *)line_view
{
    if (!_line_view) {
        _line_view = [[UIView alloc] init];
        _line_view.backgroundColor = [UIColor colorWithHexString:@"f5f6f7"];
        _line_view.frame = CGRectMake(10, CGRectGetMaxY(_card_avatarImgV.frame) + 9, _containV.frame.size.width, 1);
    }
    return _line_view;
}

- (UILabel *)desL
{
    if (!_desL) {
        _desL = [[UILabel alloc] init];
        _desL.textColor = [UIColor colorWithHexString:@"#B1B1B1"];
        _desL.text = CIMLocalizableStr(@"Personal business card");
        _desL.font = [UIFont systemFontOfSize:14.0 weight:(UIFontWeightMedium)];
        _desL.frame = CGRectMake(15, CGRectGetMaxY(_line_view.frame) + 9, 100, 15);
    }
    return _desL;
}

@end
