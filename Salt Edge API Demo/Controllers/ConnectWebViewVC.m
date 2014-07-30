//
//  ViewController.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "ConnectWebViewVC.h"
#import "SEWebView.h"
#import "SEWebViewDelegate.h"
#import "SEAPIRequestManager.h"
#import "UIView+Framing.h"
#import <SVProgressHUD.h>

static CGFloat const kControlsPositionOffset  = 10.0f;

static NSString* const kCustomerEmailKey = @"customer_email";
static NSString* const kDataKey          = @"data";
static NSString* const kConnectURLKey    = @"connect_url";

@interface ConnectWebViewVC () <SEWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField* customerEmailTextField;
@property (nonatomic, strong) UIButton* connectButton;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, strong) SEWebView* connectWebView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation ConnectWebViewVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Connect";
    [self setupEmailTextField];
    [self setupConnectButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Setup methods

- (void)setupEmailTextField
{
    self.customerEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(kControlsPositionOffset, kControlsPositionOffset, self.view.width - 2 * kControlsPositionOffset, 35.0)];
    self.customerEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.customerEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customerEmailTextField.returnKeyType = UIReturnKeyNext;
    self.customerEmailTextField.placeholder = @"Customer E-mail";
    self.customerEmailTextField.delegate = self;
    self.customerEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.customerEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.customerEmailTextField];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)setupConnectButton
{
    self.connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton sizeToFit];
    self.connectButton.center = CGPointMake(self.view.frame.size.width / 2, self.customerEmailTextField.center.y + 5 * kControlsPositionOffset);
    [self.connectButton addTarget:self action:@selector(connectPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.connectButton];
}

- (void)setupConnectWebView
{
    CGFloat tabBarHeight = self.tabBarController.tabBar.height;
    self.connectWebView = [[SEWebView alloc] initWithFrame:CGRectMake(0.0, self.view.yOrigin - tabBarHeight - 15.0, self.view.width, self.view.height - tabBarHeight) stateDelegate:self];
    [self.view addSubview:self.connectWebView];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Actions

- (void)connectPressed
{
    if (self.customerEmailTextField.text.length == 0) { return ; }
    if (self.customerEmailTextField.isFirstResponder) { [self dismissKeyboard]; }
    [self showActivityIndicator];
    [self requestToken];
}

#pragma mark - Utility methods

- (void)requestToken
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager requestConnectTokenWithParameters:@{ kCustomerEmailKey : self.customerEmailTextField.text } success:^(NSURLSessionDataTask* task, NSDictionary* tokenDictionary) {
        NSString* connectURL = tokenDictionary[kConnectURLKey];
        if (connectURL) {
            [self setupConnectWebView];
            [self loadConnectPageWithURLString:connectURL];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Could not receive the connect URL."];
            [self hideActivityIndicator];
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error code %d: %@ (%@)", error.code, error.localizedDescription, task.response]];
        [self hideActivityIndicator];
    }];
}

- (void)loadConnectPageWithURLString:(NSString*)connectURLString
{
    [self.customerEmailTextField removeFromSuperview];
    self.customerEmailTextField = nil;
    [self.connectButton removeFromSuperview];
    self.connectButton = nil;
    [self.view removeGestureRecognizer:self.tapRecognizer];
    self.tapRecognizer = nil;

    [self.connectWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:connectURLString]]];
}

#pragma mark - UI methods

- (void)showAlertWithTitle:(NSString*)title message:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void)showActivityIndicator
{
    self.customerEmailTextField.userInteractionEnabled = NO;
    self.connectButton.userInteractionEnabled = NO;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor grayColor]];
    self.activityIndicator.center = self.view.center;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
}

- (void)hideActivityIndicator
{
    self.customerEmailTextField.userInteractionEnabled = YES;
    self.connectButton.userInteractionEnabled = YES;
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}

- (void)dismissKeyboard
{
    [self.customerEmailTextField resignFirstResponder];
}

- (void)switchToLoginsViewController
{
    [self.tabBarController setSelectedIndex:2];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
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

@end
