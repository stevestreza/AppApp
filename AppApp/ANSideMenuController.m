//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "ANSideMenuController.h"
#import "MFSideMenu.h"
#import "ANGlobalStreamController.h"
#import "ANUserStreamController.h"
#import "ANUserPostsController.h"
#import "ANUserMentionsController.h"

@implementation ANSideMenuController
{
    ANUserStreamController *userStream;
    ANUserMentionsController *mentionsStream;
    ANUserPostsController *postsStream;
    ANGlobalStreamController *globalStream;
}

- (id)init
{
    self = [super init];
    
    userStream = [[ANUserStreamController alloc] init];
    mentionsStream = [[ANUserMentionsController alloc] init];
    postsStream = [[ANUserPostsController alloc] init];
    globalStream = [[ANGlobalStreamController alloc] init];
    
    _navigationArray = @[userStream, mentionsStream, postsStream, globalStream];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    ANBaseStreamController *controller = [_navigationArray objectAtIndex:indexPath.row];
    cell.textLabel.text = controller.sideMenuTitle;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = [_navigationArray objectAtIndex:indexPath.row];
    
    NSArray *controllers = [NSArray arrayWithObject:controller];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

@end
