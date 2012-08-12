//
//  ANViewControllerProtocol.h
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ANViewControllerProtocol <NSObject>

@property (nonatomic, readonly) NSString *sideMenuTitle;

- (void)refresh;

@end
