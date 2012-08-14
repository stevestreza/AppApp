//
//  ANUserViewController.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserViewController.h"
#import "SDImageView.h"
#import "ANAPICall.h"
#import "SVProgressHUD.h"
#import "UILabel+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "UIAlertView+SDExtensions.h"
#import "ANUserPostsController.h"
#import "ANUserListController.h"

#import <QuartzCore/QuartzCore.h>

@interface ANUserViewController ()

@end

@implementation ANUserViewController
{
    NSString *userID;
    NSDictionary *userData;
    NSArray *followersList;
    NSArray *followingList;
    
    CGFloat initialCoverImageYOffset;

    __weak IBOutlet SDImageView *userImageView;
    __weak IBOutlet SDImageView *coverImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *bioLabel;
    __weak IBOutlet UIView *topCoverView;
}

- (id)init
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"Me";
        
        userID = [ANAPICall sharedAppAPI].userID;
    }
    return self;
}

- (id)initWithUserDictionary:(NSDictionary *)userDictionary
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nil];
    
    userData = userDictionary;
    userID = [userData stringForKey:@"id"];
    self.title = [userData objectForKey:@"username"];

    return self;
}

- (NSString *)sideMenuTitle
{
    return @"Me";
}

- (void)configureFromUserData
{
    userImageView.imageURL = [userData valueForKeyPath:@"avatar_image.url"];
    coverImageView.imageURL = [userData valueForKeyPath:@"cover_image.url"];
    
    nameLabel.text = [userData objectForKey:@"name"];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [userData objectForKey:@"username"]];
    
    // Check for empty descriptions to avoid crashing by passing NSNull into label
    NSString *bioText = [userData valueForKeyPath:@"description.text"];
    if (bioText == (id)[NSNull null] || bioText.length == 0) {
        bioLabel.text = @"";
    } else {
        bioLabel.text = bioText;
    }
    // compute height of bio line.
    [bioLabel adjustHeightToFit:120];
    
    // now get that and set the header height..
    CGFloat defaultViewHeight = 154; // seen in the nib.
    CGFloat defaultLabelHeight = 21; // ... i'm putting these here in case we need to change it later.
    CGFloat newLabelHeight = bioLabel.frame.size.height;
    
    UIView *headerView = self.tableView.tableHeaderView;
    CGRect newHeaderFrame = headerView.frame;
    newHeaderFrame.size.height = defaultViewHeight + (newLabelHeight - defaultLabelHeight);
    headerView.frame = newHeaderFrame;
    
    if (![self isThisUserMe:userID])
    {
        if ([self doIFollowThisUser])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAction:)];
        else
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followAction:)];
    }
    self.tableView.tableHeaderView = headerView;
    [self.tableView reloadData];
}

- (void)fetchDataFromUserID
{
    [SVProgressHUD showWithStatus:@"Fetching user info"];
    
    if (!userID)
        userID = [ANAPICall sharedAppAPI].userID;
    
    [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        SDLog(@"user data = %@", dataObject);
        
        userData = (NSDictionary *)dataObject;
        [self configureFromUserData];
        [self fetchFollowData];
        
        [SVProgressHUD dismiss];
    }];
}

- (BOOL)isThisUserMe:(NSString *)thisUsersID
{
    if ([thisUsersID isEqualToString:[ANAPICall sharedAppAPI].userID])
        return YES;
    return NO;
}

- (BOOL)doIFollowThisUser
{
    BOOL result = [userData boolForKey:@"is_follower"];
    return result;
}

- (void)fetchFollowData
{
    // TODO: we're doing this here so we can get a users followers/following count.
    
    [[ANAPICall sharedAppAPI] getUserFollowers:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        followersList = (NSArray *)dataObject;
        
        [self.tableView reloadData];
    }];
    
    [[ANAPICall sharedAppAPI] getUserFollowing:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        followingList = (NSArray *)dataObject;

        [self.tableView reloadData];
    }];
}

