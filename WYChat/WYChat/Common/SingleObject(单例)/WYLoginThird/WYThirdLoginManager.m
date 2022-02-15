//
//  MSThirdLoginManager.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/15.
//

#import "WYThirdLoginManager.h"
#import <AuthenticationServices/AuthenticationServices.h>


@interface WYThirdLoginManager ()
<
ASAuthorizationControllerDelegate
>
@property (strong, nonatomic) void(^successBlock)(NSString *identity);


@end

@implementation WYThirdLoginManager

CREATE_SHARED_MANAGER(WYThirdLoginManager)


- (instancetype)init{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(obtainWechatLoginRes:)
                                                     name:WECHATLOGINRESULT
                                                   object:nil];
    }
    return self;
}


- (void)openWechatLoginSuccess:(void (^)(NSString * _Nonnull))success {
    self.successBlock = success;
    SendAuthReq *req = [[SendAuthReq alloc]init];
    req.state = @"wx_oauth_authorization_state";
    req.scope = @"snsapi_userinfo";
    [WXApi sendReq:req completion:nil];
}

-(void)openAppleLoginSuccess:(void (^)(NSString * _Nonnull))success{
    self.successBlock = success;
    if (@available(iOS 13.0, *)) {
        ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc] init];
        ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        ASAuthorizationController *auth = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        auth.delegate = self;
//        auth.presentationContextProvider = self;
        [auth performRequests];
    } else {
        [MBProgressHUD showErrorHUD:@"该系统版本不可用Apple登录" completeBlock:nil];
    }
}

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)){
    if (@available(iOS 13.0, *)) {
        if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
            ASAuthorizationAppleIDCredential *apple = (ASAuthorizationAppleIDCredential *)authorization.credential;
            NSString *identityToken = [[NSString alloc] initWithData:apple.identityToken encoding:NSUTF8StringEncoding];
            if (self.successBlock) self.successBlock(identityToken);
        } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
            
        }
    } else {
        // Fallback on earlier versions
    }
}

- (void)obtainWechatLoginRes:(NSNotification *)notification {
    SendAuthResp *resp = notification.object;
    NSString *code = resp.code;
    if (self.successBlock) self.successBlock(code);
}

 

@end
