//
//  NSString+SIM.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import "NSString+SIM.h"
@implementation NSString (SIM)

+(NSString *)utf8ToUnicode:(NSString *)string{

    return string;
    
NSUInteger length = [string length];
NSMutableString *str = [NSMutableString stringWithCapacity:0];
for (int i = 0;i < length; i++){
NSMutableString *s = [NSMutableString stringWithCapacity:0];
unichar _char = [string characterAtIndex:i];
// 判断是否为英文和数字
if (_char <= '9' && _char >='0'){
[s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
}else if(_char >='a' && _char <= 'z'){
[s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
}else if(_char >='A' && _char <= 'Z')
{
[s appendFormat:@"%@",[string substringWithRange:NSMakeRange(i,1)]];
}else{
// 中文和字符
[s appendFormat:@"\\u%x",[string characterAtIndex:i]];
// 不足位数补0 否则解码不成功
if(s.length == 4) {
[s insertString:@"00" atIndex:2];
} else if (s.length == 5) {
[s insertString:@"0" atIndex:2];
}
}
[str appendFormat:@"%@", s];
}
return str;
    
//    NSString *jay = [NSString stringWithUTF8String:[string UTF8String]];
//
//    NSData *newData = [jay dataUsingEncoding:NSNonLossyASCIIStringEncoding];
//
//    NSString *emoji = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding] ;
//    return emoji;
}

+(NSString *)replaceUnicode:(NSString *)unicodeStr
{
    
    return unicodeStr;
    NSString *tempStr1 = [unicodeStr stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *returnStr = [NSPropertyListSerialization propertyListFromData:tempData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:NULL];
    return [returnStr stringByReplacingOccurrencesOfString:@"\r\n"withString:@"\n"];
    
    
    
//    const char *jay = [jsonString UTF8String];  // jsonString 服务器返回的 json
//
//    NSData *newData = [NSData dataWithBytes:jsonString length:strlen(jay)];
//
//    NSString *emoji = [[NSString alloc] initWithData:newData encoding:NSNonLossyASCIIStringEncoding];
//
//    return emoji;
}

+ (NSMutableArray<NSValue *> *)getRangeStr:(NSString *)text findText:(NSString *)findText
{
    NSMutableArray *arrayRanges = [NSMutableArray arrayWithCapacity:20];
    if (findText == nil || [findText isEqualToString:@""])
    {
        return nil;
    }
    
    NSRange rang = [text rangeOfString:findText]; //获取第一次出现的range
    if (rang.location != NSNotFound && rang.length != 0)
    {
        [arrayRanges addObject:[NSValue valueWithRange:rang]];//将第一次的加入到数组中
        NSRange rang1 = {0,0};
        NSInteger location = 0;
        NSInteger length = 0;
        for (int i = 0;; i++)
        {
            if (0 == i)
            {
                //去掉这个abc字符串
                location = rang.location + rang.length;
                length = text.length - rang.location - rang.length;
                rang1 = NSMakeRange(location, length);
            }
            else
            {
                location = rang1.location + rang1.length;
                length = text.length - rang1.location - rang1.length;
                rang1 = NSMakeRange(location, length);
            }
            
            //在一个range范围内查找另一个字符串的range
            rang1 = [text rangeOfString:findText options:NSCaseInsensitiveSearch range:rang1];
            if (rang1.location == NSNotFound && rang1.length == 0)
            {
                break;
            }
            else
            {
                //添加符合条件的location进数组
                [arrayRanges addObject:[NSValue valueWithRange:rang1]];
            }
            
        }
        return arrayRanges;
    }
    return nil;
}


+(NSMutableAttributedString*)subStr:(NSString *)string
{

    NSError *error;

    //可以识别url的正则表达式

    NSString *regulaStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr

                                                                           options:NSRegularExpressionCaseInsensitive

                                                                             error:&error];

    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    NSMutableArray *arr=[[NSMutableArray alloc]init];

    NSMutableArray *rangeArr=[[NSMutableArray alloc]init];



    for (NSTextCheckingResult *match in arrayOfAllMatches)

    {

        NSString* substringForMatch;

        substringForMatch = [string substringWithRange:match.range];

        [arr addObject:substringForMatch];



    }

    NSString *subStr=string;

    for (NSString *str in arr) {

        [rangeArr addObject:[self rangesOfString:str inString:subStr]];

    }

    UIFont *font = [UIFont systemFontOfSize:20];

    NSMutableAttributedString *attributedText;

    attributedText=[[NSMutableAttributedString alloc]initWithString:subStr attributes:@{NSFontAttributeName :font}];



    for(NSValue *value in rangeArr)

    {

        NSInteger index=[rangeArr indexOfObject:value];

        NSRange range=[value rangeValue];

        [attributedText addAttribute:NSLinkAttributeName value:[NSURL URLWithString:[arr objectAtIndex:index]] range:range];

        [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:range];



    }

    return attributedText;
}

//获取查找字符串在母串中的NSRange
+ (NSValue *)rangesOfString:(NSString *)searchString inString:(NSString *)str {



    NSRange searchRange = NSMakeRange(0, [str length]);



    NSRange range;



    if ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {

        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));

    }

    return [NSValue valueWithRange:range];

}

