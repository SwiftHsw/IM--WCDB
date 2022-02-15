//
//  CIMFileMessageCell.m
//  ChatIM
//
//  Created by Mac on 2020/11/16.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "CIMFileMessageCell.h"
#import "CIMDownProgressView.h"

@interface CIMFileMessageCell ()
@property (nonatomic, strong) UIView *containV;
@property (nonatomic, strong) UILabel *desL;
@property (nonatomic , strong) RACDisposable *statusDis;
@property (nonatomic , strong) CIMDownProgressView *downProgressView;
@end

@implementation CIMFileMessageCell

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
       [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.containV.width + 20, 90)];
   }
   //别人发的
   else{
       float x = self.avatarImageView.right + 5;
       [self.containV setOrigin:CGPointMake(x, y)];
       y = self.avatarImageView.y + (self.conversationType == CIMConversationType_Single ? 0 : (self.messageModel.ownerTyper == ZXMessageOwnerTypeSelf ? 0 : 15));
       [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.containV.width + 20, 90)];
   }
   
    self.card_nameL.width = self.containV.width - self.card_nameL.x;
   
}

- (void)setMessageModel:(ZXMessageModel *)messageModel
{
   [super setMessageModel:messageModel];
   
    if (self.statusDis) {
        [self.statusDis dispose];
        self.statusDis = nil;
    }
    
    ZXMessageModel *currentDownMessageModel = messageModel;
//    ZXMessageModel *downM = [CIMDownMessageFileTool currentDownMessageModelWithMessageId:messageModel.messageId];
//    if (downM) {
//        currentDownMessageModel = downM;
//    }
    
    
    WeakSelf(self)
    self.statusDis = [[RACObserve(currentDownMessageModel, downProgress) merge:RACObserve(currentDownMessageModel, downStatus)] subscribeNext:^(id  _Nullable x) {
        StrongSelf(self)
        self.downProgressView.hidden = YES;
        self.downProgressView.progress = currentDownMessageModel.downProgress;
        if (currentDownMessageModel.downStatus == ZXMessageFileDownStatus_Downning) {
            self.downProgressView.hidden = NO;
        }
    }];
    
    self.card_avatarImgV.image = [UIImage fileImageWithString:messageModel.fileName];
    self.card_nameL.text = messageModel.fileName;
    self.desL.text = [NSString fileSizeForSize:messageModel.fileSize];
}

- (UIView *)containV
{
   if (!_containV) {
       _containV = [[UIView alloc] init];
       _containV.frame = CGRectMake(20, 20, 238, 64);
       [_containV addSubview:self.card_avatarImgV];
       [_containV addSubview:self.card_nameL];
       [_containV addSubview:self.desL];
       _containV.backgroundColor = UIColor.clearColor;
       UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNameCardAction)];
       tap.delegate = self;
       [_containV addGestureRecognizer:tap];
   }
   return _containV;
}


- (void)tapNameCardAction
{
   if (self.tap_avatarBlock) {
       //存在
       if ([NSFileManager.defaultManager fileExistsAtPath:[WYIMFileManager.shareManager.fileDirectorPath stringByAppendingPathComponent:self.messageModel.fileName]]) {
           self.tap_avatarBlock(CellOfClickAreaTypeFile);
       }
       //不存在，就下载
       else {
           
           ZXMessageModel *currentDownMessageModel = self.messageModel;
//           ZXMessageModel *downM = [CIMDownMessageFileTool currentDownMessageModelWithMessageId:self.messageModel.messageId];
//           if (downM) {
//               currentDownMessageModel = downM;
//           }
           
           //不处于正在下载就开启下载
           if (currentDownMessageModel.downStatus != ZXMessageFileDownStatus_Downning) {
//               [CIMDownMessageFileTool downMesssageFile:@[currentDownMessageModel]];
           }
           else
           {
//               [CIMDownMessageFileTool stopDownMesssageFile:@[currentDownMessageModel]];
               self.tap_avatarBlock(CellOfClickAreaTypeReLoadCurrentCell);
           }
       }
   }
}

- (UIImageView *)card_avatarImgV
{
   if (!_card_avatarImgV) {
       _card_avatarImgV = [[UIImageView alloc] init];
       _card_avatarImgV.frame = CGRectMake(15, 10, 44, 44);
       _card_avatarImgV.layer.cornerRadius = 22;
       
       [_card_avatarImgV addSubview:self.downProgressView];
       self.downProgressView.sd_layout
       .spaceToSuperView(UIEdgeInsetsZero);
   }
   return _card_avatarImgV;
}

- (UILabel *)card_nameL
{
   if (!_card_nameL) {
       _card_nameL = [[UILabel alloc] init];
       _card_nameL.textColor = [UIColor colorWithHexString:@"#2A2A2A"];
       _card_nameL.font = SWFont_Medium(16);
       _card_nameL.frame = CGRectMake(CGRectGetMaxX(_card_avatarImgV.frame) + 10, CGRectGetMinY(_card_avatarImgV.frame), 100, 20);
       _card_nameL.numberOfLines = 0;
       _card_nameL.lineBreakMode = NSLineBreakByTruncatingMiddle;
   }
   
   return _card_nameL;;
}

- (UILabel *)desL
{
   if (!_desL) {
       _desL = [[UILabel alloc] init];
       _desL.textColor = [UIColor colorWithHexString:@"#B1B1B1"];
       _desL.font = SWFont_Regular(14);
       _desL.frame = CGRectMake(CGRectGetMaxX(_card_avatarImgV.frame) + 10, CGRectGetMidY(_card_avatarImgV.frame) + 9, 100, 15);
   }
   return _desL;
}

- (CIMDownProgressView *)downProgressView
{
    if (_downProgressView == nil) {
        _downProgressView = [CIMDownProgressView downProgressViewWithCenterRadiu:15];
    }
    return _downProgressView;
}

@end
