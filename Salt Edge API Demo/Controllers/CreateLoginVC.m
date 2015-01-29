//
//  CreateLoginVC.m 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import "CreateLoginVC.h"
#import "SELoginFetchingDelegate.h"
#import "SELogin.h"
#import "AppDelegate.h"
#import "SEAPIRequestManager.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "SEError.h"
#import "SEProvider.h"
#import "PickerTVC.h"
#import "SEProviderField.h"
#import "Helpers.h"
#import "SEProviderFieldOption.h"
#import "Constants.h"
#import "PickerDelegate.h"
#import "OptionSelectButton.h"
#import "UIView+Framing.h"
#import "UIControl+SELoginInputFieldsAdditions.h"
#import "TabBarVC.h"
#import "CredentialsVC.h"
#import "LoginsTVC.h"

@interface CreateLoginVC() <SELoginFetchingDelegate>

@property (nonatomic, strong) SEProvider* provider;
@property (nonatomic, strong) UILabel* instructionsLabel;
@property (nonatomic, strong) NSMutableDictionary* inputControlsMappings;
@property (nonatomic, strong) NSMutableArray* inputControlsOrder;
@property (nonatomic, strong) SELogin* login;

@end

@implementation CreateLoginVC

#pragma mark -
#pragma mark - Public API

- (void)setLogin:(SELogin *)login
{
    _login = login;
    [self fetchProviderFieldsWithProviderCode:login.providerCode];
}

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
    self.title = @"Create";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Providers" style:UIBarButtonItemStylePlain target:self action:@selector(showProviders)];
}

#pragma mark - Helper methods

- (void)fetchProviders
{
    if ([AppDelegate delegate].providers.count == 0) {
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [SVProgressHUD showWithStatus:@"Loading providers..." maskType:SVProgressHUDMaskTypeGradient];
        [manager fetchFullProvidersListWithSuccess:^(NSSet* providers) {
            [AppDelegate delegate].providers = providers;
            [self showProviders];
            [SVProgressHUD dismiss];
        } failure:^(SEError* error) {
            [SVProgressHUD showErrorWithStatus:error.message];
        }];
    }
}

- (void)showProviders
{
    if ([AppDelegate delegate].providers.count == 0) {
        [self fetchProviders];
        return;
    }
    NSArray* providers = [[[[AppDelegate delegate].providers.allObjects filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mode != %@", @"file"]] valueForKeyPath:@"name"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    UINavigationController* picker = [PickerTVC pickerWithItems:providers completionBlock:^(id pickedProviderName) {
        self.provider = [[[AppDelegate delegate].providers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", pickedProviderName]] anyObject];
        [self fetchProviderFieldsWithProviderCode:self.provider.code];
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)fetchProviderFieldsWithProviderCode:(NSString*)code
{
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    [SVProgressHUD showWithStatus:@"Loading provider..."];
    [manager fetchProviderWithCode:code
                           success:^(SEProvider* provider) {
                               self.provider = provider;
                               self.inputControlsMappings = nil;
                               self.inputControlsOrder = nil;
                               [self showInputFields];
                               [SVProgressHUD dismiss];
                           }
                           failure:^(SEError* error) {
                               [SVProgressHUD showErrorWithStatus:error.message];
                           }];
}

- (void)showInputFields
{
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupInputViews];
}

- (void)setupInputViews
{
    [self setupProviderInstructionWithText:self.provider.instruction];
    if (!self.provider.isOAuth) {
        NSArray* sortedRequiredFields = [self.provider.requiredFields sortedArrayUsingComparator:^NSComparisonResult (SEProviderField* first, SEProviderField* second) {
            return [first.position integerValue] > [second.position integerValue];
        }];
        [self setupRequiredFieldsWithArray:sortedRequiredFields];
    }
    [self setupCreateButton];
}

- (void)setupProviderInstructionWithText:(NSString*)instruction
{
    self.instructionsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10.0f, 0.0, 0.0)];
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
    UIButton* createButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString* buttonTitle = self.login ? @"Reconnect login" : @"Create login";
    [createButton setTitle:buttonTitle forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createLoginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [createButton sizeToFit];
    UIView* lastInputControl = [self.inputControlsOrder lastObject];
    createButton.center = CGPointMake(self.view.width / 2, lastInputControl.center.y + createButton.height / 2 + 30.0f);
    [self.view addSubview:createButton];
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

- (void)createLoginButtonPressed
{
    for (id control in self.inputControlsOrder) {
        if (![control se_hasInputData]) {
            [control se_highlight];
            return;
        }
    }
    if (!self.login) {
        [self createLogin];
    } else {
        [self reconnectLogin];
    }
}

#pragma mark - Picker delegate

- (void)presentPickerWithOptions:(NSArray *)options withCompletionBlock:(PickerCompletionBlock)completionBlock
{
    [self presentViewController:[PickerTVC pickerWithItems:options completionBlock:completionBlock] animated:YES completion:nil];
}

#pragma mark - Helper methods

- (NSDictionary*)credentials
{
    NSMutableDictionary* credentialsDictionary = @{}.mutableCopy;
    [self.inputControlsMappings enumerateKeysAndObjectsUsingBlock:^(SEProviderField* field, UIControl* control, BOOL* stop) {
        id controlValue = [control se_inputValue];
        if (controlValue) {
            credentialsDictionary[field.name] = controlValue;
        } else {
            [NSException raise:@"NilValue" format:@"%@ has nil value", control];
        }
    }];
    return [NSDictionary dictionaryWithDictionary:credentialsDictionary];
}

- (void)createLogin
{
    NSMutableDictionary* parameters = @{ kCountryCodeKey : self.provider.countryCode,
                                         kProviderCodeKey : self.provider.code,
                                         kCustomerIdKey : [AppDelegate delegate].customerId,
                                         }.mutableCopy;

    [SVProgressHUD showWithStatus:@"Creating login..." maskType:SVProgressHUDMaskTypeGradient];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];

    if (!self.provider.isOAuth) {
        parameters[kCredentialsKey] = [self credentials];;
        [manager createLoginWithParameters:parameters
                                   success:^(SELogin* login) {
                                       [SVProgressHUD showWithStatus:@"Fetching login..." maskType:SVProgressHUDMaskTypeGradient];
                                   }
                                   failure:^(SEError* error) {
                                       [SVProgressHUD showErrorWithStatus:error.message];
                                   } delegate:self];
    } else {
        parameters[kReturnToKey] = [[AppDelegate delegate] applicationURLString];
        [manager createOAuthLoginWithParameters:parameters
                                        success:^(NSDictionary* responseObject) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:responseObject[kDataKey][kRedirectURLKey]]];
                                        }
                                        failure:^(SEError* error) {
                                            [SVProgressHUD showErrorWithStatus:error.message];
                                        } delegate:self];
    }
}

