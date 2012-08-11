//
//  NSString+SDExtensions.h
//  SetDirection
//
//  Created by Ben Galbraith on 2/25/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString(SDExtensions)

+ (id)stringWithNewUUID;

// a method to replace HTML in multi-line strings with an adequate plain-text alternative, using Unicode characters
// where appropriate to replace, e.g., <li> elements.
- (NSString *)replaceHTMLWithUnformattedText:(BOOL)keepBullets;

- (NSString *)replaceHTMLWithUnformattedText;

// a method to replace HTML in single-line strings designed for compact representation (e.g., items in a list). this
// is similar in behavior to replaceHTMLWithUnformattedText except it makes no attempt to format text for attractive
// multi-line display.
- (NSString *)stripHTMLFromListItems;

- (NSString *)escapedString;
- (NSString *)removeExcessWhitespace;
- (NSString *)removeLeadingWhitespace;
- (NSString *)removeTrailingWhitespace;
- (NSDictionary *)parseURLQueryParams;


@end
