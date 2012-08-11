//
//  NSDate+SDExtensions.h
//  SetDirection
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (SDExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)argDateString;
+ (NSDate *)dateFromRFC822String:(NSString *)argDateString;

//Time interval comparison convenience:
- (BOOL)happenedMoreThanNSecondsAgo:(int)numSeconds;
- (BOOL)happenedMoreThanNMinutesAgo:(int)numMinutes;
- (BOOL)happenedMoreThanNHoursAgo:(int)numHours;
- (BOOL)happenedMoreThanNDaysAgo:(int)numDays;
- (BOOL)happenedLessThanNSecondsAgo:(int)numSeconds;
- (BOOL)happenedLessThanNMinutesAgo:(int)numMinutes;
- (BOOL)happenedLessThanNHoursAgo:(int)numHours;
- (BOOL)happenedLessThanNDaysAgo:(int)numDays;

@end
