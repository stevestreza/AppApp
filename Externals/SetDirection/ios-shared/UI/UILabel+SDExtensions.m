//
//  UILabel+SDExtensions.m
//  AppApp
//
//  Created by brandon on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "UILabel+SDExtensions.h"

@implementation UILabel (SDExtensions)

- (void)adjustHeightToFit:(CGFloat)maxHeight
{
    CGSize maxLabelSize = CGSizeMake(self.frame.size.width, maxHeight);
    CGSize labelSize = [self.text sizeWithFont:self.font
                             constrainedToSize:maxLabelSize
                                 lineBreakMode:UILineBreakModeWordWrap];
    
    
    CGRect newFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, labelSize.width, labelSize.height);
    self.frame = newFrame;
}

@end
