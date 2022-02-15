//
//  WYIMConversationCell.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/27.
//

#import "BaseTableViewCell.h"
#import "WYIMConversationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WYIMConversationCell : BaseTableViewCell

@property (nonatomic,strong) WYIMConversationModel *conversation;

@end

NS_ASSUME_NONNULL_END
