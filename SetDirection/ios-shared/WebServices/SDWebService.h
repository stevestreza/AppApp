//
//  SDWebService.h
//
//  Created by brandon on 2/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDURLConnection.h"
#import "Reachability.h"

typedef void (^SDWebServiceCompletionBlock)(int responseCode, NSString *response, NSError **error);
typedef id (^SDWebServiceDataCompletionBlock)(int responseCode, NSString *response, NSError *error);
typedef void (^SDWebServiceUICompletionBlock)(id dataObject, NSError *error);

enum
{
    SDWebServiceErrorNoConnection = 0xBEEF,
    SDWebServiceErrorBadParams = 0x0BADF00D,
    // all other errors come from NSURLConnection and its subsystems.
};

typedef enum
{
    SDWebServiceResultFailed = NO,
    SDWebServiceResultSuccess = YES,
    SDWebServiceResultCached = 2
} SDWebServiceResult;

enum
{
	SDWTFResponseCode = -1
};

@interface SDRequestResult : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) SDWebServiceResult result;
@end

@interface SDWebService : NSObject
{
    NSMutableDictionary *normalRequests;
	NSMutableDictionary *singleRequests;
    NSLock *dictionaryLock;

	NSDictionary *serviceSpecification;
    NSUInteger requestCount;
    NSOperationQueue *dataProcessingQueue;
}

- (id)initWithSpecification:(NSString *)specificationName;
- (id)initWithSpecification:(NSString *)specificationName host:(NSString *)defaultHost;
- (SDWebServiceResult)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock;
- (SDWebServiceResult)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements completion:(SDWebServiceCompletionBlock)completionBlock shouldRetry:(BOOL)shouldRetry;
- (SDRequestResult *)performRequestWithMethod:(NSString *)requestName routeReplacements:(NSDictionary *)replacements dataProcessingBlock:(SDWebServiceDataCompletionBlock)dataProcessingBlock uiUpdateBlock:(SDWebServiceUICompletionBlock)uiUpdateBlock shouldRetry:(BOOL)shouldRetry;
- (void)cancelRequestForIdentifier:(NSString *)identifier;
- (BOOL)responseIsValid:(NSString *)response forRequest:(NSString *)requestName;
- (NSString *)baseURLInServiceSpecification;
- (BOOL)isReachable:(BOOL)showError;
- (BOOL)isReachableToHost:(NSString *)hostName showError:(BOOL)showError;
- (void)clearCache;
- (void)will302RedirectToUrl:(NSURL *)argUrl;
- (void)serviceCallDidTimeoutForUrl:(NSURL*)url;

@end
