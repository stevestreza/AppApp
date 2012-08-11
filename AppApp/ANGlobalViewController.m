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
    ANPostStatusViewController *authView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:authView animated:YES];
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
    return 130; //TODO: Dynamic based on cell content.
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

@end
