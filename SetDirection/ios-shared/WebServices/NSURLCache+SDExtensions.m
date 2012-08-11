//
//  NSURLCache+SDExtensions.m
//  SetDirection
//
//  Created by Steven Riggins on 4/27/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "NSURLCache+SDExtensions.h"
#import "NSCachedURLResponse+LeakFix.h"

static float const kSDURLCacheDefault = 3600; // Default cache expiration delay if none defined (1 hour)
static float const kNSURLCacheLastModFraction = 0.1f; // 10% since Last-Modified suggested by RFC2616 section 13.2.4

static NSDateFormatter* CreateDateFormatter(NSString *format)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    [dateFormatter setDateFormat:format];
    return dateFormatter;
}

@implementation NSURLCache(SDExtensions)

/*
 * Parse HTTP Date: http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1
 */
+ (NSDate *)dateFromHttpDateString:(NSString *)httpDate
{
    static NSDateFormatter *RFC1123DateFormatter;
    static NSDateFormatter *ANSICDateFormatter;
    static NSDateFormatter *RFC850DateFormatter;
    NSDate *date = nil;
    
    @synchronized(self) // NSDateFormatter isn't thread safe
    {
        // RFC 1123 date format - Sun, 06 Nov 1994 08:49:37 GMT
        if (!RFC1123DateFormatter) RFC1123DateFormatter = CreateDateFormatter(@"EEE, dd MMM yyyy HH:mm:ss z");
        date = [RFC1123DateFormatter dateFromString:httpDate];
        if (!date)
        {
            // ANSI C date format - Sun Nov  6 08:49:37 1994
            if (!ANSICDateFormatter) ANSICDateFormatter = CreateDateFormatter(@"EEE MMM d HH:mm:ss yyyy");
            date = [ANSICDateFormatter dateFromString:httpDate];
            if (!date)
            {
                // RFC 850 date format - Sunday, 06-Nov-94 08:49:37 GMT
                if (!RFC850DateFormatter) RFC850DateFormatter = CreateDateFormatter(@"EEEE, dd-MMM-yy HH:mm:ss z");
                date = [RFC850DateFormatter dateFromString:httpDate];
            }
        }
    }
    
    return date;
}

/*
 * This method tries to determine the expiration date based on a response headers dictionary.
 */

+ (NSDate *)fetchDateFromHeaders:(NSDictionary *)headers withStatusCode:(NSInteger)status
{
    if (status != 200 && status != 203 && status != 300 && status != 301 && status != 302 && status != 307 && status != 410)
    {
        // Uncacheable response status code
        return nil;
    }
    
    // Check Pragma: no-cache
    NSString *pragma = [headers objectForKey:@"Pragma"];
    if (pragma && [pragma isEqualToString:@"no-cache"])
    {
        // Uncacheable response
        return nil;
    }
    
    // Define "now" based on the request
    NSString *date = [headers objectForKey:@"Date"];
    NSDate *now;
    if (date)
    {
        now = [NSURLCache dateFromHttpDateString:date];
    }
    else
    {
        // If no Date: header, define now from local clock
        now = [NSDate date];
    }
    
    return now;
}

