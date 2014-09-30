//
//  LoginsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "LoginsTVC.h"
#import "LoginsTVCDelegate.h"
#import "AccountsTVC.h"
#import "Constants.h"
#import <SVProgressHUD.h>
#import "SEAPIRequestManager.h"
#import "SELogin.h"

static NSString* const kLoginTableViewCellReuseIdentifier = @"LoginTableViewCell";

@interface LoginsTVC ()

@property (nonatomic, strong) NSArray* logins;
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

#pragma mark - Setup

- (void)setup
{
    self.title = @"Logins";
    self.navigationController.navigationBarHidden = NO;
    [self reloadLoginsTableViewController];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reload)];
}

#pragma mark - Helper methods

- (void)reloadLoginsTableViewController
{
    if (!self.isLoadingLogins) {
        [SVProgressHUD showWithStatus:@"Loading..."];
        self.isLoadingLogins = YES;
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];

        [manager fetchFullLoginsListWithSuccess:^(NSURLSessionDataTask* task, NSSet* logins) {
            self.logins = [[logins allObjects] sortedArrayUsingComparator:^NSComparisonResult (SELogin* first, SELogin* second) {
                return [first.providerName localizedCaseInsensitiveCompare:second.providerName];
            }];
            [self.tableView reloadData];
            self.isLoadingLogins = NO;
            [SVProgressHUD dismiss];
        } failure:^(NSURLSessionDataTask* task, NSError* error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    }
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
    cell.detailTextLabel.text = theLogin.customerEmail;

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
        [self.tableView reloadData];
    }
}

@end
