//
//  ZXChatBoxController.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXChatBoxController.h"
#import "HDCDDeviceManager.h"
#import <TZImagePickerController/TZImagePickerController.h>
 

@interface ZXChatBoxController ()<
ZXChatBoxMoreViewDelegate,
ZXChatBoxFaceViewDelegate,
ZXChatBoxDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
TZImagePickerControllerDelegate>

@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, strong) UIView *talking_view; // 正在说话时
@property (nonatomic, strong) UIView *cancel_talk_view; // 手指划出将要取消说话时
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , assign) int32_t time;
@end

@implementation ZXChatBoxController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.chatBox];
    /**
     *  添加两个键盘回收通知
     */
    // 即将隐藏
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 键盘的Frame值即将发生变化的时候创建的额监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    WeakSelf(self)
    _chatBox.speak_touch_block = ^(UIControlEvents control_event) {
        StrongSelf(self)
        if (control_event == UIControlEventTouchDown) { // 点击控件
            
            self.talking_view.backgroundColor = [UIColor colorWithHexString:@"#636164"];
            [self.view.superview.superview addSubview:self.talking_view];
            [self startRecording];
            NSLog(@"1");
            
        }
        
        if (control_event == UIControlEventTouchDragExit) { // 手指向外拖动
            self.talking_view.backgroundColor = [UIColor colorWithHexString:@"#EC6F77"];
            UIImageView *imgV = (UIImageView *)[self.talking_view viewWithTag:10086];
            
            imgV.image = [UIImage imageNamed:@"speak_cancel"];
            UILabel *a_label = (UILabel *)[self.talking_view viewWithTag:10087];
            a_label.text = CIMLocalizableStr(@"Release fingers, cancel sending");
            NSLog(@"2");
        }
        
        if (control_event == UIControlEventTouchDragEnter) { // 手指从外部重新移回控件
            NSString *path = [[NSBundle mainBundle] pathForResource:@"话筒" ofType:@"gif"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithSmallGIFData:data scale:1];
            UIImageView *imgV = (UIImageView *)[self.talking_view viewWithTag:10086];
            imgV.image = image;
            UILabel *a_label = (UILabel *)[self.talking_view viewWithTag:10087];
            a_label.text = @"向上滑动，取消发送";
            self.talking_view.backgroundColor = [UIColor colorWithHexString:@"#636164"];
            NSLog(@"3");
        }
        
        
        
        if (control_event == UIControlEventTouchUpInside) { // 所有在控件之内触摸抬起事件
            NSString *path = [[NSBundle mainBundle] pathForResource:@"话筒" ofType:@"gif"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithSmallGIFData:data scale:1];
            UIImageView *imgV = (UIImageView *)[self.talking_view viewWithTag:10086];
            imgV.image = image;
            UILabel *a_label = (UILabel *)[self.talking_view viewWithTag:10087];
            a_label.text = @"向上滑动，取消发送";
            [self.talking_view removeFromSuperview];
            NSLog(@"4");
            [self stopRecording];
        }
        
        
        if (control_event == UIControlEventTouchUpOutside) { // 所有在控件之外触摸抬起事件
            NSString *path = [[NSBundle mainBundle] pathForResource:@"话筒" ofType:@"gif"];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithSmallGIFData:data scale:1];
            UIImageView *imgV = (UIImageView *)[self.talking_view viewWithTag:10086];
            imgV.image = image;
            UILabel *a_label = (UILabel *)[self.talking_view viewWithTag:10087];
            a_label.text = @"向上滑动，取消发送";
            [self.talking_view removeFromSuperview];
            NSLog(@"5");
            [self cancleRecording];
        }
    };
    
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    
}

#pragma mark Recording
//开始录音
-(void)startRecording{
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    [self startTime];
    [[HDCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error){
        if (error) {
            NSLog(@"message.startRecordFail");
        }
    }];
}
//结束录音
-(void)stopRecording{
    [[HDCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (aDuration < 1)
        {
            [[HDCDDeviceManager sharedInstance] cancelCurrentRecording];
        }else{
            if (!error)
            {
                NSLog(@"录音文件路径:%@",recordPath);    
                ZXMessageModel *message = [self creatMessageModelWithType:ZXMessageTypeVoice];
                message.voiceSeconds = aDuration;
                message.voicePath = [recordPath lastPathComponent];
                message.voiceSourcePath = recordPath;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:sendMessage:)]) {
                    [self.delegate chatBoxViewController:self sendMessage:message];
                }
            }
        }
    }];
}
//播放录音
-(void)playRecording{
    [[HDCDDeviceManager sharedInstance] asyncPlayingWithPath:@"" completion:^(NSError *error) {
        
    }];
}

