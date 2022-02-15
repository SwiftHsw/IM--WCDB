//
//  SWPromptBox.m
//  测试
//
//  Created by WYChat on 2021/7/21.
//  Copyright © 2021年 黄世文. All rights reserved.
//

#import "SWPromptBox.h"

typedef enum : NSUInteger {
    PromitBoxDirection_up,
    PromitBoxDirection_down,
} PromitBoxDirection;


@interface SWPromptBox ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>
@property (nonatomic , strong) UITableViewCell      *preCell;
@property (nonatomic , strong) UITableView          *boxTableView;
@property (nonatomic , assign) PromitBoxDirection   direction;              //显示方向
@property (nonatomic , assign) CGPoint              triangleTopPoint;       //三角形顶点
@property (nonatomic , assign) CGPoint              clipViewCenterInWindow; //点击视图的中心点

@end

@implementation SWPromptBox


#pragma mark - 类方法
+ (instancetype)promtBoxWithOption:(SWPromptBoxOption *)option{
    return [[self alloc] initWithPromtBoxOption:option];
}

- (instancetype)initWithPromtBoxOption:(SWPromptBoxOption *)option{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.option = option;
        self.backgroundColor = [UIColor clearColor];
        self.direction = [self getPromitBoxDirectionWithClipView:option.clipView];
        [self addSubview:self.boxTableView];
    }
    return self;
}

- (void)refreshPromitBoxView{
    [_boxTableView reloadData];
    [self upDataFrame];
}

//更新frame
-(void)upDataFrame{
    NSInteger count = self.titles != nil ? self.titles.count : self.images != nil ? self.images.count : 0;
    CGFloat tableViewY = self.direction == PromitBoxDirection_up ? 0 : self.option.triangleHeight;
    self.bounds = CGRectMake(0, 0, self.option.width, count * SWPBHeight + self.option.triangleHeight);
    _boxTableView.frame = CGRectMake(0, tableViewY, self.option.width, count * SWPBHeight);
    if (self.option.isShowAnimation) {
        [self promitBoxRemoveFromSuperViewWithValues:SWPBAnimation_appear isDelegate:NO];
    }
}


#pragma mark - CAAnimationDelegate
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self removeFromSuperview];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.titles != nil ? self.titles.count : self.images != nil ? self.images.count : 0;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell identifier]];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.textAlignment = self.option.textAlignment;
    if (self.titles != nil) {
        cell.textLabel.text = self.titles[indexPath.row];
    }
    if (self.images != nil) {
        cell.imageView.image = SWPBImage(self.images[indexPath.row]);
    }
    
    cell.textLabel.textColor = self.option.textColor;
    cell.textLabel.font = self.option.textFont;
    
    if (self.option.isHaveSelectorCell == YES && self.option.selectorIndex == indexPath.row) {
        self.preCell = cell;
        [self selectorPreCell];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.row == (self.titles.count - 1) ? SWPBHeight + 1 : SWPBHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.block) {
        if (self.promitBoxDeleget && [self.promitBoxDeleget respondsToSelector:@selector(promptBoxSelector:indexPath:)]) {
            [self.promitBoxDeleget promptBoxSelector:self.block indexPath:indexPath];
        }
    }
    [self unSelectorPreCell];
    self.preCell = [tableView cellForRowAtIndexPath:indexPath];
    [self selectorPreCell];
    [self promitBoxRemoveFromSuperViewWithValues:SWPBAnimation_disappear isDelegate:YES];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = self.option.backgroundColor;
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:self.option.separatorEdgeInsets];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:self.option.separatorEdgeInsets];
    }
}

#pragma mark - Method
-(void)selectorPreCell{
    self.preCell.textLabel.textColor = self.option.selectorTextColor;
}

-(void)unSelectorPreCell{
    self.preCell.textLabel.textColor = self.option.textColor;
}

