//
//  CLAVPlayerView.m
//  AVPlayerTest
//
//  Created by 杨博兴 on 16/10/27.
//  Copyright © 2016年 xx_cc. All rights reserved.
//

#import "CLAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "CLFullViewController.h"

@interface CLAVPlayerView ()

/** 背景imageView */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 工具条*/
@property (weak, nonatomic) IBOutlet UIView *toolView;
/** 开始暂停按钮 */
@property (strong, nonatomic) IBOutlet UIButton *playOrPauseBtn;
/** 滑动条 */
@property (strong, nonatomic) IBOutlet UISlider *progressSlider;
/** 时间Label*/
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
/** 总时间label */
@property (weak, nonatomic) IBOutlet UILabel *allTimeLabel;
/** 全屏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *fullScreen;
/** 屏幕中央的开始按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseBigBtn;

/** playerLayer */
@property(nonatomic,strong)AVPlayerLayer *playerLayer;
/** player */
@property(nonatomic,strong)AVPlayer *player;
/** playerItem */
@property(nonatomic,strong)AVPlayerItem *playerItem;

/** 是否显示toolView */
@property(nonatomic,assign)BOOL isShowToolView;

/** toolView显示时间的timer */
@property(nonatomic,strong)NSTimer *showTime;

/** slider和播放时间定时器 */
@property(nonatomic,strong)NSTimer *progressTimer;

/** 全屏播放控制器 */
@property(nonatomic,strong)CLFullViewController *fullVc;

/** 播放完毕遮盖View */
@property (weak, nonatomic) IBOutlet UIView *coverView;

@end

@implementation CLAVPlayerView


-(NSTimer *)progressTimer
{
    if (_progressTimer == nil) {
        _progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    }
    return _progressTimer;
}


+ (instancetype)videoPlayView
{
    return [[[NSBundle mainBundle]loadNibNamed:@"CLAVPlayerView" owner:nil options:nil]lastObject];
}

/** 加载xib来到awakeFromNib */
-(void)awakeFromNib
{
    // 隐藏遮盖版
    self.coverView.hidden = YES;
    
    //imageView添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.imageView addGestureRecognizer:tap];
    // 初始化player 和playerLayer
    self.player = [[AVPlayer alloc]init];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    // imageView上添加playerLayer
    [self.imageView.layer addSublayer:self.playerLayer];
    
    // 设置工具栏状态
    self.toolView.alpha = 0;
    self.isShowToolView = NO;
    
    // 设置Slider
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"thumbImage"] forState:UIControlStateNormal];
    [self.progressSlider setMaximumTrackImage:[UIImage imageNamed:@"MaximumTrackImage"] forState:UIControlStateNormal];
    [self.progressSlider setMinimumTrackImage:[UIImage imageNamed:@"MinimumTrackImage"] forState:UIControlStateNormal];
    // 设置按钮状态
    self.playOrPauseBtn.selected = NO;
}
/** layoutSubViews 布局子控件 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.imageView.bounds;
}
/** 需要播放的视频资源set方法 */
-(void)setUrlString:(NSString *)urlString
{
    _urlString = urlString;
    NSURL *url = [NSURL URLWithString:urlString];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
}
/** 中间播放按钮点击 */
- (IBAction)playOrPauseBigBtnClick:(UIButton *)sender {
    sender.hidden = YES;
    self.playOrPauseBtn.selected = YES;
    // 替换界面
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.player play];
    [self addProgressTimer];
}

/** imageView的tap手势方法 */
-(void)tapAction:(UITapGestureRecognizer *)tap
{
    if (self.player.status == AVPlayerStatusUnknown) {
        [self playOrPauseBigBtnClick:self.playOrPauseBigBtn];
        return;
    }
    self.isShowToolView = !self.isShowToolView;
    if (self.isShowToolView){
        [UIView animateWithDuration:0.5 animations:^{
            self.toolView.alpha = 1;
        }];
        if (self.playOrPauseBtn.selected) {
            [self addShowTime];
        }
    }else{
        [self removeShowTime];
        [UIView animateWithDuration:0.5 animations:^{
            self.toolView.alpha = 0;
        }];
    }
}