// 取消录音
-(void)cancleRecording{
    [self endTime];
    [[HDCDDeviceManager sharedInstance] cancelCurrentRecording];
}


#pragma mark - Public Methods
/**
 *  回收键盘方法
 *  @return
 */
- (BOOL) resignFirstResponder
{
    
    if (self.chatBox.status != TLChatBoxStatusNothing && self.chatBox.status != TLChatBoxStatusShowVoice)
    {
        // 回收键盘
        [self.chatBox resignFirstResponder];
        /**
         *  在外层已经判断是不是声音状态 和 Nothing 状态了，且判断是都不是才进来的，下面在判断是否多余了？
         *  它是判断是不是要设置成Nothing状态
         */
        self.chatBox.status = (self.chatBox.status == TLChatBoxStatusShowVoice ? self.chatBox.status : TLChatBoxStatusNothing);
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)])
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
                
            } completion:^(BOOL finished) {
                
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
                
            }];
        }
    }
    
    return [super resignFirstResponder];
}


#pragma mark - TLChatBoxDelegate
/**
 *  发送消息调用这个代理方法
 *
 *  @param chatBox     <#chatBox description#>
 *  @param textMessage 发送的消息
 */
- (void) chatBox:(ZXChatBoxView *)chatBox sendTextMessage:(NSString *)textMessage
{
    ZXMessageModel *message = [self creatMessageModelWithType:ZXMessageTypeText];
//    message.text = [textMessage stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    message.text = [NSString utf8ToUnicode:textMessage];
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController: sendMessage:)]) {
        [_delegate chatBoxViewController:self sendMessage:message];
    }
}

- (void)chatBox:(ZXChatBoxView *)chatBox changeChatBoxHeight:(CGFloat)height
{
    self.chatBoxFaceView.y = height;
    self.chatBoxMoreView.y = height;
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)])
    {
        // 改变 控制器高度
        float h = (self.chatBox.status == TLChatBoxStatusShowFace ? HEIGHT_CHATBOXVIEW : self.keyboardFrame.size.height - SAFEBOTTOM_HEIGHT) + height;
        
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: h];
    }
}


/**
 *  代理方法，传递状态改变要显示那个view
 *
 *   param chatBox
 *  @param fromStatus 开始状态
 *  @param toStatus   改变到这个状态
 */
- (void)chatBox:(ZXChatBoxView *)chatBox changeStatusForm:(ZXChatBoxStatus)fromStatus to:(ZXChatBoxStatus)toStatus
{
    
    if (toStatus == TLChatBoxStatusShowKeyboard) {      // 显示键盘 删除FaceView 和 MoreView
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.chatBoxFaceView removeFromSuperview];
            [self.chatBoxMoreView removeFromSuperview];
            
        });
        
        return;
    }
    else if (toStatus == TLChatBoxStatusShowVoice)
    {
        // 显示语音输入按钮
        // 从显示更多或表情状态 到 显示语音状态需要动画
        if (fromStatus == TLChatBoxStatusShowMore || fromStatus == TLChatBoxStatusShowFace) {
            [UIView animateWithDuration:0.3 animations:^{
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    
                    [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
                    
                }
            } completion:^(BOOL finished) {
                
                [self.chatBoxFaceView removeFromSuperview];
                [self.chatBoxMoreView removeFromSuperview];
            }];
        }
        else {
            
            [UIView animateWithDuration:0.3 animations:^{
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    
                    [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:HEIGHT_TABBAR];
                }
            }];
        }
    }
    else if (toStatus == TLChatBoxStatusShowFace)
    {
        /**
         *   变化到展示 表情View 的状态，这个过程中，根据 fromStatus 区分，要是是声音和无状态改变过来的，则高度变化是一样的。 其他的高度就是另外一种，根据 fromStatus 来进行一个区分。
         */
        if (fromStatus == TLChatBoxStatusShowVoice || fromStatus == TLChatBoxStatusNothing) {
            
            [self.chatBoxFaceView setY:self.chatBox.curHeight];
            // 添加表情View
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    
                    [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                }
            }];
        }
        else {
            // 表情高度变化
            self.chatBoxFaceView.y = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            [self.view addSubview:self.chatBoxFaceView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxFaceView.y = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxMoreView removeFromSuperview];
            }];
            // 整个界面高度变化
            if (fromStatus != TLChatBoxStatusShowMore) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                        [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                    }
                }];
            }
        }
    }
    else if (toStatus == TLChatBoxStatusShowMore)
    {
        // 显示更多面板
        if (fromStatus == TLChatBoxStatusShowVoice || fromStatus == TLChatBoxStatusNothing) {
            [self.chatBoxMoreView setY:self.chatBox.curHeight];
            [self.view addSubview:self.chatBoxMoreView];
            
            [UIView animateWithDuration:0.3 animations:^{
                if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                    [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                }
            }];
        }
        else {
            
            self.chatBoxMoreView.y = self.chatBox.curHeight + HEIGHT_CHATBOXVIEW;
            //            self.chatBoxMoreView.delegate = self;
            [self.view addSubview:self.chatBoxMoreView];
            [UIView animateWithDuration:0.3 animations:^{
                self.chatBoxMoreView.y = self.chatBox.curHeight;
            } completion:^(BOOL finished) {
                [self.chatBoxFaceView removeFromSuperview];
            }];
            
            if (fromStatus != TLChatBoxStatusShowFace) {
                
                [UIView animateWithDuration:0.2 animations:^{
                    if (self->_delegate && [self->_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
                        [self->_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight + HEIGHT_CHATBOXVIEW];
                    }
                }];
            }
        }
    }
}

