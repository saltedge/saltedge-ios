//
//  AccountsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import "AccountsTVC.h"
#import "Constants.h"
#import <SVProgressHUD.h>
#import "TransactionsTVC.h"
#import "SEAPIRequestManager.h"
#import "SEAccount.h"
#import "SELogin.h"
#import "LoginsTVCDelegate.h"
#import "ConnectWebViewVC.h"
#import "AppDelegate.h"
#import "TabBarVC.h"
#import "SEError.h"
#import "CreateLoginVC.h"
#import "SELoginFetchingDelegate.h"
#import "SEProvider.h"
#import "LoginAttemptsTVC.h"

typedef NS_ENUM(NSUInteger, SELoginActionMethod){
    SELoginActionMethodAPI = 0,
    SELoginActionMethodWebView
};

static NSString* const kLoginRefreshAction      = @"Refresh";
static NSString* const kLoginReconnectAction    = @"Reconnect";
static NSString* const kLoginViewAttemptsAction = @"View Attempts";
static NSString* const kLoginRemoveAction       = @"Remove";

static NSString* const kLoginActionMethodWebView = @"Web view";
static NSString* const kLoginActionMethodAPI     = @"API";

@interface AccountsTVC () <UIActionSheetDelegate, UIAlertViewDelegate, SELoginFetchingDelegate>

@property (nonatomic, strong) NSArray* accounts;
@property (nonatomic, strong) SEProvider* loginsProvider;
@property (nonatomic, strong) NSString* desiredLoginAction;

@end

static NSString* const kAccountCellReuseIdentifier = @"AccountTableViewCell";

@implementation AccountsTVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    [self reloadAccountsTableView];
}

#pragma mark - Setup

- (void)setup
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Actions" style:UIBarButtonItemStylePlain target:self action:@selector(actionsPressed)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Actions

- (void)actionsPressed
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kLoginRemoveAction otherButtonTitles:kLoginReconnectAction, kLoginRefreshAction, kLoginViewAttemptsAction, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Helper methods

- (void)reloadAccountsTableView
{
    [SVProgressHUD showWithStatus:@"Loading accounts..." maskType:SVProgressHUDMaskTypeGradient];

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchProviderWithCode:self.login.providerCode success:^(SEProvider* provider) {
        self.loginsProvider = provider;

        [manager fetchFullAccountsListForLoginSecret:self.login.secret success:^(NSSet* accounts) {
            self.accounts = [[accounts allObjects] sortedArrayUsingComparator:^NSComparisonResult(SEAccount* first, SEAccount* second) {
                return [first.name localizedCaseInsensitiveCompare:second.name];
            }];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(SEError* error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:error.errorMessage];
        }];

    } failure:^(SEError* error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.errorMessage];
    }];
}

- (void)showWebViewOrAPIAlert
{
    [[[UIAlertView alloc] initWithTitle:@"Choose a method for the action" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:kLoginActionMethodWebView, kLoginActionMethodAPI, nil] show];
}

- (void)showLoginAttempts
{
    LoginAttemptsTVC* loginAttempts = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginAttemptsTVC"];
    loginAttempts.login = self.login;
    [self.navigationController pushViewController:loginAttempts animated:YES];
}

- (void)refreshCurrentLoginViaAPI
{
    [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeGradient];

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    if (!self.loginsProvider.isOAuth) {
        [manager refreshLoginWithSecret:self.login.secret
                                    success:^(NSDictionary* dictionary) {
                                        if (![dictionary[kDataKey][kRefreshedKey] boolValue]) {
                                            [SVProgressHUD showErrorWithStatus:@"Could not refresh login."];
                                        }
                                    }
                                    failure:^(SEError* error) {
                                        [SVProgressHUD showErrorWithStatus:error.errorMessage];
                                    } delegate:self];
    } else {
        [manager refreshOAuthLoginWithSecret:self.login.secret
                                  parameters:@{ kReturnToKey : [AppDelegate delegate].applicationURLString }
                                     success:^(NSDictionary* responseObject) {
                                         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:responseObject[kDataKey][kRedirectURLKey]]];
                                     }
                                     failure:^(SEError* error) {
                                         [SVProgressHUD showErrorWithStatus:error.errorMessage];
                                     }];
    }
}

