//
//  SBWebViewDelegate.h
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The SBWebViewDelegate protocol defines optional methods that are to be implemented by a delegate of an SBWebView in order to be notified about Salt Edge Connect events.
 */

@protocol SBWebViewDelegate <UIWebViewDelegate>

/**
 Invoked when a callback is triggered from the Salt Edge Connect page.
 @param webView The web view which displays the Salt Edge Connect page from which the callback is triggered.
 @param response The payload within the callback. It contains two keys: "login_id" and "state". See an example response above.
 @code
 {
    "data": {
        "login_id": 997671551,
        "state": "success"
    }
 }
 @endcode
 */
- (void)webView:(SBWebView*)webView receivedCallbackWithResponse:(NSDictionary*)response;
/**
 Invoked when a error occurs within the callback from the Salt Edge Connect page.
 @param webView The web view which displays the Salt Edge Connect page from which the callback is triggered.
 @param error The error that has occured.
 */
- (void)webView:(SBWebView*)webView receivedCallbackWithError:(NSError*)error;

@end
