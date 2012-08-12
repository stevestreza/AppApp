//
//  ANPostDetailController.h
//  AppApp
//
//  Created by Nick Pannuto on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"

@interface ANPostDetailController : UIViewController {
    UILabel *usernameLabel;
    UILabel *fullnameLabel;
    UILabel *posttimeLabel;
    UILabel *statusLabel;
    SDImageView *avatarView;
}

@property (nonatomic, strong) NSDictionary *statusDict;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *fullname;
@property (nonatomic, strong) NSString *posttime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) UIImage  *avatar;

@property (nonatomic) IBOutlet UILabel *usernameLabel;
@property (nonatomic) IBOutlet UILabel *fullnameLabel;
@property (nonatomic) IBOutlet UILabel *posttimeLabel;
@property (nonatomic) IBOutlet UILabel *statusLabel;
@property (nonatomic) IBOutlet SDImageView *avatarView;

@end
