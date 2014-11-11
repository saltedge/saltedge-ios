//
//  SEAPIRequestManager.h
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

#import <Foundation/Foundation.h>

@class SEProvider, SELogin, SEError;

@protocol SELoginFetchingDelegate;

typedef void (^SEAPIRequestFailureBlock)(SEError* error);

/**
 SEAPIRequestManager is a class designed to provide convinient methods in communicating with the Salt Edge API.
 */
@interface SEAPIRequestManager : NSObject

/**
 Creates and returns an SEAPIRequestManager instance, which can communicate with the Salt Edge API.
 */
+ (instancetype)manager;

/**
 Links your Client ID and App Secret to the request manager. All outgoing requests will have the proper app-related HTTP headers set by default.

 @param clientId The ID of the client.
 @param appSecret The App Secret of the app.
 */
+ (void)linkClientId:(NSString*)clientId appSecret:(NSString*)appSecret;

/**
 Creates a new customer or returns an error if such customer exists.

 @param identifier A string that identifies the customer.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning identifier cannot be nil.
 */
- (void)createCustomerWithIdentifier:(NSString*)identifier
                             success:(void (^)(NSDictionary* responseObject))success
                             failure:(SEAPIRequestFailureBlock)failure;

/**
 Creates a login with given parameters.

 @param parameters The parameters of the login that is to be created. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login creation process that can respond to certain events.

 @warning parameters cannot be nil.

 @code
 // parameters example, listing only the required fields
 {
    "customer_id": "AtQX6Q8vRyMrPjUVtW7J_O1n06qYQ25bvUJ8CIC80-8",
    "country_code": "XF",
    "provider_code": "fakebank_simple_xf",
    "credentials": {
        "login": "username",
        "password": "secret"
    }
 }
 @endcode

 @see SELoginFetchingDelegate
 @see https://docs.saltedge.com/reference/#logins-create
 */
- (void)createLoginWithParameters:(NSDictionary*)parameters
                          success:(void (^)(SELogin* login))success
                          failure:(SEAPIRequestFailureBlock)failure
                         delegate:(id<SELoginFetchingDelegate>)delegate;


/**
 Creates a OAuth login with given parameters.

 @param parameters The parameters of the OAuth login that is to be created. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login creation process that can respond to certain events.

 @code
 // parameters example, listing only the required fields
 {
    "customer_id": "AtQX6Q8vRyMrPjUVtW7J_O1n06qYQ25bvUJ8CIC80-8",
    "country_code": "XO",
    "provider_code": "paypal_xo",
    "return_to": "your-app-url://home.local"
 }
 @endcode

 @see https://docs.saltedge.com/reference/#oauth-create
 */
- (void)createOAuthLoginWithParameters:(NSDictionary*)parameters
                               success:(void (^)(NSDictionary* responseObject))success
                               failure:(SEAPIRequestFailureBlock)failure
                              delegate:(id<SELoginFetchingDelegate>)delegate;

/**
 Fetches a certain provider.

 @param code The code of the provider that will be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning code cannot be nil.

 @see https://docs.saltedge.com/reference/#providers-show
 */
- (void)fetchProviderWithCode:(NSString*)code
                      success:(void (^)(SEProvider* provider))success
                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches the whole providers list.

 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @see https://docs.saltedge.com/reference/#providers-list
 */
- (void)fetchFullProvidersListWithSuccess:(void (^)(NSSet* providers))success
                                  failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches a set of providers based on given parameters.

 @param parameters Optional constraints set to the fetch query. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @code
 // parameters example
 {
    "from_id": 577,
    "from_date": "2014-06-08"
 }
 @endcode

 @see https://docs.saltedge.com/reference/#providers-list
 */
- (void)fetchProvidersListWithParameters:(NSDictionary*)parameters
                                 success:(void (^)(NSSet* providers))success
                                 failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches all accounts tied to a login.

 @param loginSecret The secret of the login whose accounts are going to be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginSecret cannot be nil.

 @see https://docs.saltedge.com/reference/#accounts-list
 */
