//
//  SEAPIRequestManager.m
//
//  Copyright (c) 2016 Salt Edge. https://saltedge.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SEAPIRequestManager.h"
#import "SEAPIRequestManager_private.h"
#import "Constants.h"
#import "SEProvider.h"
#import "SELogin.h"
#import "SEAccount.h"
#import "SETransaction.h"
#import "DateUtils.h"
#import "SERequestHandler.h"
#import "SEError.h"
#import "SELoginFetchingDelegate.h"
#import "SELoginAttempt.h"

/* HTTP Headers */
static NSString* const kAppSecretHeaderKey        = @"App-secret";
static NSString* const kClientIdHeaderKey         = @"Client-id";
static NSString* const kCustomerSecretHeaderKey   = @"Customer-secret";
static NSString* const kLoginSecretHeaderKey      = @"Login-secret";
static NSString* const kContentTypeHeaderKey      = @"Content-type";
static NSString* const kJSONContentTypeValue      = @"application/json";

/* HTTP Session config */
static NSDictionary* sessionHeaders;
static SEAPIRequestManagerSSLPinningMode sslPinningMode;

/* Login polling */
static CGFloat const kLoginPollDelayTime = 5.0f;

/* Other */
static NSString* const kJavascriptCallbackTypeKey = @"javascript_callback_type";
static NSString* const kiFrameCallbackType        = @"iframe";

@interface SEAPIRequestManager(/* Private */)

@property (nonatomic, strong) NSString* baseURL;
@property (nonatomic, strong) SELogin* createdLogin;

@end

@implementation SEAPIRequestManager

#pragma mark -
#pragma mark - Public API
#pragma mark - Class Methods

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSAssert(sessionHeaders != nil, @"Session configuration not set. Did you forget to link your client ID and app secret?");
    });

    SEAPIRequestManager* manager = [[[self class] alloc] init];
    return manager;
}

+ (void)setSSLPinningMode:(SEAPIRequestManagerSSLPinningMode)mode
{
    sslPinningMode = mode;
}

+ (BOOL)SSLPinningEnabled
{
    return sslPinningMode == SEAPIRequestManagerSSLPinningModeEnabled;
}

+ (void)linkClientId:(NSString *)clientId appSecret:(NSString *)appSecret
{
    NSAssert(sessionHeaders == nil, @"Session headers are already set up.");
    NSAssert(clientId != nil, @"Client ID cannot be nil");
    NSAssert(appSecret != nil, @"App secret cannot be nil");

    NSDictionary* appHeadersDictionary = @{ kClientIdHeaderKey : clientId, kAppSecretHeaderKey : appSecret, kContentTypeHeaderKey : kJSONContentTypeValue };
    sessionHeaders = [self sessionHeadersMergedWithDictionary:appHeadersDictionary];
}

+ (void)linkCustomerSecret:(NSString *)customerSecret
{
    NSAssert(customerSecret != nil, @"Customer Secret cannot be nil");

    sessionHeaders = [self sessionHeadersMergedWithDictionary:@{ kCustomerSecretHeaderKey : customerSecret }];
}

#pragma mark - Instance Methods

