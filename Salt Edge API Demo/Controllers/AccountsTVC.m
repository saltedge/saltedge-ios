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

@interface AccountsTVC ()

@property (nonatomic, strong) NSArray* accounts;

@end

static NSString* const kAccountCellReuseIdentifier = @"AccountTableViewCell";

@implementation AccountsTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reloadAccountsTableView];
}

- (void)reloadAccountsTableView
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchFullAccountsListForLoginId:self.loginId success:^(NSURLSessionDataTask* task, NSSet* accounts) {
        self.accounts = [[accounts allObjects] sortedArrayUsingComparator:^NSComparisonResult(SEAccount* first, SEAccount* second) {
            return [first.name localizedCaseInsensitiveCompare:second.name];
        }];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

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

@end