- (void)fetchFullAccountsListForLoginSecret:(NSString*)loginSecret
                                    success:(void (^)(NSSet* accounts))success
                                    failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches all transactions tied to an account.

 @param accountId The id of the account whose transactions are going to be fetched.
 @param loginSecret The login secret of the accounts' login.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning accountId cannot not be nil.

 @see https://docs.saltedge.com/reference/#transactions-list
 */
- (void)fetchFullTransactionsListForAccountId:(NSNumber*)accountId
                                  loginSecret:(NSString*)loginSecret
                                      success:(void (^)(NSSet* transactions))success
                                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches certain transactions tied to an account, based on the passed parameters.

 @param accountId The id of the account whose transactions are going to be fetched.
 @param loginSecret The login secret of the accounts' login.
 @param parameters Optional constraints set to the fetch query. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning accountId cannot not be nil.

 @code
 // parameters example, all optional
 {
    "from_id": 1839,
    "from_made_on": [NSDate dateWithTimeIntervalSinceReferenceDate:0],
    "to_made_on": [NSDate date]
 }
 @endcode

 @see https://docs.saltedge.com/reference/#transactions-list
 */
- (void)fetchTransactionsListForAccountId:(NSNumber*)accountId
                              loginSecret:(NSString*)loginSecret
                               parameters:(NSDictionary*)parameters
                                  success:(void (^)(NSSet* transactions))success
                                  failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches all pending transactions tied to an account.

 @param accountId The id of the account whose pending transactions are going to be fetched.
 @param loginSecret The login secret of the accounts' login.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning accountId cannot not be nil.

 @see https://docs.saltedge.com/reference/#transactions-list
 */
- (void)fetchFullPendingTransactionsListForAccountId:(NSNumber*)accountId
                                         loginSecret:(NSString*)loginSecret
                                             success:(void (^)(NSSet* pendingTransactions))success
                                             failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches certain pending transactions tied to an account, based on the passed parameters.

 @param accountId The id of the account whose pending transactions are going to be fetched.
 @param loginSecret The login secret of the accounts' login.
 @param parameters Optional constraints set to the fetch query. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning accountId cannot not be nil.

 @code
 // parameters example, all optional
 {
    "from_id": 2370,
    "from_made_on": [NSDate date],
    "to_made_on": [NSDate dateWithTimeIntervalSinceNow:oneDayInterval]
 }
 @endcode

 @see https://docs.saltedge.com/reference/#transactions-list
 */
- (void)fetchPendingTransactionsListForAccountId:(NSNumber*)accountId
                                     loginSecret:(NSString*)loginSecret
                                      parameters:(NSDictionary*)parameters
                                         success:(void (^)(NSSet* pendingTransactions))success
                                         failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches a login with a given login secret.

 @param loginSecret The secret of the login which is to be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginSecret cannot be nil.
 */
- (void)fetchLoginWithSecret:(NSString*)loginSecret
                     success:(void (^)(SELogin* login))success
                     failure:(SEAPIRequestFailureBlock)failure;

/**
 Provides an interactive login with a set of credentials.

 @param loginSecret The secret of the login which is currently in interactive state.
 @param credentials The interactive credentials for the login.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login creation process that can respond to certain events.
 */
- (void)provideInteractiveCredentialsForLoginWithSecret:(NSString*)loginSecret
                                            credentials:(NSDictionary*)credentials
                                                success:(void (^)(SELogin* login))success
                                                failure:(SEAPIRequestFailureBlock)failure
                                               delegate:(id<SELoginFetchingDelegate>)delegate;

/**
 Reconnects a login.

 @param loginSecret The secret of the login which is to be reconnected.
 @param credentials The credentials of the login. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login reconnect process that can respond to certain events.

 @warning credentials cannot be nil.

 @code
 // credentials example
 {
    "login": "username",
    "password": "secret"
 }
 @endcode

 @see https://docs.saltedge.com/reference/#logins-reconnect
 */