- (void)createCustomerWithIdentifier:(NSString*)identifier
                             success:(void (^)(NSDictionary* responseObject))success
                             failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(identifier != nil, @"Customer identifier cannot be nil.");

    NSDictionary* parameters = @{ kDataKey: @{ kIdentifierKey: identifier  } };

    [SERequestHandler sendPOSTRequestWithURL:[self baseURLStringByAppendingPathComponent:kCustomersPath]
                                  parameters:parameters
                                     headers:sessionHeaders
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)createLoginWithParameters:(NSDictionary*)parameters
                          success:(void (^)(SELogin* login))success
                          failure:(SEAPIRequestFailureBlock)failure
                         delegate:(id<SELoginFetchingDelegate>)delegate
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(parameters[kCountryCodeKey] != nil, @"Country code cannot be nil.");
    NSAssert(parameters[kProviderCodeKey] != nil, @"Provider code cannot be nil.");
    NSAssert(parameters[kCredentialsKey] != nil, @"Credentials cannot be nil.");

    [SERequestHandler sendPOSTRequestWithURL:[self baseURLStringByAppendingPathComponent:kLoginPath]
                                  parameters:@{ kDataKey : parameters }
                                     headers:sessionHeaders
                                     success:^(NSDictionary* responseDictionary) {
                                         SELogin* createdLogin = [SELogin objectFromDictionary:responseDictionary[kDataKey]];
                                         self.loginFetchingDelegate = delegate;
                                         self.createdLogin = createdLogin;
                                         if (success) {
                                             success(createdLogin);
                                         }
                                         if ([self isLoginFetchingDelegateSuitableForDelegation]) {
                                             [self notifyDelegateWithStartingFetchOfLogin:createdLogin];
                                             [self pollLoginWithSecret:createdLogin.secret];
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)createOAuthLoginWithParameters:(NSDictionary*)parameters
                               success:(void (^)(NSDictionary* responseObject))success
                               failure:(SEAPIRequestFailureBlock)failure
                              delegate:(id<SELoginFetchingDelegate>)delegate
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(parameters[kCountryCodeKey] != nil, @"Country code cannot be nil.");
    NSAssert(parameters[kProviderCodeKey] != nil, @"Provider code cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to URL cannot be nil.");

    NSString* OAuthCreatePath = [[self baseURLStringByAppendingPathComponent:kOAuthProvidersPath] stringByAppendingPathComponent:kLoginActionCreate];

    [SERequestHandler sendPOSTRequestWithURL:OAuthCreatePath
                                  parameters:@{ kDataKey : parameters }
                                     headers:sessionHeaders
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)fetchProviderWithCode:(NSString*)code
                      success:(void (^)(SEProvider* provider))success
                      failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(code != nil, @"Provider code cannot be nil.");

    NSString* providerPath = [[self baseURLStringByAppendingPathComponent:kProvidersPath] stringByAppendingPathComponent:code];

    [SERequestHandler sendGETRequestWithURL:providerPath
                                 parameters:nil
                                    headers:sessionHeaders
                                    success:^(NSDictionary* responseObject) {
                                        if (!success) { return; }
                                        NSDictionary* providerDictionary = responseObject[kDataKey];
                                        if (providerDictionary) {
                                            SEProvider* provider = [SEProvider objectFromDictionary:providerDictionary];
                                            success(provider);
                                        }
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)fetchFullProvidersListWithSuccess:(void (^)(NSSet* providers))success
                                  failure:(SEAPIRequestFailureBlock)failure
{
    [self requestPaginatedResourceWithPath:kProvidersPath
                                 container:@[].mutableCopy
                                   headers:sessionHeaders
                                parameters:nil
                                   success:^(NSArray* providersDictionaries) {
                                       if (!success) { return; }
                                       NSMutableSet* fullProvidersList = [NSMutableSet setWithCapacity:providersDictionaries.count];
                                       for (NSDictionary* providerDictionary in providersDictionaries) {
                                            [fullProvidersList addObject:[SEProvider objectFromDictionary:providerDictionary]];
                                        }
                                       success((NSSet*) fullProvidersList);
                                   }
                                   failure:^(SEError* error) {
                                       if (!failure) { return; }
                                       failure(error);
                                   } full:YES];
}

- (void)fetchProvidersListWithParameters:(NSDictionary *)parameters
                                 success:(void (^)(NSSet* providers))success
                                 failure:(SEAPIRequestFailureBlock)failure
{
    [self requestPaginatedResourceWithPath:kProvidersPath
                                 container:@[].mutableCopy
                                   headers:sessionHeaders
                                parameters:parameters
                                   success:^(NSArray* providerDictionaries) {
                                       if (!success) { return; }
                                       NSMutableSet* providerObjects = [NSMutableSet setWithCapacity:providerDictionaries.count];
                                       for (NSDictionary* providerDictionary in providerDictionaries) {
                                           [providerObjects addObject:[SEProvider objectFromDictionary:providerDictionary]];
                                       }
                                       success((NSSet*) providerObjects);
                                   }
                                   failure:^(SEError* error) {
                                       if (!failure) { return; }
                                       failure(error);
                                   } full:YES];
}

- (void)fetchFullAccountsListForLoginSecret:(NSString*)loginSecret
                                success:(void (^)(NSSet* accounts))success
                                failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    [SERequestHandler sendGETRequestWithURL:[self baseURLStringByAppendingPathComponent:kAccountsPath]
                                 parameters:nil
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        if (!success) { return; }
                                        NSArray* accountDictionaries = responseObject[kDataKey];
                                        NSMutableSet* accountsObjects = [NSMutableSet setWithCapacity:accountDictionaries.count];
                                        for (NSDictionary* accountDictionary in accountDictionaries) {
                                            [accountsObjects addObject:[SEAccount objectFromDictionary:accountDictionary]];
                                        }
                                        success((NSSet*) accountsObjects);
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)fetchFullTransactionsListForAccountId:(NSNumber*)accountId
                                  loginSecret:(NSString*)loginSecret
                                      success:(void (^)(NSSet* transactions))success
                                      failure:(SEAPIRequestFailureBlock)failure
{
    [self fetchTransactionsListForAccountId:accountId
                                loginSecret:loginSecret
                                 parameters:nil
                                    success:success
                                    failure:failure];
}

- (void)fetchTransactionsListForAccountId:(NSNumber*)accountId
                              loginSecret:(NSString*)loginSecret
                               parameters:(NSDictionary*)parameters
                                  success:(void (^)(NSSet* transactions))success
                                  failure:(SEAPIRequestFailureBlock)failure
{
    [self requestTransactionsListWithPath:kTransactionsPath
                                accountId:accountId
                              loginSecret:loginSecret
                               parameters:parameters
                                  success:success
                                  failure:failure];
}

- (void)fetchFullPendingTransactionsListForAccountId:(NSNumber*)accountId
                                         loginSecret:(NSString*)loginSecret
                                             success:(void (^)(NSSet* pendingTransactions))success
                                             failure:(SEAPIRequestFailureBlock)failure
{
    [self fetchPendingTransactionsListForAccountId:accountId
                                       loginSecret:loginSecret
                                        parameters:nil
                                           success:success
                                           failure:failure];
}

- (void)fetchPendingTransactionsListForAccountId:(NSNumber*)accountId
                                     loginSecret:(NSString*)loginSecret
                                      parameters:(NSDictionary*)parameters
                                         success:(void (^)(NSSet* pendingTransactions))success
                                         failure:(SEAPIRequestFailureBlock)failure
{
    NSString* pendingTransactionsPath = [kTransactionsPath stringByAppendingPathComponent:kPendingTransactions];

    [self requestTransactionsListWithPath:pendingTransactionsPath
                                accountId:accountId
                              loginSecret:loginSecret
                               parameters:parameters
                                  success:success
                                  failure:failure];
}

- (void)fetchLoginWithSecret:(NSString*)loginSecret
                     success:(void (^)(SELogin* login))success
                     failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    [SERequestHandler sendGETRequestWithURL:[self baseURLStringByAppendingPathComponent:kLoginPath]
                                 parameters:nil
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        if (!success) { return; }
                                        SELogin* fetchedLogin = [SELogin objectFromDictionary:responseObject[kDataKey]];
                                        success(fetchedLogin);
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)fetchAttemptWithId:(NSNumber *)attemptId
        forLoginWithSecret:(NSString *)loginSecret
                   success:(void (^)(SELoginAttempt*))success
                   failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(attemptId != nil, @"Attempt id cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    NSString* attemptPath = [[self baseURLStringByAppendingPathComponent:kAttemptsPath] stringByAppendingPathComponent:attemptId.description];
    [SERequestHandler sendGETRequestWithURL:attemptPath
                                 parameters:nil
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        success([SELoginAttempt objectFromDictionary:responseObject[kDataKey]]);
                                    }
                                    failure:^(NSDictionary* error) {
                                        [self failureBlockWithBlock:failure errorObject:error];
                                    }];
}

- (void)fetchAttemptsForLoginWithSecret:(NSString *)loginSecret
                                success:(void (^)(NSArray *))success
                                failure:(SEAPIRequestFailureBlock)failure
{
    [self requestPaginatedResourceWithPath:kAttemptsPath
                                 container:@[].mutableCopy
                                   headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                parameters:nil
                                   success:^(NSArray* attemptsArray) {
                                       NSMutableArray* serializedAttempts = [NSMutableArray arrayWithCapacity:attemptsArray.count];
                                       for (NSDictionary* attemptDictionary in attemptsArray) {
                                           [serializedAttempts addObject:[SELoginAttempt objectFromDictionary:attemptDictionary]];
                                       }
                                       success([NSArray arrayWithArray:serializedAttempts]);
                                   }
                                   failure:failure
                                      full:YES];
}

- (void)provideInteractiveCredentialsForLoginWithSecret:(NSString*)loginSecret
                                            credentials:(NSDictionary*)credentials
                                                success:(void (^)(SELogin* login))success
                                                failure:(SEAPIRequestFailureBlock)failure
                                               delegate:(id<SELoginFetchingDelegate>)delegate
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(credentials != nil, @"Credentials cannot be nil.");

    NSString* interactivePath = [[self baseURLStringByAppendingPathComponent:kLoginPath] stringByAppendingPathComponent:kLoginInteractive];

    [SERequestHandler sendPUTRequestWithURL:interactivePath
                                 parameters:@{ kDataKey : @{ kCredentialsKey : credentials } }
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        SELogin* fetchedLogin = [SELogin objectFromDictionary:responseObject[kDataKey]];
                                        if (success) {
                                            success(fetchedLogin);
                                        }
                                        self.loginFetchingDelegate = delegate;
                                        if ([self isLoginFetchingDelegateSuitableForDelegation]) {
                                            [self pollLoginWithSecret:fetchedLogin.secret];
                                        }
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)reconnectLoginWithSecret:(NSString*)loginSecret
                     credentials:(NSDictionary*)credentials
                         success:(void (^)(SELogin* login))success
                         failure:(SEAPIRequestFailureBlock)failure
                        delegate:(id<SELoginFetchingDelegate>)delegate
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(credentials != nil, @"Credentials cannot be nil.");

    NSString* reconnectPath = [[self baseURLStringByAppendingPathComponent:kLoginPath] stringByAppendingPathComponent:kLoginActionReconnect];

    [SERequestHandler sendPUTRequestWithURL:reconnectPath
                                 parameters:@{ kDataKey : @{ kCredentialsKey : credentials } }
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        SELogin* reconnectedLogin = [SELogin objectFromDictionary:responseObject[kDataKey]];
                                        if (success) {
                                            success(reconnectedLogin);
                                        }
                                        self.loginFetchingDelegate = delegate;
                                        if ([self isLoginFetchingDelegateSuitableForDelegation]) {
                                            [self notifyDelegateWithStartingFetchOfLogin:reconnectedLogin];
                                            [self pollLoginWithSecret:reconnectedLogin.secret];
                                        }
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)reconnectOAuthLoginWithSecret:(NSString*)loginSecret
                           parameters:(NSDictionary*)parameters
                              success:(void (^)(NSDictionary* responseObject))success
                              failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to URL cannot be nil.");

    NSString* reconnectPath = [[self baseURLStringByAppendingPathComponent:kOAuthProvidersPath] stringByAppendingPathComponent:kLoginActionReconnect];

    [SERequestHandler sendPOSTRequestWithURL:reconnectPath
                                  parameters:@{ kDataKey : parameters }
                                     headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)refreshLoginWithSecret:(NSString*)loginSecret
                       success:(void (^)(NSDictionary* responseObject))success
                       failure:(SEAPIRequestFailureBlock)failure
                      delegate:(id<SELoginFetchingDelegate>)delegate
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    NSString* refreshPath = [[self baseURLStringByAppendingPathComponent:kLoginPath] stringByAppendingPathComponent:kLoginActionRefresh];

    [SERequestHandler sendPUTRequestWithURL:refreshPath
                                 parameters:nil
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        if (success) {
                                            success(responseObject);
                                        }
                                        if (![responseObject[kDataKey][kRefreshedKey] boolValue]) { return; }
                                        self.loginFetchingDelegate = delegate;
                                        if ([self isLoginFetchingDelegateSuitableForDelegation]) {
                                            [self pollLoginWithSecret:loginSecret];
                                        }
                                    }
                                    failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)refreshOAuthLoginWithSecret:(NSString*)loginSecret
                         parameters:(NSDictionary*)parameters
                            success:(void (^)(NSDictionary* responseObject))success
                            failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to URL cannot be nil.");

    NSString* refreshPath = [[self baseURLStringByAppendingPathComponent:kOAuthProvidersPath] stringByAppendingPathComponent:kLoginActionRefresh];

    [SERequestHandler sendPOSTRequestWithURL:refreshPath
                                  parameters:@{ kDataKey : parameters }
                                     headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)removeLoginWithSecret:(NSString*)loginSecret
                      success:(void (^)(NSDictionary* responseObject))success
                      failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    [SERequestHandler sendDELETERequestWithURL:[self baseURLStringByAppendingPathComponent:kLoginPath]
                                    parameters:nil
                                       headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                       success:^(NSDictionary* responseObject) {
                                           if (success) {
                                               success(responseObject);
                                           }
                                       }
                                       failure:^(NSDictionary* errorObject) {
                                           [self failureBlockWithBlock:failure errorObject:errorObject];
                                       }];
}

