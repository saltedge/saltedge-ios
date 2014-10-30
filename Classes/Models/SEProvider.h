//
//  SEProvider.h
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
#import "SEBaseModel.h"

/**
 SEProvider represents a provider whithin the Salt Edge system.

 @see https://docs.saltedge.com/guides/providers/
 */
@interface SEProvider : SEBaseModel

@property (nonatomic, strong) NSNumber* automaticFetch;
@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* countryCode;
@property (nonatomic, strong) NSDate*   createdAt;
@property (nonatomic, strong) NSString* forumUrl;
@property (nonatomic, strong) NSString* homeUrl;
@property (nonatomic, strong) NSString* instruction;
@property (nonatomic, strong) NSNumber* interactive;
@property (nonatomic, strong) NSString* loginUrl;
@property (nonatomic, strong) NSString* mode;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSArray*  requiredFields;
@property (nonatomic, strong) NSArray*  interactiveFields;
@property (nonatomic, strong) NSString* status;
@property (nonatomic, strong) NSString* updatedAt;

/**
 Tests whether the caller and the parameter are equal.

 @return YES if the providers' codes are equal, otherwise NO.
 */
- (BOOL)isEqualToProvider:(SEProvider*)provider;

/**
 Tests whether the caller is an OAuth provider.

 @return YES if the provider is an OAuth provider, otherwise NO.
 */
- (BOOL)isOAuth;

@end
