//
//  SDImageView.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "SDImageView.h"
#import "SDURLConnection.h"

@implementation SDImageView
{
    __weak SDURLConnection *urlConnection;
    NSString *imageURL;
}

@synthesize imageURL;

- (void)setImageURL:(NSString *)value
{
    imageURL = value;
    if (urlConnection)
        [urlConnection cancel];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:value]];
    urlConnection = [SDURLConnection sendAsynchronousRequest:request shouldCache:YES withResponseHandler:^(SDURLConnection *connection, NSURLResponse *response, NSData *responseData, NSError *error) {
        UIImage *newImage = [UIImage imageWithData:responseData];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image = newImage;
            self.backgroundColor = [UIColor clearColor];
            urlConnection = nil;
        });
    }];
}

@end