//缩放
- (void)promitBoxRemoveFromSuperViewWithValues:(NSArray *)values isDelegate:(BOOL)isDelegate{
    CAKeyframeAnimation *keyAnimation = [CAKeyframeAnimation animation];
    keyAnimation.keyPath = @"transform.scale";
    keyAnimation.delegate = isDelegate == YES ? self : nil;
    keyAnimation.values = values;
    keyAnimation.duration = .3;
    keyAnimation.removedOnCompletion = YES;
    [self.layer addAnimation:keyAnimation forKey:nil];
}


//获取视图的显示方向
-(PromitBoxDirection)getPromitBoxDirectionWithClipView:(UIView *)clipView{
    PromitBoxDirection direction;
    self.clipViewCenterInWindow = [clipView.superview convertPoint:clipView.center toView:nil];
    CGPoint centerP = self.clipViewCenterInWindow;
    if (centerP.y > self.option.distance_Y) {
        direction = PromitBoxDirection_up;
    }else{
        direction = PromitBoxDirection_down;
    }
    return direction;
}


//获取视图的显示位置
- (CGPoint)getPromitBoxPostionWithClipView:(UIView *)clipView{
    
    //获取点击视图的中心点坐标
    CGPoint centerP = self.clipViewCenterInWindow;
    
    //获取点击视图的高
    CGFloat height_ClipView = CGRectGetHeight(clipView.frame);
    
    //获取自身self的宽
    CGFloat width_self = self.option.width;
    
    //修改显示距离的 Y 轴偏差
    if (self.direction == PromitBoxDirection_up) {
        centerP.y -= (height_ClipView * .5) + self.option.topSpacing;
    }else{
        centerP.y += (height_ClipView * .5) + self.option.topSpacing;
    }
    
    //提示框的左边和右边是否有超出屏幕
    CGFloat disForleft = centerP.x - (width_self * .5);
    CGFloat disForRight = (SWPBScreenWidth - centerP.x - (width_self * .5));
    
    CGFloat offsetX = width_self * .5;
    
    if (disForleft < 0) {
        offsetX -= (fabs(disForleft) +  self.option.space_For_LeftOrRight); //向右偏移量
    }
    
    if (disForRight < 0) {
        offsetX += fabs(disForRight) +  self.option.space_For_LeftOrRight; //向左偏移量
    }
    
    //设置锚点
    self.layer.anchorPoint = CGPointMake(offsetX/(width_self * 1.0), self.direction == PromitBoxDirection_up ? 1 : 0);
    
    return centerP;
}

//获取三角形顶点坐标
- (CGPoint)getTriangleTopWithWidth:(CGFloat)width height:(CGFloat)height{
    
    CGPoint pointP = CGPointMake(width * self.layer.anchorPoint.x, 0);
    
    if (self.direction == PromitBoxDirection_up) {
        pointP.y = height;
    }else{
        pointP.y = 0;
    }
    
    return pointP;
}


-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if ([_boxTableView pointInside:point withEvent:event] == YES) {
        return _boxTableView;
    }else{
        return [super hitTest:point withEvent:event];
    }
}


