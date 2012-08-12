//
//  ANPostDetailController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostDetailController.h"
#import "SDImageView.h"

@interface ANPostDetailController ()

@end

@implementation ANPostDetailController {
    NSDictionary *postData;
    
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *fullnameLabel;
    __weak IBOutlet UILabel *posttimeLabel;
    __weak IBOutlet UILabel *statusLabel;
    __weak IBOutlet SDImageView *avatarView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Post";
    }
    return self;
}

- (NSString *)sideMenuTitle
{
    return @"Post";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
