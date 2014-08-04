//
//  DMAppDelegate.h
//  DetectMe
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContextHub/ContextHub.h>

@interface DMAppDelegate : UIResponder <UIApplicationDelegate, CCHSensorPipelineDataSource, CCHSensorPipelineDelegate>

@property (strong, nonatomic) UIWindow *window;

@end