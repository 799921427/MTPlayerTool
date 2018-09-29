//
//  PlayerView.h
//  PlayerDemo
//
//  Created by 张德茂 on 2018/8/27.
//  Copyright © 2018年 张德茂. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerView : UIView

//手动添加的视图
@property (nonatomic) AVPlayer *player;
- (void)setPlayer:(AVPlayer *)player;

@end
