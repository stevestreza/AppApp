//
//  ANUserPostsController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserPostsController.h"

@interface ANUserPostsController ()

@end

@implementation ANUserPostsController
{
    NSString *userID;
}

- (id)initWithUserID:(NSString *)aUserID
{
    self = [super init];
    
    userID = aUserID;
    
    return self;
}

- (NSString *)sideMenuTitle
{
    return @"User Posts";
}


- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    if (userID)
    {
        [[ANAPICall sharedAppAPI] getUserPosts:userID uiCompletionBlock:^(id dataObject, NSError *error) {
            streamData = [NSMutableArray arrayWithArray:dataObject];
            [self.tableView reloadData];
            [self refreshCompleted];
        }];
    }
    else
    {
        [[ANAPICall sharedAppAPI] getUserPosts:^(id dataObject, NSError *error) {
            streamData = [NSMutableArray arrayWithArray:dataObject];
            [self.tableView reloadData];
            [self refreshCompleted];
        }];
    }
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
    [self loadMoreCompleted];
}
@end
