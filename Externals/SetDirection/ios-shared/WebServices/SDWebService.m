//
//  SDWebService.m
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "SDWebService.h"
#import "NSString+SDExtensions.h"
#import "NSURLCache+SDExtensions.h"
#import "NSCachedURLResponse+LeakFix.h"

#ifdef DEBUG
@interface NSURLRequest(SDExtensionsDebug)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end

@implementation NSURLRequest(SDExtensionsDebug)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
	return YES;
}
@end
#endif

@interface SDMutableURLRequest : NSMutableURLRequest
@property (nonatomic, assign) int retryCount;
@end

@implementation SDMutableURLRequest
@synthesize retryCount;
@end

@implementation SDRequestResult
+ (SDRequestResult *)objectForResult:(SDWebServiceResult)result identifier:(NSString *)identifier
{
    SDRequestResult *object = [[SDRequestResult alloc] init];
    object.result = result;
    object.identifier = identifier;
    return object;
}
@end

@implementation SDWebService

- (id)initWithSpecification:(NSString *)specificationName
{
	self = [super init];
	
    singleRequests = [[NSMutableDictionary alloc] init];
    normalRequests = [[NSMutableDictionary alloc] init];
    dictionaryLock = [[NSLock alloc] init];
	
    NSString *specFile = [[NSBundle mainBundle] pathForResource:specificationName ofType:@"plist"];
	serviceSpecification = [NSDictionary dictionaryWithContentsOfFile:specFile];
	if (!serviceSpecification)
		[NSException raise:@"SDException" format:@"Unable to load the specifications file %@.plist", specificationName];
    
    dataProcessingQueue = [[NSOperationQueue alloc] init];
    dataProcessingQueue.maxConcurrentOperationCount = 4;
    
	return self;
}

- (id)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost
{
	self = [self initWithSpecification:specificationName];
    
    NSMutableDictionary *altServiceSpecification = [serviceSpecification mutableCopy];
    [altServiceSpecification setObject:defaultHost forKey:@"baseURL"];
    serviceSpecification = altServiceSpecification;
	
	return self;
}

- (void)dealloc
{
    dataProcessingQueue = nil;
	serviceSpecification = nil;
    singleRequests = nil;
    normalRequests = nil;
}

- (BOOL)responseIsValid:(NSString *)response forRequest:(NSString *)requestName
{
    return YES;
}

- (NSString *)baseURLInServiceSpecification
{
	NSString *baseURL = [serviceSpecification objectForKey:@"baseURL"];
	
    // this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
    if ([baseURL rangeOfString:@"{"].location != NSNotFound)
    {
        NSString *prefKey = nil;
        int startPos = [baseURL rangeOfString:@"{"].location + 1;
        int endPos = [baseURL rangeOfString:@"}"].location;
        NSRange range = NSMakeRange(startPos, endPos - startPos);
        prefKey = [baseURL substringWithRange:range];
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
        baseURL = [baseURL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:server];
    }
    
	return baseURL;
}

- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError
{
    return [[Reachability reachabilityWithHostName:hostName] isReachable];
}

- (BOOL)isReachable:(BOOL)showError
{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (void)will302RedirectToUrl:(NSURL *)argUrl
{
	// Implement in service subclass for specific behavior
}

- (void)clearCache
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (NSString *)performReplacements:(NSDictionary *)replacements andUserReplacements:(NSDictionary *)userReplacements withFormat:(NSString *)routeFormat
{
    // combine the contents of routeReplacements and the passed in replacements to form
	// a complete name and value list.
	NSArray *keyList = [userReplacements allKeys];
	NSMutableDictionary *actualReplacements = [replacements mutableCopy];
    if (!actualReplacements)
        actualReplacements = [NSMutableDictionary dictionary];
	for (NSString *key in keyList)
	{
		// this takes all the data provided in replacements and overwrites any default
		// values specified in the plist.
		NSObject *value = [userReplacements objectForKey:key];
		[actualReplacements setObject:value forKey:key];
	}
	
	// now lets take that final list and apply it to the route format.
	keyList = [actualReplacements allKeys];
	NSString *result = routeFormat;
	for (NSString *key in keyList)
	{
		id object = [actualReplacements objectForKey:key];
		NSString *value = nil;
		// if its a string, assign it.
		if ([object isKindOfClass:[NSString class]])
			value = object;
		else
		{
			// if its not, run some tests to see what we can do...
			if ([object isKindOfClass:[NSNumber class]])
				value = [object stringValue];
			else
                if ([object respondsToSelector:@selector(stringValue)])
                    value = [object stringValue];
		}
		if (value)
			result = [result stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", key] withString:[value escapedString]];
	}
    
    actualReplacements = nil;
    
    return result;
}

- (void)showNetworkActivityIfNeeded
{
    if (requestCount > 0)
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)hideNetworkActivity
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)hideNetworkActivityIfNeeded
{
    if (requestCount <= 0)
    {
        requestCount = 0;
        [self performSelector:@selector(hideNetworkActivity) withObject:nil afterDelay:0.5];
    }
}

- (void)incrementRequests
{
    requestCount++;
    [self showNetworkActivityIfNeeded];
}

- (void)decrementRequests
{
	requestCount--;
	[self hideNetworkActivityIfNeeded];
}

- (NSString *)responseFromData:(NSData *)data
{
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!responseString)
        responseString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return responseString;
}

