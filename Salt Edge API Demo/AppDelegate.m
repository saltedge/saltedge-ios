//
//  AppDelegate.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import "AppDelegate.h"
#import "SEAPIRequestManager.h"
#import "TabBarVC.h"
#import <SVProgressHUD.h>
#import "SERequestHandler.h"
#import "SEError.h"
#import "SEAPIRequestManager+SEOAuthLoginHandlingAdditions.h"
#import "CreateLoginVC.h"
#import "Constants.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface AppDelegate()

@property (nonatomic, strong) TabBarVC* tabBar;

@end

@implementation AppDelegate

+ (instancetype)delegate
{
    return (AppDelegate*) [UIApplication sharedApplication].delegate;
}

- (NSString*)applicationURLString
{
    return @"saltedge-api-demo://home.local"; // the URL has to have a host, otherwise won't be a valid URL on the backend
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupAppearance];

    static NSString* const clientId  = nil; // insert your client ID here
    static NSString* const appSecret = nil; // insert your app secret here
    static NSString* const customerIdentifier = nil; // insert customer identifier here

    if (!clientId || !appSecret || !customerIdentifier) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Client ID, App Secret or Customer Identifier is not set. Please see AppDelegate.m or consult the README file." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return YES;
    }
    [SEAPIRequestManager linkClientId:clientId appSecret:appSecret];
    [SEAPIRequestManager setSSLPinningMode:SEAPIRequestManagerSSLPinningModeEnabled]; // No need to actually write this since SSL pinning is enabled by default.

    void (^setWindowRootViewController)() = ^() {
        self.tabBar = [[TabBarVC alloc] init];
        self.window.rootViewController = self.tabBar;
        [self.window makeKeyAndVisible];
        [SVProgressHUD dismiss];
    };

    __block NSString* customerSecret = [[NSUserDefaults standardUserDefaults] stringForKey:kCustomerSecretDefaultsKey];
    if (!customerSecret) {
        [SVProgressHUD showWithStatus:@"Creating customer..."];
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [manager createCustomerWithIdentifier:customerIdentifier success:^(NSDictionary* responseObject) {
            customerSecret = responseObject[kDataKey][kCustomerSecretKey];
            [[NSUserDefaults standardUserDefaults] setObject:customerSecret forKey:kCustomerSecretDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SEAPIRequestManager linkCustomerSecret:customerSecret];
            setWindowRootViewController();
        } failure:^(SEError* error) {
            setWindowRootViewController();
            [SVProgressHUD show];
            [SVProgressHUD showErrorWithStatus:error.errorMessage];
        }];
    } else {
        [SEAPIRequestManager linkCustomerSecret:customerSecret];
        setWindowRootViewController();
    }

    return YES;
}

- (void)setupAppearance
{
    [SVProgressHUD setBackgroundColor:[UIColor blackColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
}

- (CreateLoginVC*)createController
{
    return [self.tabBar.viewControllers[1] viewControllers][0];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [SEAPIRequestManager handleOpenURL:url sourceApplication:sourceApplication loginFetchingDelegate:[self createController]];
    return YES;
}

@end
