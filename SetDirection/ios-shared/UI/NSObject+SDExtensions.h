//
//  NSObject+SDExtensions.h
//
//  Created by brandon on 1/14/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

// makes loading nibs much easier.

@interface NSObject (SDExtensions)

+ (NSString *)className;
- (NSString *)className;

+ (NSString *)nibName;
+ (id)loadFromNib;
+ (id)loadFromNibNamed:(NSString *)nibName;
+ (id)loadFromNibWithOwner:(id)owner;
+ (id)loadFromNibNamed:(NSString *)nibName withOwner:(id)owner;

- (void)callSelector:(SEL)aSelector returnAddress:(void *)result argumentAddresses:(void *)arg1, ...;

@end
