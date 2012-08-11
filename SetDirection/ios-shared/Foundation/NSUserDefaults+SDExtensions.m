//
//  NSUserDefaults+SDExtensions.m
//  SetDirection
//
//  Created by brandon on 2/12/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import "NSUserDefaults+SDExtensions.h"


@implementation NSUserDefaults(SDExtensions)

// you normally won't need this, but its handy when looking up coordinates since 
// they aren't of an object type.
- (BOOL)keyExists:(NSString *)key;
{
	NSObject *object = [self objectForKey:key];
	if (object)
		return YES;
	return NO;
}

- (CLLocationCoordinate2D)coordinateForKey:(NSString *)key
{
	CLLocationCoordinate2D theCoordinate = {NAN, NAN};
	
	id theObject = [self objectForKey:key];
	if ([theObject isKindOfClass:[NSString class]])
	{
		NSArray *theComponents = [theObject componentsSeparatedByString:@","];
		if (theComponents.count == 2)
		{
			theCoordinate.latitude = [[theComponents objectAtIndex:0] doubleValue];
			theCoordinate.longitude = [[theComponents objectAtIndex:1] doubleValue];
		}
	}
	
	return theCoordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate forKey:(NSString *)key
{
	NSString *coordString = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
	[self setObject:coordString forKey:key];
}

@end
