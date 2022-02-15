//
//  ChatFaceHeleper.m
//  ZXDNLLTest
//
//  Created by mxsm on 16/5/18.
//  Copyright © 2016年 mxsm. All rights reserved.
//

#import "ChatFaceHeleper.h"
#import "ChatFace.h"
static ChatFaceHeleper * faceHeleper = nil;

@implementation ChatFaceHeleper

+(ChatFaceHeleper * )sharedFaceHelper
{
    if (!faceHeleper) {
        
        faceHeleper = [[ChatFaceHeleper alloc]init];
        
    }
    
    return  faceHeleper;
}

/**
 *   通过这个方法，从  plist 文件中取出来表情
 */
#pragma mark - Public Methods
- (NSArray *) getFaceArrayByGroupID:(NSString *)groupID
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:groupID ofType:@"plist"]];
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:array.count];
     
    for (NSDictionary *dic in array) {
        ChatFace *face = [[ChatFace alloc] init];
        face.faceID = [dic objectForKey:@"face_id"];
        face.faceName = [dic objectForKey:@"face_name"];
        [data addObject:face];
    }
    
    return data;
}

#pragma mark -  ChatFaceGroup Getter
- (NSMutableArray *) faceGroupArray
{
    
    if (_faceGroupArray == nil) {
        _faceGroupArray = [[NSMutableArray alloc] init];
        
        ChatFaceGroup *group = [[ChatFaceGroup alloc] init];
        group.faceType = TLFaceTypeEmoji;
        group.groupID = @"normal_face";
        group.groupImageName = @"EmotionsEmojiHL";
        group.facesArray = nil;
        [_faceGroupArray addObject:group];
        
//        
//        ChatFaceGroup *group_akitopus = [[ChatFaceGroup alloc] init];
//        group_akitopus.faceType = TLFaceTypeGIF;
//        group_akitopus.groupID = @"akitopus_face";
//        group_akitopus.groupImageName = @"akitopus_s_normal";
//        group_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:group_akitopus];
//        
//        ChatFaceGroup *biscuit_akitopus = [[ChatFaceGroup alloc] init];
//        biscuit_akitopus.faceType = TLFaceTypeGIF;
//        biscuit_akitopus.groupID = @"biscuit_face";
//        biscuit_akitopus.groupImageName = @"biscuit_s_normal";
//        biscuit_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:biscuit_akitopus];
//        
//        ChatFaceGroup *pic_akitopus = [[ChatFaceGroup alloc] init];
//        pic_akitopus.faceType = TLFaceTypeGIF;
//        pic_akitopus.groupID = @"pic_face";
//        pic_akitopus.groupImageName = @"pic_s_normal";
//        pic_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:pic_akitopus];
//        
//        ChatFaceGroup *sd_akitopus = [[ChatFaceGroup alloc] init];
//        sd_akitopus.faceType = TLFaceTypeGIF;
//        sd_akitopus.groupID = @"sd_face";
//        sd_akitopus.groupImageName = @"sd_s_normal";
//        sd_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:sd_akitopus];
//        
//        ChatFaceGroup *ju_akitopus = [[ChatFaceGroup alloc] init];
//        ju_akitopus.faceType = TLFaceTypeGIF;
//        ju_akitopus.groupID = @"ju_face";
//        ju_akitopus.groupImageName = @"ju_s_normal";
//        ju_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:ju_akitopus];
//        
//        ChatFaceGroup *dinosaur_akitopus = [[ChatFaceGroup alloc] init];
//        dinosaur_akitopus.faceType = TLFaceTypeGIF;
//        dinosaur_akitopus.groupID = @"dinosaur_face";
//        dinosaur_akitopus.groupImageName = @"dinosaur_s_normal";
//        dinosaur_akitopus.facesArray = nil;
//        [_faceGroupArray addObject:dinosaur_akitopus];
//        
//        ChatFaceGroup *group_peach = [[ChatFaceGroup alloc] init];
//        group_peach.faceType = TLFaceTypeGIF;
//        group_peach.groupID = @"peach_face";
//        group_peach.groupImageName = @"peach_s_normal";
//        group_peach.facesArray = nil;
//        [_faceGroupArray addObject:group_peach];
         
    }
    return _faceGroupArray;
}

@end
