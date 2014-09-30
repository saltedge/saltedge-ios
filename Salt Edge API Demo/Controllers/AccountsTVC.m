//
//  AccountsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "AccountsTVC.h"
#import <AFHTTPRequestOperationManager.h>
#import "Constants.h"
#import "Helpers.h"
#import <SVProgressHUD.h>
#import "TransactionsTVC.h"
#import "SEAPIRequestManager.h"
#import "SEAccount.h"
#import "SELogin.h"
#import "SEProviderField.h"
#import "SEProvider.h"
#import "CredentialsVC.h"
#import "LoginsTVCDelegate.h"
#import "ConnectWebViewVC.h"
#import "AppDelegate.h"
#import "TabBarVC.h"

static NSString* const kLoginRefreshAction   = @"Refresh";
static NSString* const kLoginReconnectAction = @"Reconnect";
static NSString* const kLoginRemoveAction    = @"Remove";

@interface AccountsTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray* accounts;
@property (nonatomic, strong) SEProvider* loginsProvider;
@property (nonatomic) BOOL sentInteractiveCredentials;
@property (nonatomic) BOOL isReconnectingLogin;

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
}

#pragma mark - Actions

- (void)actionsPressed
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Login actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kLoginRemoveAction otherButtonTitles:kLoginReconnectAction, kLoginRefreshAction, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Helper methods

- (void)reloadAccountsTableView
{
    [SVProgressHUD showWithStatus:@"Loading..."];

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager fetchProviderWithCode:self.login.providerCode success:^(NSURLSessionDataTask* task, SEProvider* provider) {
        self.loginsProvider = provider;

        [manager fetchFullAccountsListForLoginId:self.login.id success:^(NSURLSessionDataTask* task, NSSet* accounts) {
            self.accounts = [[accounts allObjects] sortedArrayUsingComparator:^NSComparisonResult(SEAccount* first, SEAccount* second) {
                return [first.name localizedCaseInsensitiveCompare:second.name];
            }];
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            NSLog(@"Error: %@", error);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
        
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)refreshLogin
{
    ConnectWebViewVC* connectController = [self connectController];
    [connectController setLogin:self.login];
    [connectController setRefresh:YES];
    [self.navigationController.tabBarController setSelectedIndex:0];
}

- (void)reconnectLogin
{
    ConnectWebViewVC* connectController = [self connectController];
    [connectController setLogin:self.login];
    [self.navigationController.tabBarController setSelectedIndex:0];
}

- (void)removeLogin
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager removeLoginWithId:self.login.id success:^(NSURLSessionDataTask* task, id responseObject) {
        if ([responseObject[@"data"][@"removed"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:@"Removed"];
            if ([self.delegate respondsToSelector:@selector(removedLogin:)]) {
                [self.delegate removedLogin:self.login];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Couldn't remove login"];
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (ConnectWebViewVC*)connectController
{
    AppDelegate* appDelegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    return appDelegate.tabBar.connectController;
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
    transactions.title = selectedAccount.name;
    [self.navigationController pushViewController:transactions animated:YES];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if ([buttonTitle isEqualToString:kLoginRefreshAction]) {
        [self refreshLogin];
    } else if ([buttonTitle isEqualToString:kLoginReconnectAction]) {
        [self reconnectLogin];
    } else if ([buttonTitle isEqualToString:kLoginRemoveAction]) {
        [self removeLogin];
    }
}

@end
