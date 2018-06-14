//
//  IMACompanion.h
//  InteractiveMediaAds
//
//  Represents metadata of a single companion.

#import <Foundation/Foundation.h>

/**
 * Simple data object containing metadata for a companion ad.
 */
@interface IMACompanion : NSObject

/**
 *  The URL for the static resource of this companion.
 */
@property(nonatomic, copy, readonly) NSString *staticResourceURL;

/**
 *  The API needed to execute this ad, or nil if unavailable.
 */
@property(nonatomic, copy, readonly) NSString *apiFramework;

/**
 *  The width of the companion in pixels. 0 if unavailable.
 */
@property(nonatomic, readonly) NSInteger width;

/**
 *  The height of the companion in pixels. 0 if unavailable.
 */
@property(nonatomic, readonly) NSInteger height;

- (instancetype)init NS_UNAVAILABLE;

@end
