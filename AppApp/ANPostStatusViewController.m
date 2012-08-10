//
//  ANPostStatusViewController.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostStatusViewController.h"
#import "ANAPICall.h"

@interface ANPostStatusViewController ()

-(void) updateCharCountLabel;

@end

@implementation ANPostStatusViewController
@synthesize postTextView, characterCountLabel;

- (id)init
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        [postTextView becomeFirstResponder];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [postTextView becomeFirstResponder];
}

-(void) updateCharCountLabel
{
    int textLength = 256 - [postTextView.text length];
    characterCountLabel.text = [NSString stringWithFormat:@"%i", textLength];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self updateCharCountLabel];
    return YES;
}

-(IBAction)dismissPostStatusViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction) postStatusToAppNet:(id)sender
{
    if([postTextView.text length] < 256)
    {
        
        // TODO: Disable Text View.
        // TODO: Activity Indicator.
        
        // TODO: Add delegate to API, make sure to dismiss *only* when post goes through.
        [[ANAPICall sharedAppAPI] makePostWithText: postTextView.text];
        [self dismissPostStatusViewController:nil];
    }
}

@end
