//
//  WYIMConversationViewModel.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/27.
//

#import <Foundation/Foundation.h>
#import "WYConversationViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WYIMConversationViewModel : NSObject
@property (nonatomic,assign) WYConversationViewController *viewController;

@property (nonatomic,strong) UITableView *tableView;


//初始化ui

- (void)setupInitForWYIMConversationViewModel;

@end

NS_ASSUME_NONNULL_END
