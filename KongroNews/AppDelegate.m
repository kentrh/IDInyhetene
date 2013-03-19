//
//  AppDelegate.m
//  KongroNews
//
//  Created by Kent Robin Haugen on 18.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "TestFlight.h"
#import <Parse/Parse.h>
#import "NewsParser.h"
#import <QuartzCore/QuartzCore.h>

@implementation AppDelegate{
    RootViewController *rootViewController;
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor clearColor];
    
//#define TESTING 1
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
#endif
    [TestFlight takeOff:@"3bcb0a18465d380946152965f06b5b22_MTMyMDgxMjAxMi0wOS0xNCAwODo0NDozMi4zMTIxNzc"];
    
    [Parse setApplicationId:@"SK8Boe17LDovDyHc2GUHhK2neLjT3380PRBCdkbY"
                  clientKey:@"PlYaaZSuuLECBYjgVe5pZcandovIjIuwveZcclv6"];
    
    rootViewController = [[RootViewController alloc] initWithNibName:@"RootViewController" bundle:nil];
    
    self.window.layer.cornerRadius = 3.0;
    self.window.layer.masksToBounds = YES;
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidBecomeActive" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationWillTerminate" object:nil];
}

@end
