//
//  ANPostDetailController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/12/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostDetailController.h"
#import "ANPostStatusViewController.h"
#import "ANPostDetailCell.h"
#import "ANAPICall.h"
#import "SDImageView.h"
#import "NSObject+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "UILabel+SDExtensions.h"

@implementation ANPostDetailController
{
    NSDictionary *postData;
    NSInteger postIndex;
    id matchedObject;
    ANPostDetailCell *detailCell;
    CGFloat detailCellHeight;
}

- (id)initWithPostData:(NSDictionary *)aPostData
{
    self = [super init];
    
    postData = aPostData;
    postIndex = -1;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // we're gonna reuse this cell like two mofo's.
    
    detailCell = [ANPostDetailCell loadFromNib];
    detailCell.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    detailCell.postLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    detailCell.postLabel.delegate = self;
    detailCell.postLabel.text = [postData stringForKey:@"text"];
    detailCell.nameLabel.text = [postData stringForKeyPath:@"user.name"];
    detailCell.usernameLabel.text = [NSString stringWithFormat:@"@%@", [postData stringForKeyPath:@"user.username"]];
    detailCell.userImageView.imageURL = [postData stringForKeyPath:@"user.avatar_image.url"];
    [detailCell.postLabel adjustHeightToFit:9999.0]; // hopefully unlimited in height...

    // now get that and set the header height..
    CGFloat defaultViewHeight = 221; // seen in the nib.
    CGFloat defaultLabelHeight = 21; // ... i'm putting these here in case we need to change it later.
    CGFloat newLabelHeight = detailCell.postLabel.frame.size.height;
    
    detailCellHeight = defaultViewHeight + (newLabelHeight - defaultLabelHeight);

    [detailCell.replyButton addTarget:self action:@selector(newPostAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailCell.repostButton addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSString *)usersMentioned
{
    NSString *posterUsername = [postData stringForKeyPath:@"user.username"];

    NSArray *mentions = [postData arrayForKeyPath:@"entities.mentions"];
    NSMutableString *result = [NSMutableString stringWithFormat:@"@%@ ", posterUsername];
    
    for (NSDictionary *mention in mentions)
    {
        // skip ourselves if its a reply to us.
        NSString *userID = [mention stringForKey:@"id"];
        if (![userID isEqualToString:[ANAPICall sharedAppAPI].userID])
        {
            NSString *name = [mention stringForKey:@"name"];
            [result appendFormat:@"@%@ ", name];
        }
    }
    
    return result;
}

- (IBAction)newPostAction:(id)sender
{
    NSString *replyToID = [postData stringForKey:@"id"];
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithReplyToID:replyToID];
    [self presentModalViewController:postView animated:YES];
    postView.postTextView.text = [self usersMentioned];
}

- (IBAction)repostAction:(id)sender
{
    NSString *replyToID = [postData stringForKey:@"id"];
    NSString *originalText = [postData stringForKey:@"text"];
    NSString *posterUsername = [postData stringForKeyPath:@"user.username"];

    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithReplyToID:replyToID];
    [self presentModalViewController:postView animated:YES];
    postView.postTextView.text = [NSString stringWithFormat:@"RP @%@: %@", posterUsername, originalText];
}

- (NSString *)sideMenuTitle
{
    return @"Post";
}

- (NSInteger)indexOfTargetPost
{
    NSString *postID = [postData stringForKey:@"id"];
    postIndex = -1;
    for (NSInteger i = 0; i < [streamData count]; i++)
    {
        NSDictionary *postDict = [streamData objectAtIndex:i];
        NSString *thisID = [postDict stringForKey:@"id"];
        if ([thisID isEqualToString:postID])
        {
            postIndex = i;
            break;
        }
    }
    
    return postIndex;
}

#pragma mark - tableview overrides

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == postIndex)
        return;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == postIndex)
        return detailCellHeight;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == postIndex)
        return detailCell;
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - refresh code

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    // do nothing for now.  Replies isn't implemented by the API yet.
    
    NSString *postID = [postData stringForKey:@"id"];
    [[ANAPICall sharedAppAPI] getPostReplies:postID uiCompletionBlock:^(id dataObject, NSError *error) {
        
        // sort the array by postID, so everything is in order of occurrence.
        // surely all this could be done faster/better.  i challenge you to do it and it still work right.
        
        NSArray *sortedArray = [(NSArray *)dataObject sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *id1 = [obj1 stringForKey:@"id"];
            NSString *id2 = [obj2 stringForKey:@"id"];
            if ([id1 integerValue] > [id2 integerValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if ([id1 integerValue] < [id2 integerValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        streamData = [NSMutableArray arrayWithArray:sortedArray];
        
        postIndex = [self indexOfTargetPost];
        
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:postIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
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

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
