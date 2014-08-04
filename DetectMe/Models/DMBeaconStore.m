//
//  DMBeaconStore.m
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMBeaconStore.h"
#import <ContextHub/ContextHub.h>
#import "DMConstants.h"

#import "DMBeacon.h"

NSString const *DMBeaconSyncCompletedNotification = @"DMBeaconSyncCompletedNotification";

@interface DMBeaconStore ()
@property (nonatomic, readwrite, strong) NSMutableArray *beacons;
@end

@implementation DMBeaconStore

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static DMBeaconStore *shared = nil;
    
    dispatch_once(&pred, ^{
        shared = [[DMBeaconStore alloc] init];
    });
    
    return shared;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _beacons = [NSMutableArray array];
    }
    
    return self;
}

// Creates a beacon in ContextHub and keeps a copy in our store
- (void)createBeaconWithUUID:(NSString *)uuidString major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor name:(NSString *)name completionHandler:(void (^)(DMBeacon *beacon, NSError *error))completionHandler {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    
    if (completionHandler) {
        [[CCHBeaconService sharedInstance] createBeaconWithProximityUUID:uuid major:major minor:minor name:name tags:@[DMBeaconTag] completionHandler:^(NSDictionary *beacon, NSError *error) {
            
            if (!error) {
                DMBeacon *createdBeacon = [[DMBeacon alloc] initWithDictionary:beacon];
                [self.beacons addObject:createdBeacon];
                
                // Synchronize newly created beacon with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully created and synchronized beacon %@ on ContextHub", createdBeacon.name);
                        completionHandler (createdBeacon, nil);
                    } else {
                        NSLog(@"DM: Could not synchronize creation of beacon %@ on ContextHub", createdBeacon.name);
                        completionHandler (nil, error);
                    }
                }];
            } else {
                NSLog(@"DM: Could not create beacon %@ on ContextHub", name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Synchronizes beacons from ContextHub
- (void)syncBeacons {
    [[CCHBeaconService sharedInstance] getBeaconsWithTags:@[DMBeaconTag]  completionHandler:^(NSArray *beacons, NSError *error) {
        
        if (!error) {
            NSLog(@"DM: Succesfully synced %d new beacons from ContextHub", beacons.count - self.beacons.count);
            
            [self.beacons removeAllObjects];
            
            for (NSDictionary *beaconDict in beacons) {
                DMBeacon *beacon = [[DMBeacon alloc] initWithDictionary:beaconDict];
                [self.beacons addObject:beacon];
            }
            
            // Post notification that sync is complete
            [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)DMBeaconSyncCompletedNotification object:nil];
        } else {
            NSLog(@"DM: Could not sync beacons with ContextHub");
        }
    }];
}

// Find a beacon with a specific ID in our beacon store if it exists
- (DMBeacon *)findBeaconInStoreWithID:(NSString *)beaconID {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.beaconID like %@", beaconID];
    NSArray *filteredBeacons = [self.beacons filteredArrayUsingPredicate:predicate];
    
    if ([filteredBeacons count] > 0) {
        DMBeacon *foundBeacon = filteredBeacons[0];
        
        return foundBeacon;
    }
    
    return nil;
}

// Updates a beacon in ContextHub and in our store
- (void)updateBeacon:(DMBeacon *)beacon completionHandler:(void (^)(NSError *error))completionHandler; {
    
    if (completionHandler) {
        [[CCHBeaconService sharedInstance] updateBeacon:[beacon dictionaryForBeacon] completionHandler:^(NSError *error) {
           
            if (!error) {
                // Synchronize updated beacon with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully updated and synchronized beacon %@ on ContextHub", beacon.name);
                        completionHandler (nil);
                    } else {
                        NSLog(@"DM: Could not synchronize update of beacon %@ on ContextHub", beacon.name);
                        completionHandler (error);
                    }
                }];
            } else {
                NSLog(@"DM: Could not update beacon %@ on ContextHub", beacon.name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

// Delete a beacon in ContextHub and remove it from our store
- (void)deleteBeacon:(DMBeacon *)beacon completionHandler:(void (^)(NSError *error))completionHandler; {
    
    if (completionHandler) {
        
        // Remove beacon from our array
        if ([self.beacons containsObject:beacon]) {
            [self.beacons removeObject:beacon];
        }
        
        // Remove beacon from ContextHub
        [[CCHBeaconService sharedInstance] deleteBeacon:[beacon dictionaryForBeacon] completionHandler:^(NSError *error) {
            if (!error) {
                
                // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully deleted beacon %@ on ContextHub", beacon.name);
                        completionHandler(nil);
                    } else {
                        NSLog(@"DM: Could not synchronize deletion of beacon %@ on ContextHub", beacon.name);
                        completionHandler(error);
                    }
                }];
            } else {
                NSLog(@"DM: Could not delete beacon %@ on ContextHub", beacon.name);
            }
        }];
    } else {
        [NSException raise:NSInvalidArgumentException format:@"Did not pass completionHandler to method %@", NSStringFromSelector(_cmd)];
    }
}

@end