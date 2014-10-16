//
//  Constants.h
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

#ifndef _SaltEdge_API_Demo_Constants_h
#define _SaltEdge_API_Demo_Constants_h

/* Routes */
static NSString* const kRootURL                 = @"https://www.saltedge.com";
static NSString* const kCreateTokenPath         = @"api/v2/tokens/create";
static NSString* const kReconnectTokenPath      = @"api/v2/tokens/reconnect";
static NSString* const kRefreshTokenPath        = @"api/v2/tokens/refresh";
static NSString* const kLoginPath               = @"api/v2/login";
static NSString* const kAccountsPath            = @"api/v2/accounts";
static NSString* const kTransactionsPath        = @"api/v2/transactions";
static NSString* const kPendingTransactionsPath = @"api/v2/transactions/pending";
static NSString* const kProvidersPath           = @"api/v2/providers";
static NSString* const kCustomersPath           = @"api/v2/customers";
static NSString* const kLoginInteractive        = @"interactive";
static NSString* const kLoginReconnect          = @"reconnect";
static NSString* const kLoginRefresh            = @"refresh";
static NSString* const kLoginRemove             = @"remove";

/* Provider input fields types */
static NSString* const SEProviderFieldTypeText     = @"text";
static NSString* const SEProviderFieldTypePassword = @"password";
static NSString* const SEProviderFieldTypeSelect   = @"select";
static NSString* const SEProviderFieldTypeFile     = @"file";

#endif
