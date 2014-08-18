//
//  NSString+SEModelsSerializingAdditions.h
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

/**
 SEmodelsSearilizingAdditions is a simple category which defines a few methods on NSString to help with object serialization (since the returned JSON objects do not have CamelCase keys).
 */

@interface NSString (SEModelsSerializingAdditions)

/**
 Returns a camel case counterpart of the string, if there is one.
 Example: [@"login_id" se_camelCaseCounterpart] yields @"loginId", [@"last_requested_at" se_camelCaseCounterpart] yields @"lastRequestedAt", etc.
 */
- (instancetype)se_camelCaseCounterpart;
/**
 Unlike the other similar method "capitalizedString", se_uppercaseFirstCharacter does capitalize the string but also does not lowercase the rest of it.
 */
- (instancetype)se_uppercaseFirstCharacter;

@end
