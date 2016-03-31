//
//  TransactionsTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import "TransactionsTVC.h"
#import <SVProgressHUD.h>
#import "SETransaction.h"
#import "SEAPIRequestManager.h"
#import "TransactionTableViewCell.h"
#import "SEError.h"

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
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Helper methods

- (void)reloadTransactionsTableView
{
    [SVProgressHUD showWithStatus:@"Loading transactions..." maskType:SVProgressHUDMaskTypeGradient];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchFullTransactionsListForAccountId:self.accountId loginSecret:self.loginSecret success:^(NSSet* transactions) {
        self.transactions = [transactions allObjects];
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    } failure:^(SEError* error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:error.errorMessage];
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
