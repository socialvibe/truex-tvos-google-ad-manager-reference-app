//
//  IMAStreamManager.h
//  InteractiveMediaAds
//

#import <Foundation/Foundation.h>

#import "IMAAd.h"
#import "IMAAdBreakInfo.h"
#import "IMAStreamRequest.h"

@protocol IMAVideoDisplay;

@class IMACuepoint;
@class IMASettings;
@class IMAStreamManager;

/**
 *  A callback protocol for IMAStreamManager.
 */
@protocol IMAStreamManagerDelegate<NSObject>

/**
 *  Called when the stream is initialized.
 *
 *  @param streamManager The IMAStreamManager that initialized the stream
 *  @param streamID      The streamID for this stream
 */
- (void)streamManager:(IMAStreamManager *)streamManager didInitializeStream:(NSString *)streamID;

/**
 *  Called when there is an error.
 *
 *  @param streamManager The IMAStreamManager receiving the error
 *  @param error         The NSError received by the stream manager
 */
- (void)streamManager:(IMAStreamManager *)streamManager didReceiveError:(NSError *)error;

@optional

/**
 *  Called when the stream is ready for playback.
 *
 *  @param streamManager  The IMAStreamManager that is ready for stream playback
 */
- (void)streamManagerIsReadyForPlayback:(IMAStreamManager *)streamManager;

/**
 *  Called when an ad break starts.
 *
 *  @param streamManager  The IMAStreamManager starting the ad break
 *  @param adBreakInfo    The IMAAdBreakInfo of the break that is starting
 */
- (void)streamManager:(IMAStreamManager *)streamManager
      adBreakDidStart:(IMAAdBreakInfo *)adBreakInfo;

/**
 *  Called when when the first frame of an ad is played.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that was started
 */
- (void)streamManager:(IMAStreamManager *)streamManager adDidStart:(IMAAd *)ad;

/**
 *  Called when an ad crosses the first quartile mark.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that crossed the first quartile mark
 */
- (void)streamManager:(IMAStreamManager *)streamManager adDidCrossFirstQuartile:(IMAAd *)ad;

/**
 *  Called when an ad crosses the midpoint mark.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that crossed the midpoint mark
 */
- (void)streamManager:(IMAStreamManager *)streamManager adDidCrossMidpoint:(IMAAd *)ad;

/**
 *  Called when an ad crosses the third quartile mark.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that crossed the third quartile mark
 */
- (void)streamManager:(IMAStreamManager *)streamManager adDidCrossThirdQuartile:(IMAAd *)ad;

/**
 *  Called when the last frame of an ad is played.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that was completed
 */
- (void)streamManager:(IMAStreamManager *)streamManager adDidComplete:(IMAAd *)ad;

/**
 *  Called when an ad break ends.
 *
 *  @param streamManager  The IMAStreamManager ending the ad break
 *  @param adBreakInfo    The IMAAdBreakInfo of the break that is ending
 */
- (void)streamManager:(IMAStreamManager *)streamManager adBreakDidEnd:(IMAAdBreakInfo *)adBreakInfo;

/**
 *  Called when the ad counts down to a new time.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param ad             The IMAAd that is being played
 *  @param remainingTime  The time remaining for the current ad
 */
- (void)streamManager:(IMAStreamManager *)streamManager
                   ad:(IMAAd *)ad
       didCountdownTo:(NSTimeInterval)remainingTime;

/**
 *  Called when the cuepoints for the current stream are updated.
 *
 *  @param streamManager  The IMAStreamManager playing the ad
 *  @param cuepoints      The array of cuepoints. Each cuepoint will be a dictionary with
 *                        two keys, "start" and "end", which indicate the start and the end
 *                        of the ad break respectively
 */
- (void)streamManager:(IMAStreamManager *)streamManager
    didUpdateCuepoints:(NSArray<IMACuepoint *> *)cuepoints;

@end

/**
 *  Stream manager for requesting and handling stream playback. All methods and properties of the
 *  stream manager should be called or accessed from the main thread.
 */
@interface IMAStreamManager : NSObject

/**
 *  The stream manager delegate.
 */
@property(nonatomic, weak) id<IMAStreamManagerDelegate> delegate;

/**
 *  The video display used for stream playback.
 */
@property(nonatomic, strong, readonly) id<IMAVideoDisplay> videoDisplay;

/**
 *  Stream manager settings. Note that certain settings will only be evaluated during
 *  initialization of the stream manager.
 */
@property(nonatomic, strong, readonly) IMASettings *settings;

/**
 *  Constructs a stream manager with the given video display.
 *
 *  @param videoDisplay The video display used for stream playback
 *
 *  @return An IMAStreamManager instance
 */
- (instancetype)initWithVideoDisplay:(id<IMAVideoDisplay>)videoDisplay;

/**
 *  Constructs a stream manager with the given video display and settings.
 *
 *  @param videoDisplay The video display used for stream playback
 *  @param settings     The settings used to configure stream playback
 *
 *  @return An IMAStreamManager instance
 */
- (instancetype)initWithVideoDisplay:(id<IMAVideoDisplay>)videoDisplay
                            settings:(IMASettings *)settings;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Requests a stream for playback and plays it in the video display.
 *
 *  @param streamRequest  The IMAStreamRequest containing information about the stream to be played
 */
- (void)requestStream:(IMAStreamRequest *)streamRequest;

/**
 *  Returns the stream time with ads for a given content time. Returns the given content time for
 *  live streams.
 *
 *  @param contentTime   The content time without any ads (in seconds)
 *
 *  @return The stream time that corresponds with the given content time once ads are inserted
 */
- (NSTimeInterval)streamTimeForContentTime:(NSTimeInterval)contentTime;

/**
 *  Returns the content time without ads for a given stream time. Returns the given stream time for
 *  live streams.
 *
 *  @param streamTime   The stream time with inserted ads (in seconds)
 *
 *  @return The content time that corresponds with the given stream time once ads are removed
 */
- (NSTimeInterval)contentTimeForStreamTime:(NSTimeInterval)streamTime;

/**
 *  Returns the previous cuepoint for the given stream time. Retuns nil if no such cuepoint exists.
 *
 *  @param streamTime   The stream time that the was seeked to.
 *
 *  @return The previous IMACuepoint for the given stream time.
 */
- (IMACuepoint *)previousCuepointForStreamTime:(NSTimeInterval)streamTime;

@end
