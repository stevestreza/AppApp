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
    static dispatch_once_t oncePred;
    static ANAPICall *sharedInstance = nil;
    dispatch_once(&oncePred, ^{
        sharedInstance = [[[self class] alloc] initWithSpecification:@"ANAPI"];
    });
    return sharedInstance;
}

- (void)readTokenFromDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [defaults objectForKey:@"access_token"];
    accessToken = token;
}

- (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS
    
    SDWebServiceDataCompletionBlock result = ^(int responseCode, NSString *response, NSError *error) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        id dataObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        return dataObject;
    };
    return result;
}

- (void)makePostWithText:(NSString*)text uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self readTokenFromDefaults];
    
    // App.net guys (? Alex K. and Mathew Phillips) say we should put accessToken in the headers, like so:
    // "Authorization: Bearer " + access_token
    
    NSDictionary *replacements = @{ @"accessToken" : accessToken, @"text" : text };
    
    [self performRequestWithMethod:@"postToStream" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:YES];
}

- (void)getGlobalStream:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self readTokenFromDefaults];

    NSDictionary *replacements = @{ @"accessToken" : accessToken };
    
    [self performRequestWithMethod:@"getGlobalStream" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:YES];
}





@end
