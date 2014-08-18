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
#import <AFHTTPRequestOperationManager.h>

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static NSString* const kAppId = @"34-SaltEdge-iOS-API";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SVProgressHUD* hud = [SVProgressHUD performSelector:@selector(sharedView)];
    [hud setHudBackgroundColor:[UIColor blackColor]];
    [hud setHudForegroundColor:[UIColor whiteColor]];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://localhost:4567/customers" parameters:@{ @"email": CUSTOMER_EMAIL } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SEAPIRequestManager linkAppId:kAppId customerSecret:responseObject[@"data"][@"secret"]];
        self.window.rootViewController = [[TabBarVC alloc] init];
        [self.window makeKeyAndVisible];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n Make sure you've set your app ID and app secret in the server script and launched it.", error.localizedDescription]];
    }];

    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EmptyVC"];
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
