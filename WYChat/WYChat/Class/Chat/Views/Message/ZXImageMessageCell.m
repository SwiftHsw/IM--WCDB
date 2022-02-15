//
//  ZXImageMessageCell.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXImageMessageCell.h"

@implementation ZXImageMessageCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self insertSubview:self.messageImageView belowSubview:self.messageBackgroundImageView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    float y = self.avatarImageView.y + 3 + (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
    if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
        float x = self.avatarImageView.x - self.messageImageView.width - 5;
        [self.messageImageView setOrigin:CGPointMake(x , y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.messageModel.messageSize.width+ 10, self.messageModel.messageSize.height + 10)];
    }
    else if (self.messageModel.ownerTyper == ZXMessageOwnerTypeOther) {
        float x = self.avatarImageView.x + self.avatarImageView.width + 5;
        [self.messageImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.messageModel.messageSize.width+ 10, self.messageModel.messageSize.height + 10)];
    }
}

#pragma mark - Getter and Setter
-(void)setMessageModel:(ZXMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    self.messageBackgroundImageView.hidden = NO;
    
    //图片
    if (messageModel.messageType == ZXMessageTypeImage)
    {
        //是否为视频，此处用于过滤
        if (self.isVideoCell == NO)
        {
            if(messageModel.image != nil) {
                [self.messageImageView setImage:messageModel.image];
            }
            else
            {
                [self.messageImageView setImageWithURL:CIMRequstUrl(messageModel.imageURL) placeholder:nil options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
            }
            [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width + 10, messageModel.messageSize.height + 10)];
        }
    }
    //贴纸
    else if (messageModel.messageType == ZXMessageTypeSticker)
    {
        self.messageBackgroundImageView.hidden = YES;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[messageModel.text dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *imageName = dic[@"data"][@"chartlet"];
        self.messageImageView.image = [UIImage imageNamed:imageName];
        [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width + 10, messageModel.messageSize.height + 10)];
    }
      
}


- (UIImageView *) messageImageView
{
    if (_messageImageView == nil) {
        _messageImageView = [[UIImageView alloc] init];
        [_messageImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_messageImageView setClipsToBounds:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPictureAction)];
        tap.delegate = self;
        _messageImageView.userInteractionEnabled = YES;
        [_messageImageView addGestureRecognizer:tap];

//        [tap requireGestureRecognizerToFail:self.longes];
    }
    return _messageImageView;
}


- (void)tapPictureAction
{
    if (self.tap_avatarBlock && !self.isVideoCell) {
        self.tap_avatarBlock(CellOfClickAreaTypeImg);
    }
}

@end
