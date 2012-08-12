//
//  snkyAppDelegate.m
//  AppApp
//
//  Created by Nick Pannuto on 8/8/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANAppDelegate.h"
#import "AuthViewController.h"
#import "MFSideMenuManager.h"
#import "ANSideMenuController.h"
#import "ANAPICall.h"

@implementation ANAppDelegate

static ANAppDelegate *sharedInstance = nil;

+ (ANAppDelegate *)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    sharedInstance = self;
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"c2a440bf3e4d6e2cb3a8267e89c71dc0_MTIwMjEwMjAxMi0wOC0xMCAyMTo0NjoyMC41MTQwODc"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _sideMenuController = [[ANSideMenuController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[_sideMenuController.navigationArray objectAtIndex:0]];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // make sure to display the navigation controller before calling this
    [MFSideMenuManager configureWithNavigationController:navigationController
                                      sideMenuController:_sideMenuController];

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        NSLog(@"bacon");
    }
    
    // if we don't have an access token - display auth.
    // probably should move back to calling Safari.
    if (![[ANAPICall sharedAppAPI] hasAccessToken])
    {
        AuthViewController *authView = [[AuthViewController alloc] init];
        [self.window.rootViewController presentModalViewController:authView animated:YES];
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
