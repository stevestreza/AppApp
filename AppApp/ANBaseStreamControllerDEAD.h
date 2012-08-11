//
//  ANGlobalViewController.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANGlobalViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *tableView;
-(IBAction) refreshGlobalStream:(id)sender;
-(IBAction)composeStatus:(id)sender;
@end
