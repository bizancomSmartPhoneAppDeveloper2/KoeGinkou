//
//  AppDelegate.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "AppDelegate.h"
#import <NCMB/NCMB.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NCMB setApplicationKey:@"e6ba1db5b7c8e52c7cfbf7ba245702ef8ff3fdcba6c6654ce82479d4196048b1" clientKey:@"7285a92deb165ca053373a80f277895e3a44fdd862a283e7a5aaa30d7a667dd9"];
    
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"TestClass"];
    [query whereKey:@"message" equalTo:@"test"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error == nil) {
            if ([objects count] > 0) {
                NSLog(@"[FIND] %@", [[objects objectAtIndex:0] objectForKey:@"message"]);
            } else {
                NSError *saveError = nil;
                NCMBObject *obj = [NCMBObject objectWithClassName:@"TestClass"];
                [obj setObject:@"Hello, NCMB!" forKey:@"message"];
                [obj save:&saveError];
                if (saveError == nil) {
                    NSLog(@"[SAVE] Done");
                } else {
                    NSLog(@"[SAVE-ERROR] %@", saveError);
                }
            }
        } else {
            NSLog(@"[ERROR] %@", error);
        }
    }];
        return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
