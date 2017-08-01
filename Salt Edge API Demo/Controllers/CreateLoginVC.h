//
//  CreateLoginVC.h 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2017 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SELogin;
@protocol PickerDelegate, SELoginFetchingDelegate;

@interface CreateLoginVC : UIViewController <SELoginFetchingDelegate, PickerDelegate>

- (void)setLogin:(SELogin*)login;

@end
