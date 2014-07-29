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
@protocol SELoginCreationDelegate;

/**
 SEAPIRequestManager is a subclass of AFHTTPSessionManager designed to provide convinient methods in communicating with the Salt Edge API.
 */
@interface SEAPIRequestManager : AFHTTPSessionManager

/**
 Creates and returns an SEAPIRequestManager instance.
 */
+ (instancetype)manager;

/**
 Links your App ID and App Secret to the request manager. All outgoing requests will have the proper app-related HTTP headers set by default.
 
 @param appId The App ID of the app
 @param appSecret The App Secret of the app
 */
+ (void)linkAppId:(NSString*)appId appSecret:(NSString*)appSecret;

/**
 Fetches the whole providers list.
 
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @see https://docs.saltedge.com/reference/#providers-list
 */
- (void)fetchFullProvidersListWithSuccess:(void (^)(NSURLSessionDataTask*, NSSet*))success
                                  failure:(SEAPIRequestFailureBlock)failure;

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
 Creates a login with given parameters. 
 
 @param parameters The parameters of the login that is to be created. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login creation that will respond to certain events.

 @see SELoginCreationDelegate

 @warning parameters cannot be nil.

 @code
 // parameters example
 {
    "customer_email": "email@example.com",
    "country_code": "XF",
    "provider_code": "fakebank_simple_xf",
    "credentials": {
        "login": "username",
        "password": "secret"
    }
 }
 @endcode
 
 @see https://docs.saltedge.com/reference/#logins-create
 */
- (void)createLoginWithParameters:(NSDictionary*)parameters
                          success:(void (^)(NSURLSessionDataTask*, SELogin*))success
                          failure:(SEAPIRequestFailureBlock)failure
                         delegate:(id<SELoginCreationDelegate>)delegate;

/**
 Reconnects a login with given login id and credentials.
 
 @param loginId The id of the login to reconnect.
 @param credentials The credentials object that will be used to reconnect the login. See an example above.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login reconnect process.

 @warning loginId and credentials cannot be nil.

 @code
 // credentials example
 {
    "login": "username",
    "password": "secret"
 }
 @endcode
 
 @see https://docs.saltedge.com/reference/#logins-reconnect
 */
- (void)reconnectLoginWithLoginId:(NSNumber*)loginId
                      credentials:(NSDictionary*)credentials
                          success:(void (^)(NSURLSessionDataTask*, SELogin*))success
                          failure:(SEAPIRequestFailureBlock)failure
                         delegate:(id<SELoginCreationDelegate>)delegate;

/**
 Refreshes a login with given login id. If the request succeeds, the dictionary in the success callback will contain information about the login - it's id, it's refresh status, the date of the last refresh, and the date of the refresh when it's available. All of the objects listed above will be represented in Foundation classes.
 
 @param loginId The id of the login to refresh.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.
 @param delegate The delegate of the login refresh process.

 @warning loginId cannot be nil.
 
 @see https://docs.saltedge.com/reference/#logins-refresh
 */
- (void)refreshLoginWithId:(NSNumber*)loginId
                   success:(void (^)(NSURLSessionDataTask*, NSDictionary*))success
                   failure:(SEAPIRequestFailureBlock)failure
                  delegate:(id<SELoginCreationDelegate>)delegate;

/**
 Provides the login with the interactive credentials that are currently required.
 
 @param credentials The interactive credentials that are to be supplied. See an example above.
 @param loginId The id of the login which has requested interactive input.
 @param success The callback block if the request succeeds.
 @param failure The callback block if the request fails.

 @warning credentials, loginId cannot be nil.

 @code
 // credentials example
 {
    "sms": 123456
 }
 @endcode
 
 @see https://docs.saltedge.com/reference/#logins-interactive
 */
- (void)postInteractiveCredentials:(NSDictionary*)credentials
                           forLoginId:(NSNumber*)loginId
                           success:(void (^)(NSURLSessionDataTask*, SELogin*))success
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


@end
