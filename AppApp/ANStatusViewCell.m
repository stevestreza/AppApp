//
//  ANStatusViewCell.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANStatusViewCell.h"

@interface ANStatusViewCell()

@property (nonatomic, strong) UIView *avatarView;
@property (nonatomic, strong) UILabel *statusTextLabel;
@property (nonatomic, strong) UILabel *usernameTextLabel;

- (void)registerObservers;
- (void)unregisterObservers;

@end

@implementation ANStatusViewCell
@synthesize status;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // future avatar
        self.avatarView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        self.avatarView.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.avatarView];
        
        // username
        self.usernameTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 240, 15)];
        self.usernameTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        [self.contentView addSubview:self.usernameTextLabel];
        
        // status label
        self.statusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 27, 240, 100)];
        self.statusTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.statusTextLabel.numberOfLines = 0;
        self.statusTextLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
        [self.contentView addSubview:self.statusTextLabel];
        
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
        [self.statusTextLabel setText: self.status];
        
        // handle frame resize
        CGSize maxStatusLabelSize = CGSizeMake(240,100);
        CGSize statusLabelSize = [self.status sizeWithFont:self.statusTextLabel.font
                                              constrainedToSize:maxStatusLabelSize
                                              lineBreakMode:self.statusTextLabel.lineBreakMode];
    
        CGRect statusLabelNewFrame = self.statusTextLabel.frame;
        statusLabelNewFrame.size.height = statusLabelSize.height;
        self.statusTextLabel.frame = statusLabelNewFrame;
    } else if([keyPath isEqualToString:@"username"]) {
        [self.usernameTextLabel setText: self.username];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
