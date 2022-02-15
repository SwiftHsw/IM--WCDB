//
//  ZXChatBoxView.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/19.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXChatBoxView.h"
 
#define     CHATBOX_BUTTON_WIDTH        37
#define     HEIGHT_TEXTVIEW             HEIGHT_TABBAR * 0.74
#define     MAX_TEXTVIEW_HEIGHT         104

@interface ZXChatBoxView ()<UITextViewDelegate>

@property (nonatomic, strong) UIView *topLine; // 顶部的线
@property (nonatomic, strong) UIButton *voiceButton; // 声音按钮
@property (nonatomic, strong) UITextView *textView;  // 输入框
@property (nonatomic, strong) UIButton *faceButton;  // 表情按钮
@property (nonatomic, strong) UIButton *moreButton;  // 更多按钮
@property (nonatomic, strong) UIButton *talkButton;  // 聊天键盘按钮
@property (nonatomic , strong) UILabel *jinYanLab;  //禁言提示

@end

@implementation ZXChatBoxView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _curHeight = frame.size.height;// 当前高度初始化为 49
        [self setBackgroundColor:UIColor.whiteColor];
        [self addSubview:self.topLine];
        [self addSubview:self.voiceButton];
        [self addSubview:self.textView];
        [self addSubview:self.faceButton];
        [self addSubview:self.moreButton];
        [self addSubview:self.talkButton];
        [self addSubview:self.jinYanLab];
        
        self.jinYanLab.sd_layout
        .spaceToSuperView(UIEdgeInsetsZero);

        self.status = TLChatBoxStatusNothing;//初始化状态是空
        
        WeakSelf(self)
        [RACObserve(self, isJinYan) subscribeNext:^(id  _Nullable x) {
            StrongSelf(self)
            self.jinYanLab.hidden = !self.isJinYan;
        }];
 
    }
    return self;
}


