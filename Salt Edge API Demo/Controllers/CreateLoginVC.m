//
//  CreateLoginVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "CreateLoginVC.h"
#import "Helpers.h"
#import "Constants.h"
#import <AFHTTPRequestOperationManager.h>
#import <SVProgressHUD.h>
#import "PickerTVC.h"
#import "UIView+Framing.h"
#import "UIControl+SELoginInputFieldsAdditions.h"
#import "LoginsTVC.h"
#import "OptionSelectButton.h"
#import "PickerDelegate.h"
#import "CredentialsVC.h"
#import "SEAPIRequestManager.h"
#import "SEProvider.h"
#import "SEProviderField.h"
#import "SELogin.h"
#import "SELoginCreationDelegate.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static CGFloat keyboardOffset = 0.0;
static CGFloat keyboardHeight = 152.0; // bad
static CGFloat viewYOrigin    = 0.0;

typedef void (^CompletionBlock)(void);

@interface CreateLoginVC () <UITextFieldDelegate, PickerDelegate, SELoginCreationDelegate>

@property (nonatomic, strong) NSSet* providers;
@property (nonatomic, strong) UITextField* customerEmailTextField;
@property (nonatomic, strong) UILabel* instructionsLabel;
@property (nonatomic, strong) NSMutableDictionary* inputControlsMappings;
@property (nonatomic, strong) NSMutableArray* inputControlsOrder;
@property (nonatomic, strong) UITextField* editingTextField;
@property (nonatomic, strong) SEProvider* selectedProvider;
@property (nonatomic) BOOL animatingTextFieldOffset;
@property (nonatomic) BOOL sentInteractiveCredentials;

@end

@implementation CreateLoginVC

#pragma mark -
#pragma mark - Private API
#pragma mark - View Controllers lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    [self setupCustomerEmailTextField];
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self requestProvidersListWithCompletionBlock:^{
        [SVProgressHUD dismiss];
        [self showProviderPicker];
        [self setupChooseAnotherProviderButton];
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)]];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    viewYOrigin = self.view.yOrigin;
}

#pragma mark - Setup

- (void)setup
{
    self.title = @"Create";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)setupCustomerEmailTextField
{
    self.customerEmailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 300, 35)];
    self.customerEmailTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.customerEmailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customerEmailTextField.returnKeyType = UIReturnKeyNext;
    self.customerEmailTextField.placeholder = @"Customer E-mail";
    self.customerEmailTextField.delegate = self;
    [self.inputControlsOrder addObject:self.customerEmailTextField];
    self.customerEmailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.customerEmailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:self.customerEmailTextField];
}

- (void)setupInputViews
{
    NSArray* sortedRequiredFields = [self.selectedProvider.requiredFields sortedArrayUsingComparator:^NSComparisonResult (SEProviderField* first, SEProviderField* second) {
        return [first.position integerValue] > [second.position integerValue];
    }];
    [self setupProviderInstructionWithText:self.selectedProvider.instruction];
    [self setupRequiredFieldsWithArray:sortedRequiredFields];
    [self setupCreateButton];
}

- (void)setupProviderInstructionWithText:(NSString*)instruction
{
    self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.customerEmailTextField.bottomEdge + 10.0f, 0.0, 0.0)];
    self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionsLabel.numberOfLines = 0;
    self.instructionsLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.instructionsLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    self.instructionsLabel.textColor = [UIColor blackColor];
    self.instructionsLabel.text = instruction;
    [self.instructionsLabel sizeToFit];
    self.instructionsLabel.center = CGPointMake(self.view.frame.size.width / 2, self.instructionsLabel.center.y);
    [self.view addSubview:self.instructionsLabel];
}

- (void)setupRequiredFieldsWithArray:(NSArray*)array
{
    for (SEProviderField* requiredField in array) {
        UIControl* inputControl = [self createInputControlFromObject:requiredField];
        self.inputControlsMappings[requiredField] = inputControl;
        [self.inputControlsOrder addObject:inputControl];
        inputControl.origin = CGPointMake((self.view.width - inputControl.width) / 2, self.instructionsLabel.bottomEdge + 10.0 + 45.0 * ([requiredField.position integerValue] - 1));
        [self.view addSubview:inputControl];
    }
    UITextField* lastTextField = [[self.inputControlsOrder filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"class == %@",[UITextField class]]] lastObject];
    lastTextField.returnKeyType = UIReturnKeyDone;
}

