//
//  NSURL+SBCallbacksAdditions.h
//
//  Copyright (c) 2014 Salt Edge. https://saltedge.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
 Determines whether a NSURL object is a Salt Edge Connect callback URL.

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
