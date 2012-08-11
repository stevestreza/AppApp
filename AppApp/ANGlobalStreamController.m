//
//  ANGlobalStreamController.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANGlobalStreamController.h"

@implementation ANGlobalStreamController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Global";
    
    [self refresh];
}

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [[ANAPICall sharedAppAPI] getGlobalStream:^(id dataObject, NSError *error) {
        streamData = [NSMutableArray arrayWithArray:dataObject];
        [self.tableView reloadData];
        [self refreshCompleted];
    }];
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