- (void)requestCreateTokenWithParameters:(NSDictionary*)parameters
                                 success:(void (^)(NSDictionary* responseObject))success
                                 failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(parameters[kCountryCodeKey] != nil, @"Country code cannot be nil.");
    NSAssert(parameters[kProviderCodeKey] != nil, @"Provider code cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");

    [self requestTokenWithAction:kLoginActionCreate
                       headers:sessionHeaders
                    parameters:parameters
                       success:success
                       failure:failure];
}

- (void)requestReconnectTokenForLoginSecret:(NSString*)loginSecret
                                 parameters:(NSDictionary*)parameters
                                    success:(void (^)(NSDictionary* responseObject))success
                                    failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");

    [self requestTokenWithAction:kLoginActionReconnect
                       headers:[self sessionHeadersWithLoginSecret:loginSecret]
                    parameters:parameters
                       success:success
                       failure:failure];
}

- (void)requestRefreshTokenForLoginSecret:(NSString*)loginSecret
                               parameters:(NSDictionary*)parameters
                                  success:(void (^)(NSDictionary* responseObject))success
                                  failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");

    [self requestTokenWithAction:kLoginActionReconnect
                       headers:[self sessionHeadersWithLoginSecret:loginSecret]
                    parameters:parameters
                       success:success
                       failure:failure];
}

