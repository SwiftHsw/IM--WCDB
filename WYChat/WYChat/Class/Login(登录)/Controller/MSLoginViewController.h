//
//  MSLoginViewController.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import <SWKit/SWKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MSLoginViewController : SWSuperViewContoller

@property (nonatomic,assign) MSLoginTypeFor type;


@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *smsPassBtn;
@property (weak, nonatomic) IBOutlet UIButton *fowtButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registButton;
@property (weak, nonatomic) IBOutlet UIButton *weChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *apple_loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *userXY;
@property (weak, nonatomic) IBOutlet UIButton *YSZC;
@property (weak, nonatomic) IBOutlet SWCountDownButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *vcTopCons;

@end

NS_ASSUME_NONNULL_END
