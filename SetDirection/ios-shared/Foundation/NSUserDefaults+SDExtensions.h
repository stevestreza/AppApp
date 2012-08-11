//
//  NSUserDefaults+SDExtensions.h
//  SetDirection
//
//  Created by brandon on 2/12/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSUserDefaults(SDExtensions)

- (BOOL)keyExists:(NSString *)key;

- (CLLocationCoordinate2D)coordinateForKey:(NSString *)key;
- (void)setCoordinate:(CLLocationCoordinate2D)coordinate forKey:(NSString *)key;

@end
