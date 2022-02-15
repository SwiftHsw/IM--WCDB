//
//  ViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/11.
//

#import "ViewController.h"
#import "XYDJViewController.h"
#import "HDCDDeviceManager.h"
@interface ViewController ()<XYDJViewControllerDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn addCallBackAction:^(UIButton *button) {
        
        NSString *arcConverstionId = [[NSString getRandomString] substringToIndex:4];
          
        WYIMConversationModel *conversation = [WYAppSingle.shareManager.conversationManager getOneConversationWithConversationId:arcConverstionId type:2001 isSavaIntoDB:YES];
        
        XYDJViewController *vc = [XYDJViewController chatControllerWithConversationModel:conversation];
        vc.wyDelegate = self;
        [self.navigationController pushViewController:vc animated:YES];
       
        
    }];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = UIColor.redColor;
    [self.view addSubview:btn];
     
    
}

-(void)chatViewControllerRetrunNeedReloadConversation:(XYDJViewController *)chatVC conversation:(WYIMConversationModel *)conversation{
    
    //会话管理数据
//    [CIMAPPSingle.shareManager.conversationManager updateConversationsForUnReadNum];;
//    [self.viewModel.tableView reloadData];
    
}

@end
