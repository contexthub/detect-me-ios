//
//  DMBeacon.m
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMBeacon.h"
#import <ContextHub/ContextHub.h>

#import "CLBeaconRegion+ContextHub.h"

@interface DMBeacon()
@property (nonatomic, strong) NSMutableDictionary *beaconDict;
@end

@implementation DMBeacon

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    
    if (self) {
        _beaconID = [NSString stringWithFormat:@"%ld", (long)[dictionary[@"id"] integerValue]];
        _name = dictionary[@"name"];
        _tags = dictionary[@"tags"];
        _beaconRegion = [CCHBeaconService regionForBeacon:dictionary];
        
        // Default state for a beacon is beacon out, proximity is nil
        _beaconState = CCHEventStateBeaconOut;
        _proximityState = @"";
        
        // Make a mutable copy which dictionaryForBeacon will update
        _beaconDict = [dictionary mutableCopy];
    }
    
    return self;
}

- (void)updateUUID:(NSString *)uuidString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    self.name = identifier;
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:major minor:minor identifier:self.name];
}

- (NSDictionary *)dictionaryForBeacon {
    [self.beaconDict setValue:self.beaconRegion.proximityUUID.UUIDString forKey:@"uuid"];
    [self.beaconDict setValue:self.beaconRegion.major forKey:@"major"];
    [self.beaconDict setValue:self.beaconRegion.minor forKey:@"minor"];
    [self.beaconDict setValue:self.name forKey:@"name"];
    
    [self.beaconDict setValue:self.tags forKey:@"tags"];
    
    return self.beaconDict;
}

@end