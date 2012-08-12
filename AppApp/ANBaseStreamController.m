//
//  ANBaseStreamController.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANBaseStreamController.h"
#import "ANPostStatusViewController.h"
#import "ANStatusViewCell.h"
#import "ANStreamFooterView.h"
#import "ANStreamHeaderView.h"

#import "MFSideMenu.h"
#import "NSObject+SDExtensions.h"

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
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDetails:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [streamData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // TODO: clean this up.
    NSString *statusText =[[streamData objectAtIndex: [indexPath row]] objectForKey:@"text"];
    if(statusText == (id)[NSNull null] || statusText.length == 0 ) { statusText = @"null"; }
    
    CGSize maxStatusLabelSize = CGSizeMake(240,200);
    CGSize statusLabelSize = [statusText sizeWithFont: [UIFont fontWithName:@"Helvetica" size:12.0f]
                                    constrainedToSize:maxStatusLabelSize
                                        lineBreakMode: UILineBreakModeWordWrap];
    
    CGFloat height = MAX(statusLabelSize.height, 60.0f);
    return height + 37;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    return cell;*/
    
    
    ANStatusViewCell *cell = [[ANStatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    //TODO: move data into objects.
    NSDictionary *statusDict = [streamData objectAtIndex:[indexPath row]];
    NSString *statusText = [statusDict objectForKey:@"text"];
    NSString *avatarURL = [[[statusDict objectForKey:@"user" ] objectForKey:@"avatar_image"] objectForKey:@"url"];
    
    if(statusText == (id)[NSNull null] || statusText.length == 0 ) { statusText = @"null"; }
    cell.username = [[[streamData objectAtIndex: [indexPath row]] objectForKey:@"user"] objectForKey:@"username"];
    cell.status = statusText;
    cell.avatarView.imageURL = avatarURL;
    
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
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
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


@end
