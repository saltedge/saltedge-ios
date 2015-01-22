//
//  TabBarVC.m
//  Salt Edge API Demo
//
//  Created by nemesis on 7/28/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import "TabBarVC.h"
#import "ConnectWebViewVC.h"

@interface TabBarVC ()

@end

@implementation TabBarVC

#pragma mark -
#pragma mark - Private API
#pragma mark - Initialization

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.viewControllers = @[[self controllerWithIdentifier:@"ConnectWebViewVC" title:@"Connect"],
                                 [self controllerWithIdentifier:@"CreateLoginVC" title:@"Create"],
                                 [self controllerWithIdentifier:@"LoginsTVC" title:@"Logins"]
                                 ];
    }
    return self;
}

#pragma mark - Helper methods

- (UIStoryboard*)mainStoryboard
{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

- (UINavigationController*)controllerWithIdentifier:(NSString*)identifier title:(NSString*)title
{
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:[[self mainStoryboard] instantiateViewControllerWithIdentifier:identifier]];
    controller.navigationBar.translucent = NO;
    controller.tabBarItem = [self tabBarItemWithTitle:title];
    return controller;
}

- (UITabBarItem*)tabBarItemWithTitle:(NSString*)title
{
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:@"circle"] tag:0];
    return tabBarItem;
}

#pragma mark -
#pragma mark - Public API

- (ConnectWebViewVC*)connectController
{
    return [self.viewControllers[0] viewControllers][0];
}

- (CreateLoginVC*)createController
{
    return [self.viewControllers[1] viewControllers][0];
}

@end
