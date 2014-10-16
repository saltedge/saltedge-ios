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
                             success:(void (^)(NSDictionary*))success
                             failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches a certain provider.

 @param code The code of the provider that will be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning code cannot be nil.

 @see https://docs.saltedge.com/reference/#providers-show
 */
- (void)fetchProviderWithCode:(NSString*)code
                      success:(void (^)(SEProvider*))success
                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches the whole providers list.

 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @see https://docs.saltedge.com/reference/#providers-list
 */
- (void)fetchFullProvidersListWithSuccess:(void (^)(NSSet *))success
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
                                    success:(void(^)(NSSet*))success
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
                                      success:(void(^)(NSSet*))success
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
 // parameters example
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
                                  success:(void(^)(NSSet*))success
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
                                             success:(void(^)(NSSet*))success
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
 // parameters example
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
                                         success:(void(^)(NSSet*))success
                                         failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches a login with a given login secret.

 @param loginSecret The secret of the login which is to be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginSecret cannot be nil.
 */
- (void)fetchLoginWithSecret:(NSString*)loginSecret
                     success:(void(^)(SELogin*))success
                     failure:(SEAPIRequestFailureBlock)failure;

/**
 Removes a login from the Salt Edge system. All its accounts and transactions will be removed as well.

 @param loginSecret The secret of the login which is to be removed.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginSecret cannot be nil.
 */
- (void)removeLoginWithSecret:(NSString*)loginSecret
                      success:(void(^)(NSDictionary*))success
                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for connecting a login via a web view.

 @param parameters The parameters that will go in the request payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning The parameters should at least contain a key "customer_email" with the corresponding customer email.

 @code
 // parameters example
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
                                 success:(void (^)(NSDictionary*))success
                                 failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for reconnecting a login via a web view.

 @param loginSecret The login secret for which the reconnect token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning The parameters should at least contain a key "customer_email" with the corresponding customer email.
 @warning login may not be nil.

 @code
 // parameters example
 {
    "return_to": "http://example.com"
    // optional fields here...
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#reconnect
 */
- (void)requestReconnectTokenForLoginSecret:(NSString*)loginSecret
                                 parameters:(NSDictionary*)parameters
                                    success:(void (^)(NSDictionary*))success
                                    failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for refreshing a login via a web view.

 @param loginSecret The login secret for which the refresh token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning The parameters should at least contain a key "customer_email" with the corresponding customer email.
 @warning login may not be nil.

 @code
 // parameters example
 {
    "return_to": "http://example.com"
    // optional fields here...
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#refresh
 */
- (void)requestRefreshTokenForLoginSecret:(NSString*)loginSecret
                               parameters:(NSDictionary*)parameters
                                  success:(void (^)(NSDictionary*))success
                                  failure:(SEAPIRequestFailureBlock)failure;

@end
