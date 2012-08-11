//
//  SDTimer.h
//  TrackingApiClient
//
//  Created by Brandon Sneed on 4/10/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDTimer;

typedef void (^SDTimerBlock)(SDTimer *aTimer);

@interface SDTimer : NSObject
{
    dispatch_source_t timer;
}

- (id)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock;
- (void)invalidate;

+ (SDTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock;

@end