- (void)setupCreateButton
{
    UIButton* createLoginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createLoginButton setTitle:@"Create login" forState:UIControlStateNormal];
    [createLoginButton addTarget:self action:@selector(createLoginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [createLoginButton sizeToFit];
    NSNumber* maxPosition = [self.inputControlsMappings.allKeys valueForKeyPath:@"@max.position.intValue"];
    NSPredicate* maxPositionPredicate = [NSPredicate predicateWithFormat:@"position == %@",maxPosition];
    SEProviderField* lastField = [[self.inputControlsMappings.allKeys filteredArrayUsingPredicate:maxPositionPredicate] lastObject];
    UIView* lastInputControl = self.inputControlsMappings[lastField];
    createLoginButton.center = CGPointMake(self.view.width / 2, lastInputControl.center.y + lastInputControl.height / 2 + createLoginButton.height / 2 + 10.0f);
    [self.view addSubview:createLoginButton];
}

- (void)setupChooseAnotherProviderButton
{
    UIButton* chooseAnotherProviderButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [chooseAnotherProviderButton setTitle:@"Choose another provider" forState:UIControlStateNormal];
    [chooseAnotherProviderButton addTarget:self action:@selector(chooseAnotherProviderPressed) forControlEvents:UIControlEventTouchUpInside];
    [chooseAnotherProviderButton sizeToFit];
    chooseAnotherProviderButton.center = CGPointMake(self.view.width / 2, self.view.height - self.tabBarController.tabBar.height - chooseAnotherProviderButton.height / 2 - 10.0f);
    [self.view addSubview:chooseAnotherProviderButton];
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

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.editingTextField = textField;
    if (textField.bottomEdge > self.view.height - self.tabBarController.tabBar.height - keyboardHeight - textField.height) {
        [self offsetViewOnYAxisBy:-textField.height];
        keyboardOffset += textField.height;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.view.yOrigin != viewYOrigin) {
        [self offsetViewOnYAxisBy:keyboardOffset];
        keyboardOffset = 0.0;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.inputControlsOrder containsObject:textField] && textField != [self.inputControlsOrder lastObject]) {
        UITextField* next = [self.inputControlsOrder objectAtIndex:[self.inputControlsOrder indexOfObject:textField] + 1];
        [textField resignFirstResponder];
        [next becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark - Actions

- (void)createLoginButtonPressed
{
    for (id control in self.inputControlsOrder) {
        if (![control se_hasInputData]) {
            [control se_highlight];
            return;
        }
    }
    [self createLogin];
}

- (void)chooseAnotherProviderPressed
{
    [self showProviderPicker];
}

#pragma mark - Utility methods

- (void)requestProvidersListWithCompletionBlock:(CompletionBlock)completionBlock
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchFullProvidersListWithSuccess:^(NSURLSessionDataTask* task, NSSet* providersList) {
        self.providers = providersList;
        completionBlock();
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)userSelectedProvider:(NSString*)selectedProviderName
{
    [SVProgressHUD showWithStatus:@"Loading..."];
    [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.inputControlsOrder = @[].mutableCopy;
    self.instructionsLabel = nil;
    self.inputControlsMappings = @{}.mutableCopy;
    for (UIGestureRecognizer* recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }

    [self setupCustomerEmailTextField];
    [self setupChooseAnotherProviderButton];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)]];

    NSPredicate* providerPredicate = [NSPredicate predicateWithFormat:@"name == %@", selectedProviderName];
    SEProvider* selectedProvider = [[self.providers filteredSetUsingPredicate:providerPredicate] allObjects][0];

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager fetchProviderWithCode:selectedProvider.code success:^(NSURLSessionDataTask* task, SEProvider* fetchedProvider) {
        self.selectedProvider = fetchedProvider;
        [self setupInputViews];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}


- (void)createLogin
{
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    NSMutableDictionary* credentialsDictionary = @{}.mutableCopy;
    [self.inputControlsMappings enumerateKeysAndObjectsUsingBlock:^(SEProviderField* field, UIControl* control, BOOL* stop) {
        id controlValue = [control se_inputValue];
        if (controlValue) {
            credentialsDictionary[field.name] = controlValue;
        } else {
            [NSException raise:@"NilValue" format:@"%@ has nil value", control];
        }
    }];

    NSDictionary *parameters = @{ @"customer_email" : self.customerEmailTextField.text,
                                  @"country_code" : self.selectedProvider.countryCode,
                                  @"provider_code" : self.selectedProvider.code,
                                  @"credentials" : credentialsDictionary
                                  };

    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [manager createLoginWithParameters:parameters success:^(NSURLSessionDataTask* task, SELogin* createdLogin) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showWithStatus:@"Fetching..."];
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    } delegate:self];
}

