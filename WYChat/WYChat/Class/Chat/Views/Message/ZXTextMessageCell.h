//
//  ZXTextMessageCell.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ZXMessageCell.h"

@interface ZXTextMessageCell : ZXMessageCell

@property (nonatomic, strong) YYLabel *messageTextLabel;

@property (nonatomic , strong) UIView *translateBackView;

@property (nonatomic , strong) YYLabel *translateLab;

@property (nonatomic , strong) UIButton *transleteReslutBtn;

@end
