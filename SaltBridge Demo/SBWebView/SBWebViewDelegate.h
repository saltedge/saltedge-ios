//
//  SBWebViewDelegate.h
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SBWebViewDelegate <UIWebViewDelegate>

- (void)webView:(SBWebView*)webView receivedCallbackWithResponse:(NSDictionary*)response;
- (void)webView:(SBWebView*)webView receivedCallbackWithError:(NSError*)error;

@end
