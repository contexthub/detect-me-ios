//
//  DMEditBeaconViewController.m
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMEditBeaconViewController.h"

#import "DMBeacon.h"
#import "DMBeaconStore.h"

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
        [[DMBeaconStore sharedInstance] createBeaconWithUUID:self.uuidTextField.text major:[self.majorValueTextField.text integerValue] minor:[self.minorValueTextField.text integerValue] name:self.nameTextField.text completionHandler:^(DMBeacon *beacon, NSError *error) {
            
            if (!error) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error creating your beacon in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
            }
        }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please re-enter a UUID in the correct 32-character format" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
    }
    
}

- (void)updateBeacon {
    [self.beacon updateUUID:self.uuidTextField.text major:[self.majorValueTextField.text integerValue] minor:[self.minorValueTextField.text integerValue] identifier:self.nameTextField.text];
    
    [[DMBeaconStore sharedInstance] updateBeacon:self.beacon completionHandler:^(NSError *error) {
        
        if (!error) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error creating your beacon in ContextHub" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
        }
    }];
    
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