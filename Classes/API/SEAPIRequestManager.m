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
#import "SERequestHandler.h"
#import "SEError.h"

/* HTTP Headers */

static NSString* const kAppSecretHeaderKey       = @"App-secret";
static NSString* const kClientIdHeaderKey        = @"Client-id";
static NSString* const kLoginSecretHeaderKey     = @"Login-secret";
static NSString* const kContentTypeHeaderKey     = @"Content-type";
static NSString* const kJSONContentTypeValue     = @"application/json";

/* Keys of responses and post bodies */
static NSString* const kFromIdKey                = @"from_id";
static NSString* const kDataKey                  = @"data";
static NSString* const kMetaKey                  = @"meta";
static NSString* const kNextIdKey                = @"next_id";
static NSString* const kNextPageKey              = @"next_page";
static NSString* const kLoginIdKey               = @"login_id";
static NSString* const kRefreshKey               = @"refresh";
static NSString* const kCountryCode              = @"country_code";
static NSString* const kProviderCodeKey          = @"provider_code";
static NSString* const kReturnToKey              = @"return_to";
static NSString* const kCustomerIdKey            = @"customer_id";
static NSString* const kAccountIdKey             = @"account_id";
static NSString* const kMobileKey                = @"mobile";
static NSString* const kIdentifierKey            = @"identifier";

/* HTTP Session config */
static NSDictionary* sessionHeaders;

@interface SEAPIRequestManager(/* Private */)

@property (nonatomic, strong) NSString* baseURL;

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

    SEAPIRequestManager* manager = [[[self class] alloc] initWithBaseURL:kRootURL];
    return manager;
}

+ (void)linkClientId:(NSString *)clientId appSecret:(NSString *)appSecret
{
    NSAssert(sessionHeaders == nil, @"Session headers are already set up.");
    NSAssert(clientId != nil, @"Client ID cannot be nil");
    NSAssert(appSecret != nil, @"App secret cannot be nil");

    sessionHeaders = @{ kClientIdHeaderKey : clientId, kAppSecretHeaderKey : appSecret, kContentTypeHeaderKey : kJSONContentTypeValue };
}

#pragma mark - Instance Methods

- (void)createCustomerWithIdentifier:(NSString *)identifier
                             success:(void (^)(NSDictionary *))success
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
                                     failure:^(NSDictionary* errorDictionary) {
                                         if (!failure) { return; }
                                         SEError* error = [SEError objectFromDictionary:errorDictionary];
                                         failure(error);
                                     }];
}

- (void)fetchProviderWithCode:(NSString *)code
                      success:(void (^)(SEProvider *))success
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
                                    failure:^(NSDictionary* errorDictionary) {
                                        if (!failure) { return; }
                                        SEError* error = [SEError objectFromDictionary:errorDictionary];
                                        failure(error);
                                    }];
}

- (void)fetchFullProvidersListWithSuccess:(void (^)(NSSet *))success
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

- (void)fetchFullAccountsListForLoginSecret:(NSString*)loginSecret
                                success:(void (^)(NSSet *))success
                                failure:(SEAPIRequestFailureBlock)failure
{
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
                                    failure:^(NSDictionary* errorDictionary) {
                                        if (!failure) { return; }
                                        SEError* error = [SEError objectFromDictionary:errorDictionary];
                                        failure(error);
                                    }];
}

- (void)fetchFullTransactionsListForAccountId:(NSNumber *)accountId
                                  loginSecret:(NSString *)loginSecret
                                      success:(void (^)(NSSet *))success
                                      failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(accountId != nil, @"Account id cannot be nil.");

    [self requestPaginatedResourceWithPath:kTransactionsPath
                                 container:@[].mutableCopy
                                   headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                parameters:@{ kAccountIdKey: accountId.description }
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

- (void)fetchLoginWithSecret:(NSString*)loginSecret
                     success:(void(^)(SELogin*))success
                     failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    [SERequestHandler sendGETRequestWithURL:[self baseURLStringByAppendingPathComponent:kLoginPath]
                                 parameters:nil
                                    headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                    success:^(NSDictionary* responseObject) {
                                        if (!success) { return; }
                                        SELogin* fetchedLogin = [SELogin objectFromDictionary:responseObject[kDataKey]];
                                        success(fetchedLogin);
                                    }
                                    failure:^(NSDictionary* errorDictionary) {
                                        if (!failure) { return; }
                                        SEError* error = [SEError objectFromDictionary:errorDictionary];
                                        failure(error);
                                    }];
}

