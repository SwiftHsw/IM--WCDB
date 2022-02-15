//
//  MBProgressHUD+Extension.h
//  YXMeiPo
//
//  Created by WYDM on 2018/5/26.
//  Copyright © 2018年 WYDM. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "UIViewController+MBExtension.h"

typedef void(^MBBaseBlock)(void);

@interface MBProgressHUD (Extension)

+ (void)showTextHUD:(NSString *)text completeBlock:(MBBaseBlock)complete;

+ (void)showStatusHUD:(NSString *)statusStr completeBlock:(MBBaseBlock)complete;

+ (void)showSuccessHUD:(NSString *)successStr completeBlock:(MBBaseBlock)complete;

+  (void)showInfoHUD:(NSString *)InfoStr completeBlock:(MBBaseBlock)complete;

+ (void)showErrorHUD:(NSString *)errorStr completeBlock:(MBBaseBlock)complete;

- (void)showHUD;

- (void)dissmissHUD;


@end
