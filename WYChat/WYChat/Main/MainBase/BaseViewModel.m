//
//  BaseViewModel.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "BaseViewModel.h"


@interface BaseViewModel ()

//控件

@end


@implementation BaseViewModel


-(instancetype)initViewModelFormViewController:(SWSuperViewContoller *)viewController{
    if (self == [super init]) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - Public
- (void)setupInitLayout
{
    self.viewController.navigationItem.title = @"标题";
    self.viewController.view.backgroundColor = [UIColor whiteColor];
    [self setupLayout:self.viewController.view];
   
}


#pragma mark - Private
- (void)setupLayout:(UIView *)view
{
    
    
}

@end