#pragma mark -
#pragma mark - Private API

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sslPinningMode = SEAPIRequestManagerSSLPinningModeEnabled;
    });
}

- (instancetype)init
{
    if (self = [super init]) {
        _baseURL = kRootURL;
    }
    return self;
}

- (void)requestTokenWithAction:(NSString*)path
                     headers:(NSDictionary*)headers
                  parameters:(NSDictionary*)parameters
                     success:(void (^)(NSDictionary* responseObject))success
                     failure:(SEAPIRequestFailureBlock)failure
{

    NSMutableDictionary* mutableParams = parameters.mutableCopy;
    mutableParams[kJavascriptCallbackTypeKey] = kiFrameCallbackType;
    NSDictionary* dataParameters = @{ kDataKey: mutableParams };

    NSString* tokenPath = [[self baseURLStringByAppendingPathComponent:kTokensPath] stringByAppendingPathComponent:path];

    [SERequestHandler sendPOSTRequestWithURL:tokenPath
                                  parameters:dataParameters
                                     headers:headers
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

- (void)requestPaginatedResourceWithPath:(NSString*)path
                               container:(NSMutableArray*)container
                                 headers:(NSDictionary*)headers
                              parameters:(NSDictionary*)parameters
                                 success:(void (^)(NSArray* resources))success
                                 failure:(SEAPIRequestFailureBlock)failure
                                    full:(BOOL)full
{
    [SERequestHandler sendGETRequestWithURL:[self baseURLStringByAppendingPathComponent:path]
                                 parameters:parameters
                                    headers:headers
                                    success:^(NSDictionary* responseObject) {
                                        if (!success) { return; }
                                        [container addObjectsFromArray:responseObject[kDataKey]];
                                        NSNumber* nextId = responseObject[kMetaKey][kNextIdKey];
                                        if (nextId && ![nextId isEqual:[NSNull null]] && full) {
                                            NSString* nextPage = responseObject[kMetaKey][kNextPageKey];
                                            [self requestPaginatedResourceWithPath:nextPage container:container headers:headers parameters:nil success:success failure:failure full:full];
                                        } else {
                                            success((NSArray*) container);
                                        }
                                    } failure:^(NSDictionary* errorObject) {
                                        [self failureBlockWithBlock:failure errorObject:errorObject];
                                    }];
}

- (void)requestTransactionsListWithPath:(NSString*)transactionsPath
                              accountId:(NSNumber*)accountId
                            loginSecret:(NSString*)loginSecret
                             parameters:(NSDictionary*)parameters
                                success:(void (^)(NSSet* transactions))success
                                failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(accountId != nil, @"Account id cannot be nil.");
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    NSMutableDictionary* finalParameters = parameters ? parameters.mutableCopy : [NSMutableDictionary dictionary];
    finalParameters[kAccountIdKey] = accountId;

    if (finalParameters[kFromMadeOnKey]) {
        finalParameters[kFromMadeOnKey] = [DateUtils YMDStringFromDate:finalParameters[kFromMadeOnKey]];
    }

    if (finalParameters[kToMadeOnKey]) {
        finalParameters[kToMadeOnKey] = [DateUtils YMDStringFromDate:finalParameters[kToMadeOnKey]];
    }

    [self requestPaginatedResourceWithPath:transactionsPath
                                 container:@[].mutableCopy
                                   headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                parameters:[NSDictionary dictionaryWithDictionary:finalParameters]
                                   success:^(NSArray* transactionDictionaries) {
                                       if (!success) { return; }
                                       NSMutableSet* transactionsObjects = [NSMutableSet setWithCapacity:transactionDictionaries.count];
                                       for (NSDictionary* transactionDictionary in transactionDictionaries) {
                                           [transactionsObjects addObject:[SETransaction objectFromDictionary:transactionDictionary]];
                                       }
                                       success((NSSet*) transactionsObjects);
                                   }
                                   failure:^(SEError* error) {
                                       if (failure) { failure(error); }
                                   } full:YES];
}

- (void)pollLoginWithSecret:(NSString*)loginSecret
{
    typedef void (^PollLoginBlock)();
    PollLoginBlock pollBlock = ^() {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLoginPollDelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pollLoginWithSecret:loginSecret];
        });
    };

    [self fetchLoginWithSecret:loginSecret
                       success:^(SELogin* fetchedLogin) {
                           if ([[fetchedLogin stage] isEqualToString:kLoginStageInteractive]) {
                               [self.loginFetchingDelegate loginRequestedInteractiveInput:fetchedLogin];
                           } else if ([[fetchedLogin stage] isEqualToString:kLoginStageFinish]) {
                               if (![fetchedLogin lastFailMessage] || [[fetchedLogin lastFailMessage] isEqualToString:@""]) {
                                   [self.loginFetchingDelegate loginSuccessfullyFinishedFetching:fetchedLogin];
                               } else {
                                   [self.loginFetchingDelegate login:fetchedLogin failedToFetchWithMessage:fetchedLogin.lastFailMessage];
                               }
                           } else {
                               pollBlock();
                           }
                       }
                       failure:^(SEError* failure) {
                           [self.loginFetchingDelegate login:self.createdLogin failedToFetchWithMessage:failure.errorMessage];
                           self.createdLogin = nil;
                       }];
}

