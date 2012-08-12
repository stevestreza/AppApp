//
//  UIAlertView+SDExtensions.h
//  walmart
//
//  Created by brandon on 2/17/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIAlertView(SDExtensions)

+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message;
+ (UIAlertView *)alertViewWithTitle:(NSString *)title message:(NSString *)message buttonTitle:(NSString *)buttonTitle;

@end
