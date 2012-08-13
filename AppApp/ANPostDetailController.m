//
//  ANPostDetailController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostDetailController.h"
#import "ANAPICall.h"
#import "SDImageView.h"

@interface ANUserStreamController ()

@end

@implementation ANUserStreamController
{
    NSDictionary *postDictionary;
}

- (id)initWithPostDictionary:(NSDictionary *)aPostDictionary
{
    self = [super init];
    
    postDictionary = aPostDictionary;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = nil;
}

- (NSString *)sideMenuTitle
{
    return @"Post";
}


- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    // do nothing for now.  Replies isn't implemented by the API yet.
    
    /*[[ANAPICall sharedAppAPI] getUserStream:^(id dataObject, NSError *error) {
        streamData = [NSMutableArray arrayWithArray:dataObject];
        [self.tableView reloadData];
        [self refreshCompleted];
    }];*/
    [self refreshCompleted];
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