+ (NSDate *)expirationDateFromHeaders:(NSDictionary *)headers withStatusCode:(NSInteger)status
{
    if (status != 200 && status != 203 && status != 300 && status != 301 && status != 302 && status != 307 && status != 410)
    {
        // Uncacheable response status code
        return nil;
    }
    
    // Check Pragma: no-cache
    NSString *pragma = [headers objectForKey:@"Pragma"];
    if (pragma && [pragma isEqualToString:@"no-cache"])
    {
        // Uncacheable response
        return nil;
    }
    
    // Define "now" based on the request
    NSString *date = [headers objectForKey:@"Date"];
    NSDate *now;
    if (date)
    {
        now = [NSURLCache dateFromHttpDateString:date];
    }
    else
    {
        // If no Date: header, define now from local clock
        now = [NSDate date];
    }
    
    // Look at info from the Cache-Control: max-age=n header
    NSString *cacheControl = [headers objectForKey:@"Cache-Control"];
    if (cacheControl)
    {
        NSRange foundRange = [cacheControl rangeOfString:@"no-store"];
        if (foundRange.length > 0)
        {
            // Can't be cached
            return nil;
        }
        
        NSInteger maxAge;
        foundRange = [cacheControl rangeOfString:@"max-age="];
        if (foundRange.length > 0)
        {
            NSScanner *cacheControlScanner = [NSScanner scannerWithString:cacheControl];
            [cacheControlScanner setScanLocation:foundRange.location + foundRange.length];
            if ([cacheControlScanner scanInteger:&maxAge])
            {
                if (maxAge > 0)
                {
                    return [[NSDate alloc] initWithTimeInterval:maxAge sinceDate:now];
                }
                else
                {
                    return nil;
                }
            }
        }
    }
    
    // If not Cache-Control found, look at the Expires header
    NSString *expires = [headers objectForKey:@"Expires"];
    if (expires)
    {
        NSTimeInterval expirationInterval = 0;
        NSDate *expirationDate = [NSURLCache dateFromHttpDateString:expires];
        if (expirationDate)
        {
            expirationInterval = [expirationDate timeIntervalSinceDate:now];
        }
        if (expirationInterval > 0)
        {
            // Convert remote expiration date to local expiration date
            return [NSDate dateWithTimeIntervalSinceNow:expirationInterval];
        }
        else
        {
            // If the Expires header can't be parsed or is expired, do not cache
            return nil;
        }
    }
    
    if (status == 302 || status == 307)
    {
        // If not explict cache control defined, do not cache those status
        return nil;
    }
    
    // If no cache control defined, try some heristic to determine an expiration date
    NSString *lastModified = [headers objectForKey:@"Last-Modified"];
    if (lastModified)
    {
        NSTimeInterval age = 0;
        NSDate *lastModifiedDate = [NSURLCache dateFromHttpDateString:lastModified];
        if (lastModifiedDate)
        {
            // Define the age of the document by comparing the Date header with the Last-Modified header
            age = [now timeIntervalSinceDate:lastModifiedDate];
        }
        if (age > 0)
        {
            return [NSDate dateWithTimeIntervalSinceNow:(age * kNSURLCacheLastModFraction)];
        }
        else
        {
            return nil;
        }
    }
    
    // If nothing permitted to define the cache expiration delay nor to restrict its cacheability, use a default cache expiration delay
    return [[NSDate alloc] initWithTimeInterval:kSDURLCacheDefault sinceDate:now];
    
}

// YES if url is in the cache and valid (ie non-expired
- (BOOL)isCachedAndValid:(NSURLRequest*)request
{
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
    if (response && response.response && response.responseData)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[response response];
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSDate *expirationDate = [NSURLCache expirationDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
            if ([expirationDate timeIntervalSinceNow] > 0)
            {
                return YES;
            }
        }
    }
    response = nil;
	return NO;
}	

// Makes sure the response is not expired, otherwise nil
- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request
{
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
    if (response && response.response && response.responseData)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[response response];
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSDate *expirationDate = [NSURLCache expirationDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
            if ([expirationDate timeIntervalSinceNow] > 0)
            {
                return response;
            }
        }
    }
	return nil; // Valid cached response not found
}

- (NSCachedURLResponse*)validCachedResponseForRequest:(NSURLRequest *)request forTime:(NSTimeInterval)ttl
{
    NSURLCache *urlCache = [NSURLCache sharedURLCache];
    NSCachedURLResponse *response = [urlCache cachedResponseForRequest:request];
    if (response && response.response && response.responseData)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[response response];
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSDate *expirationDate = [NSURLCache expirationDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
            NSDate *fetchDate = [NSURLCache fetchDateFromHeaders:[httpResponse allHeaderFields] withStatusCode:[httpResponse statusCode]];
            NSTimeInterval timePassed = [[NSDate date] timeIntervalSinceDate:fetchDate];
            if ([expirationDate timeIntervalSinceNow] > 0 && timePassed < ttl)
            {
                return response;
            }
        }
    }
	return nil; // Valid cached response not found
}


@end
