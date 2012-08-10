//
//  snkyAppDelegate.h
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "snkyAppNetAPIClient.h"

@class snkyViewController;

@interface snkyAppDelegate : UIResponder <UIApplicationDelegate> {
    snkyAppNetAPIClient *apiClient;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) snkyViewController *viewController;

@end
