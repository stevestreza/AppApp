//
//  SDTimer.m
//  TrackingApiClient
//
//  Created by Brandon Sneed on 4/10/12.
//  Copyright (c) 2012 SetDirection. All rights reserved.
//

#import "SDTimer.h"

@implementation SDTimer

+ (SDTimer *)timerWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock
{
    SDTimer *timer = [[SDTimer alloc] initWithInterval:interval repeats:repeats timerBlock:timerBlock];
    return timer;
}

- (id)initWithInterval:(NSTimeInterval)interval repeats:(BOOL)repeats timerBlock:(SDTimerBlock)timerBlock
{
    self = [super init];
    
    timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (timer)
    {
        __block SDTimer *blockSelf = self;
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), interval * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, ^{
            timerBlock(blockSelf);
            if (!repeats)
                [blockSelf invalidate];
        });
        dispatch_source_set_cancel_handler(timer, ^{
            dispatch_release(timer);
        });
        dispatch_resume(timer);
    }
    
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

- (void)invalidate
{
    if (timer)
    {
        dispatch_suspend(timer);
        dispatch_source_cancel(timer);
    }
}

@end
