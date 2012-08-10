//
//  ANAPICall.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANAPICall.h"

@interface ANAPICall()
{
    id delegate;
    NSString *accessToken;
    
}
-(void)readTokenFromDefaults;

@end

@implementation ANAPICall


+ (ANAPICall *)sharedAppAPI
{
    static ANAPICall *appAPI = nil;
    
    if(!appAPI) {
        appAPI = [[ANAPICall alloc] init];
    }
    
    return appAPI;
}

-(void)readTokenFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"access_token"];
    accessToken = token;
}

-(void)makePostWithText:(NSString*)text
{
        
    [self readTokenFromDefaults];
    
    NSString *postsString = [NSString stringWithFormat:@"stream/0/posts"];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: text, @"text", accessToken, @"access_token", nil];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:
                            [NSURL URLWithString:@"https://alpha-api.app.net/"]];
    
    [client postPath:postsString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:0];
        
        NSLog(@"Response: %@", dictionary);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
}

-(void)getGlobalStreamWithDelegate:(id) delegate
{
    
    [self readTokenFromDefaults];
    
    NSString *streamString = [NSString stringWithFormat:@"https://alpha-api.app.net/stream/0/posts/stream/global?access_token=%@", accessToken];
    
    NSLog(@"%@", streamString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:streamString]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [delegate globalStreamDidReturnData: JSON ];
 
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err, id JSON) {
        NSLog(@"%@", [err localizedDescription]);
        // handle error
    }];
    
    [operation start];
}





@end