#pragma mark - TLChatBoxFaceViewDelegate----表情包点击事件
- (void) chatBoxFaceViewDidSelectedFace:(ChatFace *)face groupId:(NSString *)groupId type:(TLFaceType)type
{
    
    if (type == TLFaceTypeEmoji) {
        [self.chatBox addEmojiFace:face];
    }else{
        NSDictionary *dic = @{@"data":@{@"chartlet":face.faceName,@"catalog":[groupId substringToIndex:[groupId rangeOfString:@"_face"].location]},@"type":@"3",@"content":face.faceID};
        
        ZXMessageModel *message = [self creatMessageModelWithType:ZXMessageTypeSticker];
        message.text = [dic modelToJSONString];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:sendMessage:)]) {
            [self.delegate chatBoxViewController:self sendMessage:message];
        }
    }
}

- (void) chatBoxFaceViewDeleteButtonDown
{
    [self.chatBox deleteButtonDown];
}

- (void) chatBoxFaceViewSendButtonDown
{
    [self.chatBox sendCurrentMessage];   
}


#pragma mark - TLChatBoxMoreViewDelegate
- (void) chatBoxMoreView:(ZXChatBoxMoreView *)chatBoxMoreView didSelectItem:(TLChatBoxItem)itemType
{
    // 相册
    if (itemType == TLChatBoxItemAlbum) {
        
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
        imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
//        [imagePickerVc.navigationBar addShadow];
        imagePickerVc.allowPickingGif = YES;
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.statusBarStyle = UIStatusBarStyleDefault;
        imagePickerVc.naviTitleColor = [UIColor blackColor];
        imagePickerVc.naviBgColor = [UIColor whiteColor];
        imagePickerVc.barItemTextColor = [UIColor blackColor];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
    //相机
    else if (itemType == TLChatBoxItemCamera) {
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];//初始化
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            imagePicker.videoMaximumDuration = 15;
            imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            [imagePicker setDelegate:self];
            [self presentViewController:imagePicker animated:YES completion:nil];
        }else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备不支持拍照。" preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:nil];
            [alertVC addAction:confirm];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
    }
    //文件
    else if (itemType == TLChatBoxItemFile) {
    
    }
}
 

/**
 *
 *
 *  @return 从相册读取图片的回调方法
 */
