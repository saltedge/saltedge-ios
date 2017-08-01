//
//  SEAPIRequestManager+SEOAuthLoginHandlingAdditions.h
//
//  Copyright (c) 2017 Salt Edge. https://saltedge.com
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

#import "SEAPIRequestManager.h"

@protocol SELoginFetchingDelegate;

/**
 SEOAuthLoginHandlingAdditions is a category with a very limited responsibility - handling OAuth providers redirects to your app and processing the fetching operation afterwards.
 */
@interface SEAPIRequestManager (SEOAuthLoginHandlingAdditions)

/**
 Handles a openURL call from your application delegate class when connecting an OAuth provider.

 @param url The URL that was passed in the application:openURL:sourceApplication:annotation: method of your app delegate class.
 @param sourceApplication The source application string that was passed in the application:openURL:sourceApplication:annotation: method of your app delegate class.
 @param delegate The delegate of the login creation process that can respond to certain events. 
 */
+ (void)handleOpenURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication loginFetchingDelegate:(id<SELoginFetchingDelegate>)delegate;

@end
