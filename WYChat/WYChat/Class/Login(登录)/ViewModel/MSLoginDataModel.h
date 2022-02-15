//
//  MSLoginDataModel.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MSLoginDataModel : BaseModel

@property (nonatomic , copy) NSString *mobile;

@property (nonatomic , copy) NSString *password;
   
@end


@interface MSRegistDataModel : BaseModel

@property (nonatomic , copy) NSString *mobile;
@property (nonatomic , copy) NSString *code;
@property (nonatomic , copy) NSString *password;
   
@end


NS_ASSUME_NONNULL_END
