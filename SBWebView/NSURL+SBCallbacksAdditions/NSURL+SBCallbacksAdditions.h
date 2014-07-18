//
//  NSURL+SBCallbacksAdditions.h
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The callback scheme of the Salt Edge Connect protocol.
 */
static NSString* const SBCallbackScheme = @"saltbridge";
/**
 The callback host of the Salt Edge Connect protocol.
 */
static NSString* const SBCallbackHost   = @"connect";

/**
 This category provides a few utility methods in order to aid SBWebView deal with callbacks from the Salt Edge Connect page.
 */

@interface NSURL (SBCallbacksAdditions)

/**
 Determines wheter a NSURL object is a Salt Edge Connect callback URL.
 @return YES if the NSURL object has the scheme equal to SBCallbackScheme and the host equal to SBCallbackHost, otherwise returns NO.
 @see SBCallbackScheme, SBCallbackHost
 */
- (BOOL)sb_isCallbackURL;
/**
 Provided the NSURL object is a Salt Edge Connect callback URL, this method will return the payload within the callback, if any.
 @return A dictionary containing the callback parameters. The dictionary will have the "login_id" and "state" keys with corresponding values.
 @see webView:receivedCallbackWithResponse:
 */
- (NSDictionary*)sb_callbackParametersWithError:(NSError**)error;

@end
