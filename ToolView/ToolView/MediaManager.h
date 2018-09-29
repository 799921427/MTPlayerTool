//
//  MediaManager.h
//  ToolView
//
//  Created by 张德茂 on 2018/9/27.
//  Copyright © 2018年 张德茂. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MediaManager : NSObject

//获取多媒体时长
+ (CGFloat)getVideoTimeWithURL:(NSURL *)videoURL;
//获取呀传入时间节点的帧图片（可控制是否为关键帧）
+ (UIImage *)getCoverImage:(NSURL *)movieURL atTime:(CGFloat)time isKeyImage:(BOOL)isKeyImage;


@end