#pragma mark - UIImagePickerControllerDelegate
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //发送图片
    if (image)
    {
        [self sendImages:@[[UIImage fixOrientation:image]]];
    }
    //发送视频
    else
    {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        UIImage *coverImage = [UIImage thumbnailImageForVideo:url atTime:0.0];
        NSString *coverImagePath = [WYIMFileManager.shareManager saveImageToCurrentUserDirector:coverImage];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        NSUInteger second = ceilf(urlAsset.duration.value / urlAsset.duration.timescale * 1000);
        [self sendVideoForMessage:url.absoluteString coverLocation:coverImagePath coverImage:coverImage duration:second];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TZImagepickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    [self sendImages:photos];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSLog(@"size is %f",[size floatValue]/(1024.0*1024.0));
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *coverImagePath = [WYIMFileManager.shareManager saveImageToCurrentUserDirector:coverImage];
                NSUInteger second = ceilf(asset.duration.value / asset.duration.timescale * 1000);
                [self sendVideoForMessage:urlAsset.URL.absoluteString coverLocation:coverImagePath coverImage:coverImage duration:second];
            });
        }
    }];
}
 
#pragma mark - send
- (void)sendImages:(NSArray<UIImage *> *)images
{
    for (UIImage *a_img in images) {
        NSString *imagePath = [WYIMFileManager.shareManager saveImageToCurrentUserDirector:a_img];
        [self sendImageForMessgae:a_img imagePath:imagePath];
    }
}


- (void)sendImageForMessgae:(UIImage *)image imagePath:(NSString *)imagePath
{
    ZXMessageModel *message = [self creatMessageModelWithType:ZXMessageTypeImage];
    message.imagePath = imagePath;
    message.imageWidth = image.size.width;
    message.imageHeight = image.size.height;
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:sendMessage:)]) {
        [_delegate chatBoxViewController:self sendMessage:message];
    }
}

- (void)sendVideoForMessage:(NSString *)videoPath coverLocation:(NSString *)coverLoation coverImage:(UIImage *)coverImage duration:(NSUInteger)duration
{
    ZXMessageModel *message = [self creatMessageModelWithType:ZXMessageTypeVideo];
    message.videoCoverLocationPath = coverLoation;
    message.imageWidth = coverImage.size.width;
    message.imageHeight = coverImage.size.height;
    message.videLocalSourcePath = videoPath;
    message.videoDuration = duration;
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBoxViewController:sendMessage:)]) {
        [self.delegate chatBoxViewController:self sendMessage:message];
    }
}


- (ZXMessageModel *)creatMessageModelWithType:(ZXMessageType)type
{
    return [ZXMessageModel creatMessageModelWithType:type];;
}

#pragma mark - Getter
- (ZXChatBoxView *) chatBox
{
    // 6 的初始化 0.0.375.49
    if (_chatBox == nil) {
        _chatBox = [[ZXChatBoxView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEIGHT_TABBAR)];
        [_chatBox setDelegate:self]; // 0 0 宽 49
    }
    return _chatBox;
}



/*
 *正在说话时
 */
- (UIView *)talking_view
{
    if (!_talking_view) {
        _talking_view = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, 155, 155))];
        _talking_view.center = self.view.superview.center;
        _talking_view.backgroundColor = [UIColor colorWithHexString:@"#636164"];
        _talking_view.layer.cornerRadius = 8;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"话筒" ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage imageWithSmallGIFData:data scale:1];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:(CGRectMake(35, 20, 85, 85))];
        imgV.tag = 10086;
        imgV.image = image;
        [_talking_view addSubview:imgV];
        
        UILabel *a_label = [[UILabel alloc] initWithFrame:(CGRectMake(0, CGRectGetMaxY(imgV.frame)+12, 155, 20))];
        a_label.text = @"向上滑动，取消发送";
        a_label.font = [UIFont systemFontOfSize:14];
        a_label.textColor = [UIColor whiteColor];
        a_label.textAlignment = NSTextAlignmentCenter;
        a_label.tag = 10087;
        [_talking_view addSubview:a_label];
        
    }
    return _talking_view;
}
/*
 *将要取消说话时
 */
- (UIView *)cancel_talk_view
{
    if (!_cancel_talk_view) {
        
    }
    return _cancel_talk_view;
}




// 添加创建更多View
- (ZXChatBoxMoreView *) chatBoxMoreView
{
    if (_chatBoxMoreView == nil) {
        _chatBoxMoreView = [[ZXChatBoxMoreView alloc] initWithFrame:CGRectMake(0, HEIGHT_TABBAR, SCREEN_WIDTH, HEIGHT_CHATBOXVIEW)];
        
        ZXChatBoxItemView *photosItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:CIMLocalizableStr(@"Album")
                                                                                imageName:@"相册"];
        ZXChatBoxItemView *takePictureItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:CIMLocalizableStr(@"Camera")
                                                                                     imageName:@"拍摄"];
        ZXChatBoxItemView *fileItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:CIMLocalizableStr(@"File")
                                                                               imageName:@"文件icon"];
