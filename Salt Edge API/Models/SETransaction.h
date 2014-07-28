//
//  SETransaction.h
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

#import "SEBaseModel.h"

/**
 SETransaction represents a transaction within the Salt Edge system.
 
 @see https://docs.saltedge.com/guides/transactions/
 */
@interface SETransaction : SEBaseModel

@property (nonatomic, strong) NSNumber*     id;
@property (nonatomic, strong) NSNumber*     duplicated;
@property (nonatomic, strong) NSString*     mode;
@property (nonatomic, strong) NSDate*       madeOn;
@property (nonatomic, strong) NSNumber*     amount;
@property (nonatomic, strong) NSString*     currencyCode;
@property (nonatomic, strong) NSString*     description;
@property (nonatomic, strong) NSString*     category;
@property (nonatomic, strong) NSDictionary* extra;
@property (nonatomic, strong) NSDate*       createdAt;
@property (nonatomic, strong) NSDate*       updatedAt;

/**
 Tests whether the caller and the argument are equal.
 
 @return YES if the transactions' ids are equal, otherwise NO.
 */
- (BOOL)isEqualToTransaction:(SETransaction*)transaction;

@end
