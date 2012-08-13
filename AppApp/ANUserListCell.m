//
//  ANUserListCell.m
//  AppApp
//
//  Created by brandon on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserListCell.h"

@implementation ANUserListCell
@synthesize userImageView;
@synthesize nameLabel;
@synthesize usernameLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
