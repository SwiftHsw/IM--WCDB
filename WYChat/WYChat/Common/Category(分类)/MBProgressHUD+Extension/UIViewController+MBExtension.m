//
//  UIViewController+MBExtension.m
//  SSZS
//
//  Created by WYDM on 2018/9/30.
//  Copyright © 2018年 WYDM All rights reserved.
//

#import "UIViewController+MBExtension.h"
#import <Messages/Messages.h>

@interface UIViewController ()

@property (nonatomic , strong , readwrite) MBProgressHUD *progressHUD;

@end

@implementation UIViewController (MBExtension)

#pragma mark - set
- (void)setProgressHUD:(MBProgressHUD *)progressHUD
{
    objc_setAssociatedObject(self, @selector(progressHUD), progressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - get
- (MBProgressHUD *)progressHUD
{
    if (objc_getAssociatedObject(self, _cmd) == nil)
    {
        UIView *view = KeyWindow;
        UIViewController *vc = [UIView getCurrentVC];
        if (vc.navigationController)
        {
            view = vc.navigationController.view;
        }
        self.progressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
//        self.progressHUD.activityItemsConfiguration = [UIColor whiteColor];
        self.progressHUD.removeFromSuperViewOnHide = NO;
        return self.progressHUD;
    }
    else
    {
        return objc_getAssociatedObject(self, _cmd);
    }
    
}


@end
