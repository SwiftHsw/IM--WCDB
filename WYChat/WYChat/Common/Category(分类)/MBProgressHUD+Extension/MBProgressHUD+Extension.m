//
//  MBProgressHUD+Extension.m
//  YXMeiPo
//
//  Created by WYDM on 2018/5/26.
//  Copyright © 2018年 WYDM. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

#define MBProgressHUD_Secound 2

@implementation MBProgressHUD (Extension)

+ (MBProgressHUD *)createHUD:(MBProgressHUDMode)model
                        text:(NSString *)text
               completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIView getCurrentVC].view animated:YES];
    hud.mode = model;
    hud.removeFromSuperViewOnHide = YES;
    hud.completionBlock = ^{
        if (complete) complete();
    };
    hud.label.numberOfLines = 0;
    hud.label.text = [NSString stringWithFormat:@"%@",text];
    hud.label.textColor = [UIColor whiteColor];
    //修改样式，否则等待框背景色将为半透明
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    if (model == MBProgressHUDModeIndeterminate)
    {
//        hud.activityIndicatorColor = [UIColor whiteColor];
    }
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:MBProgressHUD_Secound];
    return hud;
}

+ (UIImageView *)createImageView:(UIImage *)image
{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SWAuto(50), SWAuto(50))];
    imageV.contentMode = UIViewContentModeScaleAspectFit;
    imageV.image = image;
    return imageV;
}

+(void)showTextHUD:(NSString *)text
     completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [self createHUD:MBProgressHUDModeText
                                    text:text
                           completeBlock:complete];
}

+(void)showStatusHUD:(NSString *)statusStr
       completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [self createHUD:MBProgressHUDModeIndeterminate
                                    text:statusStr
                           completeBlock:complete];
}

+(void)showSuccessHUD:(NSString *)successStr
        completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [self createHUD:MBProgressHUDModeCustomView
                                    text:successStr
                           completeBlock:complete];
    hud.customView = [self createImageView:kImageName(@"成功")];
    hud.label.textColor = [UIColor whiteColor];
}

+(void)showInfoHUD:(NSString *)InfoStr
     completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [self createHUD:MBProgressHUDModeCustomView
                                    text:InfoStr
                           completeBlock:complete];
    hud.customView = [self createImageView:kImageName(@"提示")];
    hud.label.textColor = [UIColor whiteColor];
}

+(void)showErrorHUD:(NSString *)errorStr
      completeBlock:(MBBaseBlock)complete
{
    MBProgressHUD *hud = [self createHUD:MBProgressHUDModeCustomView
                                    text:errorStr
                           completeBlock:complete];
    hud.customView = [self createImageView:kImageName(@"错误")];
    hud.label.textColor = [UIColor whiteColor];
}

- (void)showHUD
{
    [self showAnimated:YES];
}

- (void)dissmissHUD
{
    [self hideAnimated:YES];
}

@end
