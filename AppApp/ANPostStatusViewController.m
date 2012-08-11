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

-(void) updateCharCountLabel: (NSNotification *)notification;
-(void) registerForNotifications;
-(void) unregisterForNotifications;
@end

@implementation ANPostStatusViewController
@synthesize postTextView, characterCountLabel, postButton;

- (id)init
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
    [postTextView becomeFirstResponder];
}


-(void) dealloc
{
    [self unregisterForNotifications];
}


-(void) registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharCountLabel:) name:UITextViewTextDidChangeNotification object:nil];
}

-(void) unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}





-(void) updateCharCountLabel: (NSNotification *) notification
{
    NSInteger textLength = 256 - [postTextView.text length];
    
    // unblock / block post button
    if(textLength > 0 && textLength < 256) {
        postButton.enabled = YES;
    } else {
        postButton.enabled = NO;
    }
    
    characterCountLabel.text = [NSString stringWithFormat:@"%i", textLength];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    postTextView.text = textView.text;
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
        //       ... and add the post to the status listing -- BKS.
        [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text uiCompletionBlock:^(id dataObject, NSError *error) {
            SDLog(@"post response = %@", dataObject);
        }];
        [self dismissPostStatusViewController:nil];
    }
}

@end