- (void)showInteractiveCredentialsEntryForLoginWithId:(NSNumber*)_id interactiveFieldsNames:(NSArray*)interactiveFieldsNames
{
    if (!self.sentInteractiveCredentials) {
        self.sentInteractiveCredentials = YES;
        NSMutableArray* requestedInteractiveFields = @[].mutableCopy;
        for (SEProviderField* interactiveField in self.selectedProvider.interactiveFields) {
            if ([interactiveFieldsNames containsObject:interactiveField.name]) {
                [requestedInteractiveFields addObject:interactiveField];
            }
        }

        NSAssert(requestedInteractiveFields != nil, @"Login is interactive but has no interactive fields?");
        
        CredentialsVC* interactive = [self.storyboard instantiateViewControllerWithIdentifier:@"CredentialsVC"];
        interactive.credentialFields = requestedInteractiveFields;
        interactive.completionBlock = ^(NSDictionary* interactiveCredentials) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];

            SEAPIRequestManager* manager = [SEAPIRequestManager manager];
            [manager postInteractiveCredentials:interactiveCredentials forLoginId:_id success:^(NSURLSessionDataTask* task, SELogin* login) {
                NSLog(@"Success");
                [SVProgressHUD dismiss];
            } failure:^(NSURLSessionDataTask* task, NSError* error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        };
        UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:interactive];
        [SVProgressHUD dismiss];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)showProviderPicker
{
    NSArray* providers = [[[self.providers valueForKeyPath:@"name"] allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    UINavigationController* providersPicker = [PickerTVC pickerWithItems:providers completionBlock:^(NSString* selectedProvider) {
        [self userSelectedProvider:selectedProvider];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:providersPicker animated:YES completion:nil];
}

- (void)endEditing
{
    [self.view endEditing:YES];
}

- (void)switchToLoginsViewController
{
    [self.tabBarController setSelectedIndex:2];
}

- (void)offsetViewOnYAxisBy:(CGFloat)offset
{
    if (!self.animatingTextFieldOffset) {
        self.animatingTextFieldOffset = YES;
        [UIView animateWithDuration:0.3f animations:^{
            self.view.yOrigin += offset;
        } completion:^(BOOL finished) {
            self.animatingTextFieldOffset = NO;
        }];
    }
}

#pragma mark - NSNotificationCenter callbacks

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    CGPoint finalOrigin = [[aNotification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin;
    keyboardHeight = self.view.frame.size.height - finalOrigin.y;
}

#pragma mark - Getters

- (NSSet*)providers
{
    if (!_providers) {
        _providers = [NSSet set];
    }
    return _providers;
}

- (NSMutableDictionary*)inputControlsMappings
{
    if (!_inputControlsMappings) {
        _inputControlsMappings = @{}.mutableCopy;
    }
    return _inputControlsMappings;
}

- (NSMutableArray*)inputControlsOrder
{
    if (!_inputControlsOrder) {
        _inputControlsOrder = @[].mutableCopy;
    }
    return _inputControlsOrder;
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

#pragma mark - SELoginCreation Delegate

- (void)login:(SELogin *)login requestedInteractiveCallbackWithFieldNames:(NSArray *)names
{
    [self showInteractiveCredentialsEntryForLoginWithId:login.id interactiveFieldsNames:names];
}

- (void)login:(SELogin *)login failedToFetchWithMessage:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)loginSuccessfullyFinishedFetching:(SELogin *)login
{
    [SVProgressHUD dismiss];
    [self switchToLoginsViewController];
}

@end
