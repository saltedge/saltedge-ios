//
//  CredentialsVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "CredentialsVC.h"
#import "PickerDelegate.h"
#import "PickerTVC.h"
#import "Constants.h"
#import "Helpers.h"
#import "OptionSelectButton.h"
#import "UIView+Framing.h"
#import "UIControl+SELoginInputFieldsAdditions.h"
#import "SEProviderField.h"

@interface CredentialsVC () <PickerDelegate>

@property (nonatomic, strong) NSMutableDictionary* inputControlsMappings;
@property (nonatomic, strong) NSMutableArray* inputControlsOrder;

@end

@implementation CredentialsVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Credentials";
    [self setupInputControls];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Setup

- (void)setupInputControls
{
    for (SEProviderField* field in self.credentialFields) {
        UIControl* control = [self createInputControlFromObject:field];
        control.origin = CGPointMake(10.0, 10 + 45 * ([field.position integerValue] - 1));
        [self.view addSubview:control];
        self.inputControlsMappings[field] = control;
        [self.inputControlsOrder addObject:control];
    }
}

#pragma mark - Helper methods

- (UIControl*)createInputControlFromObject:(SEProviderField*)field
{
    NSString* inputFieldType = field.nature;
    id inputControl = [Helpers inputControlFromObject:field];
    if ([inputFieldType isEqualToString:SEProviderFieldTypeText] || [inputFieldType isEqualToString:SEProviderFieldTypePassword]) {
        [inputControl setDelegate:self];
    } else if ([inputFieldType isEqualToString:SEProviderFieldTypeSelect]) {
        [inputControl setPickerDelegate:self];
    }
    return inputControl;
}

#pragma mark - Actions

- (void)donePressed
{
    for (id control in self.inputControlsOrder) {
        if (![control se_hasInputData]) {
            [control se_highlight];
            return;
        }
    }
    NSMutableDictionary* credentialsDictionary = @{}.mutableCopy;
    [self.inputControlsMappings enumerateKeysAndObjectsUsingBlock:^(SEProviderField* providerField, UIControl* control, BOOL* stop) {
        id controlValue = [control se_inputValue];
        if (controlValue) {
            credentialsDictionary[providerField.name] = controlValue;
        } else {
            [NSException raise:@"NilValue" format:@"%@ has nil value", control];
        }
    }];
    if (self.completionBlock) { self.completionBlock(credentialsDictionary); }
}

#pragma mark - Lazy getters

- (NSMutableArray*)inputControlsOrder
{
    if (!_inputControlsOrder) {
        _inputControlsOrder = @[].mutableCopy;
    }
    return _inputControlsOrder;
}

- (NSMutableDictionary*)inputControlsMappings
{
    if (!_inputControlsMappings) {
        _inputControlsMappings = @{}.mutableCopy;
    }
    return _inputControlsMappings;
}

#pragma mark - Picker Delegate

- (void)presentPickerWithOptions:(NSArray *)options withCompletionBlock:(PickerCompletionBlock)completionBlock
{
    UINavigationController* providersPicker = [PickerTVC pickerWithItems:options completionBlock:^(id selectedOption) {
        if (completionBlock) { completionBlock(selectedOption); }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:providersPicker animated:YES completion:nil];
}

@end
