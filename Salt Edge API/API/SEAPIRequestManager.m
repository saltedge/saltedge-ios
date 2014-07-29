//
//  SEAPIRequestManager.m
//
//  Copyright (c) 2014 Salt Edge. https://saltedge.com
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
#import "Constants.h"
#import "SEProvider.h"
#import "SELogin.h"
#import "SEAccount.h"
#import "SETransaction.h"
#import "SELoginCreationDelegate.h"
#import "DateUtils.h"

/* Headers */
static NSString* const kAppIdHeaderKey           = @"App-id";
static NSString* const kAppSecretHeaderKey       = @"App-secret";

/* Keys of responses and post bodies */
static NSString* const kFromIdKey                = @"from_id";
static NSString* const kDataKey                  = @"data";
static NSString* const kMetaKey                  = @"meta";
static NSString* const kCredentialsKey           = @"credentials";
static NSString* const kNextIdKey                = @"next_id";
static NSString* const kNextPageKey              = @"next_page";
static NSString* const kIdKey                    = @"id";
static NSString* const kLoginIdKey               = @"login_id";
static NSString* const kCustomerEmailKey         = @"customer_email";
static NSString* const kAccountIdKey             = @"account_id";
static NSString* const kMobileKey                = @"mobile";
static NSString* const kRefreshedKey             = @"refreshed";
static NSString* const kLastRefreshAtKey         = @"last_refresh_at";
static NSString* const kNextRefreshPossibleAtKey = @"next_refresh_possible_at";
static NSString* const kLoginStatusActive        = @"active";

static CGFloat const kLoginPollDelayTime = 5.0f;

static NSURLSessionConfiguration* sessionConfig;

@implementation SEAPIRequestManager

+ (void)linkAppId:(NSString *)appId appSecret:(NSString *)appSecret
{
    NSAssert(appSecret != nil, @"App secret can't be nil");
    NSAssert(appId != nil, @"App id can't be nil");

    sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{ kAppIdHeaderKey : appId, kAppSecretHeaderKey : appSecret }];
}

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSAssert(sessionConfig != nil, @"Session configuration not set. Did you forget to link your app id and app secret?");
    });

    SEAPIRequestManager* manager = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:kRootURL] sessionConfiguration:sessionConfig];
    manager.securityPolicy.allowInvalidCertificates = YES;
    return manager;
}

