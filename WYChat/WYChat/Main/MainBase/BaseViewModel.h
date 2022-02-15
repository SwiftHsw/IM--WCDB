//
//  BaseViewModel.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewModel : NSObject

@property (nonatomic,strong) SWSuperViewContoller *viewController;

- (instancetype)initViewModelFormViewController:(SWSuperViewContoller *)viewController;

- (void)setupInitLayout;


@end

NS_ASSUME_NONNULL_END
