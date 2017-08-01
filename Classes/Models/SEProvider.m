//
//  SEProvider.m
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

#import "SEProvider.h"
#import "SEProviderField.h"

static NSString* const kOAuthMode = @"oauth";

@implementation SEProvider

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    SEProvider* object = [super objectFromDictionary:dictionary];

    NSMutableArray* requiredFieldsObjects = [NSMutableArray arrayWithCapacity:object.requiredFields.count];
    for (NSDictionary* requiredField in object.requiredFields) {
        [requiredFieldsObjects addObject:[SEProviderField objectFromDictionary:requiredField]];
    }
    object.requiredFields = (NSArray*) requiredFieldsObjects;

    NSMutableArray* interactiveFieldsObjects = [NSMutableArray arrayWithCapacity:object.interactiveFields.count];
    for (NSDictionary* interactiveField in object.interactiveFields) {
        [interactiveFieldsObjects addObject:[SEProviderField objectFromDictionary:interactiveField]];
    }
    object.interactiveFields = (NSArray*) interactiveFieldsObjects;
    return object;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isMemberOfClass:[SEProvider class]]) {
        return NO;
    }

    return [self isEqualToProvider:object];
}

- (BOOL)isEqualToProvider:(SEProvider*)provider
{
    return [self.code isEqualToString:provider.code];
}

- (BOOL)isOAuth
{
    return [self.mode isEqualToString:kOAuthMode];
}

- (NSUInteger)hash
{
    return self.code.hash ^ self.name.hash;
}

@end
