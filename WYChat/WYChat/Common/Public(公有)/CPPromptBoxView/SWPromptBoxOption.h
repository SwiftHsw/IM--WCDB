//
//  CPPromptBoxOption.h
//  测试
//
//  Created by WYChat on 2021/7/21.
//  Copyright © 2021年 黄世文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWPrompt.h"

@interface SWPromptBoxOption : NSObject

/**圆角半径*/
@property (nonatomic , assign) CGFloat              radiu;
/**三角形高度*/
@property (nonatomic , assign) CGFloat              triangleHeight;
/**三角形底部宽度*/
@property (nonatomic , assign) CGFloat              triangleBottomWidth;

/**框背景颜色*/
@property (nonatomic , strong) UIColor              *backgroundColor;
/**文本颜色*/
@property (nonatomic , strong) UIColor              *textColor;
/**文本位置*/
@property (nonatomic , assign) NSTextAlignment      textAlignment;
/**文本大小*/
@property (nonatomic , strong) UIFont               *textFont;

/**线的间距*/
@property (nonatomic , assign) UIEdgeInsets         separatorEdgeInsets;

/**线的颜色*/
@property (nonatomic , strong) UIColor              *separatorColor;
/**视图宽度*/
@property (nonatomic , assign) CGFloat              width;
/**提示框超过Y超过多少改变方向*/
@property (nonatomic , assign) CGFloat              distance_Y;

/**被点击的视图*/
@property (nonatomic , strong) UIView               *clipView;

/**顶点与点击视图的距离*/
@property (nonatomic , assign) CGFloat              topSpacing;
/**两边与屏幕的间距*/
@property (nonatomic , assign) CGFloat              space_For_LeftOrRight;

/**是否有默认点击选择cell*/
@property (nonatomic , assign) BOOL                 isHaveSelectorCell;
/**默认选择第几个*/
@property (nonatomic , assign) NSInteger            selectorIndex;
/**选中颜色*/
@property (nonatomic , strong) UIColor              *selectorTextColor;

/**覆盖背景颜色*/
@property (nonatomic , strong) UIColor              *coverViewBackgroundColor;

/**显示动画*/
@property (nonatomic , assign) BOOL                 isShowAnimation;

/**初始化方法*/
+ (instancetype)promptBoxOptionWithClipView:(UIView *)clipView;

@end
