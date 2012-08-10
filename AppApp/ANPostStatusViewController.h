//
//  ANPostStatusViewController.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANPostStatusViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, retain) IBOutlet UITextView *postTextView;

-(IBAction)dismissPostStatusViewController:(id)sender;

@end
