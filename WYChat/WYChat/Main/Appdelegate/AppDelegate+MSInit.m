//
//  AppDelegate+MSInit.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import "AppDelegate+MSInit.h"
#import "BaseTabbarViewController.h"
#import "MSLoginViewController.h"
#import "BaseTabbarViewController.h"
@implementation AppDelegate (MSInit)
- (void)initApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    //主题色
    [NSObject setMainColor:@"#111111"];
     
    //MARK:- 键盘管理者
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    keyboardManager.enable = YES; // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    keyboardManager.enableAutoToolbar = NO; // 控制是否显示键盘上的工具条
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    
    //MARK:- 初始化
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
//    if (MSAppSingle.shareManager.isLogin) {
        self.window.rootViewController = [BaseTabbarViewController new];
//    }else{
//        MSLoginViewController *loginVc = [MSLoginViewController new];
//        loginVc.type = MSLoginTypeForPassword;
//        SWNavigationViewController *nav = [[SWNavigationViewController alloc]initWithRootViewController:loginVc];
//        self.window.rootViewController = nav;
//    }
  
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [WXApi registerApp:weChatKey universalLink:weChatUnLink];
    });
     
}


- (void)applicationWillResignActive:(UIApplication *)application {
   
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
  
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
  
}

- (void)applicationWillTerminate:(UIApplication *)application {
   [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

@end
