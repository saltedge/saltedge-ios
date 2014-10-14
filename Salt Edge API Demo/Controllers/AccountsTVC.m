//
//  AccountsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
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

static NSString* const kLoginRefreshAction   = @"Refresh";
static NSString* const kLoginReconnectAction = @"Reconnect";
static NSString* const kLoginRemoveAction    = @"Remove";

@interface AccountsTVC () <UIActionSheetDelegate>

@property (nonatomic, strong) NSArray* accounts;
@property (nonatomic, strong) SEProvider* loginsProvider;

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
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:kLoginRemoveAction otherButtonTitles:kLoginReconnectAction, kLoginRefreshAction, nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Helper methods

- (void)reloadAccountsTableView
{
    [SVProgressHUD showWithStatus:@"Loading..."];

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
            [SVProgressHUD showErrorWithStatus:error.message];
        }];

    } failure:^(SEError* error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.message];
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

    [manager removeLoginWithSecret:self.login.secret success:^(NSDictionary* responseObject) {
        if ([responseObject[@"data"][@"removed"] boolValue]) {
            [SVProgressHUD showSuccessWithStatus:@"Removed"];
            if ([self.delegate respondsToSelector:@selector(removedLogin:)]) {
                [self.delegate removedLogin:self.login];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [SVProgressHUD showErrorWithStatus:@"Couldn't remove login"];
        }
    } failure:^(SEError* error) {
        [SVProgressHUD showErrorWithStatus:error.message];
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
    [transactions setLoginSecret:self.login.secret];
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
    if (![buttonTitle isEqualToString:@"Cancel"]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
