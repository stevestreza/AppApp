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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TempCellTableIdentifier = @"TempCellTableIdentifier";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:TempCellTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TempCellTableIdentifier];
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
    }
    
    cell.textLabel.text = [[streamData objectAtIndex: [indexPath row]] objectForKey:@"text"];
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECT");
}

@end
