//
//  MediaManager.m
//  ToolView
//
//  Created by 张德茂 on 2018/9/27.
//  Copyright © 2018年 张德茂. All rights reserved.
//

#import "MediaManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation MediaManager

const float ThumbnailViewSize = 40.0;

#pragma mark - Public GetMediaDuration
+(CGFloat)getVideoTimeWithURL:(NSURL *)videoURL{
    
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    CGFloat totalSecond = urlAsset.duration.value*1.0f / urlAsset.duration.timescale;
    
    return totalSecond;
}

#pragma mark - Public GetCoverImage
+(UIImage *)getCoverImage:(NSURL *)movieURL atTime:(CGFloat)time isKeyImage:(BOOL)isKeyImage {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
    NSParameterAssert(asset); //断言，参数在应用中存在，则程序继续运行，否则打印日志
    AVAssetImageGenerator * assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //截图时，调整到正确方向
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGFloat scale = [[UIScreen mainScreen] scale];
    assetImageGenerator.maximumSize = CGSizeMake(ThumbnailViewSize * scale, ThumbnailViewSize * scale);
    
    __block CGImageRef thumbnailImageRef = NULL;
    NSError *thumbnailImageGenerationError = nil;
    //系统为了性能是默认取关键帧图片
    CMTime myTime = CMTimeMake(time, 1);
    if(!isKeyImage) {
        assetImageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
        assetImageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
        //CMTime duration = asset.duration;
        myTime = CMTimeMake(time * 30, 30);
    }
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:myTime actualTime:NULL error:nil];
    if (!thumbnailImageRef){
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    }
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    
    CGImageRelease(thumbnailImageRef);
    return thumbnailImage;
}


@end
