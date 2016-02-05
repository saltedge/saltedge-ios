//
//  LoginAttemptsTVC.m
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 2/3/16.
//  Copyright © 2016 Salt Edge. All rights reserved.
//

#import "LoginAttemptsTVC.h"
#import "SELoginAttempt.h"
#import "SVProgressHUD.h"
#import "SEAPIRequestManager.h"
#import "SELogin.h"
#import "SEError.h"
#import "SingleLoginAttemptTVC.h"

@interface LoginAttemptsTVC ()

@property (nonatomic, strong) NSArray* attempts;

@end

static NSString* const kLoginAttemptTableViewCellReuseIdentifier = @"LoginAttemptTableViewCell";

@implementation LoginAttemptsTVC

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self reloadLoginAttempts];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.attempts.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kLoginAttemptTableViewCellReuseIdentifier forIndexPath:indexPath];
    SELoginAttempt* attempt = self.attempts[indexPath.row];
    NSDate* lastRequestDate = [self nonNullLoginActionDateForAttempt:attempt];
    cell.textLabel.text = lastRequestDate.description;
    cell.detailTextLabel.textColor = [self statusColorForLoginAttempt:attempt];
    cell.detailTextLabel.text = [self statusTextForLoginAttempt:attempt];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SELoginAttempt* selectedAttempt = self.attempts[indexPath.row];
    SingleLoginAttemptTVC* attemptVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleLoginAttemptTVC"];
    attemptVC.attempt = selectedAttempt;
    attemptVC.loginSecret = self.login.secret;
    [self.navigationController pushViewController:attemptVC animated:YES];
}

#pragma mark - Helper methods

- (NSDate*)nonNullLoginActionDateForAttempt:(SELoginAttempt*)attempt
{
    return attempt.successAt ? attempt.successAt : attempt.failAt;
}

- (UIColor*)statusColorForLoginAttempt:(SELoginAttempt*)attempt
{
    if (attempt.successAt) {
        return [UIColor colorWithRed:91.0/255.0 green:182.0/255.0 blue:92.0/255.0 alpha:1.0];
    }
    return [UIColor colorWithRed:212.0/255.0 green:72.0/255.0 blue:71.0/255.0 alpha:1.0];
}

- (NSString*)statusTextForLoginAttempt:(SELoginAttempt*)attempt
{
    return attempt.successAt ? @"Success" : @"Error";
}

- (void)reloadLoginAttempts
{
    [SVProgressHUD showWithStatus:@"Loading attempts..." maskType:SVProgressHUDMaskTypeGradient];

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchAttemptsForLoginWithSecret:self.login.secret
                                     success:^(NSArray* attempts) {
                                         self.attempts = attempts;
                                         [self.tableView reloadData];
                                         [SVProgressHUD dismiss];
                                     }failure:^(SEError* error) {
                                         NSLog(@"Error: %@", error);
                                         [SVProgressHUD showErrorWithStatus:error.message];
                                     }];
}

@end