/** toolView显示时开始计时，5s后隐藏toolView */
-(void)addShowTime
{
    self.showTime = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(upDateToolView) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop]addTimer:self.showTime forMode:NSRunLoopCommonModes];
}
/** 将toolView隐藏 */
-(void)upDateToolView
{
    self.isShowToolView = !self.isShowToolView;
    [UIView animateWithDuration:0.5 animations:^{
        self.toolView.alpha = 0;
    }];
    NSLog(@"timer显示或者隐藏");
}
-(void)removeShowTime
{
    [self.showTime invalidate];
    self.showTime = nil;
}
/** toolView上暂停按钮的点击事件 */
- (IBAction)playOrPauseBtnClick:(UIButton *)sender {
    // 播放状态按钮selected为YES,暂停状态selected为NO。
    sender.selected = !sender.selected;
    if (!sender.selected) {
        self.toolView.alpha = 1;
        [self removeShowTime];
        [self.player pause];
        [self removeProgressTimer];
    }else{
        [self addShowTime];
        [self.player play];
        [self addProgressTimer];
    }
}

/** slider定时器添加 */
-(void)addProgressTimer
{
//    self.progressTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop]addTimer:self.progressTimer forMode:NSRunLoopCommonModes];
    
    [self progressTimer];
}
/** 移除slider定时器 */
-(void)removeProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}
/** 更新slider和timeLabel */
- (void)updateProgressInfo
{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval durationTime = CMTimeGetSeconds(self.player.currentItem.duration);
    
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
    self.allTimeLabel.text = [self timeToStringWithTimeInterval:durationTime];
    self.progressSlider.value = CMTimeGetSeconds(self.player.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration);
    
    
    if (self.progressSlider.value == 1) {
        [self removeProgressTimer];
        self.coverView.hidden = NO;
        NSLog(@"播放完了");
    }
    
}

/** 转换播放时间和总时间的方法 */
-(NSString *)timeToStringWithTimeInterval:(NSTimeInterval)interval;
{
    NSInteger Min = interval / 60;
    NSInteger Sec = (NSInteger)interval % 60;
    NSString *intervalString = [NSString stringWithFormat:@"%02ld:%02ld",Min,Sec];
    return intervalString;
}

/** slider拖动和点击事件 */
- (IBAction)touchDownSlider:(UISlider *)sender {
    // 按下去 移除监听器
    [self removeProgressTimer];
    [self removeShowTime];
}
- (IBAction)valueChangedSlider:(UISlider *)sender {
    
    // 计算slider拖动的点对应的播放时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * sender.value;
    self.timeLabel.text = [self timeToStringWithTimeInterval:currentTime];
}
- (IBAction)touchUpInside:(UISlider *)sender {
    [self addProgressTimer];
    //计算当前slider拖动对应的播放时间
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentItem.duration) * sender.value;
    // 播放移动到当前播放时间
    [self.player seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self addShowTime];
}





/** 全屏按钮点击事件 */
- (IBAction)fullViewBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self videoplayViewSwitchOrientation:sender.selected];
}
/** 弹出全屏播放器 */
- (void)videoplayViewSwitchOrientation:(BOOL)isFull
{
    if (isFull) {
        [self.contrainerViewController presentViewController:self.fullVc animated:NO completion:^{
            [self.fullVc.view addSubview:self];
            self.center = self.fullVc.view.center;
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                self.frame = self.fullVc.view.bounds;
            } completion:nil];
        }];
    } else {
        [self.fullVc dismissViewControllerAnimated:NO completion:^{
            [self.contrainerViewController.view addSubview:self];
            
            [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
                self.frame = CGRectMake(0, 200, self.contrainerViewController.view.bounds.size.width, self.contrainerViewController.view.bounds.size.width * 9 / 16);
            } completion:nil];
        }];
    }
}
#pragma mark - 懒加载代码
- (CLFullViewController *)fullVc
{
    if (_fullVc == nil) {
        _fullVc = [[CLFullViewController alloc] init];
    }
    return _fullVc;
}

/** 重播按钮点击 */
- (IBAction)repeatBtnClick:(UIButton *)sender {
    
//    [self playOrPauseBigBtnClick:self.playOrPauseBigBtn];
    self.progressSlider.value = 0;
    [self touchUpInside:self.progressSlider];
    self.coverView.hidden = YES;
    [self playOrPauseBigBtnClick:self.playOrPauseBigBtn];
}



@end