- (void)removeLoginWithSecret:(NSString *)loginSecret
                      success:(void (^)(NSDictionary *))success
                      failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");

    NSString* removeURL = [[self baseURLStringByAppendingPathComponent:kLoginPath] stringByAppendingPathComponent:kLoginRemove];
    [SERequestHandler sendPOSTRequestWithURL:removeURL
                                  parameters:nil
                                     headers:[self sessionHeadersWithLoginSecret:loginSecret]
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorDictionary) {
                                         if (!failure) { return; }
                                         SEError* error = [SEError objectFromDictionary:errorDictionary];
                                         failure(error);
                                     }];
}

- (void)requestCreateTokenWithParameters:(NSDictionary *)parameters
                                 success:(void (^)(NSDictionary *))success
                                 failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(parameters[kCountryCode] != nil, @"Country code cannot be nil.");
    NSAssert(parameters[kProviderCodeKey] != nil, @"Provider code cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");
    NSAssert(parameters[kCustomerIdKey] != nil, @"Customer ID cannot be nil.");

    NSMutableDictionary* mutableParameters = parameters.mutableCopy;
    mutableParameters[kMobileKey] = @YES;
    NSDictionary* dataParameters = @{ kDataKey: mutableParameters };

    [self requestTokenWithPath:kCreateTokenPath
                       headers:sessionHeaders
                    parameters:dataParameters
                       success:success
                       failure:failure];
}

- (void)requestReconnectTokenForLoginSecret:(NSString *)loginSecret
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSDictionary *))success
                                    failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");

    [self requestTokenWithPath:kReconnectTokenPath
                       headers:[self sessionHeadersWithLoginSecret:loginSecret]
                    parameters:parameters
                       success:success
                       failure:failure];
}

- (void)requestRefreshTokenForLoginSecret:(NSString *)loginSecret
                               parameters:(NSDictionary *)parameters
                                  success:(void (^)(NSDictionary *))success
                                  failure:(SEAPIRequestFailureBlock)failure
{
    NSAssert(loginSecret != nil, @"Login secret cannot be nil.");
    NSAssert(parameters[kReturnToKey] != nil, @"Return to cannot be nil.");

    [self requestTokenWithPath:kRefreshTokenPath
                       headers:[self sessionHeadersWithLoginSecret:loginSecret]
                    parameters:parameters
                       success:success
                       failure:failure];
}

#pragma mark -
#pragma mark - Private API

- (instancetype)initWithBaseURL:(NSString*)baseURL
{
    if (self = [super init]) {
        self.baseURL = baseURL;
    }
    return self;
}

- (void)requestTokenWithPath:(NSString*)path
                     headers:(NSDictionary*)headers
                  parameters:(NSDictionary*)parameters
                     success:(void (^)(NSDictionary *))success
                     failure:(SEAPIRequestFailureBlock)failure
{
    [SERequestHandler sendPOSTRequestWithURL:[self baseURLStringByAppendingPathComponent:path]
                                  parameters:parameters
                                     headers:headers
                                     success:^(NSDictionary* responseObject) {
                                         if (success) {
                                             success(responseObject);
                                         }
                                     }
                                     failure:^(NSDictionary* errorDictionary) {
                                         if (!failure) { return; }
                                         SEError* error = [SEError objectFromDictionary:errorDictionary];
                                         failure(error);
                                     }];
}

- (void)requestPaginatedResourceWithPath:(NSString*)path
                               container:(NSMutableArray*)container
                                 headers:(NSDictionary*)headers
                              parameters:(NSDictionary*)parameters
                                 success:(void (^)(NSArray*))success
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
                                    } failure:^(NSDictionary* errorDictionary) {
                                        if (!failure) { return; }
                                        SEError* error = [SEError objectFromDictionary:errorDictionary];
                                        failure(error);
                                    }];
}

#pragma mark - Helper methods

- (NSString*)baseURLStringByAppendingPathComponent:(NSString*)path
{
    return [self.baseURL stringByAppendingPathComponent:path];
}

- (NSDictionary*)sessionHeadersWithLoginSecret:(NSString*)loginSecret
{
    return [[self class] sessionHeadersWithLoginSecret:loginSecret];
}

+ (NSDictionary*)sessionHeadersWithLoginSecret:(NSString*)loginSecret
{
    NSMutableDictionary* mutableSessionHeaders = sessionHeaders.mutableCopy;
    mutableSessionHeaders[kLoginSecretHeaderKey] = loginSecret;
    return [NSDictionary dictionaryWithDictionary:mutableSessionHeaders];
}

@end
