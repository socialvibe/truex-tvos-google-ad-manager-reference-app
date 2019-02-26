//
//  ViewController.m
//  DFP Integration Demo
//
//  Copyright © 2018 true[X]. All rights reserved.
//

#import "ViewController.h"

@import AVKit;
@import InteractiveMediaAds;
@import TruexAdRenderer;

@interface ViewController () <IMAStreamManagerDelegate, TruexAdRendererDelegate>

// These three properties allow us to do the basic work of playing back ad-stitched video.
@property AVPlayerViewController *playerViewController;
@property IMAAVPlayerVideoDisplay *videoDisplay;
@property IMAStreamManager *streamManager;

// The renderer that drives the true[X] Engagement experience.
@property TruexAdRenderer *tar; // [2]

// We keep track of which ad break we're in so we know how far to seek when skipping it.
@property IMAAdBreakInfo *currentAdBreak; // [1]

@end

@implementation ViewController

//MARK: - View Controller Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = [AVPlayer new];

    self.videoDisplay = [[IMAAVPlayerVideoDisplay alloc] initWithAVPlayer:self.playerViewController.player];
    IMAVODStreamRequest *streamRequest = [[IMAVODStreamRequest alloc] initWithContentSourceID:@"2494430"
                                                                                      videoID:@"googleio-highlights"];
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
    // Keep track of this for later use. adBreakDidStart should fire before adDidStart in all cases.
    self.currentAdBreak = adBreakInfo; // [1]
}

- (void)streamManager:(IMAStreamManager *)streamManager adDidStart:(IMAAd *)ad {
    // The true[X] Engagement information is stored in a VAST companion ad, so we look through all
    // available companions to see if there's anything to work with.
    for (IMACompanion *companion in ad.companions) {
        if ([companion.apiFramework isEqualToString:@"truex"]) { // [2]
            // We pause the underlying stream in order to present the true[X] experience and seek over the current ad,
            // which is just a placeholder for the true[X] ad.
            [self.playerViewController.player pause]; // [3]
            CMTime seekTime = CMTimeAdd(
                    self.playerViewController.player.currentTime,
                    CMTimeMakeWithSeconds(ad.duration, 1000)
            );
            [self.playerViewController.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
            // The companion ad contains a URL (the "static resource URL") which tells us where to go to get the
            // ad parameters for our Engagement.
            NSString* base64Config = [companion.staticResourceURL componentsSeparatedByString:@","][1];
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64Config
                                                                      options:NSDataBase64DecodingIgnoreUnknownCharacters];
            NSError* jsonError;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:decodedData
                                                                     options:kNilOptions
                                                                       error:&jsonError];
            if (jsonError) {
                break;
            }
            NSString *slotType = self.currentAdBreak.adBreakIndex == 0 ? PREROLL : MIDROLL;
            self.tar = [[TruexAdRenderer alloc] initWithUrl:@"https://media.truex.com/placeholder.js"
                                               adParameters:jsonDict
                                                   slotType:slotType]; // [5]
            self.tar.delegate = self;

            break;
        }
    }
}

// These next two methods are required in the IMAStreamManagerDelegate protocol, but there's nothing we need to do in
// them for the purposes of this integration demo, so we leave the bodies empty.
- (void)streamManager:(IMAStreamManager *)streamManager didReceiveError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)streamManager:(IMAStreamManager *)streamManager didInitializeStream:(NSString *)streamID {
    NSLog(@"Did initialize stream: %@", streamID);
}

// MARK: - true[X] Ad Renderer Delegate Methods

// A real application would probably have something to do here, but there's nothing we're strictly required to
// do here in the simplest case.
-(void) onAdStarted:(NSString*)campaignName {
}

// This method is invoked when the viewer has earned their true[ATTENTION] credit. Since in this example their reward
// is getting to skip the ads, here we seek over the linear ad pod and into the content. Note that we don't re-enable
// playback here; the viewer might stay in their engagements for quite a while after they've earned their credit. However,
// by seeking now, we can have the play head at the right place when the viewer is ready.
-(void) onAdFreePod { // [6]
    CMTime seekTime = CMTimeMakeWithSeconds(self.currentAdBreak.timeOffset + self.currentAdBreak.duration, 1000);
    [self.playerViewController.player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

// The next three methods are all invoked when the engagement has, for whatever reason, stopped running. In all of these
// cases, we can just resume playback of the player. If the viewer has earned their true[ATTENTION] credit, then they will
// already be seeked past the ad pod, so they will se content. If not, then the playhead will still be at the beginning
// of the ad pod, so on resume, the viewer will see the ads.
-(void) onAdCompleted:(NSInteger)timeSpent { // [7]
    [self.playerViewController.player play];
}

-(void) onAdError:(NSString *)errorMessage { // [7]
    [self.playerViewController.player play];
}

-(void) onNoAdsAvailable { // [7]
    [self.playerViewController.player play];
}

// This is invoked when the user presses the menu button on the TV remote while the renderer is still showing the
// engagement choice card. In that case, we assume the user wants to cancel the whole stream, not just the true[X]
// experience, so we dismiss the view controller, exiting the app. Of course, in a real media app, this would instead
// go back to the episode list view, or whatever is appropriate.
-(void) onUserCancelStream { // [8]
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Finally, this method is invoked after the renderer has finished initialization, and since we always initialize the
// renderer right before we want to play, we just immediately begin playback.
-(void) onFetchAdComplete {
    [self.tar start:self.playerViewController]; // [5]
}

@end
