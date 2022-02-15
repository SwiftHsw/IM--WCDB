//
//  WYIMConversationCell.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/27.
//

#import "WYIMConversationCell.h"
 

@interface WYIMConversationCell ()
@property (nonatomic , strong) UIImageView *groupHeadImageView;    //群聊头像
@property (nonatomic , strong) UIImageView *singleHeadImageView;   //单聊头像
@property (nonatomic , strong) UILabel *titleLab;
@property (nonatomic , strong) YYLabel *subTitleLab;
@property (nonatomic , strong) UILabel *timeLab;
//@property (nonatomic , strong) SWRoundLab *roundLab;
@property (nonatomic , strong) UIImageView *isTopImageView;
@property (nonatomic , strong) UILabel *stateLab;
@end

@implementation WYIMConversationCell

#pragma mark - set
- (void)setConversation:(WYIMConversationModel *)conversation
{
    _conversation = conversation;
//    self.singleHeadImageView.headImageView.image = [UIImage new];
//    self.groupHeadImageView.groupModel = nil;
    
    self.singleHeadImageView.backgroundColor = UIColor.redColor;
    self.titleLab.text = conversation.conversationId;
    self.timeLab.text = conversation.dateString;
//    self.roundLab.number = conversation.recordNum;
    self.isTopImageView.hidden = !conversation.isBeTop;
    
    self.stateLab.hidden = conversation.knewMessageModel.sendState == ZXMessageSendFail ? NO : YES;
    self.subTitleLab.sd_layout
    .leftSpaceToView(conversation.knewMessageModel.sendState == ZXMessageSendFail ? self.stateLab : self.singleHeadImageView, 10);
    [self.subTitleLab updateLayout];
    
    
    @weakify(self)
    [conversation getLastString:^(NSAttributedString * _Nonnull lastString) {
        @strongify(self)
        NSMutableAttributedString * last = (NSMutableAttributedString *)lastString;
        self.subTitleLab.attributedText = [NSString textToEmojiText:last];
    }];

    self.groupHeadImageView.hidden = conversation.conversationType == CIMConversationType_Single ? YES : NO;
    self.singleHeadImageView.hidden = conversation.conversationType == CIMConversationType_Single ? NO : YES;
    
    //单聊
//    if (conversation.conversationType == CIMConversationType_Single)
//    {
//        [conversation getAddressBookFriendModelForConversation:^(CIMAddressBookFriendModel * _Nullable model, CIMConversationModel * _Nonnull conversation) {
//            if (model != nil) {
//                kStrongObject(self)
//                self.titleLab.text = model.name;
//                [self.singleHeadImageView.headImageView setImageWithURL:CIMRequstUrl(model.imgHead) placeholder:[UIImage createImageWithString:model.nickName] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
//                self.singleHeadImageView.isCustomer = model.memberType == 2;
//            }
//        }];
//    }
//    //群聊
//    else
//    {
//        [conversation getGroupInfoForConversation:^(CIMGroupInfoModel * _Nullable model, CIMConversationModel * _Nonnull conversation) {
//            kStrongObject(self)
//            //非成员
//            if (model.isNotGroupMembers) {
//                self.titleLab.text = model.groupName.length != 0 ? model.groupName : [SWKitManager.shareManager.userInfoModel nickName];
//                @try {
//                    CIMUserInfoModel *userInfoModel = SWKitManager.shareManager.userInfoModel;
//                    model.headMemberList = @[[CIMAddressBookFriendModel newModelWithNickname:userInfoModel.nickName]];
//                    self.groupHeadImageView.groupModel = model;
//                } @catch (NSException *exception) {
//
//                } @finally {
//
//                }
//            }
//            //群成员
//            else {
//                self.titleLab.text = model.groupName;
//                self.groupHeadImageView.groupModel = model;
//            }
//        }];
//    }
    
}

#pragma mark - Life
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.whiteColor;
        [self setupInitLayoutForCIMConversationCell];
    }
    return self;
}