- (void)followAction:(id)sender
{
    UIBarButtonItem *button = sender;
    button.enabled = NO;
    [[ANAPICall sharedAppAPI] followUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        // TODO: check the return here to make sure ther wasn't an error before we change the button.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAction:)];
    }];
}

- (void)unfollowAction:(id)sender
{
    UIBarButtonItem *button = sender;
    button.enabled = NO;
    [[ANAPICall sharedAppAPI] unfollowUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        // TODO: check the return here to make sure ther wasn't an error before we change the button.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followAction:)];        
    }];
}

- (NSString *)userID
{
    return userID;
}

- (BOOL)refresh
{
    // do nothing.
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    
    if (!userData)
        [self fetchDataFromUserID];
    else
    {
        [self configureFromUserData];
        [self fetchFollowData];
    }
    
    userImageView.layer.cornerRadius = 6.0;

    // Setup shadow for cover image view
    topCoverView.layer.shadowRadius = 10.0f;
    topCoverView.layer.shadowOpacity = 0.4f;
    topCoverView.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    
    CGRect shadowRect = topCoverView.bounds;
    shadowRect.size.height /= 4;
    topCoverView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
    
    // Set the initial 
    initialCoverImageYOffset = CGRectGetMinY(coverImageView.frame);
    
    // make the cover image darker.
    UIView *darkView = [[UIView alloc] initWithFrame:coverImageView.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0.4;
    [coverImageView addSubview:darkView];
}

- (void)viewDidUnload
{
    coverImageView = nil;
    userImageView = nil;
    bioLabel = nil;
    nameLabel = nil;
    usernameLabel = nil;
    topCoverView = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Posts";
            cell.detailTextLabel.text = [userData stringForKeyPath:@"counts.posts"];// api always returns 0.
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"Followers";
            cell.detailTextLabel.text = [userData stringForKeyPath:@"counts.followers"];// api always returns 0.
        }
            break;

        case 2:
        {
            cell.textLabel.text = @"Following";
            cell.detailTextLabel.text = [userData stringForKeyPath:@"counts.following"];// api always returns 0.
        }
            break;
            
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    UIViewController *controller = nil;
    
    switch (indexPath.row) {
        case 0:
            controller = [[ANUserPostsController alloc] initWithUserID:userID];
            break;
            
        case 1:
            controller = [[ANUserListController alloc] initWithUserArray:followersList];
            controller.title = @"Followers";
            break;
            
        case 2:
            controller = [[ANUserListController alloc] initWithUserArray:followingList];
            controller.title = @"Following";
            break;
            
        default:
            break;
    }

    if (controller)
        [self.navigationController pushViewController:controller animated:YES];
    else
    {
        UIAlertView *alert = [UIAlertView alertViewWithTitle:@"Unimplemented" message:@"We're still waiting on app.net to implement the api's for this.  Please bear with us."];
        [alert show];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - 
#pragma mark UIScrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Figure out the percent to parallax based on initial image offset
    CGFloat percent = -scrollView.contentOffset.y / (-initialCoverImageYOffset*2);
    
    // Round down down if over 1
    percent = percent > 1 ? 1 : percent;
    
    // if less than eq 0, we're scrolling up. original frame.
    if (percent <= 0) {
        coverImageView.frame = CGRectMake(0.0f, initialCoverImageYOffset, CGRectGetWidth(coverImageView.frame), CGRectGetHeight(coverImageView.frame));
    } else if (percent < 1) {
        
        // calculate target y based on percent
        CGFloat targY = initialCoverImageYOffset + (-initialCoverImageYOffset * percent) + scrollView.contentOffset.y;
        
        // update cover image frame
        coverImageView.frame = CGRectMake(0.0f, targY, CGRectGetWidth(coverImageView.frame), CGRectGetHeight(coverImageView.frame));
    }
}

@end
