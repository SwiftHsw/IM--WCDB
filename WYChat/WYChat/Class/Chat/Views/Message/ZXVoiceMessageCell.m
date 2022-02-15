//
//  ZXVoiceMessageCell.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXVoiceMessageCell.h"

@interface ZXVoiceMessageCell ()
@property (nonatomic , strong) UILabel *roundLab;
@end

@implementation ZXVoiceMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
       
        [self.contentView addSubview:self.voiceCountLabel];
        [self.contentView addSubview:self.voiceImgV];
        [self.contentView addSubview:self.voiceStateBtn];
        [self.contentView addSubview:self.roundLab];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    /**
    *  控件的位置根据头像的位置来确定
    */
    float y = self.avatarImageView.y + 13;
    //+ (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
    
    float x = self.avatarImageView.x + (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? - self.voiceCountLabel.width - 20 : self.avatarImageView.width + 20);
    
    [self.voiceCountLabel setOrigin:CGPointMake(x, y)];
    
    
    [self.voiceImgV setOrigin:(CGPointMake(self.voiceCountLabel.x + (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? - self.voiceImgV.width - 5 : self.voiceCountLabel.width + 5), y-5))];
    
    [self.voiceStateBtn setOrigin:(CGPointMake(self.voiceImgV.x + (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? - self.voiceStateBtn.width - 5 : self.voiceImgV.width + 5), y-6))];
    
    x = self.avatarImageView.x + (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? - self.voiceCountLabel.width - self.voiceImgV.width - self.voiceStateBtn.width - 24 - 18 : self.avatarImageView.width + 2);                                   // 左边距离头像
    y = self.avatarImageView.y ;
    //+ (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
    [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.voiceCountLabel.width + self.voiceImgV.width + self.voiceStateBtn.width + 40, 50)];
    
    self.roundLab.sd_layout
    .topEqualToView(self.messageBackgroundImageView).offset(SWAuto(10))
    .leftSpaceToView(self.messageBackgroundImageView, SWAuto(10));
    
}

#pragma mark - Getter and Setter
- (void)setMessageModel:(ZXMessageModel *)messageModel
{
    [super setMessageModel:messageModel];
    
    if (messageModel.ownerTyper == ZXMessageOwnerTypeSelf) {
        _voiceCountLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
        _voiceImgV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"voiceImg"]];
        if (!messageModel.isPlay) {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePlay"] forState:(UIControlStateNormal)];
        }else{
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePause"] forState:(UIControlStateNormal)];
        }
    }else{
        _voiceCountLabel.textColor = [UIColor colorWithHexString:@"#2A2A2A"];
        _voiceImgV.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"voiceImg_other"]];
        if (!messageModel.isPlay) {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePlay_other"] forState:(UIControlStateNormal)];
        }else{
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePause_other"] forState:(UIControlStateNormal)];
        }
    }
    
//    self.roundLab.number = messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : !messageModel.readState;
    
    _voiceCountLabel.text = [NSString stringWithFormat:@"%ld″", messageModel.voiceSeconds];
    NSDictionary*attrs=@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.0]};
    CGSize size = [_voiceCountLabel.text sizeWithAttributes:attrs];
    _voiceCountLabel.size = size;
    
    CGFloat voiceImageW = (messageModel.voiceSeconds - 1) * 5 + 30;
    voiceImageW = voiceImageW > ([UIScreen mainScreen].bounds.size.width * 0.5 - 100) ? ([UIScreen mainScreen].bounds.size.width * 0.5 - 100) : voiceImageW;
    CGSize img_size = CGSizeMake(voiceImageW, size.height+10);
    _voiceImgV.size = img_size;
    _voiceStateBtn.size = CGSizeMake(30, 30);
}


- (UILabel *)voiceCountLabel
{
    if (!_voiceCountLabel) {
        _voiceCountLabel = [[UILabel alloc] init];
        _voiceCountLabel.font = [UIFont systemFontOfSize:16.0 weight:(UIFontWeightMedium)];
        _voiceCountLabel.textColor = [UIColor whiteColor];
    }
    
    return _voiceCountLabel;
}

- (UIView *)voiceImgV
{
    if (!_voiceImgV) {
        _voiceImgV = [[UIView alloc] init];
    }
    return _voiceImgV;
}

- (UIButton *)voiceStateBtn
{
    if (!_voiceStateBtn) {
        _voiceStateBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePlay"] forState:(UIControlStateNormal)];
        [_voiceStateBtn addTarget:self action:@selector(clickToPlayOrPauseVoiceAction:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _voiceStateBtn;
}

- (UILabel *)roundLab
{
    if (_roundLab == nil) {
        _roundLab = [UILabel new];
//        _roundLab.type = CPRoundLabType_Point;
    }
    return _roundLab;
}

- (void)clickToPlayOrPauseVoiceAction:(UIButton *)sender
{
    //存在
 
    if ([[NSFileManager defaultManager] fileExistsAtPath:[WYIMFileManager.shareManager.voicesDirectorPath stringByAppendingPathComponent:self.messageModel.voicePath]] &&
        self.messageModel.voicePath != nil) {
        [self clickPlayAudio];
    }
    //不存在
    else {
        self.messageModel.voicePath = nil;
        @weakify(self)
        [self.messageModel downVoiceCompleteHandle:^{
            @strongify(self)
            NSLog(@"下载完成");
            [self clickPlayAudio];
            if (self.cpDelegate && [self.cpDelegate respondsToSelector:@selector(messageCell:updateMessageModel:)]) {
                [self.cpDelegate messageCell:self updateMessageModel:self.messageModel];
            }
        }];
    }
}

- (void)clickPlayAudio{
    //正在播放
    if (self.messageModel.isPlay)
    {
        if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf)
        {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePlay"] forState:(UIControlStateNormal)];
        }
        else
        {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePlay_other"] forState:(UIControlStateNormal)];
        }
        //暂停
        if (self.tap_avatarBlock) {
            self.tap_avatarBlock(CellOfClickAreaTypePauseVoice);
        }
    }
    //未播放
    else
    {
        if (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf)
        {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePause"] forState:(UIControlStateNormal)];
        }
        else
        {
            [_voiceStateBtn setImage:[UIImage imageNamed:@"voicePause_other"] forState:(UIControlStateNormal)];
        }
        //开启播放
        if (self.tap_avatarBlock) {
            self.tap_avatarBlock(CellOfClickAreaTypePlayVoice);
        }
    }
}

@end
