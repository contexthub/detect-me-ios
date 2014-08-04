//
//  DMBeaconCell.h
//  DetectMe
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMBeaconCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *majorLabel;
@property (nonatomic, weak) IBOutlet UILabel *minorLabel;
@property (nonatomic, weak) IBOutlet UILabel *uuidLabel;

@property (nonatomic, weak) IBOutlet UILabel *beaconStateLabel;
@property (nonatomic, weak) IBOutlet UILabel *proximityStateLabel;

@end
