//
//  ViewController.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "ConnectWebViewVC.h"
#import "AppDelegate.h"
#import "SEWebView.h"
#import "SEWebViewDelegate.h"
#import "SEAPIRequestManager.h"
#import "UIView+Framing.h"
#import <SVProgressHUD.h>

static NSString* const kCustomerEmailKey = @"customer_email";
static NSString* const kDataKey          = @"data";
static NSString* const kConnectURLKey    = @"connect_url";

@interface ConnectWebViewVC () <SEWebViewDelegate>

@property (nonatomic, strong) SEWebView* connectWebView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) SELogin* login;
@property (nonatomic)         BOOL refresh;

@end

@implementation ConnectWebViewVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Connect";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self connect];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.login = nil;
    self.refresh = NO;
}

#pragma mark - Setup methods

- (void)setupConnectWebView
{
    CGFloat tabBarHeight = self.tabBarController.tabBar.height;
    self.connectWebView = [[SEWebView alloc] initWithFrame:CGRectMake(0.0, self.view.yOrigin - tabBarHeight - 15.0, self.view.width, self.view.height - tabBarHeight) stateDelegate:self];
    [self.view addSubview:self.connectWebView];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Actions

- (void)connect
{
    [self showActivityIndicator];
    [self requestToken];
}

#pragma mark - Utility methods

- (void)requestToken
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    void (^successBlock)(NSURLSessionDataTask*, NSDictionary*) = ^(NSURLSessionDataTask* task, NSDictionary* tokenDictionary){
        NSString* connectURL = tokenDictionary[kConnectURLKey];
        if (connectURL) {
            [self setupConnectWebView];
            [self loadConnectPageWithURLString:connectURL];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Could not receive the connect URL."];
            [self hideActivityIndicator];
        }
    };

    void (^failureBlock)(NSURLSessionDataTask*, NSError*) = ^(NSURLSessionDataTask* task, NSError* error){
        [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error code %d: %@ (%@)", error.code, error.localizedDescription, task.response]];
        [self hideActivityIndicator];
    };

    NSDictionary* parameters = @{ kCustomerEmailKey : CUSTOMER_EMAIL };

    if (self.login && self.refresh) {
        [manager requestRefreshTokenForLogin:self.login parameters:parameters success:successBlock failure:failureBlock];
    } else if (self.login) {
        [manager requestReconnectTokenForLogin:self.login parameters:parameters success:successBlock failure:failureBlock];
    } else {
        [manager requestConnectTokenWithParameters:parameters success:successBlock failure:failureBlock];
    }
}

- (void)loadConnectPageWithURLString:(NSString*)connectURLString
{
    [self.connectWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:connectURLString]]];
}

#pragma mark - UI methods

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)showActivityIndicator
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor grayColor]];
    self.activityIndicator.center = self.view.center;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
}

- (void)hideActivityIndicator
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}

- (void)switchToLoginsViewController
{
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark - SEWebView Delegate

- (void)webView:(SEWebView *)webView receivedCallbackWithResponse:(NSDictionary *)response
{
    NSString* loginState = response[SELoginDataKey][SELoginStateKey];

    if ([loginState isEqualToString:SELoginStateSuccess]) {
        [self switchToLoginsViewController];
        [SVProgressHUD dismiss];
    } else if ([loginState isEqualToString:SELoginStateFetching]) {
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    } else if ([loginState isEqualToString:SELoginStateError]) {
        [SVProgressHUD showErrorWithStatus:@"Error"];
    }
}

- (void)webView:(SEWebView *)webView receivedCallbackWithError:(NSError *)error
{
    [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error code %ld: %@", (long)error.code, error.localizedDescription]];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityIndicator];
}

#pragma mark -
#pragma mark - Public API

- (void)setLogin:(SELogin *)login
{
    _login = login;
}

- (void)setRefresh:(BOOL)refresh
{
    _refresh = refresh;
}

@end
