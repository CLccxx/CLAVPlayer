//
//  CLAVPlayerView.h
//  AVPlayerTest
//
//  Created by 杨博兴 on 16/10/27.
//  Copyright © 2016年 xx_cc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLAVPlayerView : UIView

/** 需要播放的视频资源 */
@property(nonatomic,strong)NSString *urlString;

/* 包含在哪一个控制器中 */
@property (nonatomic, weak) UIViewController *contrainerViewController;

/** 快速创建 */
+ (instancetype)videoPlayView;



@end
