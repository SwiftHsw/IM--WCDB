//
//  ZXChatFaceItemView.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/20.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXChatFaceItemView.h"

@interface ZXChatFaceItemView ()

@property (nonatomic, strong) UIButton *delButton;
@property (nonatomic, strong) NSMutableArray *faceViewArray;

@end
@implementation ZXChatFaceItemView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.delButton];
    
    }
    
    return self;

}

#pragma mark - Public Methods
- (void) showFaceGroup:(ChatFaceGroup *)group formIndex:(int)fromIndex count:(int)count
{
    
#warning 清除掉上一个表情-坑逼玩意儿，搞了我一下午才定位到这个问题
    for (UIButton *a_btn in self.faceViewArray) {
        [a_btn removeFromSuperview];
    }
    [self.faceViewArray removeAllObjects];
    
    int index = 0;
    float spaceX = 12;
    float spaceY = 10;
    int row = (group.faceType == TLFaceTypeEmoji ? 3 : 2);
    int col = (group.faceType == TLFaceTypeEmoji ? 7 : 4);
    float w = (SCREEN_WIDTH - spaceX * 2) / col;
    float h = (self.height - spaceY * (row - 1)) / row;
    float x = spaceX;
    float y = spaceY;
    for (int i = fromIndex; i < fromIndex + count; i ++) {
        
        UIButton *button;
        if (index < self.faceViewArray.count) {
            
            button = [self.faceViewArray objectAtIndex:index];
        
        }else{
            button = [[UIButton alloc] init];
            [button addTarget:_target action:_action forControlEvents:_controlEvents];
            [self addSubview:button];
            [self.faceViewArray addObject:button];
        
            UIImageView *emojiImageView = [UIImageView new];
            [button addSubview:emojiImageView];
            emojiImageView.tag = 1001;
            emojiImageView.contentMode = UIViewContentModeScaleAspectFit;
            emojiImageView.sd_layout.spaceToSuperView(UIEdgeInsetsMake(10, 10, 10, 10));
            
        }
        
        index ++;
        if (i >= group.facesArray.count || i < 0) {
            
            [button setHidden:YES];
            
        }else{
            
            ChatFace  *face = [group.facesArray objectAtIndex:i];
            button.tag = i;
            UIImageView *imageView = [button viewWithTag:1001];
            imageView.image = [UIImage imageNamed:face.faceName];
            [button setFrame:CGRectMake(x, y, w, h)];
            [button setHidden:NO];
            x = (index % col == 0 ? spaceX: x + w);
            y = (index % col == 0 ? y + h : y);
        
        }
    }
    
    [_delButton setHidden:(group.faceType == TLFaceTypeEmoji ? NO : YES)];
    [_delButton setFrame:CGRectMake(x, y, w, h)];

    
}

-(void) addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    
    _target = target;
    _action = action;
    _controlEvents = controlEvents;
    [self.delButton addTarget:_target action:_action forControlEvents:_controlEvents];
    for (UIButton *button in self.faceViewArray) {
        
        [button addTarget:target action:action forControlEvents:controlEvents];
    }
}

#pragma mark - Getter
-(NSMutableArray *) faceViewArray
{
    if (_faceViewArray == nil) {
    
        _faceViewArray = [[NSMutableArray alloc] init];
    
    }
    
    return _faceViewArray;
    
}

-(UIButton *) delButton
{
    if (_delButton == nil) {
        _delButton = [[UIButton alloc] init];
        _delButton.tag = -1;
        [_delButton setImage:[UIImage imageNamed:@"DeleteEmoticonBtn"] forState:UIControlStateNormal];
    }
    return _delButton;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
