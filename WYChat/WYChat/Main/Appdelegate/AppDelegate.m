//
//  AppDelegate.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "AppDelegate.h"
#import "AppDelegate+MSInit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    WYAppSingle.shareManager.appdelegae = self;
    
    [self initApplication:application didFinishLaunchingWithOptions:launchOptions];
     
    return YES;
}





@end