-(void)setFrame:(CGRect)frame
{
    // 6 的初始化 0.0.375.49
    [super setFrame:frame];
    [self.topLine setWidth:self.width];
    //  y=  49 -  ( CHATBOX_BUTTON_WIDTH )  37 - (View 的H - Button的H )/2
    //  Voice 的高度和宽度初始化的时候都是 37 
    float y = self.height - self.voiceButton.height - (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2;
    if (self.voiceButton.y != y) {
        [UIView animateWithDuration:0.1 animations:^{
            
            // 根据 Voice 的 Y 改变 faceButton  moreButton de Y
            [self.voiceButton setY:y];
            [self.faceButton  setY:self.voiceButton.y];
            [self.moreButton  setY:self.voiceButton.y];
            
        }];
    }
}

#pragma Public Methods
- (BOOL) resignFirstResponder
{
    [self.textView resignFirstResponder];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
    [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
    [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
    return [super resignFirstResponder];
}

- (void) addEmojiFace:(ChatFace *)face
{
    NSMutableAttributedString *att = [self.textView.attributedText mutableCopy];
    [att appendString:face.faceName];
    [att addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(0, att.length)];
    [self.textView setAttributedText:att];
    
    SWLog(@"支持表情符号.contentSize.height:%lf",self.textView.contentSize.height);
    
    if (MAX_TEXTVIEW_HEIGHT < self.textView.contentSize.height) {
        float y = self.textView.contentSize.height - self.textView.height;
        y = y < 0 ? 0 : y;
        [self.textView scrollRectToVisible:CGRectMake(0, y, self.textView.width, self.textView.height) animated:YES];
    }
    
    [self textViewDidChange:self.textView];
}

/**
 *  发送当前消息
 */
- (void) sendCurrentMessage
{
    NSMutableString *string = [self.textView.text mutableCopy];
    [self.textView.attributedText enumerateAttributesInRange:NSMakeRange(0, self.textView.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        
        if (attrs[@"NSAttachment"]) {
//            SWLog(@"表情包名字===%@",attrs[CIMAttchmentTextNameKey()]);
            [string replaceCharactersInRange:range withString:attrs[CIMAttchmentTextNameKey()]];
        }
    }];
    
    if (string.length > 0) {     // send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:sendTextMessage:)]) {
            [_delegate chatBox:self sendTextMessage:string];
        }
    }
    [self.textView setText:@""];
    [self textViewDidChange:self.textView];
}


- (void) deleteButtonDown
{
    [self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""];
    [self textViewDidChange:self.textView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
#warning 关闭弹窗
//    [CIMUISIngle.shareManager dissPopupMenu];
    return [super hitTest:point withEvent:event];
}

#pragma mark - UITextViewDelegate
- (void) textViewDidBeginEditing:(UITextView *)textView
{
    /**
     *   textView 已经开始编辑的时候，判断状态
     */
    ZXChatBoxStatus lastStatus = self.status;
    self.status = TLChatBoxStatusShowKeyboard;
    if (lastStatus == TLChatBoxStatusShowFace) {
        
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        
    }
    else if (lastStatus == TLChatBoxStatusShowMore) {
        
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        
        [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
    }
    
}


/**
 *  TextView 的输入内容一改变就调用这个方法，
 *
 *  @param textView
 */
- (void) textViewDidChange:(UITextView *)textView
{
    WeakSelf(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UITextRange *selectedRange = textView.markedTextRange;
        if (!selectedRange || !selectedRange.start) {
            NSString *newText = [textView textInRange:selectedRange];

            if (newText.length < 1)
            {
                // 高亮输入框中的群链接
                NSRange range = textView.selectedRange;

                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
//                SWLog(@"---%@===%@",NSStringFromRange(range),string);
                [string addAttribute:NSForegroundColorAttributeName value:UIColor.blackColor range:NSMakeRange(0, string.string.length)];
                
                [string addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, string.string.length)];

                NSArray *matches = [NSString findAllGroupUrlWithString:textView.text];
                for (NSTextCheckingResult *match in matches)
                {
                    [string addAttribute:NSForegroundColorAttributeName value:SWMainColor range:NSMakeRange(match.range.location, match.range.length)];
                }

                textView.attributedText = string;
                textView.selectedRange = range;
            }

            /**
             *   textView 的 Frame 值是按照 talkButton  设置的
                 sizeThatSize并没有改变原始 textView 的大小
                 [label sizeToFit]; 这样搞就直接改变了这个label的宽和高，使它根据上面字符串的大小做合适的改变
             */
            StrongSelf(self)
            CGFloat height = [textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
            height = height > HEIGHT_TEXTVIEW ? height : HEIGHT_TEXTVIEW; // height大于 TextView 的高度 就取height 否则就取 TextView 的高度

            height = height < MAX_TEXTVIEW_HEIGHT ? height : textView.height;  // height 小于 textView 的最大高度 104 就取出 height 不然就取出  textView.height

            self.curHeight = height + HEIGHT_TABBAR - HEIGHT_TEXTVIEW;
             
            
            if (self.curHeight != self.height) {

                [UIView animateWithDuration:0.05 animations:^{
                    self.height = self.curHeight;
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBox:changeChatBoxHeight:)]) {
                        [self.delegate chatBox:self changeChatBoxHeight:self.curHeight];

                    }
                }];
            }

            if (height != textView.height) {
                [UIView animateWithDuration:0.05 animations:^{
                    textView.height = height;
                }];
            }
        }

        NSMutableAttributedString *string = [NSString textToEmojiTextForTextView:[[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText]];
        [string addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, string.string.length)];
        textView.attributedText = string;
        
    });
    
}

