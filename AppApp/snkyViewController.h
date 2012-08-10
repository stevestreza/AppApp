//
//  snkyViewController.h
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface snkyViewController : UIViewController {
    IBOutlet UIButton *authenticateButton;
    IBOutlet UIButton *globalStreamButton;
    IBOutlet UIButton *userStreamButton;
    IBOutlet UIButton *userPostsButton;
    IBOutlet UIButton *userMentionsButton;
    IBOutlet UIButton *matrixButton;
    NSString *accessToken;
}

-(IBAction)authenticatePress:(id)sender;
-(IBAction)globalStreamPress:(id)sender;
-(IBAction)userStreamPress:(id)sender;
-(IBAction)userPostsPress:(id)sender;
-(IBAction)userMentionsPress:(id)sender;
-(IBAction)enterTheMatrix:(id)sender;

-(void)getGlobalStream;
-(void)getUserStream;
-(void)getUserPosts;
-(void)getUserMentions;
-(void)makePostWithText:(NSString*)text;

@property (nonatomic) IBOutlet UIButton *authenticateButton;
@property (nonatomic) NSString *accessToken;

@end
