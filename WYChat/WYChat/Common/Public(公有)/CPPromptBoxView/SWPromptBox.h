//
//  CPPromptBox.h
//  测试
//
//  Created by WYChat on 2021/7/21.
//  Copyright © 2021年 黄世文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPrompt.h"

@protocol SWPromptBoxDelegate <NSObject>

-(void)promptBoxSelector:(SWPromptBoxClipBlock)clipblock indexPath:(NSIndexPath *)indexPath;

@end

@interface SWPromptBox : UIView
@property (nonatomic , strong) SWPromptBoxOption        *option;
@property (nonatomic , strong) NSMutableArray           *titles;
@property (nonatomic , strong) NSMutableArray           *images;
@property (nonatomic , strong) SWPromptBoxClipBlock     block;
@property (nonatomic , assign) id<SWPromptBoxDelegate>  promitBoxDeleget;

+ (instancetype)promtBoxWithOption:(SWPromptBoxOption *)option;
- (instancetype)initWithPromtBoxOption:(SWPromptBoxOption *)option;
- (void)refreshPromitBoxView;
- (void)promitBoxRemoveFromSuperViewWithValues:(NSArray *)values isDelegate:(BOOL)isDelegate;
@end
