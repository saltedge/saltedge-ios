//
//  AppDelegate.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TabBarVC;

static NSString* const kLoginSecretsDefaultsKey = @"LoginSecretsArray";
static NSString* const kCustomerIdDefaultsKey   = @"CustomerIdKey";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly)  TabBarVC* tabBar;
@property (strong, nonatomic) NSSet* providers;
@property (strong, nonatomic) NSString* customerId;

+ (instancetype)delegate;
- (NSString*)applicationURLString;

@end
