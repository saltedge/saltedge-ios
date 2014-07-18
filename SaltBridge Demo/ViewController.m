//
//  ViewController.m
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "ViewController.h"
#import "SBWebView.h"
#import "SBWebViewDelegate.h"
#import <AFHTTPRequestOperationManager.h>

static NSString* const kAppId      = nil; // Enter your app id here
static NSString* const kAppSecret  = nil; // Enter your app secret here
static NSString* const kRootURL    = @"https://saltedge.com";
static NSString* const kTokensPath = @"api/v1/tokens";

static CGFloat const kControlsPositionOffset  = 15.0f;
static CGFloat const kTextFieldHeight         = 30.0f;

@interface ViewController () <SBWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField* emailTextField;
@property (nonatomic, strong) UIButton* connectButton;
@property (nonatomic, strong) UITapGestureRecognizer* tapRecognizer;
@property (nonatomic, strong) SBWebView* connectWebView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@end

@implementation ViewController

#pragma mark - Private API
#pragma mark - View Controller's lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupEmailTextField];
    [self setupConnectButton];
    [self validateAppCredentials];
}

#pragma mark - Setup methods

- (void)setupEmailTextField
{
    self.emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(kControlsPositionOffset, 3 * kControlsPositionOffset, self.view.frame.size.width - 2 * kControlsPositionOffset, kTextFieldHeight)];
    self.emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.placeholder = @"Client email";
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.delegate = self;
    [self.view addSubview:self.emailTextField];

    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:self.tapRecognizer];
}

- (void)setupConnectButton
{
    self.connectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton sizeToFit];
    self.connectButton.center = CGPointMake(self.view.frame.size.width / 2, self.emailTextField.center.y + 5 * kControlsPositionOffset);
    [self.connectButton addTarget:self action:@selector(connectPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.connectButton];
}

- (void)setupConnectWebView
{
    self.connectWebView = [[SBWebView alloc] initWithFrame:self.view.frame stateDelegate:self];
    [self.view addSubview:self.connectWebView];
    [self.view bringSubviewToFront:self.activityIndicator];
}

#pragma mark - Button actions

- (void)connectPressed
{
    if (self.emailTextField.text.length == 0) { return ; }
    if (self.emailTextField.isFirstResponder) { [self dismissKeyboard]; }
    [self showActivityIndicator];
    [self requestToken];
}

#pragma mark - Utility methods

- (void)requestToken
{
    // In order to use Salt Edge Connect, a token is needed - so we request it here
    // See for more information: https://docs.saltedge.com/guides/tokens/

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer* serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:kAppId forHTTPHeaderField:@"App-id"];
    [serializer setValue:kAppSecret forHTTPHeaderField:@"App-secret"];
    [manager setRequestSerializer:serializer];

    NSDictionary* parameters = @{ @"data": @{
                                          @"customer_email" : self.emailTextField.text,
                                          @"mobile" : @YES
                                          }
                                  };

    [manager POST:[kRootURL stringByAppendingPathComponent:kTokensPath] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* connectURL = responseObject[@"data"][@"connect_url"];
        if (connectURL) {
            [self setupConnectWebView];
            [self loadConnectPageWithURLString:connectURL];
        } else {
            [self showAlertWithTitle:@"Error" message:@"Could not receive the connect URL."];
            [self hideActivityIndicator];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error code %d: %@ (%@)", error.code, error.localizedDescription, operation.responseObject]];
        [self hideActivityIndicator];
    }];
}

- (void)validateAppCredentials
{
    if (!kAppId || !kAppSecret) {
        [NSException raise:@"NoCredentials" format:@"*** Please provide your App Id and App Secret in order to use SaltBridge"];
    }
}

- (void)loadConnectPageWithURLString:(NSString*)connectURLString
{
    [self.emailTextField removeFromSuperview];
    self.emailTextField = nil;
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
    self.emailTextField.userInteractionEnabled = NO;
    self.connectButton.userInteractionEnabled = NO;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor grayColor]];
    self.activityIndicator.center = self.view.center;
    [self.activityIndicator startAnimating];
    [self.view addSubview:self.activityIndicator];
}

- (void)hideActivityIndicator
{
    self.emailTextField.userInteractionEnabled = YES;
    self.connectButton.userInteractionEnabled = YES;
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
}

- (void)dismissKeyboard
{
    [self.emailTextField resignFirstResponder];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    return YES;
}

#pragma mark - SBWebView Delegate

- (void)webView:(SBWebView *)webView receivedCallbackWithResponse:(NSDictionary *)response
{
    NSNumber* loginID    = response[SBLoginDataKey][SBLoginIdKey];
    NSString* loginState = response[SBLoginDataKey][SBLoginStateKey];
    NSString* message    = [NSString stringWithFormat:@"Login with id %@ ", loginID.description];

    if ([loginState isEqualToString:SBLoginStateSuccess]) {
        message = [message stringByAppendingString:@"was successfully fetched."];
    } else if ([loginState isEqualToString:SBLoginStateFetching]) {
        message = [message stringByAppendingString:@"is currently being fetched."];
    } else if ([loginState isEqualToString:SBLoginStateError]) {
        message = [message stringByAppendingString:@"wasn't fetched due to an error."];
    }

    [self showAlertWithTitle:@"Callback" message:message];
}

- (void)webView:(SBWebView *)webView receivedCallbackWithError:(NSError *)error
{
    [self showAlertWithTitle:@"Error" message:[NSString stringWithFormat:@"Error code %d: %@", error.code, error.localizedDescription]];
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideActivityIndicator];
}

@end
