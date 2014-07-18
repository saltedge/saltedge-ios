//
//  SBWebView.h
//
//  Copyright (c) 2014 Salt Edge. https://saltedge.com
//

#import <UIKit/UIKit.h>

static NSString* const SBLoginStateError    = @"error";
static NSString* const SBLoginStateFetching = @"fetching";
static NSString* const SBLoginStateSuccess  = @"success";

static NSString* const SBLoginStateKey      = @"state";
static NSString* const SBLoginIdKey         = @"login_id";
static NSString* const SBLoginDataKey       = @"data";

@protocol SBWebViewDelegate;

/**
 SBWebView is a subclass of UIWebView designed for assisting with Salt Edge Connect implementation in iOS apps. 
 @see https://docs.saltedge.com/guides/connect/ for more information
 */
@interface SBWebView : UIWebView

/**
 The state delegate of the login that is currently processed. This object will be notified about events such as the state of the login (fetching, success, error) and about any errors that will occur in the processing.

 @warning must not be nil in order to receive Salt Edge Connect callbacks.
 @see SBWebViewDelegate
 */
@property (nonatomic, weak) id<SBWebViewDelegate> stateDelegate;

/**
 Initializes an SBWebView object with the specified frame and state delegate.
 This is the designated initializer.
 @param frame The frame of the web view that is going to be initialized.
 @param stateDelegate The state delegate of the web view that's going to be notified about events.
 @return the initialized SBWebView object.
 */
- (instancetype)initWithFrame:(CGRect)frame stateDelegate:(id<SBWebViewDelegate>)stateDelegate;

@end
