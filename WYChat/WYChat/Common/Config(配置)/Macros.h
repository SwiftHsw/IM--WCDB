//
//  Macros.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/15.
//

#ifndef Macros_h
#define Macros_h


static NSInteger statrTime = 60;

static NSString * weChatKey = @"";

static NSString * weChatUnLink = @"";

static NSString * WECHATLOGINRESULT = @"WECHATLOGINRESULT";
 
 
#define HEIGHT_TABBAR       49 // 标签

#define     DEFAULT_CHATBOX_COLOR            UIColorRGBA(244.0, 244.0, 246.0, 1.0)
 
#define     DEFAULT_LINE_GRAY_COLOR          UIColorRGBA(188.0, 188.0, 188.0, 0.6f)

#define     DEFAULT_CHAT_BACKGROUND_COLOR    UIColorRGBA(235.0, 235.0, 235.0, 1.0)

#define     DEFAULT_BACKGROUND_COLOR         UIColorRGBA(239.0, 239.0, 244.0, 1.0)

#define HEIGHT_CHATBOXVIEW  215// 更多 view

 


UIKIT_STATIC_INLINE NSString *CIMLocalizableStr(NSString *key)
{
    //多语言
//    NSString *language = [CPUserDefaultTool appLanguage];
//    if ([language isEqualToString:KCIMAPPLanguage_system]) {
//        language = currentSystemLanguage();
//    }
    
//    return [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"system" ofType:@"lproj"]] localizedStringForKey:key value:nil table:@"Localizable"];
    return  key;
}


UIKIT_STATIC_INLINE NSURL *CIMRequstUrl(NSString *string)
{
    string = [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASEURL,string]];
}

UIKIT_STATIC_INLINE NSString *CIMCurrentLanguageStr()
{
    NSString *language = @"system";
    //系统语言
    if ([language isEqualToString:@"system"]) {
        //获取当前系统的语言
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        //中文
        if([language hasPrefix:@"zh-Hans"] ||
           [language hasPrefix:@"wuu-Hans"] ||
           [language hasPrefix:@"zh-Hant"] ||
           [language hasPrefix:@"yue-Hant"]) {
            return @"zh";
        }
        //其他按英文处理
        else {
            return @"en";
        }
    }
    //选择语言
    else {
        return [language containsString:@"en"] ? @"en" : @"zh";
    }
}

//富文本图片对应的内容标识
UIKIT_STATIC_INLINE NSString *CIMAttchmentTextNameKey()
{
    return @"CIMAttchmentTextNameKey";
}

UIKIT_STATIC_INLINE UIColor *SWLineColor()
{
    return SWColor(@"eeeeee");
}

#endif /* Macros_h */
