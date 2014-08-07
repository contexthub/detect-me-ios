//
//  DMDetectBeaconViewController.m
//  DetectMe
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMDetectBeaconViewController.h"
#import <ContextHub/ContextHub.h>

#import "DMBeacon.h"
#import "DMConstants.h"

#import "DMBeaconCell.h"
#import "DMEditBeaconViewController.h"

#import "CLBeaconRegion+ContextHub.h"

@interface DMDetectBeaconViewController ()
@property (nonatomic, weak) DMBeacon *selectedBeacon;
@end

@implementation DMDetectBeaconViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.beaconArray = [NSMutableArray array];
    
    self.verboseContextHubLogging = YES; // Verbose logging shows all responses from ContextHub
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do initial data sync
    [self refreshBeacons];
    
    // Register to listen to notification about sensor pipeline posting events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:CCHSensorPipelineDidPostEvent object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Beacons

- (void)refreshBeacons {
    [[CCHBeaconService sharedInstance] getBeaconsWithTags:@[DMBeaconTag] completionHandler:^(NSArray *beacons, NSError *error) {
        
        if (!error) {
            
            if (self.verboseContextHubLogging) {
                NSLog(@"DM: [CCHBeaconService getBeaconsWithTags: completionHandler:] response: %@", beacons);
            }
            
            NSLog(@"DM: Succesfully synced %d new beacons from ContextHub", (int)(beacons.count - self.beaconArray.count));
            
            [self.beaconArray removeAllObjects];
            
            for (NSDictionary *beaconDict in beacons) {
                DMBeacon *beacon = [[DMBeacon alloc] initWithDictionary:beaconDict];
                [self.beaconArray addObject:beacon];
            }
            
            
        } else {
            NSLog(@"DM: Could not sync beacons with ContextHub");
        }
    }];
}

#pragma mark - Actions

// Edit/Done button was tapped
- (IBAction)toggleEditing:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    // Update button UI
    [self updateEditButtonUI];
}

// Update button UI
- (void)updateEditButtonUI {
    UIBarButtonSystemItem editButtonType = self.tableView.editing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:editButtonType target:self action:@selector(toggleEditing:)];
    self.navigationItem.leftBarButtonItem = editButtonItem;
}

#pragma mark - Events

// Handle an event from ContextHub
- (void)handleEvent:(NSNotification *)notification {
    NSDictionary *event = notification.object;
    
    // Check and make sure it's a beacon event
    if ([event valueForKeyPath:CCHBeaconEventKeyPath]) {
        NSLog(@"event: %@", event);
        // Get the name of the beacon from the ID, look inside our store
        NSString *beaconID = [event valueForKeyPath:CCHBeaconEventIDKeyPath];
        
        // Find the beacon we are interested in (if it exists)
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.beaconID like %@", beaconID];
        NSArray *filteredBeacons = [self.beaconArray filteredArrayUsingPredicate:predicate];
        
        DMBeacon *foundBeacon = nil;
        if ([filteredBeacons count] > 0) {
            foundBeacon = filteredBeacons[0];
        }
        
        // Check and see if we know about this beacon
        if (foundBeacon) {
            NSLog(@"event name key: %@", [event valueForKeyPath:CCHEventNameKeyPath]);
            
            if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconIn) {
                foundBeacon.beaconState = CCHEventStateBeaconIn;
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconOut)  {
                foundBeacon.beaconState = CCHEventStateBeaconOut;
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconChanged)  {
                foundBeacon.beaconState = CCHEventStateBeaconIn;
                
                // Save the proximity state when we have a beacon changed event
                foundBeacon.proximityState = [event valueForKeyPath:CCHEventStateKeyPath];
            }
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editBeaconSegue"]) {
        DMEditBeaconViewController *editVC = segue.destinationViewController;
        editVC.beacon = self.beaconArray[[self.tableView indexPathForSelectedRow].row];
        editVC.verboseContextHubLogging = self.verboseContextHubLogging;
        editVC.beaconArray = self.beaconArray;
    }
}