- (void)reconnectLogin
{
    NSDictionary* credentialsDictionary = [self credentials];

    [SVProgressHUD showWithStatus:@"Reconnecting login..." maskType:SVProgressHUDMaskTypeGradient];
    SEAPIRequestManager* manager = [SEAPIRequestManager manager];
    if (!self.provider.isOAuth) {
        [manager reconnectLoginWithSecret:self.login.secret
                              credentials:credentialsDictionary
                                  success:nil
                                  failure:^(SEError* error) {
                                      [SVProgressHUD showErrorWithStatus:error.message];
                                  } delegate:self];
    } else {
        [manager reconnectOAuthLoginWithSecret:self.login.secret
                                    parameters:@{ kReturnToKey : [AppDelegate delegate].applicationURLString }
                                       success:^(NSDictionary* responseObject) {
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:responseObject[kDataKey][kRedirectURLKey]]];
                                       }
                                       failure:^(SEError* error) {
                                           [SVProgressHUD showErrorWithStatus:error.message];
                                       }];
    }
}

#pragma mark - Lazy getters

- (NSMutableArray*)inputControlsOrder
{
    if (!_inputControlsOrder) {
        _inputControlsOrder = [NSMutableArray array];
    }
    return _inputControlsOrder;
}

- (NSMutableDictionary*)inputControlsMappings
{
    if (!_inputControlsMappings) {
        _inputControlsMappings = [NSMutableDictionary dictionary];
    }
    return _inputControlsMappings;
}

#pragma mark - SELoginCreation Delgeate

- (void)login:(SELogin*)login failedToFetchWithMessage:(NSString *)message
{
    [SVProgressHUD showErrorWithStatus:message];
}

- (void)loginRequestedInteractiveInput:(SELogin*)login
{
    CredentialsVC* credentialsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CredentialsVC"];
    NSPredicate* predicate = [NSPredicate predicateWithBlock:^BOOL(SEProviderField* field, NSDictionary* bindings) {
        return [login.interactiveFieldsNames containsObject:field.name];
    }];
    credentialsVC.credentialFields = [self.provider.interactiveFields filteredArrayUsingPredicate:predicate];
    credentialsVC.interactiveHtml = login.interactiveHtml;
    credentialsVC.completionBlock = ^(NSDictionary* credentials) {
        [SVProgressHUD showWithStatus:@"Sending credentials..." maskType:SVProgressHUDMaskTypeGradient];
        SEAPIRequestManager* manager = [SEAPIRequestManager manager];
        [manager provideInteractiveCredentialsForLoginWithSecret:login.secret
                                                     credentials:credentials
                                                         success:^(SELogin* login) {
                                                             [self dismissViewControllerAnimated:YES completion:^{
                                                                 [SVProgressHUD showWithStatus:@"Fetching login..." maskType:SVProgressHUDMaskTypeGradient];
                                                             }];
                                                         }
                                                         failure:^(SEError* error) {
                                                             [SVProgressHUD showErrorWithStatus:error.message];
                                                         }
                                                        delegate: self];
    };
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:credentialsVC];
    [SVProgressHUD dismiss];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)loginSuccessfullyFinishedFetching:(SELogin *)login
{
    _login = nil;
    NSMutableSet* loginSecrets = [NSSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:kLoginSecretsDefaultsKey]].mutableCopy;
    if (!loginSecrets) {
        loginSecrets = [NSMutableSet set];
    }
    [loginSecrets addObject:login.secret];
    [[NSUserDefaults standardUserDefaults] setObject:[loginSecrets allObjects] forKey:kLoginSecretsDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    LoginsTVC* loginsController = [self.tabBarController.viewControllers[2] viewControllers][0];
    [loginsController reloadLoginsTableViewController];
    [[[AppDelegate delegate] tabBar] setSelectedIndex:2];
    [SVProgressHUD dismiss];
}

- (void)OAuthLoginCannotBeFetched
{
    [SVProgressHUD showErrorWithStatus:@"OAuth login cannot be fetched"];
}

@end

