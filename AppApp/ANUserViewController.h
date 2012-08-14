//
//  ANUserViewController.h
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANViewControllerProtocol.h"

@interface ANUserViewController : UITableViewController<ANViewControllerProtocol>

@property (nonatomic, readonly) NSString *sideMenuTitle;
@property (nonatomic, readonly) NSString *userID;

- (id)initWithUserDictionary:(NSDictionary *)userDictionary;

@end
