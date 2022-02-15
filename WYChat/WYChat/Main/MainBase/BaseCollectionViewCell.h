//
//  BaseCollectionViewCell.h
//  Mac
//
//  Created by Mac on 2017/10/13.
//  Copyright © 2017年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseCollectionViewCell : UICollectionViewCell

/**
 图片（不和textLab共用）
 */
@property (nonatomic , strong) UIImageView *baseImageView;

/**
 图片标题（不和textLab共用）
 */
@property (nonatomic , strong) UILabel *baseTitleLab;

/**
 文字（不和imageView/titlelab共用）
 */
@property (nonatomic , strong) UILabel *textLab;

/**
 大图片
 */
@property (nonatomic , strong) UIImageView *bigBaseImageView;

/**
 添加线
 */
- (void)addLineColor:(UIColor *)color;


+(NSString *)identifier;



@end
