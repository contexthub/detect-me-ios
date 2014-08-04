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
#import "DMBeaconStore.h"

#import "DMBeaconCell.h"
#import "DMEditBeaconViewController.h"

#import "CLBeaconRegion+ContextHub.h"

@interface DMDetectBeaconViewController ()
@property (nonatomic, weak) DMBeacon *selectedBeacon;
@end

@implementation DMDetectBeaconViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do initial data sync
    [[DMBeaconStore sharedInstance] syncBeacons];
    
    // Register to listen to notification about sensor pipeline posting events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:CCHSensorPipelineDidPostEvent object:nil];
    
    // Register to listen to notifications about beacon sync being completed
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCompleted:) name:(NSString *)DMBeaconSyncCompletedNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        
        // Get the name of the beacon from the ID, look inside our store
        NSString *beaconID = [event valueForKeyPath:CCHBeaconEventIDKeyPath];
        DMBeacon *beacon = [[DMBeaconStore sharedInstance] findBeaconInStoreWithID:beaconID];
        
        // Check and see if we know about this beacon
        if (beacon) {
            
            if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconIn) {
                beacon.beaconState = CCHEventStateBeaconIn;
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconOut)  {
                beacon.beaconState = CCHEventStateBeaconOut;
            } else if ([event valueForKeyPath:CCHEventNameKeyPath] == CCHEventNameBeaconChanged)  {
                beacon.beaconState = CCHEventStateBeaconIn;
                
                // Save the proximity state when we have a beacon changed event
                beacon.proximityState = [event valueForKeyPath:CCHEventStateKeyPath];
            }
        }
    }
}

// Respond to synchronization finishing by removing and adding all beacons
- (void)syncCompleted:(NSNotification *)notification {
    [self.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editBeaconSegue"]) {
        DMEditBeaconViewController *editVC = segue.destinationViewController;
        editVC.beacon = [DMBeaconStore sharedInstance].beacons[[self.tableView indexPathForSelectedRow].row];
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
    return [DMBeaconStore sharedInstance].beacons.count;
}

// Information for a row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DMBeaconCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DMBeaconCellIdentifier"];
    DMBeacon *beacon = [DMBeaconStore sharedInstance].beacons[indexPath.row];
    
    cell.nameLabel.text = [NSString stringWithFormat:@"Name: %@", beacon.name];
    cell.uuidLabel.text = beacon.beaconRegion.proximityUUID.UUIDString;
    cell.majorLabel.text = [NSString stringWithFormat:@"Major: %d", [beacon.beaconRegion.major integerValue]];
    cell.minorLabel.text = [NSString stringWithFormat:@"Minor: %d", [beacon.beaconRegion.minor integerValue]];
    
    if ([beacon.beaconState isEqualToString:CCHEventStateBeaconIn]) {
        cell.beaconStateLabel.text = @"In";
        cell.beaconStateLabel.textColor = [UIColor greenColor];
        
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
        DMBeacon *beaconToDelete = [DMBeaconStore sharedInstance].beacons[indexPath.row];
        [[DMBeaconStore sharedInstance] deleteBeacon:beaconToDelete completionHandler:^(NSError *error) {
            
            if (!error) {
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                // Synchronize beacons (this would not need to be done if push were enabled)
                [[DMBeaconStore sharedInstance] syncBeacons];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Error deleting beacon from ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
            
            // Stop table editing
            [self.tableView setEditing:FALSE animated:YES];
            [self updateEditButtonUI];
        }];
    }
}

@end