- (IBAction)unwindToDetectBeaconVC:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Table View Methods

// Number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.beaconArray.count;
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DMBeaconCellIdentifier"];
    DMBeacon *beacon = self.beaconArray[indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"Name: %@", beacon.name];
    cell.uuidLabel.text = beacon.beaconRegion.proximityUUID.UUIDString;
    cell.majorLabel.text = [NSString stringWithFormat:@"Major: %ld", (long)[beacon.beaconRegion.major integerValue]];
    cell.minorLabel.text = [NSString stringWithFormat:@"Minor: %ld", (long)[beacon.beaconRegion.minor integerValue]];
    
    if ([beacon.beaconState isEqualToString:CCHEventStateBeaconIn]) {
        cell.beaconStateLabel.text = @"In";
        cell.beaconStateLabel.textColor = [UIColor colorWithRed:0.0 green:0.375 blue:0.0 alpha:1.0];
        
        if ([beacon.proximityState isEqualToString:CCHEventStateBeaconChangedImmediate]) {
            cell.proximityStateLabel.text = @"Immediate";
            cell.proximityStateLabel.textColor = [UIColor greenColor];
        } else if ([beacon.proximityState isEqualToString:CCHEventStateBeaconChangedImmediate]) {
            cell.proximityStateLabel.text = @"Near";
            cell.proximityStateLabel.textColor = [UIColor yellowColor];
        } else if ([beacon.proximityState isEqualToString:CCHEventStateBeaconChangedImmediate]) {
            cell.proximityStateLabel.text = @"Far";
            cell.proximityStateLabel.textColor = [UIColor redColor];
        } else {
            cell.proximityStateLabel.text = @"Unknown";
            cell.proximityStateLabel.textColor = [UIColor blueColor];
        }
    } else if ([beacon.beaconState isEqualToString:CCHEventStateBeaconOut]) {
        cell.beaconStateLabel.text = @"Out";
        cell.beaconStateLabel.textColor = [UIColor redColor];
        cell.proximityStateLabel.text = @"N/A";
    } else {
        cell.beaconStateLabel.text = @"Unknown";
        cell.beaconStateLabel.textColor = [UIColor blueColor];
        cell.proximityStateLabel.text = @"Unknown";
        cell.proximityStateLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

// A row is being updated/deleted
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete a beacon
        DMBeacon *beaconToDelete = self.beaconArray[indexPath.row];
        
        // Delete the geofence
        NSMutableDictionary *beaconDict = [NSMutableDictionary dictionary];
        [beaconDict setValue:beaconToDelete.beaconRegion.proximityUUID.UUIDString forKey:@"uuid"];
        [beaconDict setValue:beaconToDelete.beaconRegion.major forKey:@"major"];
        [beaconDict setValue:beaconToDelete.beaconRegion.minor forKey:@"minor"];
        [beaconDict setValue:beaconToDelete.name forKey:@"name"];
        [beaconDict setValue:beaconToDelete.beaconID forKey:@"id"];
        [beaconDict setValue:beaconToDelete.tags forKey:@"tags"];
        
        // Remove beacon from our array
        if ([self.beaconArray containsObject:beaconToDelete]) {
            [self.beaconArray removeObject:beaconToDelete];
        }
        
        // Remove beacon from ContextHub
        [[CCHBeaconService sharedInstance] deleteBeacon:beaconDict completionHandler:^(NSError *error) {
            if (!error) {
                
                // Synchronize the sensor pipeline with ContextHub (if you have push set up correctly, you can skip this step!)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully deleted beacon %@ on ContextHub", beaconToDelete.name);
                        
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        
                        [self refreshBeacons];
                    } else {
                        NSLog(@"DM: Could not synchronize deletion of beacon %@ on ContextHub", beaconToDelete.name);
                    }
                    
                    // Stop table editing
                    [self.tableView setEditing:FALSE animated:YES];
                    [self updateEditButtonUI];
                }];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting beacon from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                NSLog(@"DM: Could not delete beacon %@ on ContextHub", beaconToDelete.name);
            }
        }];
    }
}

@end