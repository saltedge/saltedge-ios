//
//  LoginsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import "LoginsTVC.h"
#import "LoginsTVCDelegate.h"
#import "AccountsTVC.h"
#import "Constants.h"
#import <SVProgressHUD.h>
#import "SEAPIRequestManager.h"
#import "SELogin.h"
#import "AppDelegate.h"
#import "SEError.h"

static NSString* const kLoginTableViewCellReuseIdentifier = @"LoginTableViewCell";

@interface LoginsTVC ()

@property (atomic, strong)    NSArray* logins;
@property (nonatomic, strong) UILabel* noDataLabel;
@property (nonatomic) BOOL isLoadingLogins;

@end

@implementation LoginsTVC

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
    if (!self.logins) {
        [self reloadLoginsTableViewController];
    }
}

#pragma mark - Setup

- (void)setup
{
    self.title = @"Logins";
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupNoDataLabel
{
    if (self.noDataLabel) { return; }
    self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.noDataLabel.text = @"No data to show";
    [self.noDataLabel sizeToFit];
    self.noDataLabel.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:self.noDataLabel];
}

#pragma mark - Helper methods

- (void)reloadLoginsTableViewController
{
    self.logins = @[];
    NSArray* loginSecrets = [[NSUserDefaults standardUserDefaults] arrayForKey:kLoginSecretsDefaultsKey];
    if (loginSecrets.count == 0) {
        [self setupNoDataLabel];
    } else if (!self.isLoadingLogins) {
        [self removeNoDataLabel];
        self.isLoadingLogins = YES;
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
        for (NSString* loginSecret in loginSecrets) {
            [manager fetchLoginWithSecret:loginSecret success:^(SELogin* login) {
                NSMutableArray* mutableLogins = self.logins.mutableCopy;
                [mutableLogins addObject:login];
                self.logins = [NSArray arrayWithArray:mutableLogins];
                [self.tableView reloadData];
                if ([loginSecrets indexOfObject:loginSecret] == loginSecrets.count - 1) {
                    [SVProgressHUD dismiss];
                    self.isLoadingLogins = NO;
                }
            } failure:^(SEError* error) {
                [SVProgressHUD showErrorWithStatus:error.message];
                self.isLoadingLogins = NO;
            }];
        }
    }
}

- (void)removeNoDataLabel
{
    [self.noDataLabel removeFromSuperview];
    self.noDataLabel = nil;
}

#pragma mark - Actions

- (void)reload
{
    [self reloadLoginsTableViewController];
}

#pragma mark - UITableView Delegate / Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logins.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLoginTableViewCellReuseIdentifier forIndexPath:indexPath];
    SELogin* theLogin = self.logins[indexPath.row];
    cell.textLabel.text = theLogin.providerName;
    cell.detailTextLabel.text = theLogin.status;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SELogin* selectedLogin = self.logins[indexPath.row];
    AccountsTVC* accounts = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountsTVC"];
    accounts.delegate = self;
    [accounts setLogin:selectedLogin];
    accounts.title = selectedLogin.providerName;
    [self.navigationController pushViewController:accounts animated:YES];
}

#pragma mark - LoginsTVC Delegate

- (void)removedLogin:(SELogin *)login
{
    if ([self.logins containsObject:login]) {
        NSMutableArray* mutableLoginsCopy = self.logins.mutableCopy;
        [mutableLoginsCopy removeObject:login];
        self.logins = [NSArray arrayWithArray:mutableLoginsCopy];
        if (self.logins.count == 0) {
            [self setupNoDataLabel];
        }
        [self.tableView reloadData];
    }
}

@end