#pragma mark - Private
- (void)setupInitLayoutForCIMConversationCell
{
    //,self.roundLab,
    [self.contentView sd_addSubviews:@[self.groupHeadImageView,self.singleHeadImageView,self.titleLab,self.subTitleLab,self.stateLab,self.timeLab,self.isTopImageView]];
    
    self.groupHeadImageView.sd_layout
    .centerYEqualToView(self.contentView)
    .leftSpaceToView(self.contentView, SWAuto(15))
    .heightIs(SWAuto(45))
    .widthEqualToHeight();
    [self.groupHeadImageView updateLayout];
    
    self.singleHeadImageView.sd_layout
    .centerYEqualToView(self.contentView)
    .leftSpaceToView(self.contentView, SWAuto(15))
    .heightIs(SWAuto(45))
    .widthEqualToHeight();
    [self.singleHeadImageView updateLayout];
    
//    self.roundLab.sd_layout
//    .topEqualToView(self.singleHeadImageView).offset(-SWAuto(5))
//    .rightEqualToView(self.singleHeadImageView).offset(SWAuto(5));
//    [self.roundLab setSd_cornerRadiusFromHeightRatio:@.5];
    
    self.timeLab.sd_layout
    .topEqualToView(self.singleHeadImageView)
    .rightSpaceToView(self.contentView, 15)
    .heightRatioToView(self.singleHeadImageView, 0.5)
    .minWidthIs(SWAuto(40));
    [self.timeLab setSingleLineAutoResizeWithMaxWidth:200];
    
    self.titleLab.sd_layout
    .topEqualToView(self.singleHeadImageView)
    .leftSpaceToView(self.singleHeadImageView, 10)
    .heightRatioToView(self.singleHeadImageView, 0.5)
    .rightSpaceToView(self.timeLab, SWAuto(10));
     
    self.subTitleLab.sd_layout
    .topSpaceToView(self.titleLab, 0)
    .bottomEqualToView(self.singleHeadImageView)
    .rightSpaceToView(self.contentView, 20);
    
    self.stateLab.sd_layout
    .centerYEqualToView(self.subTitleLab)
    .leftEqualToView(self.titleLab)
    .widthIs(SWAuto(20))
    .heightEqualToWidth();
    [self.stateLab setSd_cornerRadiusFromHeightRatio:@.5];
    
    self.subTitleLab.sd_layout
    .leftSpaceToView(self.singleHeadImageView, 10);
     
    self.isTopImageView.sd_layout
    .topEqualToView(self.contentView)
    .rightEqualToView(self.contentView)
    .widthIs(SWAuto(10))
    .heightEqualToWidth();
    
}
 

- (UIImageView *)groupHeadImageView
{
    if (_groupHeadImageView == nil) {
        _groupHeadImageView = [UIImageView new];
    }
    return _groupHeadImageView;;
}

- (UIImageView *)singleHeadImageView
{
    if (_singleHeadImageView == nil) {
        _singleHeadImageView = [UIImageView new];
    }
    return _singleHeadImageView;
}

- (UILabel *)titleLab
{
    if (_titleLab == nil) {
        _titleLab = [UILabel new];
        _titleLab.textColor = SWColor(@"222222");
        _titleLab.font = SWFont_Medium(16);
    }
    return _titleLab;
}

- (YYLabel *) subTitleLab
{
    if (_subTitleLab == nil) {
        _subTitleLab = [YYLabel new];
        _subTitleLab.numberOfLines = 0;
        _subTitleLab.backgroundColor = [UIColor clearColor];
        _subTitleLab.clearContentsBeforeAsynchronouslyDisplay = NO;
        _subTitleLab.textContainerInset = UIEdgeInsetsZero;
    }
    return _subTitleLab;
}

- (UILabel *)timeLab
{
    if (_timeLab == nil) {
        _timeLab = [UILabel new];
        _timeLab.textColor = SWColor(@"#B1B0B0");
        _timeLab.font = SWFont_Regular(13);
    }
    return _timeLab;
}

//- (SWRoundLab *)roundLab
//{
//    if (_roundLab == nil) {
//        _roundLab = [SWRoundLab new];
//        _roundLab.type = SWRoundLabType_Number;
//        _roundLab.layer.borderColor = UIColor.whiteColor.CGColor;
//        _roundLab.layer.borderWidth = 1;
//    }
//    return _roundLab;
//}

- (UIImageView *)isTopImageView
{
    if (_isTopImageView == nil) {
        _isTopImageView = [UIImageView new];
        _isTopImageView.contentMode = UIViewContentModeScaleAspectFit;
        _isTopImageView.image = kImageName(@"置顶");
    }
    return _isTopImageView;
}

- (UILabel *)stateLab
{
    if (_stateLab == nil) {
        _stateLab = [UILabel new];
        _stateLab.textColor = UIColor.whiteColor;
        _stateLab.font = SWFont_Bold(15);
        _stateLab.text = @"!";
        _stateLab.textAlignment = NSTextAlignmentCenter;
        _stateLab.backgroundColor = UIColor.redColor;
    }
    return _stateLab;
}

@end

