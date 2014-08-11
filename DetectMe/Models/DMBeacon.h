//
//  DMBeacon.h
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DMBeacon : NSObject

@property (nonatomic, copy, readonly) NSString *beaconID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, copy) NSString *beaconState;
@property (nonatomic, copy) NSString *proximityState;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (void)updateUUID:(NSString *)uuidString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier;

@end