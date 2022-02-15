//
//  NSString+SIM.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SIM)
+(NSString *)utf8ToUnicode:(NSString *)string;

+(NSString *)replaceUnicode:(NSString *)unicodeStr;

+ (NSMutableArray<NSValue *> *)getRangeStr:(NSString *)text findText:(NSString *)findText;

+ (NSMutableAttributedString*)subStr:(NSString *)string;

+ (NSArray<NSTextCheckingResult *> *)findAllGroupUrlWithString:(NSString *)string;

+ (NSMutableAttributedString *)textToEmojiText:(NSMutableAttributedString *)attributedString;

+ (NSMutableAttributedString *)textToEmojiTextForTextView:(NSMutableAttributedString *)attributedString;

+ (NSString *)fileSizeForSize:(NSInteger)size;
@end

NS_ASSUME_NONNULL_END
