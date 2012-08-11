//
//  NSString+SDExtensions.m
//  SetDirection
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSString+SDExtensions.h"


@implementation NSString(SDExtensions)

- (NSString *)replaceHTMLWithUnformattedText {
    return [self replaceHTMLWithUnformattedText:NO];
}

- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets {
    NSString* fixed = self;
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

    // kill the HTML entities
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"&#[0-9]+;"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@""];
    
    if (keepBullets) {
        error = NULL;
        regex = [NSRegularExpression regularExpressionWithPattern:@"<li>"
                                                          options:NSRegularExpressionCaseInsensitive
                                                            error:&error];
        fixed = [regex stringByReplacingMatchesInString:fixed 
                                                options:0 
                                                  range:NSMakeRange(0, [fixed length]) 
                                           withTemplate:@"\n• "];
    }
    
    // kill the HTML tags
    error = NULL;
    
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];

    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];
    
    // a final trimmy trimmy
    fixed = [fixed stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return fixed;
}

- (NSString*)stripHTMLFromListItems {
    NSString *fixed = self;

    // some common entities
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    fixed = [fixed stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];

    
    // replace any HTML tag with a space
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<*[A-Z][A-Z0-9]* ?\\/>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];

    // replace two or more spaces with one
    error = NULL;
    regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    fixed = [regex stringByReplacingMatchesInString:fixed 
                                            options:0 
                                              range:NSMakeRange(0, [fixed length]) 
                                       withTemplate:@" "];

    return fixed;
}


- (NSString*)escapedString 
{            
	NSString *selfCopy = [self mutableCopy];
	return (__bridge_transfer  NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)selfCopy, NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), kCFStringEncodingUTF8);
}

- (NSString *)removeExcessWhitespace 
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s{2,}"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self 
                                            options:0 
                                              range:NSMakeRange(0, [self length]) 
                                       withTemplate:@" "];
}

- (NSString *)removeLeadingWhitespace 
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^\\s+"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self 
                                           options:0 
                                             range:NSMakeRange(0, [self length]) 
                                      withTemplate:@""];
}

- (NSString *)removeTrailingWhitespace 
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+$"
                                                                           options:0
                                                                             error:&error];
    return [regex stringByReplacingMatchesInString:self 
                                           options:0 
                                             range:NSMakeRange(0, [self length]) 
                                      withTemplate:@""];
}


+ (id)stringWithNewUUID
{
	NSString*	uuidString = nil;
	
	CFUUIDRef	uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	if (uuidRef)
	{
		uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
		
		CFRelease(uuidRef);
	}
	
	return uuidString;
}

- (NSDictionary *)parseURLQueryParams{
    NSMutableDictionary *queryComponents = [NSMutableDictionary dictionary];
    for(NSString *keyValuePairString in [self componentsSeparatedByString:@"&"])
    {
        NSArray *keyValuePairArray = [keyValuePairString componentsSeparatedByString:@"="];
        if ([keyValuePairArray count] < 2) continue; 
        NSString *key = [keyValuePairArray objectAtIndex:0];
        NSString *value = [[keyValuePairArray objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
        [queryComponents setObject:value forKey:key];
    }
    return queryComponents;
}


@end

