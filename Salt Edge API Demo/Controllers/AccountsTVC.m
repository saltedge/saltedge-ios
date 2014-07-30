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
#import "SELoginCreationDelegate.h"
#import "SELogin.h"
#import "SEProviderField.h"
#import "SEProvider.h"
#import "CredentialsVC.h"

static NSString* const kLoginRefreshAction   = @"Refresh";
static NSString* const kLoginReconnectAction = @"Reconnect";

@interface AccountsTVC () <UIActionSheetDelegate, SELoginCreationDelegate>

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
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Login actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:kLoginRefreshAction, kLoginReconnectAction, nil];
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
    self.isReconnectingLogin = NO;

    [SVProgressHUD showWithStatus:@"Refreshing..." maskType:SVProgressHUDMaskTypeGradient];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    [manager refreshLoginWithId:self.login.id success:^(NSURLSessionDataTask* task, NSDictionary* refreshResponse) {
        if (![refreshResponse[@"refreshed"] boolValue]) {
            [SVProgressHUD showErrorWithStatus:@"Couldn't refresh login"];
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } delegate:self];
}

- (void)reconnectLogin
{
    self.isReconnectingLogin = YES;

    NSArray* sortedRequiredFields = [self.loginsProvider.requiredFields sortedArrayUsingComparator:^NSComparisonResult (SEProviderField* first, SEProviderField* second) {
        return [first.position integerValue] > [second.position integerValue];
    }];

    [self presentCredentialsScreenWithFields:sortedRequiredFields completion:^(NSDictionary* credentials) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showWithStatus:@"Reconnecting..." maskType:SVProgressHUDMaskTypeGradient];

        SEAPIRequestManager* manager = [SEAPIRequestManager manager];

        [manager reconnectLoginWithLoginId:self.login.id credentials:credentials success:^(NSURLSessionDataTask* task, SELogin* login) {
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        } delegate:self];
    }];
}

- (void)showInteractiveScreenWithInteractiveFields:(NSArray*)interactiveFields
{
    [self presentCredentialsScreenWithFields:interactiveFields completion:^(NSDictionary* interactiveCredentials) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];

        SEAPIRequestManager* manager = [SEAPIRequestManager manager];

        [manager postInteractiveCredentials:interactiveCredentials forLoginId:self.login.id success:^(NSURLSessionDataTask* task, SELogin* login) {
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    }];
}

- (void)presentCredentialsScreenWithFields:(NSArray*)fields completion:(void (^)(NSDictionary*))completion
{
    CredentialsVC* credentials = [self.storyboard instantiateViewControllerWithIdentifier:@"CredentialsVC"];
    credentials.credentialFields = fields;
    credentials.completionBlock = completion;
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:credentials];
    [SVProgressHUD dismiss];
    [self presentViewController:navController animated:YES completion:nil];
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
    }
}

#pragma mark - SELoginCreation Delegate

- (void)login:(SELogin *)login failedToFetchWithMessage:(NSString *)message
{
    self.isReconnectingLogin = NO;
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)login:(SELogin *)login requestedInteractiveCallbackWithFieldNames:(NSArray *)names
{
    if (!self.sentInteractiveCredentials) {
        self.sentInteractiveCredentials = YES;
        NSMutableArray* requestedInteractiveFields = @[].mutableCopy;
        for (SEProviderField* interactiveField in self.loginsProvider.interactiveFields) {
            if ([names containsObject:interactiveField.name]) {
                [requestedInteractiveFields addObject:interactiveField];
            }
        }

        NSAssert(requestedInteractiveFields != nil, @"Login is interactive but has no interactive fields?");

        [self showInteractiveScreenWithInteractiveFields:requestedInteractiveFields];
    }
}

- (void)loginSuccessfullyFinishedFetching:(SELogin *)login
{
    NSString* message = @"Refreshed";
    if (self.isReconnectingLogin) {
        self.isReconnectingLogin = NO;
        message = @"Reconnected";
    }
    [SVProgressHUD showSuccessWithStatus:message];
}

@end
