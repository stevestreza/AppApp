//
//  ANStatusViewCell.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANStatusViewCell.h"

@interface ANStatusViewCell()
{
    SDImageView *avatarView;
    UILabel *statusTextLabel;
    UILabel *usernameTextLabel;

}
- (void)registerObservers;
- (void)unregisterObservers;

@end

@implementation ANStatusViewCell
@synthesize status, avatar, username, avatarView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // future avatar
        avatarView = [[SDImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        avatarView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview: avatarView];
        
        // username
        usernameTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 15)];
        usernameTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        [self.contentView addSubview: usernameTextLabel];
        
        // status label
        statusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 27, 240, 100)];
        statusTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        statusTextLabel.numberOfLines = 0;
        statusTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        [self.contentView addSubview: statusTextLabel];
        
        // register observers
        [self registerObservers];
    }
    return self;
}


-(void) dealloc
{
    [self unregisterObservers];
}

- (void)registerObservers
{
    [self addObserver:self forKeyPath:@"status" options:0 context:0];
    [self addObserver:self forKeyPath:@"username" options:0 context:0];
    
}

- (void)unregisterObservers
{
    [self removeObserver:self forKeyPath:@"status"];
    [self removeObserver:self forKeyPath:@"username"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"status"]) {
        [statusTextLabel setText: self.status];
        
        // handle frame resize
        CGSize maxStatusLabelSize = CGSizeMake(240,100);
        CGSize statusLabelSize = [self.status sizeWithFont: statusTextLabel.font
                                              constrainedToSize:maxStatusLabelSize
                                              lineBreakMode: statusTextLabel.lineBreakMode];
    
        CGRect statusLabelNewFrame = statusTextLabel.frame;
        statusLabelNewFrame.size.height = statusLabelSize.height;
        statusTextLabel.frame = statusLabelNewFrame;
    } else if([keyPath isEqualToString:@"username"]) {
        [usernameTextLabel setText: self.username];
    } else if([keyPath isEqualToString:@"avatar"]) 
{
    if(self.avatar) {
        avatarView.image = self.avatar;
        avatarView.backgroundColor = [UIColor clearColor];
    }
}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
