//
//  TabBarVC.h
//  Salt Edge API Demo
//
//  Created by nemesis on 7/28/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConnectWebViewVC, CreateLoginVC;

@interface TabBarVC : UITabBarController

- (ConnectWebViewVC*)connectController;
- (CreateLoginVC*)createController;

@end
