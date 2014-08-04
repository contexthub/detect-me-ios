//
//  CLBeaconRegion+ContextHub.h
//  DetectMe
//
//  Created by Joefrey Kibuule on 5/28/14.
//  Copyright (c) 2014 ChaiONE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const CCHEventNameKeyPath;
extern NSString * const CCHEventStateKeyPath;

extern NSString * const CCHEventNameBeaconIn;
extern NSString * const CCHEventNameBeaconOut;
extern NSString * const CCHEventNameBeaconChanged;

extern NSString * const CCHEventStateBeaconIn;
extern NSString * const CCHEventStateBeaconOut;
extern NSString * const CCHEventStateBeaconChangedImmediate;
extern NSString * const CCHEventStateBeaconChangedNear;
extern NSString * const CCHEventStateBeaconChangedFar;

extern NSString * const CCHBeaconEventKeyPath;
extern NSString * const CCHBeaconEventIDKeyPath;
extern NSString * const CCHBeaconEventUUIDKeyPath;
extern NSString * const CCHBeaconEventMajorValueKeyPath;
extern NSString * const CCHBeaconEventMinorValueKeyPath;

extern NSString * const CCHBeaconChangedEventRSSIKeyPath;
extern NSString * const CCHBeaconChangedEventProximityImmediate;
extern NSString * const CCHBeaconChangedEventProximityNear;
extern NSString * const CCHBeaconChangedEventProximityFar;

/**
 The ContextHub category extensions to CLBeaconRegion allow for easy retrieval and comparison of beacons generated from CCHSensorPipeline events
 */
@interface CLBeaconRegion (ContextHub)

/**
 Create a CLBeaconRegion object from a NSNotification object made when ContextHub detects a new beacon
 @param notification notification object containing information about the beacon which triggered an event
 */
+ (instancetype)beaconFromNotification:(NSNotification *)notification;

/**
 Determines whether this CLBeaconRegion and another CLBeaconRegion are the equal based on UUID, major and minor values
 @param otherBeacon beacon to be compared against
 */
- (BOOL)isEqualToBeacon:(CLBeaconRegion *)otherBeacon;

/**
 Determines if a beacon is equal to the same state as a notification from ContextHub (in, out, changed) 
 @param notification notification object containing information about the beacon which triggered an event
 @param beaconEvent event name for the beacon (CCHEventNameBeaconIn, CCHEventNameBeaconOut, CCHEventNameBeaconChanged)
 */
- (BOOL)isEqualToBeaconFromNotification:(NSNotification *)notification withEvent:(NSString *)beaconEvent;

/**
 Determines if a beacon is equal to the same proximity as a notification from ContextHub (immediate, near, far)
 @param notification notification object containing information about the beacon which triggered an event
 @param beaconProximity proximity which the beacon is in (CCHEventStateBeaconChangedImmediate, CCHEventStateBeaconChangedNear, CCHEventStateBeaconChangedFar)
 */
- (BOOL)isEqualToBeaconFromNotification:(NSNotification *)notification inProximity:(NSString *)beaconProximity;

@end