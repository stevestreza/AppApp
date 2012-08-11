//
//  SDURLConnection
//  ServiceTest
//
//  Created by Brandon Sneed on 11/3/11.
//  Copyright (c) 2011 SetDirection. All rights reserved.
//

#import "SDURLConnection.h"
#import "NSString+SDExtensions.h"
#import "NSCachedURLResponse+LeakFix.h"

#import <libkern/OSAtomic.h>

@interface SDURLResponseCompletionDelegate : NSObject
{
@public
    SDURLConnectionResponseBlock responseHandler;
@private
	NSMutableData *responseData;
	NSHTTPURLResponse *httpResponse;
    BOOL shouldCache;
    BOOL isRunning;
    BOOL stopRunloop;
}

@property (atomic, assign) BOOL isRunning;

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache;
- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache shouldStopRunloop:(BOOL)stopRunloop;

@end

@implementation SDURLResponseCompletionDelegate

@synthesize isRunning;

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache
{
    if (self = [super init])
	{
        responseHandler = [newHandler copy];
        shouldCache = cache;
		responseData = [NSMutableData dataWithCapacity:0];
        self.isRunning = YES;
    }
	
    return self;
}

- (id)initWithResponseHandler:(SDURLConnectionResponseBlock)newHandler shouldCache:(BOOL)cache shouldStopRunloop:(BOOL)shouldStopRunloop
{
    if (self = [super init])
	{
        responseHandler = [newHandler copy];
        shouldCache = cache;
        stopRunloop = shouldStopRunloop;
		responseData = [NSMutableData dataWithCapacity:0];
        self.isRunning = YES;
    }
	
    return self;
}

- (void)dealloc
{
    responseHandler = nil;
    responseData = nil;
}

#pragma mark NSURLConnection delegate

- (void)connection:(SDURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	httpResponse = (NSHTTPURLResponse *)response;
	[responseData setLength:0];	
}

- (void)connection:(SDURLConnection *)connection didFailWithError:(NSError *)error
{
    responseHandler(connection, nil, responseData, error);
    responseHandler = nil;
    self.isRunning = NO;
    if (stopRunloop)
        CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(SDURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connectionDidFinishLoading:(SDURLConnection *)connection
{
    responseHandler(connection, httpResponse, responseData, nil);
    responseHandler = nil;
    self.isRunning = NO;
    if (stopRunloop)
        CFRunLoopStop(CFRunLoopGetCurrent());
}

- (NSCachedURLResponse *)connection:(SDURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSCachedURLResponse *realCache = [[NSCachedURLResponse alloc] initWithResponse:cachedResponse.response data:cachedResponse.responseData userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
    return shouldCache ? realCache : nil;
}

@end

#pragma mark -

@implementation SDURLConnection

static NSOperationQueue *networkOperationQueue = nil;

+ (void)initialize
{
    networkOperationQueue = [[NSOperationQueue alloc] init];
    networkOperationQueue.maxConcurrentOperationCount = 4;
}

- (void)cancel
{
    self->pseudoDelegate.isRunning = NO;
    [self->pseudoDelegate connection:self didFailWithError:[NSError errorWithDomain:@"SDURLConnectionDomain" code:NSURLErrorCancelled userInfo:nil]];
    [super cancel];
}

+ (SDURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler
{
    if (!handler)
        @throw @"sendAsynchronousRequest must be given a handler!";
    
    SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:[handler copy] shouldCache:cache];
    SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (!connection)
        SDLog(@"Unable to create a connection!");

    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
    
    return connection;
}

+ (SDURLConnection *)sendAsynchronousRequestInBackground:(NSURLRequest *)request shouldCache:(BOOL)cache withResponseHandler:(SDURLConnectionResponseBlock)handler
{
    if (!handler)
        @throw @"sendAsynchronousRequest must be given a handler!";
    
    SDURLResponseCompletionDelegate *delegate = [[SDURLResponseCompletionDelegate alloc] initWithResponseHandler:[handler copy] shouldCache:cache shouldStopRunloop:YES];
    SDURLConnection *connection = [[SDURLConnection alloc] initWithRequest:request delegate:delegate startImmediately:NO];
    if (!connection)
        SDLog(@"Unable to create a connection!");
    
    [networkOperationQueue addOperationWithBlock:^{
        [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [connection start];
        
        [[NSRunLoop currentRunLoop] run];
    }];
    
    return connection;
}

@end