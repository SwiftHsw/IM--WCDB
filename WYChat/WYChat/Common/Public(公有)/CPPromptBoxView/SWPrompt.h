//
//  SWPrompt.h
//  测试
//
//  Created by WYChat on 2021/7/21.
//  Copyright © 2021年 黄世文. All rights reserved.
//


/*
 
 //配置属性
 SWPromptBoxOption *option = [SWPromptBoxOption promptBoxOptionWithClipView:sender];
 
 //初始化
 SWPromptBoxView *PromptBoxView = [SWPromptBoxView promptBoxViewWithOption:option];
 
 //添加数据
 [PromptBoxView addTitles:@[@"nihao",@"ceshi"] images:nil didSelector:^(NSIndexPath *indexPath) {
 //点击回调
 NSLog(@"%@",indexPath);
 
 } cancleSelector:^{
 //取消回调
 NSLog(@">>>>>>");
 
 }];
 
 //显示
 [PromptBoxView showPrompt];
 
 */

#ifndef SWPrompt_h
#define SWPrompt_h

//点击回调
typedef void(^SWPromptBoxClipBlock)(NSIndexPath *indexPath);
//取消回调
typedef void(^SWPromptBoxCancleBlock)(void);

#import <UIKit/UIKit.h>
#import "SWPromptBoxOption.h"
#import "SWPromptBoxView.h"
#import "SWPromptBox.h"


#define SWPBScreenWidth               [UIScreen mainScreen].bounds.size.width
#define SWPBScreenHeight              [UIScreen mainScreen].bounds.size.height
#define SWPBHeight                    40 //cell默认高度
#define SWPBAnimation_appear          @[@0,@1.2,@1]
#define SWPBAnimation_disappear       @[@1,@1.2,@0]
#define SWPBImage(x)                  [UIImage imageNamed:(x)]



#endif /* SWPrompt_h */
