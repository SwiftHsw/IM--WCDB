//
//  WYIMFileManager.m
//  WYChat
//
//  Created by 黄世文 on 2021/10/19.
//

#import "WYIMFileManager.h"

@interface WYIMFileManager ()

@property (nonatomic , strong) WYIMFileManager *fileManger;

@end

@implementation WYIMFileManager

static WYIMFileManager *instance = nil;

+(instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[WYIMFileManager alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}


- (NSString *)connectCurrentUserDirectory:(NSString *)userID
{
    //根据用户创建库
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:userID];

    [self createDirectoryAtPath:directoryPath];
    return directoryPath;
}


/// 创建文件夹
- (void)createDirectoryAtPath:(NSString *)directoryPath
{
    //判断当前是否存在文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL flag = YES;
    BOOL isExists = [fileManager fileExistsAtPath:directoryPath isDirectory:&flag];

    //不存在，则创建
    if (!isExists) {

        NSError *error = nil;

        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error];

        if (!error) {
            SWLog(@"文件夹创建成功");
        }
        else
        {
            SWLog(@"文件夹创建失败:%@",error.description);
        }
    }
    else
    {
        SWLog(@"文件夹存在")
    }
}

///保存图片到当前用户的图片文件夹中
- (NSString *)saveImageToCurrentUserDirector:(UIImage *)image
{
    return [self writeImageToCurrentUserImagesDirector:image directorPath:[self imagesDirectorPath]];
}

//保存图片难道路径
- (NSString *)writeImageToCurrentUserImagesDirector:(UIImage *)image directorPath:(NSString *)directorPath
{
    NSString *imageName = [NSString stringWithFormat:@"image_%u%u%lld%u%u.png",arc4random_uniform(1000),arc4random_uniform(99),(long long)[[NSDate date] timeIntervalSince1970],arc4random_uniform(9),arc4random_uniform(99)];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@", directorPath, imageName];
    NSData *imageData = (UIImagePNGRepresentation(image) == nil ? UIImageJPEGRepresentation(image, 1) : UIImagePNGRepresentation(image));
    [imageData writeToFile:imagePath atomically:YES];
    
    //返回图片名
    return imageName;;
}

- (NSString *)imagesDirectorPath
{
    //获取当前用户对应的文件夹
    NSString *userDirector = [WYIMFileManager.shareManager connectCurrentUserDirectory:@"8008"];
    
    //获取存图片的文件夹
    NSString *imageDirector = [userDirector stringByAppendingPathComponent:@"images"];
    [WYIMFileManager.shareManager createDirectoryAtPath:imageDirector];
    
    return imageDirector;
}

- (NSString *)videosDirectorPath
{
    //获取当前用户对应的文件夹
    NSString *userDirector = [WYIMFileManager.shareManager connectCurrentUserDirectory:@"8008"];
    
    //获取存视频的文件夹
    NSString *videosDirector = [userDirector stringByAppendingPathComponent:@"videos"];
    [WYIMFileManager.shareManager createDirectoryAtPath:videosDirector];
    
    return videosDirector;
}

- (NSString *)voicesDirectorPath
{
    //获取当前用户对应的文件夹
    NSString *userDirector = [WYIMFileManager.shareManager connectCurrentUserDirectory:@"8008"];
    
    //获取存语音的文件夹
    NSString *videosDirector = [userDirector stringByAppendingPathComponent:@"voices"];
    [WYIMFileManager.shareManager createDirectoryAtPath:videosDirector];
    
    return videosDirector;
}

- (NSString *)fileDirectorPath
{
    //根据用户创建库
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directoryPath = [documentPath stringByAppendingPathComponent:@"file"];
    [self createDirectoryAtPath:directoryPath];
    return directoryPath;
}
@end

