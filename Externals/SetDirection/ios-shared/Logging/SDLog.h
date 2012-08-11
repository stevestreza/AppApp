//
//  SDLog.h
//
//  Created by brandon on 2/12/11.
//  Copyright 2011 Set Direction. All rights reserved.
//

#import <Foundation/Foundation.h>

// this turns off logging if DEBUG is not defined in the target
// assuming one is using SDLog everywhere to log to console.

#if defined(TESTFLIGHT)
#define SDLog(__FORMAT__, ...) NSLog((@"%s [Line %d] " __FORMAT__), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#elif defined(DEBUG) && !defined(TESTFLIGHT)
#define SDLog NSLog
#else
#define SDLog(x...)
#endif

#if defined(DEBUG)
#define SDLogResponse(__FORMAT__, ...) { if ([[NSUserDefaults standardUserDefaults] boolForKey:@"kIncludeResponsesInLogs"]) SDLog(__FORMAT__, ##__VA_ARGS__); }
#else
#define SDLogResponse(x...)
#endif
