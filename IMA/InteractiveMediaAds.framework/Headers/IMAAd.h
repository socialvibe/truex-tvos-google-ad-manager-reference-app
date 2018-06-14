//
//  IMAAd.h
//  InteractiveMediaAds
//
//  Represents metadata of a single ad.

#import <Foundation/Foundation.h>

@class IMAAdBreakInfo;
@class IMACompanion;

/**
 *  Data object representation of a single ad.
 */
@interface IMAAd : NSObject

/**
 *  The ad ID as specified in the VAST response.
 */
@property(nonatomic, copy, readonly) NSString *adID;

/**
 *  The ad title from the VAST response.
 */
@property(nonatomic, copy, readonly) NSString *adTitle;

/**
 *  The ad system from the VAST response.
 */
@property(nonatomic, copy, readonly) NSString *adSystem;

/**
 *  The ad description.
 */
@property(nonatomic, copy, readonly) NSString *adDescription;

/**
 *  The advertiser name.
 */
@property(nonatomic, copy, readonly) NSString *advertiserName;

/**
 *  The ID for the selected creative of the inline ad.
 */
@property(nonatomic, copy, readonly) NSString *creativeID;

/**
 *  The Ad-ID for the selected creative of the inline ad.
 */
@property(nonatomic, copy, readonly) NSString *creativeAdID;

/**
 *  The deal ID for the inline ad.
 */
@property(nonatomic, copy, readonly) NSString *dealID;

/**
 *  The registry associated with cataloging the UniversalAdID of the selected creative for the ad.
 */
@property(nonatomic, copy, readonly) NSString *universalAdIDRegistry;

/**
 *  The UniversalAdID of the selected creative for the ad.
 */
@property(nonatomic, copy, readonly) NSString *universalAdIDValue;

/**
 *  The duration of the ad.
 */
@property(nonatomic, readonly) NSTimeInterval duration;

/**
 *  The position of the current ad in this ad break.
 */
@property(nonatomic, readonly) NSInteger adPosition;

/**
 *  Set of ad break properties.
 */
@property(nonatomic, strong, readonly) IMAAdBreakInfo *adBreakInfo;

/**
 *  The companion ads specified in the VAST response.
 */
@property(nonatomic, copy, readonly) NSArray<IMACompanion *> *companions;

/**
 *  The ad IDs for the wrapper ads, starting with the ad closest to inline.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *wrapperAdIDs;

/**
 *  The ad systems for the wrapper ads, starting with the ad closest to inline.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *wrapperAdSystems;

/**
 *  The creative IDs for the wrapper ads, starting with the ad closest to inline.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *wrapperCreativeIDs;

/**
 *  The deal IDs for the wrapper ads, starting with the ad closest to inline.
 */
@property(nonatomic, copy, readonly) NSArray<NSString *> *wrapperDealIDs;


- (instancetype)init NS_UNAVAILABLE;

@end