////内容将要发生改变编辑
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
 
    //发送
    if ([text isEqualToString:@"\n"]){
        [self sendCurrentMessage];
        textView.textColor = UIColor.blackColor;
        return NO;
    }
    /**
     *
     */
    else if (textView.text.length > 0 && [text isEqualToString:@""]) {       // delete
         
        [textView deleteBackward];
  
        // 判断删除的是一个群链接字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:textView.text];
        NSArray *matches = [NSString findAllGroupUrlWithString:textView.text];
        BOOL inAt = NO;
        NSInteger index = range.location;
        for (NSTextCheckingResult *match in matches)
        {
            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
            if (NSLocationInRange(range.location, newRange))
            {
                inAt = YES;
                index = match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        
        if (inAt)
        {
            textView.text = @"";
            textView.textColor = UIColor.blackColor;
            [textView insertText:string];
            textView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
        
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    NSRange range = textView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    
    NSArray *matches = [NSString findAllGroupUrlWithString:textView.text];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
        if (NSLocationInRange(range.location, newRange))
        {
            textView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
            break;
        }
    }
}


- (void)setStatus:(ZXChatBoxStatus)status
{
    _status = status;
    ZXChatBoxStatus lastStatus = TLChatBoxStatusNothing;
    
    self.faceButton.enabled = YES;
    self.moreButton.enabled = YES;
    self.voiceButton.enabled = YES;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
        [_delegate chatBox:self changeStatusForm:lastStatus to:status];
    }
}


#pragma mark - Event Response
/**
 *  声音按钮点击
 *
 */
- (void) voiceButtonDown:(UIButton *)sender
{
    ZXChatBoxStatus lastStatus = self.status;
    
    // 正在显示talkButton，改为现实键盘状态
    if (lastStatus == TLChatBoxStatusShowVoice) {
        self.status = TLChatBoxStatusShowKeyboard;
        [self.talkButton setHidden:YES];
        [self.textView setHidden:NO];
        [self.textView becomeFirstResponder];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        
        [self textViewDidChange:self.textView];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
    else {
        // 显示talkButton
        self.curHeight = HEIGHT_TABBAR;
        [self setHeight:self.curHeight];
        self.status = TLChatBoxStatusShowVoice;// 如果不是显示讲话的Button，就显示讲话的Button，状态也改变为 shouvoice
        [self.textView resignFirstResponder];
        [self.textView setHidden:YES];
        [self.talkButton setHidden:NO];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowFace) {
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowMore) {
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
          
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
            
        }
    }
}

/**
 *  表情按钮点击时间
 *
 */
- (void) faceButtonDown:(UIButton *)sender
{
    ZXChatBoxStatus lastStatus = self.status;// 记录下上次的状态
    if (lastStatus == TLChatBoxStatusShowFace) {
        // 正在显示表情，改为现实键盘状态
        self.status = TLChatBoxStatusShowKeyboard;
        
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
    else {
        
        self.status = TLChatBoxStatusShowFace;
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowMore) {
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
            [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowVoice) {
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
            [self textViewDidChange:self.textView];
        }
        else if (lastStatus == TLChatBoxStatusShowKeyboard) {
            
            [self.textView resignFirstResponder];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
            
        }
    }
    
}

/**
 *   + 按钮点击
 *
 */
- (void) moreButtonDown:(UIButton *)sender
{
    
    ZXChatBoxStatus lastStatus = self.status;
    if (lastStatus == TLChatBoxStatusShowMore) {
        
        self.status = TLChatBoxStatusShowKeyboard;
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [self.textView becomeFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
    else {
        
        self.status = TLChatBoxStatusShowMore;
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboard"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"ToolViewKeyboardHL"] forState:UIControlStateHighlighted];
        if (lastStatus == TLChatBoxStatusShowFace) {
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
            [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        }
        else if (lastStatus == TLChatBoxStatusShowVoice) {
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
            [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
            [_talkButton setHidden:YES];
            [_textView setHidden:NO];
            [self textViewDidChange:self.textView];
        }
        else if (lastStatus == TLChatBoxStatusShowKeyboard) {
            [self.textView resignFirstResponder];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(chatBox:changeStatusForm:to:)]) {
            [_delegate chatBox:self changeStatusForm:lastStatus to:self.status];
        }
    }
}

- (void) talkButtonDown:(UIButton *)sender
{
    [_talkButton setTitle:CIMLocalizableStr(@"Loose end") forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateNormal];
    if (self.speak_touch_block) {
        self.speak_touch_block(UIControlEventTouchDown);
    }
}

- (void) talkButtonUpInside:(UIButton *)sender
{
    [_talkButton setTitle:CIMLocalizableStr(@"Hold to talk") forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    if (self.speak_touch_block) {
        self.speak_touch_block(UIControlEventTouchUpInside);
    }
}

- (void) talkButtonUpOutside:(UIButton *)sender
{
    [_talkButton setTitle:CIMLocalizableStr(@"Hold to talk") forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    if (self.speak_touch_block) {
        self.speak_touch_block(UIControlEventTouchUpOutside);
    }
    
}

- (void) talkButtonDragEnter:(UIButton *)sender
{
    [_talkButton setTitle:CIMLocalizableStr(@"Hold to talk") forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
    if (self.speak_touch_block) {
        self.speak_touch_block(UIControlEventTouchDragEnter);
    }
    
}


- (void) talkButtonDragExit:(UIButton *)sender
{
    [_talkButton setTitle:CIMLocalizableStr(@"Loose end") forState:UIControlStateNormal];
    [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateNormal];
    if (self.speak_touch_block) {
        self.speak_touch_block(UIControlEventTouchDragExit);
    }
}



#pragma mark - Getter
- (UIView *) topLine
{
    if (_topLine == nil) {
        _topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.5)];
//        [_topLine setBackgroundColor:WBColor(165, 165, 165, 1.0)];
        _topLine.backgroundColor = UIColor.clearColor;
    }
    return _topLine;
}

- (UIButton *) voiceButton
{
    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoice"] forState:UIControlStateNormal];
        [_voiceButton setImage:[UIImage imageNamed:@"ToolViewInputVoiceHL"] forState:UIControlStateHighlighted];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UITextView *) textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:self.talkButton.frame];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView.layer setMasksToBounds:YES];
        [_textView.layer setCornerRadius:4.0f];
        [_textView.layer setBorderWidth:0.5f];
        [_textView.layer setBorderColor:self.topLine.backgroundColor.CGColor];
        _textView.backgroundColor = SWColor(@"#F5F5F5");
        [_textView setScrollsToTop:NO];
        [_textView setReturnKeyType:UIReturnKeySend];// 返回按钮更改为发送
        [_textView setDelegate:self];
        
   
    }
    return _textView;
}

- (UIButton *) faceButton
{
    if (_faceButton == nil) {
        _faceButton = [[UIButton alloc] initWithFrame:CGRectMake(self.moreButton.x - CHATBOX_BUTTON_WIDTH, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotion"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"ToolViewEmotionHL"] forState:UIControlStateHighlighted];
        [_faceButton addTarget:self action:@selector(faceButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}

- (UIButton *) moreButton
{
    if (_moreButton == nil) {
        _moreButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - CHATBOX_BUTTON_WIDTH, (HEIGHT_TABBAR - CHATBOX_BUTTON_WIDTH) / 2, CHATBOX_BUTTON_WIDTH, CHATBOX_BUTTON_WIDTH)];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtn_Black"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"TypeSelectorBtnHL_Black"] forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *) talkButton
{
    if (_talkButton == nil) {
        _talkButton = [[UIButton alloc] initWithFrame:CGRectMake(self.voiceButton.x + self.voiceButton.width + 4, self.height * 0.13, self.faceButton.x - self.voiceButton.x - self.voiceButton.width - 8, HEIGHT_TEXTVIEW)];
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.5]] forState:UIControlStateHighlighted];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:12.0f];
        _talkButton.backgroundColor = SWColor(@"#F5F5F5");
        [_talkButton setHidden:YES];
        [_talkButton addTarget:self action:@selector(talkButtonDown:) forControlEvents:UIControlEventTouchDown]; // 点击控件或者另外一根手指点击了控件
        [_talkButton addTarget:self action:@selector(talkButtonUpInside:) forControlEvents:UIControlEventTouchUpInside]; // 在空间内的抬起事件
        [_talkButton addTarget:self action:@selector(talkButtonUpOutside:) forControlEvents:UIControlEventTouchUpOutside]; // 在控件外的抬起时间
        [_talkButton addTarget:self action:@selector(talkButtonDragExit:) forControlEvents:UIControlEventTouchDragExit]; // 向控件外拖动
        [_talkButton addTarget:self action:@selector(talkButtonDragEnter:) forControlEvents:UIControlEventTouchDragEnter]; // 向控件内拖动
    }
    return _talkButton;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UILabel *)jinYanLab
{
    if (_jinYanLab == nil) {
        _jinYanLab = [UILabel new];
        _jinYanLab.textColor = SWColor(@"2b2b2b");
        _jinYanLab.font = SWFont_Regular(15);
        _jinYanLab.backgroundColor = self.backgroundColor;
        _jinYanLab.textAlignment = NSTextAlignmentCenter;
        _jinYanLab.text = CIMLocalizableStr(@"All members are prohibited from speaking");
    }
    return _jinYanLab;
}

@end
