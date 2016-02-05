//
//  SEWebView.h
//
//  Copyright (c) 2016 Salt Edge. https://saltedge.com
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

#import <UIKit/UIKit.h>

static NSString* const SELoginStateError      = @"error";
static NSString* const SELoginStateFetching   = @"fetching";
static NSString* const SELoginStateSuccess    = @"success";

static NSString* const SELoginStageKey        = @"stage";
static NSString* const SELoginSecretKey       = @"secret";
static NSString* const SELoginIDKey           = @"login_id";
static NSString* const SELoginDuplicatedIDKey = @"duplicated_login_id";
static NSString* const SELoginDataKey         = @"data";

@protocol SEWebViewDelegate;

/**
 SEWebView is a subclass of UIWebView designed for assisting with Salt Edge Connect implementation in iOS apps.

 @see https://docs.saltedge.com/guides/connect/ for more information
 */
@interface SEWebView : UIWebView

/**
 The state delegate of the login that is currently processed. This object will be notified about events such as the state of the login (fetching, success, error) and about any errors that will occur in the processing.

 @warning must not be nil in order to receive Salt Edge Connect callbacks.

 @see SEWebViewDelegate
 */
@property (nonatomic, weak) id<SEWebViewDelegate> stateDelegate;

/**
 Initializes an SEWebView object with the specified frame and state delegate.
 This is the designated initializer.

 @param frame The frame of the web view that is going to be initialized.
 @param stateDelegate The state delegate of the web view that's going to be notified about events.

 @return the initialized SEWebView object.
 */
- (instancetype)initWithFrame:(CGRect)frame stateDelegate:(id<SEWebViewDelegate>)stateDelegate;

@end
