//
//  MSLoginViewModel.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import "BaseViewModel.h"
#import "MSLoginDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSLoginViewModel : BaseViewModel
 
@property (nonatomic , strong) MSLoginDataModel *dataModel;

@end

NS_ASSUME_NONNULL_END
