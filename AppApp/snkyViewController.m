//
//  snkyViewController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "snkyViewController.h"
#import "snkyAppNetAPIClient.h"
#import "AFJSONRequestOperation.h"

@interface snkyViewController ()

@end

@implementation snkyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(IBAction)authenticatePress:(id)sender {
    // this uses a working clientID, but you should probably get your own
    // https://alpha.app.net/developer/apps/
    //
    NSString *clientID = @"RG2Brqye96rLZQtjwRenVZsBrMtpYXYP";
    NSString *redirectURI = @"appapp://callmemaybe";
    NSString *scopes = @"stream write_post";
    NSString *authURLstring = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=%@&scope=%@",clientID, redirectURI, scopes];
    NSURL *authURL = [NSURL URLWithString:[authURLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:authURL];
    if (canOpenURL){
        [[UIApplication sharedApplication] openURL:authURL];
    }
}

-(IBAction)globalStreamPress:(id)sender {
    [self getGlobalStream];
}

-(IBAction)userStreamPress:(id)sender {
    [self getUserStream];
}

-(IBAction)userPostsPress:(id)sender {
    [self getUserPosts];
}

-(IBAction)userMentionsPress:(id)sender {
    [self getUserMentions];
}

-(IBAction)enterTheMatrix:(id)sender {
        [self makePostWithText:@"I smell bad and I can't read good!!!! #AppApp"];
}

-(void)getGlobalStream {
    snkyAppNetAPIClient *apiClient = [snkyAppNetAPIClient sharedClient];
    
    NSString *streamString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/stream/global?access_token=%@", [apiClient accessToken]];
    
    NSLog(@"%@", streamString);

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:streamString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *globalStream = JSON;
        NSLog(@"%@", globalStream);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err, id JSON) {
        NSLog(@"%@", [err localizedDescription]);
        // handle error
    }];
    
    [operation start];
}

-(void)getUserStream {
    snkyAppNetAPIClient *apiClient = [snkyAppNetAPIClient sharedClient];
    
    NSString *streamString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/stream?access_token=%@", [apiClient accessToken]];
    
    NSLog(@"%@", streamString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:streamString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *userStream = JSON;
        NSLog(@"%@", userStream);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err, id JSON) {
        NSLog(@"%@", [err localizedDescription]);
        // handle error
    }];
    
    [operation start];
}

-(void)getUserPosts {
    snkyAppNetAPIClient *apiClient = [snkyAppNetAPIClient sharedClient];
    
    NSString *postsString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/me/posts?access_token=%@", [apiClient accessToken]];
    
    NSLog(@"%@", postsString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:postsString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *userPosts = JSON;
        NSLog(@"%@", userPosts);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err, id JSON) {
        NSLog(@"%@", [err localizedDescription]);
        // handle error
    }];
    
    [operation start];
}

-(void)getUserMentions {
    snkyAppNetAPIClient *apiClient = [snkyAppNetAPIClient sharedClient];
    
    NSString *mentionsString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/users/me/mentions?access_token=%@", [apiClient accessToken]];
    
    NSLog(@"%@", mentionsString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:mentionsString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSArray *userMentions = JSON;
        NSLog(@"%@", userMentions);
        
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err, id JSON) {
        NSLog(@"%@", [err localizedDescription]);
        // handle error
    }];
    
    [operation start];
}

-(void)makePostWithText:(NSString*)text {
    snkyAppNetAPIClient *apiClient = [snkyAppNetAPIClient sharedClient];
    
    NSString *postsString = [NSString stringWithFormat:@"stream/0/posts"];
    
    NSLog(@"%@", postsString);
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: text, @"text", [apiClient accessToken], @"access_token", nil];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
                            [NSURL URLWithString:@"https://alpha-api.app.net/"]];
    
    [client postPath:postsString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", text);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
