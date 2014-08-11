//
//  DMDetectBeaconViewController.h
//  DetectMe
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMDetectBeaconViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *beaconArray;
@property (nonatomic) BOOL verboseContextHubLogging;

@end