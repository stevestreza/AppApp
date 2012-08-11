//
//  SDURLConnection.h
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDURLConnection;
@class SDURLResponseCompletionDelegate;

typedef void (^SDURLConnectionResponseBlock)(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error);

@interface SDURLConnection : NSURLConnection
{
    SDURLResponseCompletionDelegate *pseudoDelegate;
}

+ (SDURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler;
+ (SDURLConnection *)sendAsynchronousRequestInBackground:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler;

@end
