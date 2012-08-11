//
//  NSCachedURLResponse+LeakFix.m
//  SetDirection
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "NSCachedURLResponse+LeakFix.h"

@implementation NSCachedURLResponse (LeakFix)

// iOS 5.0 and 5.1 have a leak when accessing NSCachedURLResponse.data
// If the data backed in the NSCachedURLResponse meets certain criteria
// the method will always return the same NSData but with its retain count incremented
// In other cases, we will get back a new NSData
// This accessor attempts to release the overretained memory if the objects are the same
// and multiple accesses have seemingly increased the retain count
// The Analyzer warning can be ignored because we are doing evil things in this code
- (NSData *)responseData
{
    NSData *result = nil;

    __unsafe_unretained NSData *first = self.data;
    NSUInteger firstCount = CFGetRetainCount((__bridge CFTypeRef)first);
    __unsafe_unretained NSData *second = self.data;
    NSUInteger secondCount = CFGetRetainCount((__bridge CFTypeRef)second);
    result = first;

    if (first == second)
    {
        if (firstCount != secondCount)
        {
            // this os build has the leak...  commence serious bullshit.
            
            // release our 2 total accesses that incurred a retain.
            CFRelease((__bridge CFTypeRef)result);
            CFRelease((__bridge CFTypeRef)result);
        }
    }    
    return result;
}

@end
