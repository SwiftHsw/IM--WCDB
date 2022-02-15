//
//  WYDataModel.m
//  网络请求
//
//  Created by chenp on 17/3/30.
//  Copyright © 2017年 CPJY. All rights reserved.
//

#import "WYDataModel.h"
#import <AVFoundation/AVFoundation.h>

static NSString *upload_Image = @"multipart/form-data";
static NSString *upload_Audio = @"multipart/form-data";
static NSString *upload_Video = @"multipart/form-data";
static NSString *upload_File =  @"multipart/form-data";


#define SWDataModelTimeIntervalSince1970 [NSString stringWithFormat:@"%lld",(long long)([[NSDate date] timeIntervalSince1970] * 1000)]

@implementation WYDataModel

- (void)setType:(WYDataModelUpload_Type)type
{
    _type = type;
    if (type == WYDataModelUpload_Image) {
        self.image_type = _type;
    }else if (type == WYDataModelUpload_Video){
        self.video_type = _type;
    }else if (type == WYDataModelUpload_Audio){
        self.audio_type = _type;
    } else if (type == WYDataModelUpload_File){
        self.file_type = _type;
    }
}

- (void)setImage_type:(WYDataModelUpload_Type)image_type
{
    _image_type = image_type;
    self.image_mimeType = upload_Image;
}

-(void)setVideo_type:(WYDataModelUpload_Type)video_type{
    _video_type = video_type;
    self.video_mimeType = upload_Video;
}

-(void)setAudio_type:(WYDataModelUpload_Type)audio_type{
    _audio_type = audio_type;
    self.audio_mimeType = upload_Audio;
}

- (void)setFile_type:(WYDataModelUpload_Type)file_type
{
    _file_type = file_type;
    self.file_mimeType = upload_File;
}

- (void)setDataModelWithImage:(UIImage * _Nonnull)image
                        type:(WYDataModelUpload_Type)type
                    fileName:(NSString * _Nonnull)fileName
{
    self.type = type;
    self.image_data = UIImageJPEGRepresentation(image, 1);
    if (self.image_data.length > 300000)
    {
        self.image_data = UIImageJPEGRepresentation(image, 0.1);
    }
    
    NSString *timeStr = SWDataModelTimeIntervalSince1970;
    self.image_name = [NSString stringWithFormat:@"%@",fileName];
    self.image_fileName = [NSString stringWithFormat:@"%@_%@.png",fileName,timeStr];
}

-(void)setDataModelWithVideoPath:(NSString * _Nonnull)videoPath
                            type:(WYDataModelUpload_Type)type
                        fileName:(NSString * _Nonnull)fileName{
    self.type = type;
    self.video_path = videoPath;
    self.video_data = [NSData dataWithContentsOfFile:videoPath];
    
    NSString *timeStr = SWDataModelTimeIntervalSince1970;
    self.video_Name = [NSString stringWithFormat:@"%@",fileName];
    self.video_fileName = [NSString stringWithFormat:@"%@%@_.mp4",fileName,timeStr];
}

-(void)setDataModelWithAudioPath:(NSString * _Nonnull)AudioPath
                            type:(WYDataModelUpload_Type)type
                        fileName:(NSString * _Nonnull)fileName{
    self.type = type;
    self.audio_path = AudioPath;
    self.audio_data = [NSData dataWithContentsOfFile:AudioPath];
    
    NSString *timeStr = SWDataModelTimeIntervalSince1970;
    self.audio_fileName = [NSString stringWithFormat:@"%@_%@.amr",fileName,timeStr];
    self.audio_name = [NSString stringWithFormat:@"%@",fileName];
}

-(void)setDataModelWithFilePath:(NSString * _Nonnull)filePath type:(WYDataModelUpload_Type)type fileName:(NSString * _Nonnull)fileName key:(NSString *)key
{
    self.type = type;
    self.file_path = filePath;
    self.file_data = [NSData dataWithContentsOfFile:filePath];
    self.file_fileName = fileName;
    self.file_name = key;
}

@end
