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
        NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response: %@", text);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
}



@end
