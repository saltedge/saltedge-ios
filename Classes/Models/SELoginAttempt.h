//
//  SELoginAttempt.h
//
//  Copyright (c) 2017 Salt Edge. https://saltedge.com
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
#import "SELoginAttemptStage.h"

/**
 SELoginAttempt represents an attempt to fetch a login.

 @warning When fetching a login attempt or getting it from a login object via login.lastAttempt, it may not have all fields present.
 */

@interface SELoginAttempt : SEBaseModel

@property (nonatomic, strong) NSString*            id;
@property (nonatomic, strong) SELoginAttemptStage* lastStage;
@property (nonatomic, strong) NSArray*             stages;
@property (nonatomic, strong) NSNumber*            finished;
@property (nonatomic, strong) NSNumber*            finishedRecent;
@property (nonatomic, strong) NSNumber*            interactive;
@property (nonatomic, strong) NSNumber*            partial;
@property (nonatomic, strong) NSNumber*            automaticFetch;
@property (nonatomic, strong) NSDate*              createdAt;
@property (nonatomic, strong) NSDate*              updatedAt;
@property (nonatomic, strong) NSDate*              successAt;
@property (nonatomic, strong) NSDate*              failAt;
@property (nonatomic, strong) NSString*            failErrorClass;
@property (nonatomic, strong) NSString*            failMessage;

@end
