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
#import "DateUtils.h"

/* HTTP Headers */
static NSString* const kAppIdHeaderKey           = @"App-id";
static NSString* const kAppSecretHeaderKey       = @"App-secret";
static NSString* const kCustomerSecretHeaderKey  = @"Customer-secret";

/* Keys of responses and post bodies */
static NSString* const kFromIdKey                = @"from_id";
static NSString* const kDataKey                  = @"data";
static NSString* const kMetaKey                  = @"meta";
static NSString* const kNextIdKey                = @"next_id";
static NSString* const kNextPageKey              = @"next_page";
static NSString* const kLoginIdKey               = @"login_id";
static NSString* const kRefreshKey               = @"refresh";
static NSString* const kCustomerEmailKey         = @"customer_email";
static NSString* const kAccountIdKey             = @"account_id";
static NSString* const kMobileKey                = @"mobile";

/* HTTP Session config */
static NSURLSessionConfiguration* sessionConfiguration;

@implementation SEAPIRequestManager

#pragma mark -
#pragma mark - Public API
#pragma mark - Class Methods

+ (instancetype)manager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSAssert(sessionConfiguration != nil, @"Session configuration not set. Did you forget to link your app id and app/customer secret?");
    });

    SEAPIRequestManager* manager = [[[self class] alloc] initWithBaseURL:[NSURL URLWithString:kRootURL] sessionConfiguration:sessionConfiguration];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:0];
    return manager;
}

+ (void)linkAppId:(NSString *)appId appSecret:(NSString *)appSecret
{
    NSAssert(sessionConfiguration == nil, @"Session configuration is already set up.");
    NSAssert(appId != nil, @"App id can't be nil");
    NSAssert(appSecret != nil, @"App secret can't be nil");

    sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ kAppIdHeaderKey : appId, kAppSecretHeaderKey : appSecret }];
}

+ (void)linkAppId:(NSString *)appId customerSecret:(NSString *)customerSecret
{
    NSAssert(sessionConfiguration == nil, @"Session configuration is already set up.");
    NSAssert(appId != nil, @"App id can't be nil");
    NSAssert(customerSecret != nil, @"Customer secret can't be nil");

    sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ kAppIdHeaderKey : appId, kCustomerSecretHeaderKey : customerSecret }];
}

#pragma mark - Instance Methods

- (void)fetchFullLoginsListWithSuccess:(void (^)(NSURLSessionDataTask *, NSSet *))success
                               failure:(SEAPIRequestFailureBlock)failure
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

- (void)fetchFullAccountsListForLoginId:(NSNumber *)loginId
                                success:(void (^)(NSURLSessionDataTask *, NSSet *))success
                                failure:(SEAPIRequestFailureBlock)failure
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

- (void)fetchFullTransactionsListForAccountId:(NSNumber *)accountId
                                      success:(void (^)(NSURLSessionDataTask *, NSSet *))success
                                      failure:(SEAPIRequestFailureBlock)failure
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

- (void)fetchProviderWithCode:(NSString *)code
                      success:(void (^)(NSURLSessionDataTask *, SEProvider *))success
                      failure:(SEAPIRequestFailureBlock)failure
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

- (void)removeLoginWithId:(NSNumber *)loginId
                  success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success
                  failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginId != nil, @"loginId cannot be nil.");

    NSString* url = [[kLoginsPath stringByAppendingPathComponent:loginId.description] stringByAppendingPathComponent:kLoginsRemove];

    SEAPIRequestManager* manager = [[self class] manager];

    [manager POST:url parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) { success(task, responseObject); }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)requestConnectTokenWithParameters:(NSDictionary *)parameters
                                  success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success
                                  failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(parameters[kCustomerEmailKey] != nil, @"Customer email cannot be nil");

    [self requestTokenWithParameters:parameters success:success failure:failure];
}

- (void)requestReconnectTokenForLogin:(SELogin *)login
                           parameters:(NSDictionary*)parameters
                              success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success
                              failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(login != nil, @"Login cannot be nil");
    NSAssert(parameters[kCustomerEmailKey] != nil, @"Customer email cannot be nil");

    NSMutableDictionary* mutableParameters = parameters.mutableCopy;
    mutableParameters[kLoginIdKey] = login.id;

    [self requestTokenWithParameters:mutableParameters success:success failure:failure];
}

- (void)requestRefreshTokenForLogin:(SELogin *)login
                         parameters:(NSDictionary*)parameters
                            success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success
                            failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(login != nil, @"Login cannot be nil");
    NSAssert(parameters[kCustomerEmailKey] != nil, @"Customer email cannot be nil");

    NSMutableDictionary* mutableParameters = parameters.mutableCopy;
    mutableParameters[kLoginIdKey] = login.id;
    mutableParameters[kRefreshKey] = [NSNumber numberWithBool:true];

    [self requestTokenWithParameters:mutableParameters success:success failure:failure];
}

#pragma mark -
#pragma mark - Private API

- (void)requestTokenWithParameters:(NSDictionary*)parameters
                           success:(void (^)(NSURLSessionDataTask *, NSDictionary *))success
                           failure:(SEAPIRequestFailureBlock)failure
{
    SEAPIRequestManager* manager = [[self class] manager];

    NSMutableDictionary* mobileParameters = parameters.mutableCopy;
    mobileParameters[kMobileKey]  = [NSNumber numberWithBool:true];

    [manager POST:kTokensPath parameters:@{ kDataKey : mobileParameters } success:^(NSURLSessionDataTask* task, id responseObject) {
        if (success) { success(task, responseObject[kDataKey]); }
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        if (failure) { failure(task, error); }
    }];
}

- (void)requestPaginatedResourceWithPath:(NSString*)path
                               container:(NSMutableArray*)container
                                 success:(void (^)(NSURLSessionDataTask* task, NSArray*))success
                                 failure:(SEAPIRequestFailureBlock)failure full:(BOOL)full
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

@end