- (SDWebServiceResult)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock
{
    return [self performRequestWithMethod:requestName routeReplacements:replacements completion:completionBlock shouldRetry:YES];
}

- (SDWebServiceResult)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock shouldRetry:(BOOL)shouldRetry
{
    SDWebServiceDataCompletionBlock combinedBlock = ^id (int responseCode, NSString *response, NSError *error) {
        completionBlock(responseCode, response, &error);
        return nil;
    };
    return [self performRequestWithMethod:requestName routeReplacements:replacements dataProcessingBlock:combinedBlock uiUpdateBlock:nil shouldRetry:shouldRetry].result;
}

- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
{
    NSString *identifier = [NSString stringWithNewUUID];
    
	// construct the URL based on the specification.
	NSString *baseURL = [serviceSpecification objectForKey:@"baseURL"];
	NSDictionary *requestList = [serviceSpecification objectForKey:@"requests"];
	NSDictionary *requestDetails = [requestList objectForKey:requestName];
	NSString *routeFormat = [requestDetails objectForKey:@"routeFormat"];
	NSString *method = [requestDetails objectForKey:@"method"];
    NSNumber *showNoConnectionAlertObj = [requestDetails objectForKey:@"showNoConnectionAlert"];
    BOOL showNoConnectionAlert = showNoConnectionAlertObj != nil ? [showNoConnectionAlertObj boolValue] : YES;
	BOOL postMethod = [[method uppercaseString] isEqualToString:@"POST"];
    
    // Allowing for the dynamic specification of baseURL at runtime
    // (initially to accomodate the suggestions search)
    NSString *altBaseURL = [replacements objectForKey:@"baseURL"];
    if (altBaseURL) {
        baseURL = altBaseURL;
    }
    else {
        // if this method has its own baseURL use it instead.
        altBaseURL = [requestDetails objectForKey:@"baseURL"];
        if (altBaseURL) {
            baseURL = altBaseURL;
        }
    }
    
    // this allows for having a settings bundle for one to specify an alternate server for debug/qa/etc.
    if ([baseURL rangeOfString:@"{"].location != NSNotFound)
    {
        NSString *prefKey = nil;
        int startPos = [baseURL rangeOfString:@"{"].location + 1;
        int endPos = [baseURL rangeOfString:@"}"].location;
        NSRange range = NSMakeRange(startPos, endPos - startPos);
        prefKey = [baseURL substringWithRange:range];
        NSString *server = [[NSUserDefaults standardUserDefaults] objectForKey:prefKey];
        baseURL = [baseURL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"{%@}", prefKey] withString:server];
    }
    
	//NSString *hostName = [[NSURL URLWithString:baseURL] host];
    if (![self isReachable:showNoConnectionAlert]) 
        // || ![self isReachableToHost:hostName showError:showNoConnectionAlert])
        //  ^^^^^^^^^^^^^^^^^^^^^^^^^^ don't ever do that on the main thread.
    {
        // we ain't got no connection Lt. Dan
        NSError *error = [NSError errorWithDomain:@"SDWebServiceError" code:SDWebServiceErrorNoConnection userInfo:nil];
        dataProcessingBlock(0, nil, error);
        return [SDRequestResult objectForResult:SDWebServiceResultFailed identifier:nil];
    }
    
    // get cache details
    NSNumber *cache = [requestDetails objectForKey:@"cache"];
    NSNumber *cacheTTL = [requestDetails objectForKey:@"cacheTTL"];
    
    NSDictionary *routeReplacements = [requestDetails objectForKey:@"routeReplacement"];
    if (!routeReplacements)
        routeReplacements = [NSDictionary dictionary];
    NSString *route = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:routeFormat];
	
	// there are some unparsed parameters which means either the plist is wrong, or the caller 
	// gave us a list of replacements that weren't sufficient to continue on.
	if ([route rangeOfString:@"{"].location != NSNotFound)
	{
		[NSException raise:@"SDException" format:@"Unable to create request.  The URL still contains replacement markers: %@", route];
	}
	
    // setup post data if we need to.
    NSString *postParams = nil;
	NSString *postJSON = nil;
    if (postMethod)
    {
        NSString *postFormat = [requestDetails objectForKey:@"postFormat"];
        if (postFormat)
        {
			if ([postFormat isEqualToString:@"JSON"])
			{
				// post data is raw JSON
				postJSON = [replacements objectForKey:@"JSON"];
			}
			else
			{
				// post data is in 'foo1={bar1}&foo2={bar2}...' form
				postParams = [self performReplacements:routeReplacements andUserReplacements:replacements withFormat:postFormat];
				// there are some unparsed parameters which means either the plist is wrong, or the caller 
				// gave us a list of replacements that weren't sufficient to continue on.
				if ([postParams rangeOfString:@"{"].location != NSNotFound)
				{
					[NSException raise:@"SDException" format:@"Unable to create request.  The post params still contains replacement markers: %@", postParams];
				}
			}
        }
    }
    
	// build the url and put it here...
    NSString* escapedUrlString = [NSString stringWithFormat:@"%@%@", baseURL, route];
	NSURL *url = [NSURL URLWithString:escapedUrlString];
	SDLog(@"outgoing request = %@", url);
	
	SDMutableURLRequest *request = [SDMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setHTTPShouldHandleCookies:YES];
	[request setHTTPShouldUsePipelining:NO];	// THIS WILL FUCK YOUR SHIT UP BRAH! 7 WAYS FROM SUNDAY!  In other words, this cannot be YES or our servers will return incorrect data
												// Service A's data will be returned for Service B, and vice-versa