- (void)drawRect:(CGRect)rect {
    
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    self.layer.position = [self getPromitBoxPostionWithClipView:self.option.clipView];
    self.triangleTopPoint = [self getTriangleTopWithWidth:width height:height];   //三角形顶点
    
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    UIBezierPath *path =  [UIBezierPath bezierPathWithRect:rect];
    [self.option.backgroundColor set];
    [path fill];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    path =  [UIBezierPath bezierPath];
    
    CGFloat radiu = self.option.radiu;
    
    //右上两点
    CGPoint rightUpStartP = CGPointMake(width - radiu, 0);
    CGPoint rightUpEndP = CGPointMake(width, radiu);
    
    //右下两点
    CGPoint rightDownStartP = CGPointMake(width,height - radiu);
    CGPoint rightDownEndP = CGPointMake(width - radiu, height);
    
    //左下两点
    CGPoint leftUpStartP = CGPointMake(0, radiu);
    CGPoint leftUpEndP = CGPointMake(radiu, 0);
    
    //左上两点
    CGPoint leftDownStartP = CGPointMake(radiu,height);
    CGPoint leftDownEndP = CGPointMake(0, height - radiu);
    
    //四个角的控制点
    CGPoint rightUpP_ctr = CGPointMake(width, 0);
    CGPoint rightDownP_ctr = CGPointMake(width, rect.size.height);
    CGPoint leftUpP_ctr = CGPointMake(0, 0);
    CGPoint leftDownP_ctr = CGPointMake(0, rect.size.height);
    
    CGFloat topDistance = self.option.triangleHeight;  //三角形高度
    
    
    CGPoint topP = self.triangleTopPoint;
    CGFloat triangleCentX = topP.x;
    
    if (triangleCentX > rightUpStartP.x) {
        triangleCentX = rightUpStartP.x - self.option.triangleBottomWidth ;
    }else if(triangleCentX <= leftDownStartP.x){
        triangleCentX = leftDownStartP.x + self.option.triangleBottomWidth ;
    }
    
    CGFloat lettP_X = triangleCentX - self.option.triangleBottomWidth;
    CGFloat rightP_X = triangleCentX + self.option.triangleBottomWidth;
    
    CGPoint leftP = CGPointMake(lettP_X < radiu ? radiu : lettP_X, topP.y);  //三角行左边点
    CGPoint rightP = CGPointMake(rightP_X > (width - radiu) ? (width - radiu) : rightP_X , topP.y); //三角行右边点
    
    
    
    if (self.direction == PromitBoxDirection_up) {
        rightDownStartP.y -= topDistance;
        rightDownEndP.y -= topDistance;
        leftDownStartP.y -= topDistance;
        leftDownEndP.y -= topDistance;
        rightDownP_ctr.y -= topDistance;
        leftDownP_ctr.y -= topDistance;
        leftP.y -= topDistance;
        rightP.y -= topDistance;
    }else{
        rightUpStartP.y += topDistance;
        rightUpEndP.y += topDistance;
        leftUpStartP.y += topDistance;
        leftUpEndP.y += topDistance;
        leftUpP_ctr.y += topDistance;
        rightUpP_ctr.y += topDistance;
        leftP.y += topDistance;
        rightP.y += topDistance;
    }
    
    
    //连线
    [path moveToPoint:rightUpStartP];
    [path addQuadCurveToPoint:rightUpEndP controlPoint:rightUpP_ctr];
    [path addLineToPoint:rightDownStartP];
    [path addQuadCurveToPoint:rightDownEndP controlPoint:rightDownP_ctr];
    [path addLineToPoint:leftDownStartP];
    [path addQuadCurveToPoint:leftDownEndP controlPoint:leftDownP_ctr];
    [path addLineToPoint:leftUpStartP];
    [path addQuadCurveToPoint:leftUpEndP controlPoint:leftUpP_ctr];
    
    [path moveToPoint:topP];
    [path addLineToPoint:leftP];
    [path addLineToPoint:rightP];
    [path closePath];
    [path addClip];
    [image drawInRect:rect];
}


#pragma mark - get
-(UITableView *)boxTableView{
    if (_boxTableView == nil) {
        _boxTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.option.width, 0) style:UITableViewStylePlain];
        [_boxTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell identifier]];
        _boxTableView.layer.cornerRadius = self.option.radiu;
        _boxTableView.backgroundColor = [UIColor clearColor];
        _boxTableView.separatorColor = self.option.separatorColor;
        _boxTableView.dataSource = self;
        _boxTableView.delegate = self;
        _boxTableView.bounces = NO;
        _boxTableView.showsVerticalScrollIndicator = NO;
        _boxTableView.showsHorizontalScrollIndicator = NO;
        _boxTableView.scrollEnabled = NO;
        if ([_boxTableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_boxTableView setSeparatorInset:self.option.separatorEdgeInsets];
        }
        if ([_boxTableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_boxTableView setLayoutMargins:self.option.separatorEdgeInsets];
        }
    }
    return _boxTableView;
}

@end
