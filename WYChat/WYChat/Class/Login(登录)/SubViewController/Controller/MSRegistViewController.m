//
//  MSRegistViewController.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/15.
//

#import "MSRegistViewController.h"


@interface MSRegistModel : BaseModel
@property (nonatomic,copy) NSString *mobile;
@property (nonatomic,copy) NSString *code;
@property (nonatomic,copy) NSString *password;
@end

@implementation MSRegistModel
@end

 
@interface MSRegistViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logo;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet SWCountDownButton *getCodeBtn;
@property (weak, nonatomic) IBOutlet UITextField *code;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (nonatomic,strong)MSRegistModel *dataModel;
@end

@implementation MSRegistViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNavgationBarHidden:NO animated:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"注册";
    [self setupBingding];
    ATViewBorderRadius(self.getCodeBtn, 5, 0.5, UIColor.grayColor);
}
#pragma mark - 注册回调
- (IBAction)compleAction:(id)sender {
    
    [MBProgressHUD showSuccessHUD:@"注册成功" completeBlock:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
      
}
- (void)setupBingding{
    @weakify(self)
    RAC(self.getCodeBtn,enabled) = [RACObserve(self.dataModel, mobile)
                                              map:^id _Nullable(id  _Nullable value) {
        @strongify(self)
        return  @(self.dataModel.mobile.length == 11);
    }];
    
    
    RAC(self.registBtn,enabled) =   [[[RACObserve(self.dataModel, mobile)
                                        merge:RACObserve(self.dataModel, code)]
                                        merge:RACObserve(self.dataModel, password)]
                                               map:^id _Nullable(id  _Nullable value) {
        @strongify(self)
       
        return @(self.dataModel.mobile.length == 11
        && self.dataModel.password.length > 0
        && self.dataModel.code.length > 0  );
    }];
    
     
    [[self.mobile rac_textSignal]subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [UITextField sw_limitTextField:self.mobile limitNumber:11 limitHandeler:^{
            [MBProgressHUD showErrorHUD:@"只能输入11位的手机号码" completeBlock:nil];
        }];
    }];
    [[self.password rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [UITextField sw_limitTextField:self.password limitNumber:16 limitHandeler:^{
            SWLog(@"请输入6-16位密码");
        }];
    }];
    
    [[self.code rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [UITextField sw_limitTextField:self.code limitNumber:4 limitHandeler:^{
            SWLog(@"请输入正确的验证码");
        }];
    }];
     
    [[self.getCodeBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        //发送验证码
        [self.progressHUD showHUD];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.progressHUD dissmissHUD]; 
            [self.getCodeBtn countDownChanging:^NSString *(SWCountDownButton *countDownButton, NSUInteger second) {
                countDownButton.enabled = NO;
                return [NSString stringWithFormat:@"%zd秒后重新发送", second];
            }];
            [self.getCodeBtn countDownFinished:^NSString *(SWCountDownButton *countDownButton, NSUInteger second) {
                countDownButton.enabled = YES;
                return @"获取验证码";
            }];
            [self.getCodeBtn startCountDownWithSecond:statrTime];
        });
       
    }];
      
    RAC(self.dataModel,mobile) = [self.mobile rac_textSignal];
    RAC(self.dataModel,password) = [self.password rac_textSignal];
    RAC(self.dataModel,code) = [self.code rac_textSignal];
    
    
}
 

- (MSRegistModel *)dataModel{
    if (!_dataModel) {
        _dataModel = [MSRegistModel new];
    }
    return _dataModel;
}
@end