#ifdef HUGE_SERVICES_TIMEOUT
	[request setTimeoutInterval:120];
#else
	[request setTimeoutInterval:60];
#endif

	if (shouldRetry)
		[request setRetryCount:3];
	else
		[request setRetryCount:0];
	
    if (postMethod)
    {
		NSString *post = nil;
		if (postParams)
		{
			NSMutableString *mutablePost = [[NSMutableString alloc] init];
			SDLog(@"request post: %@", postParams);
			NSArray *parameters = [postParams componentsSeparatedByString:@"&"];
			for (NSString *aParameter in parameters) {
				NSArray *keyVal = [aParameter componentsSeparatedByString:@"="];
				if ([keyVal count] == 2) {
					NSString *decodedKey = [keyVal objectAtIndex:0];			// Pass encoded values to NSURLConnection
					NSString *decodedValue = [keyVal objectAtIndex:1];
					[mutablePost appendFormat:@"%@=%@&", decodedKey, decodedValue];
				} else {
					[NSException raise:@"SDException" format:@"Unable to create request. Post param does not have proper key value pair: %@", keyVal];
				}
			}
			// Remove dangling '&' after simple sanity check
			if ([mutablePost length]) {
				mutablePost = [NSMutableString stringWithString:[mutablePost substringToIndex:[mutablePost length] - 1]];
			}
			post = mutablePost;
			[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		}
		else if (postJSON)
		{
			post = postJSON;
			[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
		}
		if (post)
		{
			NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
			[request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
			[request setHTTPBody:postData];
		}
    }
    
    // setup caching
    if (cache && [cache boolValue])
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
	else
		[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
	// setup the completion blocks.  we call the same block because failure means
	// different things with different APIs.  pass along the info we've gathered
	// to the handler, and let it decide.  if its an HTTP failure, that'll get
	// passed along as well.
    
    __block SDWebService *blockSelf = self;
	    
#ifdef DEBUG
    NSDate *startDate = [NSDate date];
#endif

	SDURLConnectionResponseBlock urlCompletionBlock = ^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error) {
		@autoreleasepool {
			NSString *responseString = [self responseFromData:responseData];

#ifdef DEBUG
			SDLog(@"Service call took %lf seconds. URL was: %@", [[NSDate date] timeIntervalSinceDate:startDate], url);
#endif
			
            // if the connection was cancelled, skip the retry bit.  this lets your block get called with nil data, etc.
            if ([error code] != NSURLErrorCancelled)
            {
                if ([error code] == NSURLErrorTimedOut)
                    [self serviceCallDidTimeoutForUrl:url];
                
                if (([error code] == NSURLErrorTimedOut || ![blockSelf responseIsValid:responseString forRequest:requestName]) && shouldRetry)
                {
                    // remove it from the cache if its there.
                    NSURLCache *cache = [NSURLCache sharedURLCache];
                    [cache removeCachedResponseForRequest:request];

                    SDRequestResult *newObject = [blockSelf performRequestWithMethod:requestName routeReplacements:replacements dataProcessingBlock:dataProcessingBlock uiUpdateBlock:uiUpdateBlock shouldRetry:NO];
                    
                    // do some sync/cleanup stuff here.
                    SDURLConnection *newConnection = [normalRequests objectForKey:newObject.identifier];
                    
                    [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
                    [normalRequests setObject:newConnection forKey:identifier];
                    [normalRequests removeObjectForKey:newObject.identifier];
                    [dictionaryLock unlock];
                    
                    [blockSelf decrementRequests];
                    return;
                }
            }
            
			// remove from the requests lists
            [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
            [singleRequests removeObjectForKey:requestName];
            [normalRequests removeObjectForKey:identifier];
            [dictionaryLock unlock];
            
			// Saw at least one case where response was NSURLResponse, not NSHTTPURLResponse; Test case went away
			// So be defensive and return SDWTFResponseCode if we did not get a NSHTTPURLResponse
			int code = SDWTFResponseCode;
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
			if ([response isKindOfClass:[NSHTTPURLResponse class]])
			{
				code = [httpResponse statusCode];
			}
			
			// handle redirects in a crappy way.. need to rework this to be done inside of SDURLConnection.
			if (code == 302)
			{
				[blockSelf will302RedirectToUrl:httpResponse.URL];
			}
			
			if (uiUpdateBlock == nil)
                dataProcessingBlock(code, responseString, error);
            else
            {
                [dataProcessingQueue addOperationWithBlock:^{
                    id dataObject = nil;
                    if (code != NSURLErrorCancelled)
                        dataObject = dataProcessingBlock(code, responseString, error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        uiUpdateBlock(dataObject, error);
                    });
                }];
            }
			
			[blockSelf decrementRequests];
		}
	};

	NSURLCache *urlCache = [NSURLCache sharedURLCache];
	NSCachedURLResponse *response = [urlCache validCachedResponseForRequest:request forTime:[cacheTTL unsignedLongValue]];
	if (cache && response && response.response)
	{
		NSString *cachedString = [self responseFromData:response.responseData];
		if (cachedString)
		{
			SDLog(@"***USING CACHED RESPONSE***");
            
			[self incrementRequests];
            
            urlCompletionBlock(nil, response.response, response.responseData, nil);
            
			return [SDRequestResult objectForResult:SDWebServiceResultCached identifier:nil];
		}
	}

	[self incrementRequests];
    
	// see if this is a singleton request.
    BOOL singleRequest = NO;
	NSNumber *singleRequestNumber = [requestDetails objectForKey:@"singleRequest"];
    if (singleRequestNumber)
    {
        singleRequest = [singleRequestNumber boolValue];
        
        // if it is, lets cancel any with matching names.
        if (singleRequest)
        {
			SDURLConnection *existingConnection = [singleRequests objectForKey:requestName];
			if (existingConnection)
			{
				SDLog(@"Cancelling call.");
				[existingConnection cancel];
				[singleRequests removeObjectForKey:requestName];
				[self decrementRequests];
			}
        }
    }

	SDURLConnection *connection = [SDURLConnection sendAsynchronousRequestInBackground:request shouldCache:YES withResponseHandler:urlCompletionBlock];
    
    [dictionaryLock lock]; // NSMutableDictionary isn't thread-safe for writing.
    if (singleRequest)
        [singleRequests setObject:connection forKey:requestName];
    else
        [normalRequests setObject:connection forKey:identifier];
    [dictionaryLock unlock];
    
	return [SDRequestResult objectForResult:SDWebServiceResultSuccess identifier:identifier];
}

- (void)cancelRequestForIdentifier:(NSString *)identifier
{
    SDURLConnection *connection = [normalRequests objectForKey:identifier];
    [connection cancel];
}

- (void)serviceCallDidTimeoutForUrl:(NSURL*)url
{
	// currently handling in subclass
}

@end
