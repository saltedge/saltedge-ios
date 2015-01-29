//
//  ViewController.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import "ConnectWebViewVC.h"
#import "AppDelegate.h"
#import "SEWebView.h"
#import "SEWebViewDelegate.h"
#import "SEAPIRequestManager.h"
#import "UIView+Framing.h"
#import <SVProgressHUD.h>
#import "SELogin.h"
#import "SEError.h"
#import "PickerTVC.h"
#import "SEProvider.h"
#import "Constants.h"
#import "LoginsTVC.h"

static NSString* const kCustomerEmailKey = @"customer_email";
static NSString* const kConnectURLKey    = @"connect_url";

@interface ConnectWebViewVC () <SEWebViewDelegate>

@property (nonatomic, strong) SEWebView* connectWebView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) SEProvider* provider;
@property (nonatomic, strong) SELogin* login;
@property (nonatomic)         BOOL refresh;

@end

@implementation ConnectWebViewVC

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

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self setupConnectWebView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.login = nil;
    self.refresh = NO;
}

#pragma mark - Setup methods

- (void)setup
{
    self.title = @"Connect";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Providers" style:UIBarButtonItemStylePlain target:self action:@selector(showProviders)];
    SVProgressHUD* hud = [SVProgressHUD performSelector:@selector(sharedView)];
    [hud setHudBackgroundColor:[UIColor blackColor]];
    [hud setHudForegroundColor:[UIColor whiteColor]];
}

- (void)setupConnectWebView
{
    CGFloat tabBarHeight = self.tabBarController.tabBar.height;
    self.connectWebView = [[SEWebView alloc] initWithFrame:CGRectMake(0.0, self.view.yOrigin - tabBarHeight - 15.0, self.view.width, self.view.height - tabBarHeight) stateDelegate:self];
    self.connectWebView.hidden = YES;
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

- (void)fetchProviders
{
    if ([AppDelegate delegate].providers.count == 0) {
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [SVProgressHUD showWithStatus:@"Loading providers..." maskType:SVProgressHUDMaskTypeGradient];
        [manager fetchFullProvidersListWithSuccess:^(NSSet* providers) {
            [AppDelegate delegate].providers = providers;
            [self showProviders];
            [SVProgressHUD dismiss];
        } failure:^(SEError* error) {
            [SVProgressHUD showErrorWithStatus:error.message];
        }];
    }
}

- (void)showProviders
{
    if ([AppDelegate delegate].providers.count == 0) {
        [self fetchProviders];
        return;
    }
    NSArray* providers = [[[[AppDelegate delegate].providers.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mode != %@", @"file"]] valueForKeyPath:@"name"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    UINavigationController* picker = [PickerTVC pickerWithItems:providers completionBlock:^(id pickedProviderName) {
        NSPredicate* namePredicate = [NSPredicate predicateWithFormat:@"name = %@", pickedProviderName];
        self.provider = [[AppDelegate delegate].providers.allObjects filteredArrayUsingPredicate:namePredicate][0];
        [self requestToken];
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)requestToken
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [SVProgressHUD showWithStatus:@"Requesting token..." maskType:SVProgressHUDMaskTypeGradient];
    if (!self.login) {
        NSString* customerId = [AppDelegate delegate].customerId;
        [manager requestCreateTokenWithParameters:@{ @"country_code" : self.provider.countryCode, @"provider_code" : self.provider.code, @"return_to" : @"http://httpbin.org", @"customer_id" : customerId } success:^(NSDictionary* responseObject) {
            [self loadConnectPageWithURLString:responseObject[kDataKey][kConnectURLKey]];
        } failure:^(SEError* error) {
            NSLog(@"%@", error);
        }];
    } else if (self.refresh) {
        [manager requestRefreshTokenForLoginSecret:self.login.secret parameters:@{ @"return_to": @"http://httpbin.org" } success:^(NSDictionary* responseObject) {
            [self loadConnectPageWithURLString:responseObject[kDataKey][kConnectURLKey]];
        } failure:^(SEError* error) {
            NSLog(@"%@", error);
            [SVProgressHUD showErrorWithStatus:error.message];
        }];
    } else {
        [manager requestReconnectTokenForLoginSecret:self.login.secret parameters:@{ @"return_to": @"http://httpbin.org" } success:^(NSDictionary* responseObject) {
            [self loadConnectPageWithURLString:responseObject[kDataKey][kConnectURLKey]];
        } failure:^(SEError* error) {
            NSLog(@"%@", error);
            [SVProgressHUD showErrorWithStatus:error.message];
        }];
    }
}

- (void)loadConnectPageWithURLString:(NSString*)connectURLString
{
    self.connectWebView.hidden = NO;
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
    LoginsTVC* loginsController = [self.tabBarController.viewControllers[2] viewControllers][0];
    [loginsController reloadLoginsTableViewController];
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark - SEWebView Delegate

- (void)webView:(SEWebView *)webView receivedCallbackWithResponse:(NSDictionary *)response
{
    NSString* loginState = response[SELoginDataKey][SELoginStateKey];

    if ([loginState isEqualToString:SELoginStateSuccess]) {
        [self switchToLoginsViewController];
        [SVProgressHUD dismiss];
    } else if ([loginState isEqualToString:SELoginStateFetching]) {
        NSString* loginSecret = response[kDataKey][SELoginSecretKey];
        NSMutableSet* loginSecrets = [NSSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kLoginSecretsDefaultsKey]].mutableCopy;
        if (!loginSecrets) {
            loginSecrets = [NSMutableSet set];
        }
        [loginSecrets addObject:loginSecret];
        [[NSUserDefaults standardUserDefaults] setObject:[loginSecrets allObjects] forKey:kLoginSecretsDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (self.login && !self.login.interactive.boolValue) {
            [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
        }
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
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        [SVProgressHUD dismiss];
        [self hideActivityIndicator];
    }
}

@end
