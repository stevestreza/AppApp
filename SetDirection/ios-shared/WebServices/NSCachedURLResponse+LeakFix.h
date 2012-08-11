//
//  NSCachedURLResponse+LeakFix.h
//  SetDirection
//
//  Created by Brandon Sneed on 4/29/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCachedURLResponse (LeakFix)

// workaround for a leak in ios5 when the data property is accessed.

- (NSData *)responseData;

@end
