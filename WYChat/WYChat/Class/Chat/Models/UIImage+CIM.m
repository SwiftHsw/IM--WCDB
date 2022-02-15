//
//  UIImage+CIM.m
//  ChatIM
//
//  Created by Mac on 2020/8/13.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "UIImage+CIM.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImage (CIM)

+ (UIImage *)createImageWithString:(NSString *)charStr
{
    return [self createImageWithString:charStr size:CGSizeMake(50, 50)];
}

+ (UIImage *)createImageWithString:(NSString *)charStr size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:rect];
    lab.font = SWFont_Bold(size.height * 0.5);
    lab.textColor = UIColor.whiteColor;
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = [charStr substringWithRange:NSMakeRange(0, charStr.length >= 1 ? 1 : 0)];
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, UIScreen.mainScreen.scale);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [SWMainColor set];
    [path fill];
    
    [lab drawTextInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;;
}

//截取封面
+ (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;

    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];

    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;

}

+ (UIImage*) maskImage:(UIImage *)image withMask:(UIImage *)maskImage
{

    CGImageRef maskRef = maskImage.CGImage;

    CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
        CGImageGetHeight(maskRef),
        CGImageGetBitsPerComponent(maskRef),
        CGImageGetBitsPerPixel(maskRef),
        CGImageGetBytesPerRow(maskRef),
        CGImageGetDataProvider(maskRef), NULL, false);

    CGImageRef masked = CGImageCreateWithMask([image CGImage], mask);
    return [UIImage imageWithCGImage:masked];

}

+(UIImage *)cpGetQrCodeImageWithInfo:(NSString *)info isTransparent:(BOOL)isTransparent width:(CGFloat)width_size height:(CGFloat)height_size{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSString *dataString = info;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    CIImage *outputImage = [filter outputImage];
    UIImage *image = [UIImage createNonInterpolatedUIImageFormCIImage:outputImage width:width_size height:height_size];
    if (isTransparent == YES)
        {
        image = [UIImage imageToTransparent:image];
    }
    return image;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image width:(CGFloat)width_size height:(CGFloat)height_size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(width_size/CGRectGetWidth(extent), height_size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

+ (UIImage*) imageToTransparent:(UIImage*) image
{
    
    // 分配内存
    
    const int imageWidth = image.size.width;
    
    const int imageHeight = image.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    
    
    // 创建context
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    
    
    
    // 遍历像素
    
    int pixelNum = imageWidth * imageHeight;
    
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
        
    {
        
        //        //去除白色...将0xFFFFFF00换成其它颜色也可以替换其他颜色。
        
        //        if ((*pCurPtr & 0xFFFFFF00) >= 0xffffff00){
        
        //
        
        //            uint8_t* ptr = (uint8_t*)pCurPtr;
        
        //            ptr[0] = 0;
        
        //        }
        
        //接近白色
        
        //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:R,ptr[2]:G,ptr[3]:B
        
        //分别取出RGB值后。进行判断需不需要设成透明。
        
        uint8_t* ptr = (uint8_t*)pCurPtr;
        
        if (ptr[1] > 240 && ptr[2] > 240 && ptr[3] > 240)
        {
            
            //当RGB值都大于240则比较接近白色的都将透明度设为0.-----即接近白色的都设置为透明。某些白色背景具有杂质就会去不干净，用这个方法可以去干净
            
            ptr[0] = 0;
            
        }
        
    }
    
    // 将内存转成image
    
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, nil);
    
    
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,
                                        
                                        kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,
                                        
                                        NULL, true,kCGRenderingIntentDefault);
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    
    CGImageRelease(imageRef);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    return resultUIImage;
    
}

+ (UIImage *)fixOrientation:(UIImage *)srcImg {
if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
CGAffineTransform transform = CGAffineTransformIdentity;
switch (srcImg.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
        
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
        
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    case UIImageOrientationUp:
    case UIImageOrientationUpMirrored:
        break;
}

switch (srcImg.imageOrientation) {
    case UIImageOrientationUpMirrored:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
        
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
        transform = CGAffineTransformScale(transform, -1, 1);
        break;
    case UIImageOrientationUp:
    case UIImageOrientationDown:
    case UIImageOrientationLeft:
    case UIImageOrientationRight:
        break;
}

CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                         CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                         CGImageGetColorSpace(srcImg.CGImage),
                                         CGImageGetBitmapInfo(srcImg.CGImage));
CGContextConcatCTM(ctx, transform);
switch (srcImg.imageOrientation) {
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
        break;
        
    default:
        CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
        break;
}

CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
UIImage *img = [UIImage imageWithCGImage:cgimg];
CGContextRelease(ctx);
CGImageRelease(cgimg);
return img;
}


+ (UIImage *)fileImageWithString:(NSString *)string
{
    NSString *imageName = @"未知文件";
    string = [string lowercaseString];
    if ([string hasSuffix:@"gif"]) {
        imageName = @"GIF";
    }
    else if ([string hasSuffix:@"html"]) {
        imageName = @"html";
    }
    else if ([string hasSuffix:@"jpg"] ||
             [string hasSuffix:@"jpeg"]) {
        imageName = @"jpg";
    }
    else if ([string hasSuffix:@"mp3"] ||
             [string hasSuffix:@"wav"] ||
             [string hasSuffix:@"midi"] ||
             [string hasSuffix:@"amr"]) {
        
        imageName = @"mp3";
    }
    else if ([string hasSuffix:@"avi"] ||
             [string hasSuffix:@"mov"] ||
             [string hasSuffix:@"rmvb"] ||
             [string hasSuffix:@"rm"] ||
             [string hasSuffix:@"flv"] ||
             [string hasSuffix:@"mp4"] ||
             [string hasSuffix:@"3gp"] ||
             [string hasSuffix:@"mpeg"] ||
             [string hasSuffix:@"navi"] ||
             [string hasSuffix:@"asf"] ||
             [string hasSuffix:@"wmv"]) {
        imageName = @"mp4";
    }
    else if ([string hasSuffix:@"pdf"]) {
        imageName = @"pdf";
    }
    else if ([string hasSuffix:@"png"]) {
        imageName = @"png";
    }
    else if ([string hasSuffix:@"ppt"] ||
             [string hasSuffix:@"pptx"]) {
        imageName = @"ppt";
    }
    else if ([string hasSuffix:@"psd"]) {
        imageName = @"psd";
    }
    else if ([string hasSuffix:@"rar"] ||
             [string hasSuffix:@"zip"] ||
             [string hasSuffix:@"jar"]) {
        imageName = @"rar";
    }
    else if ([string hasSuffix:@"svg"]) {
        imageName = @"svg";
    }
    else if ([string hasSuffix:@"ttx"]) {
        imageName = @"ttx";
    }
    else if ([string hasSuffix:@"txt"]) {
        imageName = @"txt";
    }
    else if ([string hasSuffix:@"word"] ||
             [string hasSuffix:@"doc"] ||
             [string hasSuffix:@"docx"]) {
        imageName = @"word";
    }
    else if ([string hasSuffix:@"xls"]) {
        imageName = @"xls";
    }
    else if ([string hasSuffix:@"zip"]) {
        imageName = @"zip";
    }
    UIImage *img = [UIImage imageNamed:kStringIsEmpty(imageName) ? @"weixindenglu" : imageName];
    if (img) {
        return  img;
    }
    return kImageName(@"weixindenglu");
}

@end
