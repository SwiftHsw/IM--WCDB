//
//  CPTableView.h
//  绘制-tableView
//
//  Created by lk06 on 17/1/13.
//  Copyright © 2017年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWPrompt.h"

@class SWPromptBoxOption;

@interface SWPromptBoxView : UIView

/**初始化*/
+ (instancetype)promptBoxViewWithOption:(SWPromptBoxOption *)manager;

/**添加数据*/
- (void)addTitles:(NSArray *)titles
           images:(NSArray *)images
      didSelector:(SWPromptBoxClipBlock)block
   cancleSelector:(SWPromptBoxCancleBlock)cancle;

/**显示*/
- (void)showPrompt;

@end

@interface UITableViewCell (CPPromptBoxIdentifier)
+(NSString *)identifier;
@end



