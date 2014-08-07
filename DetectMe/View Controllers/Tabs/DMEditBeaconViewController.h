//
//  DMEditBeaconViewController.h
//  DetectMe
//
//  Created by Joefrey Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DMBeacon;

@interface DMEditBeaconViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, weak) DMBeacon *beacon;
@property (nonatomic, weak) NSMutableArray *beaconArray;
@property (nonatomic) BOOL verboseContextHubLogging;

@end