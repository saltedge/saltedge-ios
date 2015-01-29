//
//  LoginsTVCDelegate.h
//  Salt Edge API Demo
//
//  Created by nemesis on 8/18/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SELogin;

@protocol LoginsTVCDelegate <NSObject>

- (void)removedLogin:(SELogin*)login;

@end
