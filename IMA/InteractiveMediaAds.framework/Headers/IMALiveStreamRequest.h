//
//  IMALiveStreamRequest.h
//  InteractiveMediaAds
//
//  Declares a representation of a stream request for live streams.
//

#import "IMAStreamRequest.h"

/**
 * Data object describing a live stream request.
 */

@interface IMALiveStreamRequest : IMAStreamRequest

/**
 * This is used to determine which stream should be played.
 * The live stream request asset key is an identifier which can be
 * <a href="https://goo.gl/wjL9DI">
 * found in the DFP UI</a>.
 *
 * @type {!string}
 */
@property(nonatomic, copy, readonly) NSString *assetKey;

/**
 *  Initializes a live stream request instance with the given assetKey.
 *
 *  @param assetKey The stream assetKey used to determine which stream should be played
 *
 *  @return The IMALIVEStreamRequest instance
 */
- (instancetype)initWithAssetKey:(NSString *)assetKey;

- (instancetype)init NS_UNAVAILABLE;

@end
