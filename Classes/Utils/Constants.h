//
//  Constants.h
//
//  Copyright (c) 2015 Salt Edge. https://saltedge.com
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

#ifndef _SaltEdge_API_Demo_Constants_h
#define _SaltEdge_API_Demo_Constants_h

/* Routes and paths */
static NSString* const kRootURL                 = @"https://www.saltedge.com";
static NSString* const kTokensPath              = @"api/v3/tokens";
static NSString* const kLoginPath               = @"api/v3/login";
static NSString* const kAttemptsPath            = @"api/v3/attempts";
static NSString* const kAccountsPath            = @"api/v3/accounts";
static NSString* const kTransactionsPath        = @"api/v3/transactions";
static NSString* const kProvidersPath           = @"api/v3/providers";
static NSString* const kOAuthProvidersPath      = @"api/v3/oauth_providers";
static NSString* const kCustomersPath           = @"api/v3/customers";
static NSString* const kLearnPath               = @"api/v3/categories/learn";
static NSString* const kLoginInteractive        = @"interactive";
static NSString* const kPendingTransactions     = @"pending";

/* Login actions */
static NSString* const kLoginActionReconnect = @"reconnect";
static NSString* const kLoginActionCreate    = @"create";
static NSString* const kLoginActionRefresh   = @"refresh";

/* Provider input fields types */
static NSString* const SEProviderFieldTypeText     = @"text";
static NSString* const SEProviderFieldTypePassword = @"password";
static NSString* const SEProviderFieldTypeSelect   = @"select";
static NSString* const SEProviderFieldTypeFile     = @"file";

/* Keys of responses and post bodies */
static NSString* const kFromIdKey                = @"from_id";
static NSString* const kDataKey                  = @"data";
static NSString* const kCredentialsKey           = @"credentials";
static NSString* const kMetaKey                  = @"meta";
static NSString* const kNextIdKey                = @"next_id";
static NSString* const kNextPageKey              = @"next_page";
static NSString* const kLoginIdKey               = @"login_id";
static NSString* const kRefreshKey               = @"refresh";
static NSString* const kRefreshedKey             = @"refreshed";
static NSString* const kRemovedKey               = @"removed";
static NSString* const kCountryCodeKey           = @"country_code";
static NSString* const kProviderCodeKey          = @"provider_code";
static NSString* const kReturnToKey              = @"return_to";
static NSString* const kRedirectURLKey           = @"redirect_url";
static NSString* const kCustomerSecretKey        = @"secret";
static NSString* const kAccountIdKey             = @"account_id";
static NSString* const kFromMadeOnKey            = @"from_made_on";
static NSString* const kToMadeOnKey              = @"to_made_on";
static NSString* const kMobileKey                = @"mobile";
static NSString* const kIdentifierKey            = @"identifier";
static NSString* const kLoginStageFinish         = @"finish";
static NSString* const kLoginStageInteractive    = @"interactive";

#endif
