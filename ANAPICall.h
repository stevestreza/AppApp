//
//  ANAPICall.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

@interface ANAPICall : NSObject

+ (ANAPICall *)sharedAppAPI;
-(void) makePostWithText:(NSString*)text;
-(void)getGlobalStreamWithDelegate:(id) delegate;
@end

@protocol ANAPIDelegate <NSObject>
-(void) globalStreamDidReturnData:(NSArray *) data;
@end