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
#import <AFHTTPSessionManager.h>

typedef void (^SEAPIRequestFailureBlock)(NSURLSessionDataTask* task, NSError* error);

@class SEProvider, SELogin;

/**
 SEAPIRequestManager is a subclass of AFHTTPSessionManager designed to provide convinient methods in communicating with the Salt Edge API.
 */
@interface SEAPIRequestManager : AFHTTPSessionManager

/**
 Creates and returns an SEAPIRequestManager instance.
 */
+ (instancetype)manager;

/**
 Links your App id and App Secret to the request manager. All outgoing requests will have the proper app-related HTTP headers set by default.

 @param appId The App id of the app.
 @param appSecret The App Secret of the app.
 */
+ (void)linkAppId:(NSString*)appId appSecret:(NSString*)appSecret;

/**
 Links your App id and Customer Secret to the request manager. All outgoing requests will have the proper app-related HTTP headers set by default. Also note that the customer secret is retrieved from the web server that the client should set up.

 @param appId The App id of the app.
 @param customerSecret The customer secret returned by your web server.
 */
+ (void)linkAppId:(NSString*)appId customerSecret:(NSString*)customerSecret;

/**
 Fetches all the logins tied to your app.

 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @see https://docs.saltedge.com/reference/#logins-list
 */
- (void)fetchFullLoginsListWithSuccess:(void (^)(NSURLSessionDataTask*, NSSet*))success
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
                      success:(void (^)(NSURLSessionDataTask*, SEProvider*))success
                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches all accounts tied to a login.

 @param loginId The id of the login whose accounts are going to be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginId cannot be nil.

 @see https://docs.saltedge.com/reference/#accounts-list
 */
- (void)fetchFullAccountsListForLoginId:(NSNumber*)loginId
                            success:(void(^)(NSURLSessionDataTask*, NSSet*))success
                            failure:(SEAPIRequestFailureBlock)failure;

/**
 Fetches all transactions tied to an account.

 @param accountId The id of the account whose transactions are going to be fetched.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning accountId cannot not be nil.

 @see https://docs.saltedge.com/reference/#transactions-list
 */
- (void)fetchFullTransactionsListForAccountId:(NSNumber*)accountId
                                      success:(void(^)(NSURLSessionDataTask*, NSSet*))success
                                      failure:(SEAPIRequestFailureBlock)failure;

/**
 Removes the login with given login id from the system, also removing all associated accounts and transactions.

 @param loginId The id of the login to remove.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning loginId cannot be nil.

 @see https://docs.saltedge.com/reference/#logins-remove
 */
- (void)removeLoginWithId:(NSNumber*)loginId
                  success:(void (^)(NSURLSessionDataTask*, NSDictionary*))success
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
    "customer_email": "customer@app.com"
    // optional fields here...
 }
 @endcode

 @see https://docs.saltedge.com/reference/#tokens-create
 */
- (void)requestConnectTokenWithParameters:(NSDictionary*)parameters
                                  success:(void (^)(NSURLSessionDataTask*, NSDictionary*))success
                                  failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for reconnecting a login via a web view.

 @param login The login for which the reconnect token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @code
 // parameters example
 {
 "customer_email": "customer@app.com"
 // optional fields here...
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#reconnect
 */
- (void)requestReconnectTokenForLogin:(SELogin*)login
                           parameters:(NSDictionary*)parameters
                              success:(void (^)(NSURLSessionDataTask*, NSDictionary*))success
                              failure:(SEAPIRequestFailureBlock)failure;

/**
 Requests a token for refreshing a login via a web view.

 @param login The login for which the refresh token is requested.
 @param parameters The parameters that will go with the payload. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @code
 // parameters example
 {
 "customer_email": "customer@app.com"
 // optional fields here...
 }
 @endcode

 @see https://docs.saltedge.com/guides/logins/#refresh
 */
- (void)requestRefreshTokenForLogin:(SELogin*)login
                         parameters:(NSDictionary*)parameters
                            success:(void (^)(NSURLSessionDataTask*, NSDictionary*))success
                            failure:(SEAPIRequestFailureBlock)failure;

@end
