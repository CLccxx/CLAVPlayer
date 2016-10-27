//
//  ViewController.m
//  AVPlayerTest
//
//  Created by 杨博兴 on 16/10/27.
//  Copyright © 2016年 xx_cc. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CLAVPlayerView.h"

@interface ViewController ()

@property(nonatomic,strong)CLAVPlayerView *playView;

@end

@implementation ViewController





- (void)viewDidLoad {
    [super viewDidLoad];
    
//    CLAVPlayerView *playView = [[[NSBundle mainBundle]loadNibNamed:@"CLAVPlayerView" owner:nil options:nil]lastObject];

    [self setUpVideoPlayView];
    
    self.playView.urlString = @"http://120.25.226.186:32812/resources/videos/minion_02.mp4";
}


-(void)setUpVideoPlayView
{
    self.playView = [CLAVPlayerView videoPlayView];
    self.playView.frame = CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width * 9 / 16);
    self.playView.contrainerViewController = self;
    [self.view addSubview:self.playView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
