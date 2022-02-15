//
//  BaseCollectionViewCell.m
//  Mac
//
//  Created by Mac on 2017/10/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import "BaseCollectionViewCell.h"
 
@interface BaseCollectionViewCell ()

@property (nonatomic , assign) BOOL isAddAllLine;


@end


@implementation BaseCollectionViewCell

#pragma mark - Life
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.contentView addSubview:self.textLab];
        self.textLab.sd_layout.spaceToSuperView(UIEdgeInsetsZero);
        
        [self.contentView addSubview:self.bigBaseImageView];
        [self.contentView addSubview:self.baseImageView];
        [self.contentView addSubview:self.baseTitleLab];
        
        self.bigBaseImageView.sd_layout
        .spaceToSuperView(UIEdgeInsetsZero);
        
        self.baseImageView.sd_layout
        .centerXEqualToView(self.contentView)
        .centerYEqualToView(self.contentView).offset(-SWAuto(10))
        .widthIs(SWAuto(SWAuto(35)))
        .heightEqualToWidth();
        
        self.baseTitleLab.sd_layout
        .leftEqualToView(self.contentView)
        .rightEqualToView(self.contentView)
        .topSpaceToView(self.baseImageView, SWAuto(4))
        .autoHeightRatio(0);
        
    }
    return self;
}

- (void)addLineColor:(UIColor *)color
{
    if (!self.isAddAllLine)
    {
        self.isAddAllLine = YES;
//        [self addBottomLineWithOffset:0 color:color];
//        [self addTopLineWithOffset:0 color:color];
//        [self addLeftLineWithOffset:0 color:color];
//        [self addRightLineWithOffset:0 color:color];
    }
}

+(NSString *)identifier{
    return NSStringFromClass(self);
}

#pragma mark - get
- (UILabel *)textLab{
    if (_textLab == nil)
    {
        _textLab = [UILabel new];
    }
    return _textLab;
}

-(UIImageView *)baseImageView
{
    if (_baseImageView == nil)
    {
        _baseImageView = [UIImageView new];
        _baseImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _baseImageView;
}

- (UIImageView *)bigBaseImageView
{
    if (_bigBaseImageView == nil)
    {
        _bigBaseImageView = [UIImageView new];
        _bigBaseImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bigBaseImageView.clipsToBounds = YES;
    }
    return _bigBaseImageView;
}

-(UILabel *)baseTitleLab
{
    if (_baseTitleLab == nil)
    {
        _baseTitleLab = [UILabel new];
        _baseTitleLab.textColor = SWColor(@"000000");
        _baseTitleLab.font = SWFont_Regular(12);
        _baseTitleLab.textAlignment = NSTextAlignmentCenter;
    }
    return _baseTitleLab;
}

@end

