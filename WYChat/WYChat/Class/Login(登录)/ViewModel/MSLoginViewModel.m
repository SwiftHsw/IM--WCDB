//
//  MSLoginViewModel.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import "MSLoginViewModel.h"
#import "MSLoginViewController.h"
#import "BaseTabbarViewController.h"
#import "MSForgetPasswordViewController.h"
#import "MSRegistViewController.h"
#import "WYThirdLoginManager.h"

@implementation MSLoginViewModel

-(void)setupInitLayout{
   
    MSLoginViewController *viewController =  (MSLoginViewController *) self.viewController;
     
    [self addActionButton:viewController];
    
    [self setupBingding:viewController];
    
  
    if (viewController.type == MSLoginTypeForMobileSMS ) {
        //验证码界面
        viewController.rightCons.constant = 10;
        viewController.title = @"验证码登录";
        viewController.getCodeBtn.hidden = NO;
        viewController.passwordTextField.placeholder = @"请输入验证码";
        [viewController.smsPassBtn setTitle:@"密码登录" forState:UIControlStateNormal];
        ATViewBorderRadius(viewController.getCodeBtn, 5, 0.5, UIColor.grayColor);
          
    }else{
        //密码登录界面
        viewController.vcTopCons.constant += NAVBAR_HEIGHT;
        viewController.rightCons.constant = -100;
        viewController.getCodeBtn.hidden = YES;
        viewController.passwordTextField.placeholder = @"请输入密码";
        [viewController.smsPassBtn setTitle:@"验证码登录" forState:UIControlStateNormal];
    }
    
    
}

#pragma mark - 按钮操作域
- (void)addActionButton:(MSLoginViewController *)viewController{
    
    //短信验证码登录点击切换
    [viewController.smsPassBtn addCallBackAction:^(UIButton *button) {
        if (viewController.type == MSLoginTypeForMobileSMS ) {
            [viewController.navigationController popViewControllerAnimated:YES];
        }else{
            MSLoginViewController *loginVc = [MSLoginViewController new];
            loginVc.type = MSLoginTypeForMobileSMS;
            [viewController.navigationController pushViewController:loginVc animated:YES];
        }
    }];
    
    //获取验证码
    [viewController.getCodeBtn addCallBackAction:^(UIButton *button) {
        [viewController.getCodeBtn countDownChanging:^NSString *(SWCountDownButton *countDownButton, NSUInteger second) {
            countDownButton.enabled = NO;
            return [NSString stringWithFormat:@"%zd秒后重新发送", second];
        }];
        [viewController.getCodeBtn countDownFinished:^NSString *(SWCountDownButton *countDownButton, NSUInteger second) {
            countDownButton.enabled = YES;
            return @"获取验证码";
        }];
        [viewController.getCodeBtn startCountDownWithSecond:statrTime];
    }];
    
    //登录
    @weakify(self)
    [viewController.loginButton addCallBackAction:^(UIButton *button) {
        @strongify(self)
        [viewController.progressHUD showHUD];
        [WYAppSingle.shareManager.userServer.loginCommand execute:[self.dataModel mj_keyValues]];
    }];
    
    //忘记密码
    [viewController.fowtButton addCallBackAction:^(UIButton *button) {
        [viewController.navigationController pushViewController:MSForgetPasswordViewController.new animated:YES];
    }];
    
    //注册
    [viewController.registButton addCallBackAction:^(UIButton *button) {
        
        [viewController.navigationController pushViewController:MSRegistViewController.new animated:YES];
    }];
  
    if (![WXApi isWXAppInstalled]) {
        viewController.weChatBtn.hidden = YES;
    }else{
        //微信登录
        [viewController.weChatBtn addCallBackAction:^(UIButton *button) {
            [WYThirdLoginManager.sharedManager openWechatLoginSuccess:^(NSString * _Nonnull identity) {
                
            }];
        }];
    }
    //苹果登录
    if (@available(iOS 13.0, *)) {
        [viewController.apple_loginBtn addCallBackAction:^(UIButton *button) {
            [WYThirdLoginManager.sharedManager openAppleLoginSuccess:^(NSString * _Nonnull identity) {
                
            }];
        }];
    }else{
        viewController.apple_loginBtn.hidden = YES;
    }
    
    //隐私政策
    [viewController.YSZC addCallBackAction:^(UIButton *button) {
            
    }];
    //用户服务协议
    [viewController.userXY addCallBackAction:^(UIButton *button) {
            
    }];
    
    //登录成功回调
    [WYAppSingle.shareManager.userServer.loginCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
          //保存用户数据
        if (x) {
            [AppUserCache setUserInfo:x];
            [WYAppSingle shareManager].userModel = [NSObject mj_objectWithKeyValues:x];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [viewController.progressHUD dissmissHUD];
                BaseTabbarViewController *tabba= [BaseTabbarViewController new];
                KeyWindow.rootViewController = tabba;
            });
        }
    }];
    
}

#pragma mark - 监听属性
- (void)setupBingding:(MSLoginViewController *)viewController{
     
    @weakify(self)
    [[viewController.mobileTextField rac_textSignal]subscribeNext:^(NSString * _Nullable x) {
        [UITextField sw_limitTextField:viewController.mobileTextField limitNumber:11 limitHandeler:^{
            [MBProgressHUD showErrorHUD:@"只能输入11位的手机号码" completeBlock:nil];
        }];
    }];
    [[viewController.passwordTextField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        [UITextField sw_limitTextField:viewController.passwordTextField limitNumber:16 limitHandeler:^{
            SWLog(@"请输入6-16位密码");
        }];
    }];
    RAC(viewController.loginButton,enabled) = [[RACObserve(self.dataModel, mobile)
                                               merge:RACObserve(self.dataModel, password)]
                                               map:^id _Nullable(id  _Nullable value) {
        @strongify(self)
        return @(self.dataModel.mobile.length == 11 &&self.dataModel.password.length > 0);
         
    }];
    RAC(viewController.getCodeBtn,enabled) = [RACObserve(self.dataModel, mobile)
                                              map:^id _Nullable(id  _Nullable value) {
        @strongify(self)
        return  @(self.dataModel.mobile.length == 11);
    }];
    
    RAC(self.dataModel,mobile) = [viewController.mobileTextField rac_textSignal];
    RAC(self.dataModel,password) = [viewController.passwordTextField rac_textSignal];
  
}



#pragma mark - lazy

- (MSLoginDataModel *)dataModel
{
    if (_dataModel == nil) {
        _dataModel = [MSLoginDataModel new];
    }
    return _dataModel;
}

@end
