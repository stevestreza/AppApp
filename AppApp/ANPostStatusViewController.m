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
{
    NSString *replyToID;
}

@synthesize postTextView, characterCountLabel, postButton, groupView;

- (id)init
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (id)initWithReplyToID:(NSString *)aReplyToID
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        replyToID = aReplyToID;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
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


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [postTextView becomeFirstResponder];
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // support orientation change for writing a new post. 
    return (toInterfaceOrientation==UIInterfaceOrientationPortrait ||
            toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation==UIInterfaceOrientationLandscapeRight);
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
        
        if (replyToID)
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text replyToPostID:replyToID uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
            }];        
        }
        else
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
            }];
        }
        [self dismissPostStatusViewController:nil];
    }
}


#pragma mark - UIKeyboard handling


- (void) applyKeyboardSizeChange:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *animationDuration = [dict valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [dict valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect newFrame;
    UIView *aViewToResize = self.groupView;
    
    CGRect keyboardEndFrame;
    [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    newFrame = aViewToResize.frame;
    newFrame.size.height = keyboardEndFrame.origin.y - newFrame.origin.y;
    [UIView animateWithDuration:[animationDuration floatValue]
                          delay:0.0
                        options:[curve integerValue]
                     animations:^{
                         aViewToResize.frame = newFrame;
                     }
                     completion:NULL];
}


@end
