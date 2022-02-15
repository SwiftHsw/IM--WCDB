//
//  UIImage+CIM.h
//  ChatIM
//
//  Created by Mac on 2020/8/13.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CIM)

/// 根据文字创建图片
/// @param charStr 文字
+ (UIImage *)createImageWithString:(NSString *)charStr;

/// 根据文字创建图片
/// @param charStr 文字
/// @param size 大小
+ (UIImage *)createImageWithString:(NSString *)charStr size:(CGSize)size;

/// 视频封面截取
/// @param videoURL 本地视频地址
/// @param time 视频的某个时间
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

+ (UIImage*)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

/// 字符串转二维码
/// @param info 字符串内容
/// @param isTransparent 是否去除白色像素
/// @param width_size 大小
+(UIImage *)cpGetQrCodeImageWithInfo:(NSString *)info isTransparent:(BOOL)isTransparent width:(CGFloat)width_size height:(CGFloat)height_size;

/// 矫正图片
+ (UIImage *)fixOrientation:(UIImage *)srcImg;

/// 根据字符串结尾找到对应图片
+ (UIImage *)fileImageWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
