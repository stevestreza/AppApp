//
//  ANBaseStreamController.h
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STableViewController.h"
#import "ANAPICall.h"
#import "ANViewControllerProtocol.h"
#import "ANStatusViewCell.h"

@interface ANBaseStreamController : STableViewController<ANViewControllerProtocol>
{
@protected
    NSMutableArray *streamData;
}

@property (nonatomic, readonly) NSString *sideMenuTitle;

- (BOOL)refresh;

@end
