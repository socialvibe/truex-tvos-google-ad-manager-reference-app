//
//  IMAVODStreamRequest.h
//  InteractiveMediaAds
//
//  Declares a representation of a stream request for on-demand streams.
//

#import "IMAStreamRequest.h"

/**
 * Data object describing a VOD stream request.
 */

@interface IMAVODStreamRequest : IMAStreamRequest

/**
 *  The stream request content source ID. This is used to determine the
 *  content source of the stream.
 */
@property(nonatomic, copy, readonly) NSString *contentSourceID;

/**
 *  The stream request video ID. This is used to determine which specific video
 *  stream should be played.
 */
@property(nonatomic, copy, readonly) NSString *videoID;

/**
 *  Initializes a VOD stream request instance with the given content source ID and video ID.
 *
 *  @param contentSourceID  The content source ID used to determine the content source
 *  @param videoID          The video ID used to determine the specific video
 *
 *  @return The IMAVODStreamRequest instance
 */
- (instancetype)initWithContentSourceID:(NSString *)contentSourceID videoID:(NSString *)videoID;

- (instancetype)init NS_UNAVAILABLE;

@end