- (void)fetchFullProvidersListWithSuccess:(void (^)(NSURLSessionDataTask*, NSSet *))success failure:(SEAPIRequestFailureBlock)failure
{
    [self requestPaginatedResourceWithPath:kProvidersPath container:@[].mutableCopy success:^(NSURLSessionDataTask* task, NSArray* providersDictionaries) {
        if (success) {
            NSMutableSet* fullProvidersList = [NSMutableSet setWithCapacity:providersDictionaries.count];
            for (NSDictionary* providerDictionary in providersDictionaries) {
                [fullProvidersList addObject:[SEProvider objectFromDictionary:providerDictionary]];
            }
            success(task, (NSSet*) fullProvidersList);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    } full:YES];
}

- (void)fetchFullLoginsListWithSuccess:(void (^)(NSURLSessionDataTask *, NSSet *))success failure:(SEAPIRequestFailureBlock)failure
{
    [self requestPaginatedResourceWithPath:kLoginsPath container:@[].mutableCopy success:^(NSURLSessionDataTask* task, NSArray* loginsDictionaries) {
        if (success) {
            NSMutableSet* fullLoginsList = [NSMutableSet setWithCapacity:loginsDictionaries.count];
            for (NSDictionary* loginDictionary in loginsDictionaries) {
                [fullLoginsList addObject:[SELogin objectFromDictionary:loginDictionary]];
            }
            success(task, (NSSet*) fullLoginsList);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    } full:YES];
}

- (void)fetchFullAccountsListForLoginId:(NSNumber *)loginId success:(void (^)(NSURLSessionDataTask *, NSSet *))success failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginId != nil, @"loginId cannot be nil.");

    SEAPIRequestManager* manager = [[self class] manager];

    [manager GET:kAccountsPath parameters:@{ kLoginIdKey : loginId } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) {
            NSArray* accountsDictionaries = responseObject[kDataKey];
            NSMutableSet* accountsObjects = [NSMutableSet setWithCapacity:accountsDictionaries.count];
            for (NSDictionary* accountDictionary in accountsDictionaries) {
                [accountsObjects addObject:[SEAccount objectFromDictionary:accountDictionary]];
            }
            success(task, (NSSet*) accountsObjects);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)fetchFullTransactionsListForAccountId:(NSNumber *)accountId success:(void (^)(NSURLSessionDataTask *, NSSet *))success failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(accountId != nil, @"accountId cannot be nil.");

    NSString* url = [kTransactionsPath stringByAppendingFormat:@"?%@=%@", kAccountIdKey, accountId.description];
    [self requestPaginatedResourceWithPath:url container:@[].mutableCopy success:^(NSURLSessionDataTask* task, NSArray* transactionDictionaries) {
        if (success) {
            NSMutableSet* transactionsObjects = [NSMutableSet setWithCapacity:transactionDictionaries.count];
            for (NSDictionary* transactionDictionary in transactionDictionaries) {
                [transactionsObjects addObject:[SETransaction objectFromDictionary:transactionDictionary]];
            }
            success(task, (NSSet*) transactionsObjects);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    } full:YES];
}

- (void)fetchProviderWithCode:(NSString *)code success:(void (^)(NSURLSessionDataTask *, SEProvider *))success failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(code != nil, @"code cannot be nil.");

    SEAPIRequestManager* manager = [[self class] manager];
    NSString* url = [kProvidersPath stringByAppendingPathComponent:code];

    [manager GET:url parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) {
            NSDictionary* providerDictionary = responseObject[kDataKey];
            if (providerDictionary) {
                SEProvider* provider = [SEProvider objectFromDictionary:providerDictionary];
                success(task, provider);
            }
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)createLoginWithParameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, SELogin *))success failure:(SEAPIRequestFailureBlock)failure delegate:(id<SELoginCreationDelegate>)delegate
{
    SEAPIRequestManager* manager = [[self class] manager];

    [manager POST:kLoginsPath parameters:@{ kDataKey : parameters } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) {
            NSNumber* loginId = responseObject[kDataKey][kIdKey];
            SELogin* login = [SELogin objectFromDictionary:responseObject[kDataKey]];
            if (loginId) {
                [self pollLoginWithId:loginId delegate:delegate];
            }
            success(task, login);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)reconnectLoginWithLoginId:(NSNumber *)loginId credentials:(NSDictionary *)credentials success:(void (^)(NSURLSessionDataTask *, SELogin *))success failure:(SEAPIRequestFailureBlock)failure delegate:(id<SELoginCreationDelegate>)delegate
{
    NSAssert(loginId != nil, @"loginId cannot be nil.");
    NSAssert(credentials != nil, @"credentials cannot be nil.");

    NSString* url = [[kLoginsPath stringByAppendingPathComponent:loginId.description] stringByAppendingPathComponent:kLoginsReconnect];

    SEAPIRequestManager* manager = [[self class] manager];

    [manager POST:url parameters:@{ kDataKey : @{ kCredentialsKey : credentials } } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) {
            NSNumber* loginId = responseObject[kDataKey][kIdKey];
            SELogin* login = [SELogin objectFromDictionary:responseObject[kDataKey]];
            if (loginId) {
                [self pollLoginWithId:loginId delegate:delegate];
            }
            success(task, login);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)refreshLoginWithId:(NSNumber *)loginId success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(SEAPIRequestFailureBlock)failure delegate:(id<SELoginCreationDelegate>)delegate
{
    NSAssert(loginId != nil, @"loginId cannot be nil.");

    NSString* url = [[kLoginsPath stringByAppendingPathComponent:loginId.description] stringByAppendingPathComponent:kLoginsRefresh];

    SEAPIRequestManager* manager = [[self class] manager];

    [manager POST:url parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        if (!success) { return; }
        NSDictionary* responseDataDictionary = responseObject[kDataKey];
        if (responseDataDictionary) {
            if ([responseDataDictionary[kRefreshedKey] boolValue]) {
                [self pollLoginWithId:loginId delegate:delegate];
            }

            NSMutableDictionary* resultingDictionary = responseDataDictionary.mutableCopy;

            resultingDictionary[kLastRefreshAtKey] = [DateUtils dateFromISO8601String:responseDataDictionary[kLastRefreshAtKey]];
            resultingDictionary[kNextRefreshPossibleAtKey] = [DateUtils dateFromISO8601String:responseDataDictionary[kNextRefreshPossibleAtKey]];
            success(task, resultingDictionary);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)postInteractiveCredentials:(NSDictionary *)credentials forLoginId:(NSNumber *)loginId success:(void (^)(NSURLSessionDataTask *, SELogin *))success failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginId != nil, @"loginId cannot be nil.");
    
    SEAPIRequestManager* manager = [[self class] manager];
    NSString* url = [[kLoginsPath stringByAppendingPathComponent:loginId.description] stringByAppendingPathComponent:kLoginsInteractive];

    [manager POST:url parameters:@{ kDataKey : credentials } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) {
            SELogin* login = nil;
            NSDictionary* loginDictionary = responseObject[kDataKey];
            if (loginDictionary) {
                login = [SELogin objectFromDictionary:loginDictionary];
            }
            success(task, login);
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)requestConnectTokenWithParameters:(NSDictionary *)parameters success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(parameters[kCustomerEmailKey] != nil, @"Customer email cannot be nil");

    NSMutableDictionary* mobileParameters = parameters.mutableCopy;
    mobileParameters[kMobileKey] = @YES;

    SEAPIRequestManager* manager = [[self class] manager];

    [manager POST:kTokensPath parameters:@{ kDataKey : mobileParameters } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) { success(task, responseObject[kDataKey]); }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

#pragma mark -
#pragma mark - Private API

- (void)requestPaginatedResourceWithPath:(NSString*)path container:(NSMutableArray*)container success:(void (^)(NSURLSessionDataTask* task, NSArray*))success failure:(SEAPIRequestFailureBlock)failure full:(BOOL)full
{
    SEAPIRequestManager* manager = [[self class] manager];

    [manager GET:path parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        [container addObjectsFromArray:responseObject[kDataKey]];
        NSNumber* nextId = responseObject[kMetaKey][kNextIdKey];
        if (nextId && ![nextId isEqual:[NSNull null]] && full) {
            NSString* nextPage = responseObject[kMetaKey][kNextPageKey];
            [self requestPaginatedResourceWithPath:nextPage container:container success:success failure:failure full:full];
        } else {
            if (success) {
                success(task, (NSArray*) container);
            }
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)pollLoginWithId:(NSNumber*)loginId delegate:(id<SELoginCreationDelegate>)delegate
{
    static BOOL notifiedDelegateAboutInteractive;
    notifiedDelegateAboutInteractive = notifiedDelegateAboutInteractive ?: NO;

    SEAPIRequestManager* manager = [[self class] manager];
    NSString* url = [kLoginsPath stringByAppendingPathComponent:loginId.description];

    [manager GET:url parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        SELogin* refetchedLogin = [SELogin objectFromDictionary:responseObject[kDataKey]];
        if (!refetchedLogin.id) { return; }

        if ([refetchedLogin.stage isEqualToString:kLoginsInteractive] && !notifiedDelegateAboutInteractive) {
            if ([delegate respondsToSelector:@selector(login:requestedInteractiveCallbackWithFieldNames:)]) {
                [delegate login:refetchedLogin requestedInteractiveCallbackWithFieldNames:refetchedLogin.interactiveFieldsNames];
                notifiedDelegateAboutInteractive = YES;
            }
        }

        if ([refetchedLogin.finished boolValue]) {
            if ([refetchedLogin.status isEqualToString:kLoginStatusActive]) {
                if ([delegate respondsToSelector:@selector(loginSuccessfullyFinishedFetching:)]) {
                    [delegate loginSuccessfullyFinishedFetching:refetchedLogin];
                }
            } else if (refetchedLogin.lastFailMessage.length) {
                if ([delegate respondsToSelector:@selector(login:failedToFetchWithMessage:)]) {
                    [delegate login:refetchedLogin failedToFetchWithMessage:refetchedLogin.lastFailMessage];
                }
            }
            notifiedDelegateAboutInteractive = NO;
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kLoginPollDelayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self pollLoginWithId:loginId delegate:delegate];
            });
        }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
#warning rethink this
        // ?
    }];
}

@end
