//
//  IMAVideoDisplay.h
//  InteractiveMediaAds
//
//  Declares a protocol describing a player capable of playing a stream.

@protocol IMAVideoDisplay;

@protocol IMAVideoDisplayDelegate<NSObject>

/**
 *  Informs the SDK that timed metadata was received.
 *
 *  @param videoDisplay The IMAVideoDisplay that received the timed metadata event
 *  @param metadata     The metadata dictionary received with the timed metadata event
 */
- (void)videoDisplay:(id<IMAVideoDisplay>)videoDisplay
    didReceiveTimedMetadata:(NSDictionary<NSString *, NSString *> *)metadata;

/**
 *  Informs the SDK that the current time of the stream was updated.
 *
 *  @param videoDisplay The IMAVideoDisplay that progressed
 *  @param currentTime  The current time of the stream being played
 */
- (void)videoDisplay:(id<IMAVideoDisplay>)videoDisplay
    didProgressToTime:(NSTimeInterval)currentTime;

/**
 *  Informs the SDK that the video display failed to play the stream.
 *
 *  @param videoDisplay The IMAVideoDisplay that failed to play the stream
 *  @param error        The NSError that cause playback to fail
 */
- (void)videoDisplay:(id<IMAVideoDisplay>)videoDisplay didFailWithError:(NSError *)error;

/**
 *  Informs the SDK that the video display is about to play a stream.
 *
 *  @param videoDisplay The IMAVideoDisplay that is ready to play a stream
 */
- (void)videoDisplayIsReadyForPlayback:(id<IMAVideoDisplay>)videoDisplay;

@end

/**
 *  Declares a protocol describing a player capable of playing a stream.
 */
@protocol IMAVideoDisplay<NSObject>

/**
 *  Allows the player to send events to the SDK.
 */
@property(nonatomic, weak) id<IMAVideoDisplayDelegate> delegate;

/**
 *  Called to inform the VideoDisplay to load the passed URL with the subtitles for the stream.
 *  Subtitles are available only for dynamic ad insertion VOD streams and can be ignored
 *  for client side ads or dynamic ad insertion live streams.
 *
 *  @param url        The URL of the stream
 *  @param subtitles  The subtitles for the stream. Each entry in the subtitles array is an
 *                    *NSDictionary* that corresponds to a language. Each dictionary will have a
 *                    *language* key with a two letter language string value and one or more
 *                    subtitle key/value pairs. Here's an example NSDictionary for English:
 *
 *                    "language" -> "en"
 *                    "webvtt" -> "https://somedomain/vtt/en.vtt"
 *                    "ttml" -> "https://somedomain/ttml/en.ttml"
 */
- (void)loadURL:(NSURL *)url withSubtitles:(NSArray<NSDictionary *> *)subtitles;

@end
