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

    NSArray *myFollowingList;

    __weak IBOutlet SDImageView *userImageView;
    __weak IBOutlet SDImageView *coverImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *bioLabel;
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

- (BOOL)doIFollowThisUser:(NSString *)thisUsersID
{
    BOOL result = NO;
    for (NSDictionary *userDict in myFollowingList)
    {
        NSString *tmpID = [userDict stringForKey:@"id"];
        if ([thisUsersID isEqualToString:tmpID])
        {
            result = YES;
            break;
        }
    }
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

        // temp attempt at doing follow-a-user working from here until the api returns flags for it.
        if ([userID isEqualToString:[ANAPICall sharedAppAPI].userID])
            myFollowingList = followingList;
        
        [self.tableView reloadData];
    }];
    
    // temp attempt at doing follow-a-user working from here until the api returns flags for it.
    if (![userID isEqualToString:[ANAPICall sharedAppAPI].userID])
    {
        [[ANAPICall sharedAppAPI] getUserFollowing:[ANAPICall sharedAppAPI].userID uiCompletionBlock:^(id dataObject, NSError *error) {
            myFollowingList = (NSArray *)dataObject;
            
            if ([self doIFollowThisUser:userID])
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAction:)];
            }
            else
            {
                self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followAction:)];
            }
        }];
    }
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

@end
