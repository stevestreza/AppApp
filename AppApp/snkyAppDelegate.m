//
//  snkyAppDelegate.m
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "snkyAppDelegate.h"
#import "AuthViewController.h"

@implementation snkyAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ANGlobalViewController alloc] init];
    
    //self.viewController = [[snkyViewController alloc] initWithNibName:@"snkyViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        NSLog(@"bacon");
    }
    
    // if we don't have an access token - display auth.
    // probably should move back to calling Safari.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"access_token"]) {
        AuthViewController *authView = [[AuthViewController alloc] init];
        [self.viewController presentModalViewController:authView animated:YES];
    }
    
    return YES;
}


// https://[your registered redirect URI]/#access_token=[user access token]
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Display text
    
    /*NSString *fragment = [url fragment];
    NSArray *components = [fragment componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    
    NSLog(@"%@",parameters);
    
    NSString *token = [parameters objectForKey:@"access_token"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"access_token"];
    [defaults synchronize];
    NSLog(@"access_token saved to defaults");
    */
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
