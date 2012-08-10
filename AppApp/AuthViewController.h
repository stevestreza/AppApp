//
//  AuthViewController.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIWebView *authWebView;

-(IBAction)dismissAuthenticationViewController:(id)sender;

@end
