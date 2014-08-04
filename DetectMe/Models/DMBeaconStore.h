//
//  DMBeaconStore.h
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString const *DMBeaconSyncCompletedNotification;

@class DMBeacon;

@interface DMBeaconStore : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *beacons;

+ (DMBeaconStore *)sharedInstance;

- (void)createBeaconWithUUID:(NSString *)uuidString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor name:(NSString *)name completionHandler:(void (^)(DMBeacon *beacon, NSError *error))completionHandler;
- (void)syncBeacons;
- (DMBeacon *)findBeaconInStoreWithID:(NSString *)beaconID;
- (void)updateBeacon:(DMBeacon *)beacon completionHandler:(void (^)(NSError *error))completionHandler;
- (void)deleteBeacon:(DMBeacon *)beacon completionHandler:(void (^)(NSError *error))completionHandler;

@end