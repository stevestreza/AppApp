//
//  ANBaseStreamController.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANBaseStreamController.h"
#import "ANPostStatusViewController.h"
#import "ANStreamFooterView.h"
#import "ANStreamHeaderView.h"
#import "ANUserViewController.h"
#import "ANPostDetailController.h"

#import "MFSideMenu.h"
#import "NSObject+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"

@interface ANBaseStreamController ()

@end

@implementation ANBaseStreamController

- (void)viewDidLoad
{
    self.title = self.sideMenuTitle;
    [super viewDidLoad];
    
    [self setupSideMenuBarButtonItem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(newPostAction:)];
    
    // setup refresh/load more
    
    self.headerView = [ANStreamHeaderView loadFromNib];
    self.footerView = [ANStreamFooterView loadFromNib];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.011 green:0.486 blue:0.682 alpha:1];
    
    // add gestures
    UISwipeGestureRecognizer *detailsRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDetails:)];
    [detailsRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    UISwipeGestureRecognizer *menuRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSideMenu:)];
    [menuRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [self.tableView addGestureRecognizer:detailsRecognizer];
    [self.tableView addGestureRecognizer:menuRecognizer];
    
    if ([[ANAPICall sharedAppAPI] hasAccessToken])
        [self refresh];
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

#pragma mark - Helper methods

- (void)composeStatus
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:postView animated:YES];
}

- (IBAction)newPostAction:(id)sender
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:postView animated:YES];
}

- (void)showUserAction:(id)sender
{
    NSUInteger index = [(UIControl *)sender tag];
    NSDictionary *postDict = [streamData objectAtIndex:index];
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    ANUserViewController *userController = [[ANUserViewController alloc] initWithUserDictionary:userDict];
    [self.navigationController pushViewController:userController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [streamData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *statusText =[[streamData objectAtIndex: [indexPath row]] objectForKey:@"text"];
    if(statusText == (id)[NSNull null] || statusText.length == 0 ) { statusText = @"null"; }
    
    CGSize maxStatusLabelSize = CGSizeMake(240,200);
    CGSize statusLabelSize = [statusText sizeWithFont: [UIFont fontWithName:@"Helvetica" size:12.0f]
                                    constrainedToSize:maxStatusLabelSize
                                        lineBreakMode: UILineBreakModeWordWrap];
    
    CGFloat height = MAX(ANStatusViewCellUsernameTextHeight + statusLabelSize.height, ANStatusViewCellAvatarHeight)
            + ANStatusViewCellTopMargin + ANStatusViewCellBottomMargin;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ANStatusViewCell";
    ANStatusViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ANStatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }    
    //TODO: move data into objects.
    NSDictionary *statusDict = [streamData objectAtIndex:[indexPath row]];
    NSString *statusText = [statusDict objectForKey:@"text"];
    NSString *avatarURL = [[[statusDict objectForKey:@"user" ] objectForKey:@"avatar_image"] objectForKey:@"url"];

    
    if(statusText == (id)[NSNull null] || statusText.length == 0 ) { statusText = @"null"; }
    cell.username = [[[streamData objectAtIndex: [indexPath row]] objectForKey:@"user"] objectForKey:@"username"];
    cell.status = statusText;
    cell.statusTextLabel.delegate = self;
    
    //detect usernames
    NSArray* mentions = [[[streamData objectAtIndex: [indexPath row]]
                          objectForKey:@"entities"] objectForKey:@"mentions"];
    for(NSDictionary* mention in mentions) {
        NSRange indicies = NSMakeRange([[mention objectForKey:@"pos"] integerValue],
                                       [[mention objectForKey:@"len"] integerValue]);
        [cell.statusTextLabel addLinkToURL:[NSURL URLWithString:
                                            [NSString stringWithFormat:@"username://%@",
                                             [mention objectForKey:@"id"]]] withRange:indicies];
        
        
    }

    
    [cell.avatarView  setImageURL:avatarURL
                    withPlaceholderImage:[UIImage imageNamed:@"placeholderAvatar.png"]];
    // TODO: i know this is janky.  fix it.
    cell.showUserButton.tag = indexPath.row;
    // END JANKY.
    [cell.showUserButton addTarget:self action:@selector(showUserAction:) forControlEvents:UIControlEventTouchUpInside];
    
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
    
    NSDictionary *postData = [streamData objectAtIndex:indexPath.row];
    ANPostDetailController *detailController = [[ANPostDetailController alloc] initWithPostData:postData];
    [self.navigationController pushViewController:detailController animated:YES];
    
     /*<#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Gesture Handling

- (void)swipeToDetails:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    NSLog(@"SWIPE TO DETAILS %@!", [streamData objectAtIndex: [indexPath row]]);
}

- (void)swipeToSideMenu:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    [self.navigationController setMenuState:MFSideMenuStateVisible];
}

#pragma mark - Pull to Refresh

- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    ANStreamHeaderView *hv = (ANStreamHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(ANStreamHeaderView *)self.headerView activityIndicator] stopAnimating];
}

// Update the header text while the user is dragging
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    ANStreamHeaderView *hv = (ANStreamHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

- (BOOL)refresh
{
    if (![super refresh])
        return NO;
    
    // Do your async call here
    // This is just a dummy data loader:
    [self performSelector:@selector(addItemsOnTop) withObject:nil afterDelay:2.0];
    // See -addItemsOnTop for more info on how to finish loading
    return YES;
}

#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more).
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    ANStreamFooterView *fv = (ANStreamFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    ANStreamFooterView *fv = (ANStreamFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:2.0];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

#pragma mark - Refresh methods

- (void)addItemsOnTop
{
//    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    /*[[ANAPICall sharedAppAPI] getGlobalStream:^(id dataObject, NSError *error) {
        streamData = [NSMutableArray arrayWithArray:dataObject];
        [self.tableView reloadData];
        [self refreshCompleted];
    }];*/
}

- (void)addItemsOnBottom
{
//    [self.tableView reloadData];
//    
//    if (items.count > 50)
//        self.canLoadMore = NO; // signal that there won't be any more items to load
//    else
//        self.canLoadMore = YES;
    
    // Inform STableViewController that we have finished loading more items
    //[self loadMoreCompleted];
}

#pragma mark - TTTAttributedLabel delgate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if([[url scheme]isEqualToString:@"username"]) {
        NSString *userID = [url host];
        [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
            NSDictionary *userData = dataObject;
            ANUserViewController* userViewController = [[ANUserViewController alloc] initWithUserDictionary:userData];
            [self.navigationController pushViewController:userViewController animated:YES];
        }];
        
    } else if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}


@end
