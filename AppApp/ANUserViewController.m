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
#import <QuartzCore/QuartzCore.h>

@interface ANUserViewController ()

@end

@implementation ANUserViewController
{
    NSString *userID;
    
    __weak IBOutlet SDImageView *userImageView;
    __weak IBOutlet SDImageView *coverImageView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Me";
    }
    return self;
}

- (NSString *)sideMenuTitle
{
    return @"Me";
}

- (void)setUserID:(NSString *)value
{
    [SVProgressHUD showWithStatus:@"Fetching user info"];
    
    if (![value isEqualToString:userID])
    {
        userID = value;
        [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
            SDLog(@"user data = %@", dataObject);
            
            NSDictionary *userData = (NSDictionary *)dataObject;
            
            userImageView.imageURL = [userData valueForKeyPath:@"avatar_image.url"];
            coverImageView.imageURL = [userData valueForKeyPath:@"cover_image.url"];
            
            [SVProgressHUD dismiss];
        }];
    }
}

- (NSString *)userID
{
    return userID;
}

- (void)refresh
{
    // do nothing.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:userImageView.layer.bounds
                                                      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft
                                                            cornerRadii:CGSizeMake(6.0, 6.0)];
    
    maskLayer.fillColor = [[UIColor whiteColor] CGColor];
    maskLayer.backgroundColor = [[UIColor clearColor] CGColor];
    maskLayer.path = [roundedPath CGPath];
    // Add mask
    //userImageView.layer.mask = maskLayer;
    
    userImageView.layer.masksToBounds = NO;
    userImageView.layer.cornerRadius = 6.0;
    userImageView.layer.shadowRadius = 5.0;
    userImageView.layer.shadowOpacity = 0.75;
    userImageView.layer.shadowOffset = CGSizeMake(0, 1);
    userImageView.layer.shouldRasterize = YES;
    userImageView.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:userImageView.bounds cornerRadius:6.0] CGPath];

    
    self.userID = [ANAPICall sharedAppAPI].userID;
}

- (void)viewDidUnload
{
    coverImageView = nil;
    userImageView = nil;
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
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
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

@end
