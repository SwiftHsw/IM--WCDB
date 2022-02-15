//
//  BaseTabbarViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/13.
//

#import "BaseTabbarViewController.h"
#import "ViewController.h"
#import "WYConversationViewController.h"

@interface BaseTabbarViewController ()

@end

@implementation BaseTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupChildVc:WYConversationViewController.new
                 title:@"消息"
                 image:@""
         selectedImage:@""
           normalColor:SWColor(@"111111")
           selectColor:SWColor(@"111111")];
    
    
    
 
    [self setupChildVc:ViewController.new
                 title:@"手机靓号"
                 image:@""
         selectedImage:@""
           normalColor:SWColor(@"111111")
           selectColor:SWColor(@"111111")];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
