//
//  SELoginFetchingDelegate.h
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

#import <Foundation/Foundation.h>

@class SELogin;

/**
 SELoginFetchingDelegate is a protocol that is used to notify a delegate about events that are occuring in the process while some login actions are being performed (create, refresh, reconnect). Such events are: login required interactive credentials, login failed to fetch, login started fetching, login cannot be fetched and login failed to fetch.
 */
@protocol SELoginFetchingDelegate <NSObject>

@optional
/**
 This message is sent to the delegate when the login has started the fetching process.

 @param login The login that is being fetched.
 */
- (void)loginStartedFetching:(SELogin*)login;

@required

/**
 This message is sent to the delegate when the login failed to fetch for some reason.

 @param login The login which failed to fetch.
 @param message The reason why the login failed to fetch.

 @warning login may be nil. Always perform a check to see whether the login object is not nil.
 */
- (void)login:(SELogin*)login failedToFetchWithMessage:(NSString*)message;

/**
 This message is sent to the delegate when the login has required interactive user input.
 Look for the requested fields in login's interactiveFieldsNames property.

 @param login The login which requested interactive credentials input.
 */
- (void)loginRequestedInteractiveInput:(SELogin*)login;

/**
 This message is sent to the delegate when the login successfully finishes fetching.

 @param login The login which was successfully connected and finished fetching.
 */
- (void)loginSuccessfullyFinishedFetching:(SELogin*)login;

@end
