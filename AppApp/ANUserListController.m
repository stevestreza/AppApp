//
//  ANUserListController.m
//  AppApp
//
//  Created by brandon on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserListController.h"
#import "ANUserViewController.h"
#import "ANUserListCell.h"
#import "NSDictionary+SDExtensions.h"
#import "NSObject+SDExtensions.h"

@implementation ANUserListController
{
    NSArray *userArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserArray:(NSArray *)aUserArray
{
    self = [super initWithNibName:@"ANUserListController" bundle:nil];
    
    userArray = aUserArray;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userListCell";
    ANUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [ANUserListCell loadFromNib];
    
    // Configure the cell...
    NSDictionary *userObject = [userArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = [userObject stringForKey:@"name"];
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", [userObject stringForKeyPath:@"username"]];
    cell.userImageView.imageURL = [userObject stringForKeyPath:@"avatar_image.url"];
    
    // seems like we should use is_following here instead, but this one shows the correct results.
    BOOL following = [userObject boolForKey:@"is_follower"];
    cell.checkImage.hidden = !following;
    
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

/*
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
*/

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
    ANUserViewController *userController = [[ANUserViewController alloc] initWithUserDictionary:[userArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:userController animated:YES];
}

@end
