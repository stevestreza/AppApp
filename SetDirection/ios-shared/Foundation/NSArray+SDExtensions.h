//
//  NSArray+SDExtensions.h
//  navbar2
//
//  Created by Brandon Sneed on 7/26/11.
//  Copyright 2011 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableArray (NSMutableArray_SDExtensions)

- (void)shuffle;

@end

@interface NSArray (NSArray_SDExtensions)

- (id)nextToLastObject;
- (void)callSelector:(SEL)aSelector argumentAddresses:(void *)arg1, ...;
- (NSArray*) shuffledArray;
- (NSArray *)reversedArray;

@end
