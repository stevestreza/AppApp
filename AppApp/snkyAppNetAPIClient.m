//
//  snkyAppNetAPIClient.m
//  AppApp
//
//  Created by Nick Pannuto on 8/9/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "snkyAppNetAPIClient.h"

#import "AFJSONRequestOperation.h"

static NSString * const kAFAppNetAPIBaseURLString = @"https://alpha-api.app.net/";

@implementation snkyAppNetAPIClient

+ (snkyAppNetAPIClient *)sharedClient {
    static snkyAppNetAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[snkyAppNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kAFAppNetAPIBaseURLString]];
    });
    
    return _sharedClient;
}



@end