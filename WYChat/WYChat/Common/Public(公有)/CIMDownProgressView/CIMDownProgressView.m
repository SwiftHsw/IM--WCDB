//
//  CIMDownProgressView.m
//  ChatIM
//
//  Created by Mac on 2020/11/18.
//  Copyright © 2020 ChatIM. All rights reserved.
//

#import "CIMDownProgressView.h"

@interface CIMDownProgressView ()
@property (nonatomic , assign) CGFloat radiu;
@end

@implementation CIMDownProgressView

#pragma mark - set
- (void)setProgress:(CGFloat)progress
{
    _progress = progress == 0 ? 0.001 : progress;
    [self setNeedsDisplay];
}

#pragma mark - Life
+ (instancetype)downProgressViewWithCenterRadiu:(CGFloat)radiu
{
    CIMDownProgressView *view = [[CIMDownProgressView alloc] initWithRadiu:radiu];
    return view;
}

- (instancetype)initWithRadiu:(CGFloat)radiu
{
    self = [super init];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.radiu = radiu;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    [[UIColor.blackColor colorWithAlphaComponent:.5] set];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:5 + self.radiu startAngle:0 endAngle:M_PI * 2 clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), 0)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(0, CGRectGetMaxY(rect))];
    [path addLineToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), 0)];
    [path closePath];
    [path fill];
    
    
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect)) radius:self.radiu startAngle:-M_PI_2 endAngle:-M_PI_2 + M_PI * 2 * self.progress clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))];
    [path closePath];
    [path fill];
}


@end
