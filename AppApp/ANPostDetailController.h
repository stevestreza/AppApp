//
//  ANPostDetailController.h
//  AppApp
//
//  Created by Nick Pannuto on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANBaseStreamController.h"
#import "TTTAttributedLabel.h"

@interface ANPostDetailController : ANBaseStreamController <TTTAttributedLabelDelegate>

- (id)initWithPostData:(NSDictionary *)aPostData;

@end
