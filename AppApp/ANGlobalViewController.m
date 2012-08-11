//
//  ANGlobalViewController.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANGlobalViewController.h"
#import "ANAPICall.h"
#import "ANPostStatusViewController.h"
#import "ANStatusViewCell.h"

@interface ANGlobalViewController ()<UITableViewDelegate, UITableViewDataSource, ANAPIDelegate>
{
    NSMutableArray *streamData;
}
@end

@implementation ANGlobalViewController
@synthesize tableView;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add gestures
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDetails:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:recognizer];
    
    [self refreshStream];
}

-(void) refreshStream
{
    [[ANAPICall sharedAppAPI] getGlobalStreamWithDelegate:self];
}

-(void) globalStreamDidReturnData:(NSArray *)data
{
    if(streamData) {
        streamData = nil;
    }
    
    streamData = [[NSMutableArray alloc] initWithArray:data];
    [tableView reloadData];
}

-(IBAction)composeStatus:(id)sender
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:postView animated:YES];
}

-(IBAction) refreshGlobalStream:(id)sender
{
    [self refreshStream];
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ANStatusViewCell *cell = [[ANStatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
    //TODO: move data into objects.
    NSString *statusText =[[streamData objectAtIndex: [indexPath row]] objectForKey:@"text"];
    
    if(statusText == (id)[NSNull null] || statusText.length == 0 ) { statusText = @"null"; }
    cell.username = [[[streamData objectAtIndex: [indexPath row]] objectForKey:@"user"] objectForKey:@"username"];
    cell.status = statusText;

    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECT");
}

- (void)swipeToDetails:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    NSLog(@"SWIPE TO DETAILS %@!", [streamData objectAtIndex: [indexPath row]]);
}

@end
