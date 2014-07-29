//
//  SEBaseModel.m
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
#import "NSString+SEModelsSerializingAdditions.h"
#import "DateUtils.h"

static NSArray* datesPropertiesNames;

@implementation SEBaseModel

+ (void)initialize
{
    datesPropertiesNames = @[@"createdAt", @"updatedAt", @"deletedAt", @"lastFailAt", @"lastSuccessAt", @"lastRequestAt"];
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    NSAssert(dictionary != nil, @"the object's dictionary representation cannot be nil.");
    
    id object = [[self alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id value, BOOL* stop) {
        NSString* propertyName = [key se_camelCaseCounterpart];
        NSString* setterMethodName = [NSString stringWithFormat:@"set%@:", [propertyName se_uppercaseFirstCharacter]];
        SEL selector = NSSelectorFromString(setterMethodName);
        if ([object respondsToSelector:selector]) {
            id valueToSet = value;
            if ([datesPropertiesNames containsObject:propertyName] && ![valueToSet isEqual:[NSNull null]]) {
                valueToSet = [DateUtils dateFromISO8601String:value];
            }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [object performSelector:selector withObject:valueToSet];
#pragma clang diagnostic pop
        }
    }];
    return object;
}

@end