- (void)reconnectLoginWithSecret:(NSString*)loginSecret
                     credentials:(NSDictionary*)credentials
                         success:(void (^)(SELogin* login))success
                         failure:(SEAPIRequestFailureBlock)failure
                        delegate:(id<SELoginFetchingDelegate>)delegate;

/**
 Reconnects a OAuth login.

 @param loginSecret The secret of the OAuth login which is to be reconnected.
 @param parameters The parameters of the reconnect request. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @code
 // parameters example
 {
    "return_to": "your-app-url://home.local",
    "return_login_id": false
 }
 @endcode

 @see https://docs.saltedge.com/reference/#oauth-reconnect
 */
- (void)reconnectOAuthLoginWithSecret:(NSString*)loginSecret
                           parameters:(NSDictionary*)parameters
                              success:(void (^)(NSDictionary* responseObject))success
                              failure:(SEAPIRequestFailureBlock)failure;

/**
 Refreshes a login.

 @param loginSecret The secret of the login which is to be refreshed.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login reconnect process that can respond to certain events.

 @warning Only automatic logins can be refreshed.

 @see https://docs.saltedge.com/reference/#logins-refresh
 */
- (void)refreshLoginWithSecret:(NSString*)loginSecret
                       success:(void (^)(NSDictionary* responseObject))success
                       failure:(SEAPIRequestFailureBlock)failure
                      delegate:(id<SELoginFetchingDelegate>)delegate;

/**
 Refreshes a OAuth login.

 @param loginSecret The secret of the OAuth login which is to be refreshed.
 @param parameters The parameters of the reconnect request. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @code
 // parameters example, listing only the required fields
 {
    "return_to": "your-app-url://home.local"
 }
 @endcode

 @see https://docs.saltedge.com/reference/#oauth-refresh
 */
- (void)refreshOAuthLoginWithSecret:(NSString*)loginSecret
                         parameters:(NSDictionary*)parameters
                            success:(void (^)(NSDictionary* responseObject))success
                            failure:(SEAPIRequestFailureBlock)failure;

/**
 Removes a login from the Salt Edge system. All its accounts and transactions will be removed as well.

 @param loginSecret The secret of the login which is to be removed.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginSecret cannot be nil.
 */
- (void)removeLoginWithSecret:(NSString*)loginSecret
                      success:(void (^)(NSDictionary* responseObject))success
                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for connecting a login via a web view.

 @param parameters The parameters that will go in the request payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning parameters cannot be nil. Required fields are: "country_code", "provider_code", "customer_id", "return_to"

 @code
 // parameters example, listing only the required fields
 {
    "country_code": "XO"
    "provider_code": "paypal_xo",
    "customer_id": "customer id string",
    "return_to": "http://example.com"
 }
 @endcode

 @see https://docs.saltedge.com/reference/#tokens-create
 */
- (void)requestCreateTokenWithParameters:(NSDictionary*)parameters
                                 success:(void (^)(NSDictionary* responseObject))success
                                 failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for reconnecting a login via a web view.

 @param loginSecret The login secret for which the reconnect token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning parameters cannot be nil. "return_to" is the only required field.
 @warning login may not be nil.

 @code
 // parameters example, listing only the required fields
 {
    "return_to": "http://example.com"
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#reconnect
 */
- (void)requestReconnectTokenForLoginSecret:(NSString*)loginSecret
                                 parameters:(NSDictionary*)parameters
                                    success:(void (^)(NSDictionary* responseObject))success
                                    failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for refreshing a login via a web view.

 @param loginSecret The login secret for which the refresh token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning parameters cannot be nil. "return_to" is the only required field.
 @warning login may not be nil.

 @code
 // parameters example, listing only the required fields
 {
    "return_to": "http://example.com"
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#refresh
 */
- (void)requestRefreshTokenForLoginSecret:(NSString*)loginSecret
                               parameters:(NSDictionary*)parameters
                                  success:(void (^)(NSDictionary* responseObject))success
                                  failure:(SEAPIRequestFailureBlock)failure;

@end
