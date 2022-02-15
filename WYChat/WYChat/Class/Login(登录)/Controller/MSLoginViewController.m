//
//  MSLoginViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/14.
//

#import "MSLoginViewController.h"
#import "MSLoginViewModel.h"


@interface MSLoginViewController ()

@property (nonatomic,strong) MSLoginViewModel *viewModel;

@end

@implementation MSLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self setNavgationBarHidden:self.type == MSLoginTypeForPassword animated:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.viewModel setupInitLayout];
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}
 
- (MSLoginViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[MSLoginViewModel alloc] initViewModelFormViewController:self];
    }
    return _viewModel;
}
@end
