//
//  ViewController.m
//  DFP Integration Demo
//
//  Created by Avi Finkel on 6/13/18.
//  Copyright © 2018 True[X]. All rights reserved.
//

#import "ViewController.h"

@import AVKit;
@import InteractiveMediaAds;

@interface ViewController () <IMAStreamManagerDelegate>

@property AVPlayerViewController *playerViewController;
@property IMAAVPlayerVideoDisplay *videoDisplay;
@property IMAStreamManager *streamManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = [AVPlayer new];

    self.videoDisplay = [[IMAAVPlayerVideoDisplay alloc] initWithAVPlayer:self.playerViewController.player];

    IMAVODStreamRequest *streamRequest = [[IMAVODStreamRequest alloc] initWithContentSourceID:@"2479896" videoID:@"googleio-highlights"];

    self.streamManager = [[IMAStreamManager alloc] initWithVideoDisplay:self.videoDisplay];
    [self.streamManager requestStream:streamRequest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentViewController:self.playerViewController animated:false completion:nil];
}

- (void)streamManager:(IMAStreamManager *)streamManager adBreakDidStart:(IMAAdBreakInfo *)adBreakInfo {
    NSLog(@"%@", adBreakInfo);
}

- (void)streamManager:(IMAStreamManager *)streamManager didUpdateCuepoints:(NSArray<IMACuepoint *> *)cuepoints {
    for (IMACuepoint *cuepoint in cuepoints) {
        NSLog(@"%@", cuepoint);
    }
}

@end