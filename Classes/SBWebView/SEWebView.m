//
//  SEWebView.m
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

#import "SEWebView.h"
#import "NSURL+SBCallbacksAdditions/NSURL+SBCallbacksAdditions.h"
#import "SEWebViewDelegate.h"

@interface SEWebView(/* Private */) <UIWebViewDelegate>
@end

@implementation SEWebView

#pragma mark - Public API
#pragma mark - Designated Initializer

- (instancetype)initWithFrame:(CGRect)frame stateDelegate:(id<SEWebViewDelegate>)stateDelegate
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        _stateDelegate = stateDelegate;
    }
    return self;
}

#pragma mark - Private API
#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = request.URL;
    if (url.sb_isCallbackURL) {
        NSError* error = nil;
        NSDictionary* callbackParameters = [url sb_callbackParametersWithError:&error];
        if (!error) {
            if (callbackParameters[SELoginDataKey][SELoginSecretKey] && callbackParameters[SELoginDataKey][SELoginStateKey]) {
                if ([self.stateDelegate respondsToSelector:@selector(webView:receivedCallbackWithResponse:)]) {
                    [self.stateDelegate webView:self receivedCallbackWithResponse:callbackParameters];
                }
            }
        } else {
            if ([self.stateDelegate respondsToSelector:@selector(webView:receivedCallbackWithError:)]) {
                [self.stateDelegate webView:self receivedCallbackWithError:error];
            }
        }
        return NO;
    }
    if ([self.stateDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.stateDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.stateDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.stateDelegate webView:self didFailLoadWithError:error];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.stateDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.stateDelegate webViewDidFinishLoad:self];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.stateDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.stateDelegate webViewDidStartLoad:self];
    }
}

@end
