//
//  snkyAppNetAPIClient.h
//  AppApp
//
//  Created by Nick Pannuto on 8/9/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

// I don't actually use this for anything other than holding the accessToken, terrible, I know
@interface snkyAppNetAPIClient : AFHTTPClient {
    NSString *accessToken;
}

@property (nonatomic) NSString *accessToken;

+ (snkyAppNetAPIClient *)sharedClient;

@end
