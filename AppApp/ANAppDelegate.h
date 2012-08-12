//
//  snkyAppDelegate.h
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANSideMenuController.h"

@interface ANAppDelegate : UIResponder <UIApplicationDelegate> {
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ANSideMenuController *sideMenuController;

+ (ANAppDelegate *)sharedInstance;

@end
