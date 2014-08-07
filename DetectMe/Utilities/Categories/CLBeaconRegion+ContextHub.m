//
//  CLBeaconRegion+ContextHub.m
//  DetectMe
//
//  Created by Joefrey Kibuule on 5/28/14.
//  Copyright (c) 2014 ChaiONE. All rights reserved.
//

#import "CLBeaconRegion+ContextHub.h"
#import <ContextHub/ContextHub.h>

NSString * const CCHEventNameKeyPath = @"event.name";
NSString * const CCHEventStateKeyPath = @"event.data.state";

NSString * const CCHEventNameBeaconIn = @"beacon_in";
NSString * const CCHEventNameBeaconOut = @"beacon_out";
NSString * const CCHEventNameBeaconChanged = @"beacon_changed";

NSString * const CCHEventStateBeaconIn = @"beacon_in";
NSString * const CCHEventStateBeaconOut = @"beacon_out";
NSString * const CCHEventStateBeaconChangedImmediate = @"immediate_state";
NSString * const CCHEventStateBeaconChangedNear = @"near_state";
NSString * const CCHEventStateBeaconChangedFar = @"far_state";

NSString * const CCHBeaconEventKeyPath = @"event.data.beacon";
NSString * const CCHBeaconEventIDKeyPath = @"event.data.beacon.name";
NSString * const CCHBeaconEventUUIDKeyPath = @"event.data.beacon.uuid";
NSString * const CCHBeaconEventMajorValueKeyPath = @"event.data.beacon.major";
NSString * const CCHBeaconEventMinorValueKeyPath = @"event.data.beacon.minor";

NSString * const CCHBeaconChangedEventRSSIKeyPath = @"event.data.beacon.rssi";
NSString * const CCHBeaconChangedEventProximityImmediate = @"immediate_state";
NSString * const CCHBeaconChangedEventProximityNear = @"near_state";
NSString * const CCHBeaconChangedEventProximityFar = @"far_state";

@implementation CLBeaconRegion (ContextHub)

// Creates a beacon from a notification object's data
+ (instancetype)beaconFromNotification:(NSNotification *)notification {
    NSDictionary *event = notification.object;
    
    // Lack of "beacon" key means this event is not from a beacon
    if (![event valueForKeyPath:CCHBeaconEventKeyPath]) {
        return nil;
    }
    
    return [CCHBeaconService regionForBeacon:[event valueForKeyPath:CCHBeaconEventKeyPath]];
    
    /*
    // Grab beacon data from event
    NSString *uuid = [event valueForKeyPath:CCHBeaconEventUUIDKeyPath];
    NSString *major = [event valueForKeyPath:CCHBeaconEventMajorValueKeyPath];
    NSString *minor = [event valueForKeyPath:CCHBeaconEventMinorValueKeyPath];
    NSString *identifer = [event valueForKeyPath:CCHBeaconEventIDKeyPath];
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] major:[major integerValue] minor:[minor integerValue] identifier:identifer];
    
    return beaconRegion;*/
}

// Tests to see if two beacons are the equal based on their UUID, major, and minor identifiers
- (BOOL)isEqualToBeacon:(CLBeaconRegion *)otherBeacon {
    if ([self.proximityUUID isEqual:otherBeacon.proximityUUID] && [self.major isEqual:otherBeacon.major] && [self.minor isEqual:otherBeacon.minor]) {
        return true;
    }
    
    return false;
}

// Determines if a beacon is equal to the same state as a notification from ContextHub (in, out, changed) 
- (BOOL)isEqualToBeaconFromNotification:(NSNotification *)notification withEvent:(NSString *)beaconEvent {
    CLBeaconRegion *notificationBeacon = [CLBeaconRegion beaconFromNotification:notification];
    
    if (![self isEqualToBeacon:notificationBeacon]) {
        return false;
    }
    
    NSDictionary *event = notification.object;
    NSString *eventName = [event valueForKeyPath:CCHEventNameKeyPath];
    
    if ([beaconEvent isEqualToString:CCHEventNameBeaconIn]) {
        if (![eventName isEqualToString:CCHEventNameBeaconIn]) {
            return false;
        }
    } else if ([beaconEvent isEqualToString:CCHEventNameBeaconOut]) {
        if (![eventName isEqualToString:CCHEventNameBeaconOut]) {
            return false;
        }
    } else if ([beaconEvent isEqualToString:CCHEventNameBeaconChanged]){
        if (![eventName isEqualToString:CCHEventNameBeaconChanged]) {
            return false;
        }
    }
    
    return true;
}

// Determines if a beacon is equal to the same proximity as a notification from ContextHub (immediate, near, far)
- (BOOL)isEqualToBeaconFromNotification:(NSNotification *)notification inProximity:(NSString *)beaconProximity {
    CLBeaconRegion *notificationBeacon = [CLBeaconRegion beaconFromNotification:notification];
    
    if (![self isEqualToBeacon:notificationBeacon]) {
        return false;
    }
    
    NSDictionary *event = notification.object;
    NSString *eventName = [event valueForKeyPath:CCHEventNameKeyPath];
    NSString *state = [event valueForKeyPath:CCHEventStateKeyPath];
    
    if ([beaconProximity isEqualToString:CCHEventStateBeaconChangedImmediate]) {
        if (![self isImmediateToBeaconWithEvent:eventName state:state]) {
            return false;
        }
    } else if ([beaconProximity isEqualToString:CCHEventStateBeaconChangedNear]) {
        if (![self isNearBeaconWithEvent:eventName state:state]) {
            return false;
        }
    } else if ([beaconProximity isEqualToString:CCHEventStateBeaconChangedFar]){
        if (![self isFarFromBeaconWithEvent:eventName state:state]) {
            return false;
        }
    }
    
    return true;
}

#pragma mark - Helper methods

- (BOOL)isImmediateToBeaconWithEvent:(NSString *)eventName state:(NSString *)state {
    return ([eventName isEqualToString:CCHEventNameBeaconChanged] && [state isEqualToString:CCHEventStateBeaconChangedImmediate]);
}

- (BOOL)isNearBeaconWithEvent:(NSString *)eventName state:(NSString *)state {
    return ([eventName isEqualToString:CCHEventNameBeaconChanged] && [state isEqualToString:CCHEventStateBeaconChangedNear]);
}

- (BOOL)isFarFromBeaconWithEvent:(NSString *)eventName state:(NSString *)state {
    return ([eventName isEqualToString:CCHEventNameBeaconChanged] && [state isEqualToString:CCHEventStateBeaconChangedFar]);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Beacon: %@, UUID: %@, Major #: %@, Minor #: %@", self.identifier, self.proximityUUID, self.major, self.minor];
}

@end