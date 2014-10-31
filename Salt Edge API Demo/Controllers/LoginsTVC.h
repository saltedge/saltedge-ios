//
//  LoginsTVC.h 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginsTVCDelegate.h"

@interface LoginsTVC : UITableViewController <LoginsTVCDelegate>

- (void)reloadLoginsTableViewController;

@end
