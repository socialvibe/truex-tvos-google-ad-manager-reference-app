//
//  IMASettings.h
//  InteractiveMediaAds
//
//  Copyright © 2017 Google. All rights reserved.
//
//  Stores SDK wide settings. Only instantiated in the SDK.

#import <Foundation/Foundation.h>

/**
 *  The IMASettings class stores stream manager settings.
 */
@interface IMASettings : NSObject <NSCopying>

/**
 *  Toggles debug mode which will output detailed log information to the console.
 *  Debug mode should be disabled in Release. The default value is NO.
 */
@property(nonatomic) BOOL enableDebugMode;
@end
