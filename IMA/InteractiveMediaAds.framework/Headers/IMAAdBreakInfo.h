//
//  IMAAdBreakInfo.h
//  InteractiveMediaAds
//
//  Represents metadata for a single ad break.

#import <Foundation/Foundation.h>

/**
 *  Simple data object containing ad break metadata.
 */
@interface IMAAdBreakInfo : NSObject

/**
 *  Total number of ads in this ad break. Will be 1 for standalone ads.
 */
@property(nonatomic, readonly) NSInteger totalAds;

/**
 *  The duration of the ad break in seconds.
 */
@property(nonatomic, readonly) NSTimeInterval duration;

/**
 *  The index of the ad break 0...N is returned regardless of whether the ad is a
 *  pre-, mid-, or post-roll. Defaults to -1 if this ad is not part of an ad break,
 *  or the break is not part of an ad playlist, or the stream is not VOD.
 */
@property(nonatomic, readonly) NSInteger adBreakIndex;

/**
 *  The stream time at which the current ad break was scheduled to start. Defaults
 *  to 0 if this ad is not part of an ad break, or the break is not part of an ad playlist,
 *  or the stream is not VOD.
 */
@property(nonatomic, readonly) NSTimeInterval timeOffset;

- (instancetype)init NS_UNAVAILABLE;

@end
