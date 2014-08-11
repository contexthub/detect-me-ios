//
//  DMEditBeaconViewController.m
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMEditBeaconViewController.h"
#import <ContextHub/ContextHub.h>

#import "DMBeacon.h"
#import "DMConstants.h"

@interface DMEditBeaconViewController ()

@property (nonatomic, weak) IBOutlet UITextField *nameTextField;
@property (nonatomic, weak) IBOutlet UITextField *uuidTextField;
@property (nonatomic, weak) IBOutlet UITextField *majorValueTextField;
@property (nonatomic, weak) IBOutlet UITextField *minorValueTextField;

@end

@implementation DMEditBeaconViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.beacon) {
        self.title = @"Edit Beacon";
        self.nameTextField.text = self.beacon.name;
        self.uuidTextField.text = self.beacon.beaconRegion.proximityUUID.UUIDString;
        self.majorValueTextField.text = self.beacon.beaconRegion.major.stringValue;
        self.minorValueTextField.text = self.beacon.beaconRegion.minor.stringValue;
    } else {
        self.title = @"New Beacon";
        UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
        self.navigationItem.leftBarButtonItem = editButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Beacons

- (void)createBeacon {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    
    if (uuid) {
        // Create a beacon from the DMBeaconStore
        CLBeaconMajorValue major = [self.majorValueTextField.text integerValue];
        CLBeaconMinorValue minor = [self.minorValueTextField.text integerValue];
        NSString *name = self.nameTextField.text;
        [[CCHBeaconService sharedInstance] createBeaconWithProximityUUID:uuid major:major minor:minor name:name tags:@[DMBeaconTag] completionHandler:^(NSDictionary *beacon, NSError *error) {
            
            if (!error) {
                
                if (self.verboseContextHubLogging) {
                    NSLog(@"DM: [CCHBeaconService createBeaconWithProximityUUID: major: minor: name: tags: completionHandler:] response: %@", beacon);
                }
                
                DMBeacon *createdBeacon = [[DMBeacon alloc] initWithDictionary:beacon];
                [self.beaconArray addObject:createdBeacon];
                
                // Synchronize newly created beacon with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully created and synchronized beacon %@ on ContextHub", createdBeacon.name);
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } else {
                        NSLog(@"DM: Could not synchronize creation of beacon %@ on ContextHub", createdBeacon.name);
                    }
                }];
            } else {
                NSLog(@"DM: Could not create beacon %@ on ContextHub", name);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error creating your beacon in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please re-enter a UUID in the correct 32-character format" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
}

- (void)updateBeacon {
    [self.beacon updateUUID:self.uuidTextField.text major:[self.majorValueTextField.text integerValue] minor:[self.minorValueTextField.text integerValue] identifier:self.nameTextField.text];
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:self.uuidTextField.text];
    
    if (uuid) {
        // Update the beacon
        NSMutableDictionary *beaconDict = [NSMutableDictionary dictionary];
        [beaconDict setValue:self.beacon.beaconRegion.proximityUUID.UUIDString forKey:@"uuid"];
        [beaconDict setValue:self.beacon.beaconRegion.major forKey:@"major"];
        [beaconDict setValue:self.beacon.beaconRegion.minor forKey:@"minor"];
        [beaconDict setValue:self.beacon.name forKey:@"name"];
        [beaconDict setValue:self.beacon.tags forKey:@"tags"];
        
        NSNumber *beaconID = [NSNumber numberWithInt:(int)[self.beacon.beaconID integerValue]];
        [beaconDict setValue:beaconID forKey:@"id"];
        
        [[CCHBeaconService sharedInstance] updateBeacon:beaconDict completionHandler:^(NSError *error) {
            
            if (!error) {
                // Synchronize updated beacon with sensor pipeline (this happens automatically if push is configured)
                [[CCHSensorPipeline sharedInstance] synchronize:^(NSError *error) {
                    
                    if (!error) {
                        NSLog(@"DM: Successfully updated and synchronized beacon %@ on ContextHub", self.beacon.name);
                        //[self.navigationController popViewControllerAnimated:YES];
                    } else {
                        NSLog(@"DM: Could not synchronize update of beacon %@ on ContextHub", self.beacon.name);
                    }
                }];
            } else {
                NSLog(@"DM: Could not update beacon %@ on ContextHub", self.beacon.name);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error creating your beacon in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please re-enter a UUID in the correct 32-character format" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
}

#pragma mark - Actions

- (void)cancelButtonTapped:(id)sender {
    if (self.beacon) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
    
    if (self.beacon) {
        [self updateBeacon];
    } else {
        [self createBeacon];
    }
}

#pragma mark - Table View Methods

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    [footer.textLabel setTextColor:[UIColor whiteColor]];
}

#pragma mark - Text Field Delegate Methods

// Move from one text field to the next with the "Done" button, register with the last button
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case 0:
            [self.uuidTextField becomeFirstResponder];
            
            break;
        case 1:
            [self.majorValueTextField becomeFirstResponder];
            
            break;
        case 2:
            [self.minorValueTextField becomeFirstResponder];
            
            break;
        case 3:
            [self doneButtonTapped:nil];
            
            break;
        default:
            
            break;
    }
    
    return NO;
}

@end