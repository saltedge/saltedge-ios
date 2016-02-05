//
//  SingleLoginAttemptTVC.m
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 2/4/16.
//  Copyright © 2016 Salt Edge. All rights reserved.
//

#import "SingleLoginAttemptTVC.h"
#import "SEAPIRequestManager.h"
#import "SELoginAttempt.h"
#import "SELoginAttemptStage.h"
#import "SVProgressHUD.h"
#import "SEError.h"

static NSString* const kAttemptStageCellReuseIdentifier = @"AttemptStageTableViewCell";
static NSString* const kStageNameKey                    = @"name";
static NSString* const kStageCreatedAtKey               = @"created_at";

@interface SingleLoginAttemptTVC ()

@property (nonatomic, strong) NSArray* stages;

@end

@implementation SingleLoginAttemptTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self requestFullLoginAttempt];
}

- (void)requestFullLoginAttempt
{
    [SVProgressHUD showWithStatus:@"Loading attempt..."];

    NSArray* (^sortStagesByCreatedAt)(NSArray*) = ^NSArray*(NSArray* stages) {
        return [stages sortedArrayUsingComparator:^NSComparisonResult(SELoginAttemptStage* first, SELoginAttemptStage* second) {
            return [first.createdAt compare:second.createdAt];
        }];
    };
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchAttemptWithId:self.attempt.id
             forLoginWithSecret:self.loginSecret
                        success:^(SELoginAttempt* attempt) {
                            self.stages = sortStagesByCreatedAt(attempt.stages);
                            [self.tableView reloadData];
                            [SVProgressHUD dismiss];
                        } failure:^(SEError* error) {
                            [SVProgressHUD showErrorWithStatus:error.message];
                        }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stages.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAttemptStageCellReuseIdentifier forIndexPath:indexPath];
    SELoginAttemptStage* stage = self.stages[indexPath.row];
    cell.textLabel.text = stage.name;
    cell.detailTextLabel.text = stage.createdAt.description;
    return cell;
}

@end
