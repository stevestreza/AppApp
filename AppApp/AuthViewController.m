//
//  AuthViewController.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "AuthViewController.h"
#import "ANAPICall.h"
#import "SVProgressHUD.h"
#import "ANAppDelegate.h"

@implementation AuthViewController
@synthesize authWebView;

- (id)init
{
    self = [super initWithNibName:@"AuthViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO: MOVE OUT OF HERE
    NSString *redirectURI = @"appapp://callmemaybe";
    
    NSString *scopes = @"stream write_post follow messages";
    NSString *authURLstring = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=%@&scope=%@", kANAPIClientID, redirectURI, scopes];
    NSURL *authURL = [NSURL URLWithString:[authURLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:authURL];
    
    [authWebView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray *components = [[request URL].absoluteString  componentsSeparatedByString:@"#"];
    
    if([components count]) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            
            if([[component componentsSeparatedByString:@"="] count] > 1) {
            [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
            }
        }
        
        if([parameters objectForKey:@"access_token"])
        {
            NSString *token = [parameters objectForKey:@"access_token"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:@"access_token"];
            [defaults synchronize];
            
            [SVProgressHUD showWithStatus:@"Getting user information"];
            
            [[ANAPICall sharedAppAPI] getCurrentUser:^(id dataObject, NSError *error) {
                SDLog(@"currentUser = %@", dataObject);
                
                // all we need right now is userID, but there may be more stuff later.
                
                NSString *userID = [(NSDictionary *)dataObject objectForKey:@"id"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:userID forKey:@"userID"];
                [defaults synchronize];
                
                [self dismissAuthenticationViewController:nil];
                [SVProgressHUD dismiss];
                NSArray *controllers = [ANAppDelegate sharedInstance].sideMenuController.navigationArray;
                [controllers makeObjectsPerformSelector:@selector(refresh)];
            }];
        }
    }

    return YES;
}

-(IBAction)dismissAuthenticationViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
