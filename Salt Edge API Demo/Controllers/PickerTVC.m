//
//  PickerTVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "PickerTVC.h"

static NSString* const kPickerCellReuseIdentifier = @"PickerTableViewCell";

@interface PickerTVC ()

@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) PickerCompletionBlock completionBlock;

@end

@implementation PickerTVC

#pragma mark -
#pragma mark - Public API

+ (UINavigationController*)pickerWithItems:(NSArray *)items completionBlock:(PickerCompletionBlock)completion
{
    PickerTVC* pickerTableViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PickerTVC"];
    pickerTableViewController.items = items;
    pickerTableViewController.completionBlock = completion;
    UINavigationController* pickerNavController = [[UINavigationController alloc] initWithRootViewController:pickerTableViewController];
    pickerTableViewController.title = @"Select";
    return pickerNavController;
}

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed)];
}

#pragma mark - Actions

- (void)cancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView Delegate / Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kPickerCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.items[indexPath.row] description];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.completionBlock) {
        NSString* selectedItem = [self.items[indexPath.row] description];
        self.completionBlock(selectedItem);
    }
}

@end
