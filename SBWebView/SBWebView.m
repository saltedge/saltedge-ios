//
//  SBWebView.m
//
//  Copyright (c) 2014 Salt Edge. https://saltedge.com
//

#import "SBWebView.h"
#import "NSURL+SBCallbacksAdditions/NSURL+SBCallbacksAdditions.h"
#import "SBWebViewDelegate.h"

@interface SBWebView(/* Private */) <UIWebViewDelegate>
@end

@implementation SBWebView

#pragma mark - Public API
#pragma mark - Designated Initializer

- (instancetype)initWithFrame:(CGRect)frame stateDelegate:(id<SBWebViewDelegate>)stateDelegate
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
            if (callbackParameters[SBLoginDataKey][SBLoginIdKey] && callbackParameters[SBLoginDataKey][SBLoginStateKey]) {
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
