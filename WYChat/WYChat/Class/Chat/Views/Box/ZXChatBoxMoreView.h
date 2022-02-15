//
//  ZXChatBoxMoreView.h
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/19.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXChatBoxItemView.h"

typedef NS_ENUM(NSInteger, TLChatBoxItem) {
    TLChatBoxItemAlbum = 0,
    TLChatBoxItemCamera = 1,
    TLChatBoxItemFile = 2,
};

@class ZXChatBoxMoreView;
@protocol ZXChatBoxMoreViewDelegate <NSObject>

- (void)chatBoxMoreView:(ZXChatBoxMoreView *)chatBoxMoreView didSelectItem:(TLChatBoxItem)itemType;

@end

@interface ZXChatBoxMoreView : UIView

@property (nonatomic, weak) id<ZXChatBoxMoreViewDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *items;

@end
