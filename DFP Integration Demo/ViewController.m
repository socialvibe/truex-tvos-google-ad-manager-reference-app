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
@import TruexAdRenderer;

@interface ViewController () <IMAStreamManagerDelegate, TruexAdRendererDelegate>

@property AVPlayerViewController *playerViewController;
@property IMAAVPlayerVideoDisplay *videoDisplay;
@property IMAStreamManager *streamManager;

@property TruexAdRenderer *tar;

@property IMAAdBreakInfo *currentAdBreak;

@end

@implementation ViewController


//MARK: - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = [AVPlayer new];

    self.videoDisplay = [[IMAAVPlayerVideoDisplay alloc] initWithAVPlayer:self.playerViewController.player];

    IMAVODStreamRequest *streamRequest = [[IMAVODStreamRequest alloc] initWithContentSourceID:@"2479896" videoID:@"googleio-highlights"];

    self.streamManager = [[IMAStreamManager alloc] initWithVideoDisplay:self.videoDisplay];
    self.streamManager.delegate = self;
    [self.streamManager requestStream:streamRequest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentViewController:self.playerViewController animated:false completion:nil];
}

//MARK: - IMA Stream Manager Delegate Methods

- (void)streamManager:(IMAStreamManager *)streamManager adBreakDidStart:(IMAAdBreakInfo *)adBreakInfo {
    self.currentAdBreak = adBreakInfo;
}

- (void)streamManager:(IMAStreamManager *)streamManager adDidStart:(IMAAd *)ad {
    for (IMACompanion *companion in ad.companions) {
        if ([companion.apiFramework isEqualToString:@"truex"]) {
            [self.playerViewController.player pause];
            // Do that True[X] thing
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:companion.staticResourceURL]];
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *slotType;
                if (self.currentAdBreak.adBreakIndex == 0) {
                    slotType = PREROLL;
                }
                else {
                    slotType = MIDROLL;
                }
                self.tar = [[TruexAdRenderer alloc] initWithUrl:@"https://media.truex.com/placeholder.js" adParameters:jsonDict slotType:slotType];
                self.tar.delegate = self;
            }];
            [task resume];
            break;
        }
    }
}

- (void)streamManager:(IMAStreamManager *)streamManager didReceiveError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)streamManager:(IMAStreamManager *)streamManager didInitializeStream:(NSString *)streamID {
    NSLog(@"Did initialize stream: %@", streamID);
}

// MARK: - True[X] Ad Renderer Delegate Methods

-(void) onAdStarted:(NSString*)campaignName {
}

-(void) onAdCompleted:(NSInteger)timeSpent {
    [self.playerViewController.player play];
}

-(void) onAdError:(NSString *)errorMessage {
    [self.playerViewController.player play];
}

-(void) onNoAdsAvailable {
    [self.playerViewController.player play];
}

-(void) onAdFreePod {
    CMTime seekTime = CMTimeAdd(
        self.playerViewController.player.currentTime,
        CMTimeMakeWithSeconds(self.currentAdBreak.duration, 1000)
    );
    [self.playerViewController.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void) onUserCancelStream {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) onFetchAdComplete {
    if (self.tar) {
        [self.tar start:self.playerViewController];
    }
}

@end