- (void)refreshLoginWithMethod:(SELoginActionMethod)method
{
    if (method == SELoginActionMethodWebView) {
        ConnectWebViewVC* connectController = [self connectController];
        [connectController setLogin:self.login];
        [connectController setRefresh:YES];
        [connectController requestToken];
        [self.navigationController.tabBarController setSelectedIndex:0];
    } else {
        [self refreshCurrentLoginViaAPI];
    }
}

- (void)reconnectLoginWithMethod:(SELoginActionMethod)method
{
    if (method == SELoginActionMethodWebView) {
        ConnectWebViewVC* connectController = [self connectController];
        [connectController setLogin:self.login];
        [connectController requestToken];
        [self.navigationController.tabBarController setSelectedIndex:0];
    } else {
        CreateLoginVC* createController = [self createController];
        [createController setLogin:self.login];
        [self.navigationController.tabBarController setSelectedIndex:1];
    }
}

- (void)removeLogin
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager removeLoginWithSecret:self.login.secret success:^(NSDictionary* responseObject) {
        if ([responseObject[kDataKey][kRemovedKey] boolValue]) {
            NSMutableArray* loginSecrets = [[NSUserDefaults standardUserDefaults] arrayForKey:kLoginSecretsDefaultsKey].mutableCopy;
            [loginSecrets removeObject:self.login.secret];
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:loginSecrets] forKey:kLoginSecretsDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SVProgressHUD showSuccessWithStatus:@"Removed"];
            if ([self.delegate respondsToSelector:@selector(removedLogin:)]) {
                [self.delegate removedLogin:self.login];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Couldn't remove login"];
        }
    } failure:^(SEError* error) {
        [SVProgressHUD showErrorWithStatus:error.errorMessage];
    }];
}

- (ConnectWebViewVC*)connectController
{
    return [AppDelegate delegate].tabBar.connectController;
}

- (CreateLoginVC*)createController
{
    return [AppDelegate delegate].tabBar.createController;
}

#pragma mark - UITableView Data Source / Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accounts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAccountCellReuseIdentifier forIndexPath:indexPath];
    SEAccount* theAccount = self.accounts[indexPath.row];
    cell.textLabel.text = theAccount.name;
    cell.detailTextLabel.text =  [NSString stringWithFormat:@"%@ %@", theAccount.balance.description, theAccount.currencyCode];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SEAccount* selectedAccount = self.accounts[indexPath.row];
    TransactionsTVC* transactions = [self.storyboard instantiateViewControllerWithIdentifier:@"TransactionsTVC"];
    [transactions setAccountId:selectedAccount.id];
    [transactions setLoginSecret:self.login.secret];
    transactions.title = selectedAccount.name;
    [self.navigationController pushViewController:transactions animated:YES];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:kLoginRefreshAction] || [buttonTitle isEqualToString:kLoginReconnectAction]) {
        self.desiredLoginAction = buttonTitle;
        [self showWebViewOrAPIAlert];
    } else if ([buttonTitle isEqualToString:kLoginViewAttemptsAction]) {
        [self showLoginAttempts];
    } else if ([buttonTitle isEqualToString:kLoginRemoveAction]) {
        [self removeLogin];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kLoginActionMethodWebView]) {
        if ([self.desiredLoginAction isEqualToString:kLoginRefreshAction]) {
            [self refreshLoginWithMethod:SELoginActionMethodWebView];
        } else {
            [self reconnectLoginWithMethod:SELoginActionMethodWebView];
        }
    } else if ([buttonTitle isEqualToString:kLoginActionMethodAPI]) {
        if ([self.desiredLoginAction isEqualToString:kLoginRefreshAction]) {
            [self refreshLoginWithMethod:SELoginActionMethodAPI];
        } else {
            [self reconnectLoginWithMethod:SELoginActionMethodAPI];
        }
    }
    if (![buttonTitle isEqualToString:@"Cancel"] &&
        !([buttonTitle isEqualToString:kLoginActionMethodAPI] && [self.desiredLoginAction isEqualToString:kLoginRefreshAction])) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - SELogin Fetching Delegate

- (void)login:(SELogin *)login failedToFetchWithMessage:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)loginRequestedInteractiveInput:(SELogin *)login
{
    // not possible, we only refresh logins here in this view controller 
}

- (void)loginSuccessfullyFinishedFetching:(SELogin *)login
{
    [SVProgressHUD showSuccessWithStatus:@"Refreshed"];
}

@end
