//
//  IMAStreamRequest.h
//  InteractiveMediaAds
//
//  Abstract class representation of a stream request. This object is not meant to be created.

#import <Foundation/Foundation.h>

/**
 *  Data class describing the stream request.
 */
@interface IMAStreamRequest : NSObject

/**
 *  The stream request API key. It's configured through the
 *  <a href="//support.google.com/dfp_premium/answer/6381445">
 *  DFP Admin UI</a> and provided to the publisher to unlock their content.
 *  It verifies the applications that are attempting to access the content.
 */
@property(nonatomic, copy) NSString *apiKey;

/**
 *  The stream request authorization token. This is used in place of the API key for stricter
 *  content authorization. The publisher can control individual content streams authorized based
 *  on this token.
 */
@property(nonatomic, copy) NSString *authToken;

/**
 *  The ID to be used to debug the stream with the stream activity monitor. This is used to provide
 *  a convenient way to allow publishers to find a stream log in the stream activity monitor tool.
 */
@property(nonatomic, copy) NSString *streamActivityMonitorID;

/**
 *  You can override a limited set of ad tag parameters on your stream request.
 *  <a href="//support.google.com/dfp_premium/answer/7320899">
 *  Supply targeting parameters to your stream</a> provides more information.
 *
 *  You can use the dai-ot and dai-ov parameters for stream variant preference.
 *  See <a href="//support.google.com/dfp_premium/answer/7320898">
 *  Override Stream Variant Parameters</a> for more information.
 */
@property(nonatomic, copy) NSDictionary<NSString *, NSString *> *adTagParameters;

/**
 *  The suffix that the SDK will append to the query of the stream manifest URL. Do not include the
 *  '?' separator at the start. The SDK will account for the existence of parameters in the URL
 *  already, removing existing ones that collide with ones supplied here. This suffix needs to be
 *  sanitized and encoded as the SDK will not do this.
 */
@property(nonatomic, copy) NSString *manifestURLSuffix;

- (instancetype)init NS_UNAVAILABLE;

@end