- (void)learnTransactionCategoriesForLoginSecret:(NSString*)loginSecret
                                    transactions:(NSArray*)learningArray
                                         success:(void (^)(NSDictionary* responseObject))success
                                         failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(sessionHeaders[kCustomerSecretHeaderKey] != nil, @"Customer Secret cannot be nil.");
    NSAssert(learningArray != nil, @"learningArray cannot be nil.");

    [SERequestHandler sendPOSTRequestWithURL:[self baseURLStringByAppendingPathComponent:kLearnPath]
                                  parameters:@{ kDataKey: learningArray }
                                     headers:sessionHeaders
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorObject) {
                                         [self failureBlockWithBlock:failure errorObject:errorObject];
                                     }];
}

#pragma mark - Helper methods

- (BOOL)isLoginFetchingDelegateSuitableForDelegation
{
    return [self.loginFetchingDelegate conformsToProtocol:@protocol(SELoginFetchingDelegate)];
}

- (NSString*)baseURLStringByAppendingPathComponent:(NSString*)path
{
    return [self.baseURL stringByAppendingPathComponent:path];
}

- (NSDictionary*)sessionHeadersWithLoginSecret:(NSString*)loginSecret
{
    return [[self class] sessionHeadersWithLoginSecret:loginSecret];
}

- (void)failureBlockWithBlock:(SEAPIRequestFailureBlock)failureBlock errorObject:(NSDictionary*)errorObject
{
    if (!failureBlock) { return; }
    SEError* error = [SEError objectFromDictionary:errorObject];
    failureBlock(error);
}

+ (NSDictionary*)sessionHeadersWithLoginSecret:(NSString*)loginSecret
{
    return [self sessionHeadersMergedWithDictionary:@{ kLoginSecretHeaderKey : loginSecret }];
}

+ (NSDictionary*)sessionHeadersMergedWithDictionary:(NSDictionary*)dictionary
{
    if (!sessionHeaders) {
        sessionHeaders = [NSDictionary dictionary];
    }

    NSMutableDictionary* mutableSessionHeaders = sessionHeaders.mutableCopy;
    [mutableSessionHeaders addEntriesFromDictionary:dictionary];
    return [NSDictionary dictionaryWithDictionary:mutableSessionHeaders];
}

- (void)notifyDelegateWithStartingFetchOfLogin:(SELogin*)login
{
    if ([self.loginFetchingDelegate respondsToSelector:@selector(loginStartedFetching:)]) {
        [self.loginFetchingDelegate loginStartedFetching:login];
    }
}

@end
