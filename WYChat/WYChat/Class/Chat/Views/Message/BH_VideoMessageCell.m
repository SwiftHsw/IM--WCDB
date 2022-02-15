//
//  BH_VideoMessageCell.m
//  BaiHaiChatIMApplication
//
//  Created by Mac on 2020/7/21.
//  Copyright © 2020 bh. All rights reserved.
//

#import "BH_VideoMessageCell.h"

@interface BH_VideoMessageCell ()
@property(nonatomic , strong) UIButton  *playBtn;

@end

@implementation BH_VideoMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.messageImageView addSubview:self.playBtn];
     
        NSLayoutConstraint *cons5 = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.messageImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
        NSLayoutConstraint *cons6 = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
        NSLayoutConstraint *cons7 = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:40];
        NSLayoutConstraint *cons8 = [NSLayoutConstraint constraintWithItem:self.playBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.messageImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        [self.messageImageView addConstraints:@[cons5,cons6,cons7,cons8]];
    }
    return self;
}

#pragma mark - set
-(void)setMessageModel:(ZXMessageModel *)messageModel
{
    self.isVideoCell = YES;
    [super setMessageModel:messageModel];
    
    if(messageModel.videoCoverImage != nil)
    {
        [self.messageImageView setImage:messageModel.videoCoverImage];
        [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width + 10, messageModel.messageSize.height + 10)];
    }
    else
    {
        [self.messageImageView setSize:CGSizeMake(messageModel.messageSize.width + 10, messageModel.messageSize.height + 10)];
        
        //网络获取视频处
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [UIImage thumbnailImageForVideo:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASEURL,messageModel.videoRemotePath]] atTime:0];
            NSString *videoCoverPath = [WYIMFileManager.shareManager saveImageToCurrentUserDirector:image];
            messageModel.videoCoverLocationPath = videoCoverPath;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.messageImageView setImage:messageModel.videoCoverImage];
                if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:updateMessageModel:)]) {
                    [self.cpDelegate messageCell:self updateMessageModel:messageModel];
                }
            });
        });
        
    }
    
//    switch (self.messageModel.ownerTyper) {
//        case ZXMessageOwnerTypeSelf:
//            self.messageBackgroundImageView.image = [[UIImage imageNamed:@"message_sender_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
//            break;
//        case ZXMessageOwnerTypeOther:
//            [self.messageBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch]];
//            break;
//        default:
//            break;
//    }
    
}

#pragma mark - get
+ (NSString *)identifier
{
    return NSStringFromClass(self);
}

- (UIButton *)playBtn
{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateNormal];
        _playBtn.translatesAutoresizingMaskIntoConstraints = NO;
        @weakify(self)
        [[_playBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.tap_avatarBlock) {
                self.tap_avatarBlock(CellOfClickAreaTypePlayVideo);
            }
        }];
    }
    return _playBtn;
}

@end
