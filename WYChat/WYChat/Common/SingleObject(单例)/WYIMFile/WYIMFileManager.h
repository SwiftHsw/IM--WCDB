//
//  WYIMFileManager.h
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WYIMFileManager : NSObject

+(instancetype)shareManager;

/// 找到对应用户的文件夹
- (NSString *)connectCurrentUserDirectory:(NSString *)userID;

/// 创建文件夹
- (void)createDirectoryAtPath:(NSString *)directoryPath;

///保存图片到当前用户的图片文件夹中
- (NSString *)saveImageToCurrentUserDirector:(UIImage *)image;

/// 图片文件夹路径
- (NSString *)imagesDirectorPath;

/// 视频文件夹路径
- (NSString *)videosDirectorPath;

/// 语音文件夹路径
- (NSString *)voicesDirectorPath;

/// 非图片、视频、语言文件路径
- (NSString *)fileDirectorPath;


@end

NS_ASSUME_NONNULL_END
