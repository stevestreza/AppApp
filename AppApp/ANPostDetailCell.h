//
//  ANPostDetailHeaderView.h
//  AppApp
//
//  Created by brandon on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDImageView.h"
#import "TTTAttributedLabel.h"

@interface ANPostDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *postLabel;
@property (weak, nonatomic) IBOutlet SDImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;

@end