+ (NSArray<NSTextCheckingResult *> *)findAllGroupUrlWithString:(NSString *)string
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"https?://[\\da-zA-Z-_.]+(:\\d{0,5})?/share/url/g/[\\da-zA-Z]+ " options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, [string length])];
    return matches;
}

+ (NSMutableAttributedString *)textToEmojiText:(NSMutableAttributedString *)attributedString
{
    if (attributedString ==  nil) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSString *regularExpStr = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *arr = [regularExp matchesInString:attributedString.string options:NSMatchingReportProgress range:NSMakeRange(0, attributedString.string.length)];
    [[[arr reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imageName = [attributedString.string substringWithRange:obj.range];
        UIImage *image = kImageName(imageName);
        if (image) {
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithImage:image];
            NSMutableAttributedString *att = [NSMutableAttributedString attachmentStringWithContent:imageView contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(20, 20) alignToFont:[UIFont systemFontOfSize:13] alignment:YYTextVerticalAlignmentCenter];
            [att appendString:@" "];
            [attributedString replaceCharactersInRange:obj.range withAttributedString:att];
        }
    }];
    return attributedString;
}

+ (NSMutableAttributedString *)textToEmojiTextForTextView:(NSMutableAttributedString *)attributedString
{
    if (attributedString ==  nil) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSString *regularExpStr = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
    NSError *error = nil;
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray<NSTextCheckingResult *> *arr = [regularExp matchesInString:attributedString.string options:NSMatchingReportProgress range:NSMakeRange(0, attributedString.string.length)];
    [[[arr reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *imageName = [attributedString.string substringWithRange:obj.range];
        UIImage *image = kImageName(imageName);
        if (image) {
            NSTextAttachment *attchment = [NSTextAttachment new];
            attchment.image = image;
            attchment.bounds = CGRectMake(0, -1, 20, 20);
            NSAttributedString *attchText = [NSAttributedString attributedStringWithAttachment:attchment];
            
            NSMutableAttributedString *att = [NSMutableAttributedString new];
            [att appendAttributedString:attchText];
            [att addAttributes:@{CIMAttchmentTextNameKey() : imageName} range:NSMakeRange(0 , att.length)];
            [attributedString replaceCharactersInRange:obj.range withAttributedString:att];
        }
    }];
    return attributedString;
}

+ (NSString *)fileSizeForSize:(NSInteger)size
{
    NSString *sizeStr = [NSString stringWithFormat:@"%ldB",(unsigned long)size];
    
    if (size > 1000.0)
        {
        sizeStr = [NSString stringWithFormat:@"%.2lfKB",size / 1000.0];
    }
    if (size > 1000.0 * 1000.0)
        {
        sizeStr = [NSString stringWithFormat:@"%.2lfM",size / 1000.0 / 1000.0];
    }
    if (size > 1000.0 * 1000.0 * 1000.0)
        {
        sizeStr = [NSString stringWithFormat:@"%.2lfG",size / 1000.0 / 1000.0 / 1000.0];
    }
    return sizeStr;
}

@end
