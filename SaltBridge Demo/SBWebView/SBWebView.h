//
//  SBWebView.h
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* const SBLoginStateError    = @"error";
static NSString* const SBLoginStateFetching = @"fetching";
static NSString* const SBLoginStateSuccess  = @"success";

static NSString* const SBLoginStateKey      = @"state";
static NSString* const SBLoginIdKey         = @"login_id";

@protocol SBWebViewDelegate;

@interface SBWebView : UIWebView

@property (nonatomic, weak) id <SBWebViewDelegate> stateDelegate;

- (instancetype)initWithFrame:(CGRect)frame stateDelegate:(id<SBWebViewDelegate>)stateDelegate;

@end
