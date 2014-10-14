//
//  AppDelegate.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "AppDelegate.h"
#import "SEAPIRequestManager.h"
#import "TabBarVC.h"
#import <SVProgressHUD.h>
#import "SERequestHandler.h"
#import "SEError.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface AppDelegate()

@property (nonatomic, strong) TabBarVC* tabBar;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    static NSString* const clientId  = nil; // insert your client ID here
    static NSString* const appSecret = nil; // insert your app secret here
    static NSString* const customerIdentifier = nil; // insert customer identifier here

    if (!clientId || !appSecret || !customerIdentifier) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Client ID, App Secret or Customer Identifier is not set. Please see AppDelegate.m or consult the README file." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return YES;
    }

    [SEAPIRequestManager linkClientId:clientId appSecret:appSecret];

    void (^setWindowRootViewController)() = ^() {
        self.tabBar = [[TabBarVC alloc] init];
        self.window.rootViewController = self.tabBar;
        [self.window makeKeyAndVisible];
    };

    __block NSString* customerId = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomerIdDefaultsKey];
    if (!customerId) {
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [manager createCustomerWithIdentifier:customerIdentifier success:^(NSDictionary* responseObject) {
            customerId = responseObject[@"data"][@"customer_id"];
            [[NSUserDefaults standardUserDefaults] setObject:customerId forKey:kCustomerIdDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            setWindowRootViewController();
        } failure:^(SEError* error) {
            NSLog(@"%@", error);
        }];
    } else {
        setWindowRootViewController();
    }

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
