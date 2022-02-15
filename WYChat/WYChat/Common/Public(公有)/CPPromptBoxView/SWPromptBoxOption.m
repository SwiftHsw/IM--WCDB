//
//  CPPromptBoxOption.m
//  测试
//
//  Created by WYChat on 2021/7/21.
//  Copyright © 2021年 黄世文. All rights reserved.
//

#import "SWPromptBoxOption.h"


@implementation SWPromptBoxOption

+ (instancetype)promptBoxOptionWithClipView:(UIView *)clipView{
    return [[self alloc] initWithClipView:clipView];
}

- (instancetype)initWithClipView:(UIView *)clipView{
    self = [super init];
    if (self) {
        self.clipView = clipView;
        [self initData];
    }
    return self;
}

- (void)initData{
    self.textFont = [UIFont systemFontOfSize:15];
    self.space_For_LeftOrRight = 10;
    self.topSpacing = 0;
    self.distance_Y = SWPBScreenHeight * .5;
    self.radiu = 5;
    self.triangleHeight = 10;
    self.triangleBottomWidth = 10;
    self.width = 120;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    self.textColor = [UIColor whiteColor];
    self.textAlignment = NSTextAlignmentLeft;
    self.separatorEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.separatorColor = [UIColor whiteColor];
    self.isShowAnimation = YES;
    self.selectorTextColor = [UIColor orangeColor];
}

@end
