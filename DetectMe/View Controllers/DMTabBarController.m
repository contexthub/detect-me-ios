//
//  DMTabBarController.m
//  DetectMe
//
//  Created by Jeff Kibuule on 8/3/14.
//  Copyright (c) 2014 ChaiOne. All rights reserved.
//

#import "DMTabBarController.h"

/**
 Tab bar indicies
 */
typedef NS_ENUM(NSUInteger, DMTabBarIndex) {
    DMTabBarListIndex = 0,
    DMTabBarAboutIndex
};

@implementation DMTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // Initially selected tab bar icon needs to have selected images
    UITabBarItem *tabBarItem = self.tabBar.items[0];
    tabBarItem.image = [UIImage imageNamed:@"DetectTabBarIcon"];
    tabBarItem.selectedImage = [UIImage imageNamed:@"DetectSelectedTabBarIcon"];
}

// Selected tab bar item should have selected tab bar item icons
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    switch ([tabBarController selectedIndex]) {
        case DMTabBarListIndex:
            viewController.tabBarItem.image = [UIImage imageNamed:@"DetectTabBarIcon"];
            viewController.tabBarItem.selectedImage = [UIImage imageNamed:@"DetectSelectedTabBarIcon"];
            
            break;
        case DMTabBarAboutIndex:
            viewController.tabBarItem.image = [UIImage imageNamed:@"AboutTabBarIcon"];
            viewController.tabBarItem.selectedImage = [UIImage imageNamed:@"AboutSelectedTabBarIcon"];
            
            break;
        default:
            
            break;
    }
}

@end