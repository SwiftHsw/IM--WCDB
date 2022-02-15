//
//  BH_ImageMessgeClickView.m
//  BaiHaiChatIMApplication
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 bh. All rights reserved.
//

#import "BH_ImageMessgeClickView.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface BH_ImageMessgeClickView ()<
UIScrollViewDelegate>
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIImageView *imageView;
@property (nonatomic , assign) CGRect rect;
@end

@implementation BH_ImageMessgeClickView

 + (instancetype)imageMessgeClickViewWithImage:(UIImage *)image rect:(CGRect)rect
 {
     BH_ImageMessgeClickView *view = [[BH_ImageMessgeClickView alloc] initWithFrame:UIScreen.mainScreen.bounds];
     view.imageView.image = image;
     view.rect = rect;
     return view;
 }

 - (instancetype)initWithFrame:(CGRect)frame
 {
     self = [super initWithFrame:frame];
     if (self) {
         self.backgroundColor = UIColor.blackColor;
         [self addSubview:self.scrollView];
         [self.scrollView addSubview:self.imageView];
         self.imageView.userInteractionEnabled = NO;
         
         UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
         [self addGestureRecognizer:tap];
         WeakSelf(self)
         [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
             StrongSelf(self)
             [self dissCoverView];
         }];
         
         UITapGestureRecognizer *twoTap = [UITapGestureRecognizer new];
         [self addGestureRecognizer:twoTap];
         twoTap.numberOfTapsRequired = 2;
         [tap requireGestureRecognizerToFail:twoTap];
         [[twoTap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
             if (self.scrollView.zoomScale != 1) {
                 [self.scrollView setZoomScale:1.0 animated:YES];
             }
             else {
                 CGPoint p = [x locationInView:self.scrollView];
                 [self.scrollView zoomToRect:CGRectMake(p.x, p.y, 1, 1) animated:YES];
             }
         }];
     }
     return self;
 }

#pragma mark - 获取比例
+(CGFloat)getScaleWithWidth:(CGFloat)width tagetWidth:(CGFloat)tagerWidth
{
    return (width / tagerWidth);
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.contentSize.width;
    CGFloat height = scrollView.contentSize.height;
    CGFloat x = (scrollView.frame.size.width - width) * .5;
    x = x < 0 ? 0 : x;
    CGFloat y = (scrollView.frame.size.height - height) * .5;
    y = y < 0 ? 0 : y;
    self.imageView.frame = CGRectMake(x, y, width, height);
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

 - (void)showCoverView
 {
     [[UIApplication sharedApplication].delegate.window addSubview:self];
     self.alpha = 0;
     self.imageView.frame = self.rect;
     [UIView animateWithDuration:.2 animations:^{
         self.alpha = 1;
         CGFloat height = UIScreen.mainScreen.bounds.size.height;
         CGFloat width = UIScreen.mainScreen.bounds.size.width;
         
         CGFloat i_w = width;
         CGFloat i_h = self.imageView.image.size.height / self.imageView.image.size.width * i_w;
         
         CGFloat x = 0;
         CGFloat y = ((height - i_h) * 0.5) < 0 ? 0 : (height - i_h) * 0.5;
         
         self.imageView.frame = CGRectMake(x, y, i_w, i_h);
         [self.scrollView setZoomScale:1];
     }];
     
 }

 - (void)dissCoverView
 {
     [self.scrollView setZoomScale:1 animated:YES];
     [UIView animateWithDuration:.2 animations:^{
         self.alpha = 0;
         self.imageView.frame = self.rect;
     } completion:^(BOOL finished) {
         [self removeFromSuperview];
     }];

 }

 - (UIImageView *)imageView
 {
     if (_imageView == nil) {
         _imageView = [UIImageView new];
         _imageView.contentMode = UIViewContentModeScaleAspectFill;
         _imageView.userInteractionEnabled = YES;
     }
     return _imageView;
 }

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [_scrollView setMaximumZoomScale:2];
        [_scrollView setMinimumZoomScale:0.7];
        _scrollView.delegate = self;
        _scrollView.userInteractionEnabled = YES;
    }
    return _scrollView;
}

@end
