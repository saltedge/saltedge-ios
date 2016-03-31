//
//  SELogin.h
//
//  Copyright (c) 2016 Salt Edge. https://saltedge.com
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

#import "SEBaseModel.h"
#import "SELoginAttempt.h"

/**
 SELogin represents a login within the Salt Edge system.

 @see https://docs.saltedge.com/guides/logins/
 */
@interface SELogin : SEBaseModel

@property (nonatomic, strong) NSNumber*       id;
@property (nonatomic, strong) SELoginAttempt* lastAttempt;
@property (nonatomic, strong) NSString*       secret;
@property (nonatomic, strong) NSString*       status;
@property (nonatomic, strong) NSString*       countryCode;
@property (nonatomic, strong) NSString*       providerCode;
@property (nonatomic, strong) NSString*       providerName;
@property (nonatomic, strong) NSDate*         createdAt;
@property (nonatomic, strong) NSDate*         updatedAt;
@property (nonatomic, strong) NSDate*         lastSuccessAt;
@property (nonatomic, strong) NSDate*         nextRefreshPossibleAt;

/**
 Tests whether the caller and the parameter are equal.

 @return YES if the logins' ids are equal, otherwise NO.
 */
- (BOOL)isEqualToLogin:(SELogin*)login;

/**
 Convenience method for getting the last login stage from the last attempt.
 This will be equal to the caller's lastAttempt.lastStage.name

 @return The login stage from the last attempt.
 */
- (NSString*)stage;

/**
 Convenience method for getting the last fail message from the last attempt.
 This will be equal to the caller's lastAttempt.failMessage

 @return The login stage from the last attempt.
 */
- (NSString*)lastFailMessage;

@end
