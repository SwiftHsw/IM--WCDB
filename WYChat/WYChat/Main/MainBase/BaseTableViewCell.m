//
//  BaseTableViewCell.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupBingdingForBase];
    }
    return self;
}

- (void)setupBingdingForBase
{
    @weakify(self)
    [RACObserve(self, accessoryType) subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
        {
            [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[UIButton class]])
                {
                    UIButton *btn = (UIButton *)obj;
                    [btn setBackgroundImage:kImageName(@"to_promote_list_more") forState:UIControlStateNormal];
                }
            }];
        }
    }];
}

+(NSString *)identifier{
    return NSStringFromClass(self);
}



@end
