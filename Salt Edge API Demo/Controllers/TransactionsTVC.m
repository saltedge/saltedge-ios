//
//  TransactionsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "TransactionsTVC.h"
#import <SVProgressHUD.h>
#import "SETransaction.h"
#import "SEAPIRequestManager.h"
#import "TransactionTableViewCell.h"

static NSString* const kTransactionCellReuseIdentifier = @"TransactionTableViewCell";

@interface TransactionsTVC ()

@property (nonatomic, strong) NSArray* transactions;

@end

@implementation TransactionsTVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
    [self reloadTransactionsTableView];
}

#pragma mark - Setup

- (void)setupTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:kTransactionCellReuseIdentifier bundle:nil] forCellReuseIdentifier:kTransactionCellReuseIdentifier];
}

#pragma mark - Helper methods

- (void)reloadTransactionsTableView
{
    [SVProgressHUD showWithStatus:@"Loading"];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchFullTransactionsListForAccountId:self.accountId success:^(NSURLSessionDataTask* task, NSSet* transactions) {
        self.transactions = [transactions allObjects];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransactionTableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:kTransactionCellReuseIdentifier forIndexPath:indexPath];
    [cell setTransaction:self.transactions[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRANSACTION_CELL_HEIGHT;
}

@end
