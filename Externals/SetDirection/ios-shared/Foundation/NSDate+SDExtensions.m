//
//  NSDate+SDExtensions.m
//  SetDirection
//
//  Created by Sam Grover on 3/8/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSDate+SDExtensions.h"


@implementation NSDate (SDExtensions)

+ (NSDate *)dateFromISO8601String:(NSString *)argDateString
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	return [formatter dateFromString:argDateString];
}

+ (NSDate *)dateFromRFC822String:(NSString *)argDateString
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
	return [formatter dateFromString:argDateString];
}

// ---------------------------------------------------------------- //
// Time interval comparison convenience methods

-(BOOL)happenedMoreThanNSecondsAgo:(int)numSeconds
{
	if([self timeIntervalSinceNow] < -numSeconds)
	{
		return YES;
	}
	return NO;
}

-(BOOL)happenedMoreThanNMinutesAgo:(int)numMinutes
{
	return [self happenedMoreThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedMoreThanNHoursAgo:(int)numHours
{
	return [self happenedMoreThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedMoreThanNDaysAgo:(int)numDays
{
	return [self happenedMoreThanNHoursAgo: numDays * 24];
}

-(BOOL)happenedLessThanNSecondsAgo:(int)numSeconds
{
	if([self timeIntervalSinceNow] > -numSeconds)
	{
		return YES;
	}	
	return NO;
}

-(BOOL)happenedLessThanNMinutesAgo:(int)numMinutes
{
	return [self happenedLessThanNSecondsAgo: numMinutes * 60];
}

-(BOOL)happenedLessThanNHoursAgo:(int)numHours
{
	return [self happenedLessThanNMinutesAgo: numHours * 60];
}

-(BOOL)happenedLessThanNDaysAgo:(int)numDays
{
	return [self happenedLessThanNHoursAgo: numDays * 24];
}

@end
