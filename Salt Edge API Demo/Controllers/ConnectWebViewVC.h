//
//  ViewController.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SELogin;

@interface ConnectWebViewVC : UIViewController

- (void)setLogin:(SELogin*)login;
- (void)setRefresh:(BOOL)refresh;
- (void)requestToken;

@end
