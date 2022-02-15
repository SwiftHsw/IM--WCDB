//
//  UIViewController+MBExtension.h
//  SSZS
//
//  Created by WYDM on 2018/9/30.
//  Copyright © 2018年 WYDM All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIViewController (MBExtension)

@property (nonatomic , strong , readonly) MBProgressHUD *progressHUD;
 
@end
