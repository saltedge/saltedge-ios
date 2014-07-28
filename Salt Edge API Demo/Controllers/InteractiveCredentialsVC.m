//
//  InteractiveCredentialsVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "InteractiveCredentialsVC.h"
#import "PickerDelegate.h"
#import "PickerTVC.h"
#import "Constants.h"
#import "Helpers.h"
#import "OptionSelectButton.h"
#import "UIView+Framing.h"
#import "UIControl+SELoginInputFieldsAdditions.h"
#import "SEProviderField.h"

@interface InteractiveCredentialsVC () <PickerDelegate>

@property (nonatomic, strong) NSMutableDictionary* inputControlsMappings;
@property (nonatomic, strong) NSMutableArray* inputControlsOrder;

@end

@implementation InteractiveCredentialsVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Interactive";
    [self setupInputControls];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)setupInputControls
{
    for (SEProviderField* interactiveField in self.interactiveFields) {
        UIControl* control = [self createInputControlFromObject:interactiveField];
        control.origin = CGPointMake(10.0, 10 + 60 * ([interactiveField.position integerValue] - 1));
        [self.view addSubview:control];
        self.inputControlsMappings[interactiveField] = control;
        [self.inputControlsOrder addObject:control];
    }
}

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
