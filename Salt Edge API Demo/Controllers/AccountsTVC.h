//
//  AccountsTVC.h 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SELogin;
@protocol LoginsTVCDelegate;

@interface AccountsTVC : UITableViewController

@property (nonatomic, strong) SELogin* login;
@property (nonatomic, weak)   id<LoginsTVCDelegate> delegate;

@end