//        ZXChatBoxItemView *videoCallItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"视频聊天"
//                                                                                   imageName:@"sharemore_videovoip"];
//        ZXChatBoxItemView *giftItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"红包"
//                                                                              imageName:@"sharemore_wallet"];
//        ZXChatBoxItemView *transferItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"转账"
//                                                                                  imageName:@"sharemorePay"];
//        ZXChatBoxItemView *positionItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"位置"
//                                                                                  imageName:@"sharemore_location"];
//        ZXChatBoxItemView *favoriteItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"收藏"
//                                                                                  imageName:@"sharemore_myfav"];
//        ZXChatBoxItemView *businessCardItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"名片"
//                                                                                      imageName:@"sharemore_friendcard" ];
//        ZXChatBoxItemView *interphoneItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"实时对讲机"
//                                                                                    imageName:@"sharemore_wxtalk" ];
//        ZXChatBoxItemView *voiceItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"语音输入"
//                                                                               imageName:@"sharemore_voiceinput"];
//        ZXChatBoxItemView *cardsItem = [ZXChatBoxItemView createChatBoxMoreItemWithTitle:@"卡券"
//                                                                               imageName:@"sharemore_wallet"];
        //        [_chatBoxMoreView setItems:[[NSMutableArray alloc] initWithObjects:photosItem, takePictureItem, videoItem, videoCallItem, giftItem, transferItem, positionItem, favoriteItem, businessCardItem, interphoneItem, voiceItem, cardsItem, nil]];
        [_chatBoxMoreView setItems:[[NSMutableArray alloc] initWithObjects:photosItem, takePictureItem,fileItem, nil]];
        
        [_chatBoxMoreView setDelegate:self];
    }
    return _chatBoxMoreView;
}


-(ZXChatBoxFaceView *) chatBoxFaceView
{
    if (_chatBoxFaceView == nil) {
        _chatBoxFaceView = [[ZXChatBoxFaceView alloc] initWithFrame:CGRectMake(0, HEIGHT_TABBAR, SCREEN_WIDTH, HEIGHT_CHATBOXVIEW)];
        [_chatBoxFaceView setDelegate:self];
    }
    return _chatBoxFaceView;
}

/**
 *   在控制器里面添加键盘的监听，
 *
 *  @return <#return value description#>
 */
#pragma mark - Private Methods
- (void)keyboardWillHide:(NSNotification *)notification{
    self.keyboardFrame = CGRectZero;
    if (_chatBox.status == TLChatBoxStatusShowFace || _chatBox.status == TLChatBoxStatusShowMore) {
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        
        [_delegate chatBoxViewController:self didChangeChatBoxHeight:self.chatBox.curHeight];
    }
}

/**
 *  点击了 textView 的时候，这个方法的调用是比  - (void) textViewDidBeginEditing:(UITextView *)textView 要早的。
 
 */
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    
    self.keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (_chatBox.status == TLChatBoxStatusShowKeyboard && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        
        return;
        
    }
    else if ((_chatBox.status == TLChatBoxStatusShowFace || _chatBox.status == TLChatBoxStatusShowMore) && self.keyboardFrame.size.height <= HEIGHT_CHATBOXVIEW) {
        
        return;
        
    }
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxViewController:didChangeChatBoxHeight:)]) {
        
        // 改变控制器.View 的高度 键盘的高度 + 当前的 49
        [_delegate chatBoxViewController:self didChangeChatBoxHeight: self.keyboardFrame.size.height - SAFEBOTTOM_HEIGHT + self.chatBox.curHeight];
        
    }
}

- (void)dealloc{
    
    /**
     *  移除键盘通知
     */
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateTime
{
    self.time ++;
    if (self.time > 60) {
        self.chatBox.speak_touch_block(UIControlEventTouchUpInside);
        [self endTime];
    }
}

- (void)startTime
{
    self.time = 0;
    self.timer.fireDate = [NSDate distantPast];
}

- (void)endTime
{
    self.time = 0;
    _timer.fireDate = [NSDate distantFuture];
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - get
- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        [NSRunLoop.mainRunLoop addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
