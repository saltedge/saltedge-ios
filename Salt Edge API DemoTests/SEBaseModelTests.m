//
//  SEBaseModelTests.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/24/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SEProvider.h"
#import "SEProviderField.h"
#import "NSString+SEModelsSerializingAdditions.h"
#import "DateUtils.h"

@interface SEBaseModelTests : XCTestCase {
    NSDictionary* providerDictionary;
}
@end

@implementation SEBaseModelTests

- (void)setUp
{
    [super setUp];
    providerDictionary = @{ @"automatic_fetch" : @YES,
                            @"code" : @"fakebank_simple_xf",
                            @"country_code" : @"XF",
                            @"created_at" : @"2014-02-07T12:56:54Z",
                            @"forum_url" : @"https://example.com",
                            @"home_url" : @"https://example.com",
                            @"instruction" : @"Please fill in all the fields",
                            @"interactive" : @NO,
                            @"login_url" : @"https://example.com",
                            @"mode" : @"web",
                            @"name" : @"Fake Bank Simple",
                            @"required_fields" : @[
                                        @{ @"english_name" : @"Login",
                                           @"localized_name" : @"Login",
                                           @"name" : @"login",
                                           @"nature" : @"text",
                                           @"position" : @1,
                                           },
                                        @{ @"english_name" : @"Password",
                                           @"localized_name" : @"Password",
                                           @"name" : @"password",
                                           @"nature" : @"password",
                                           @"position" : @2,
                                           }
                                    ],
                            @"status" : @"active",
                            @"updated_at" : @"2014-06-06T13:34:35Z"
                            };
}

- (void)tearDown
{
    providerDictionary = nil;
    [super tearDown];
}

- (void)testObjectFromDictionary
{
    SEProvider* provider = [SEProvider objectFromDictionary:providerDictionary];

    XCTAssertNotNil(provider, @"Created object should not be nil");
    XCTAssertTrue([provider isMemberOfClass:[SEProvider class]], @"Returned object should be instancetype of the class method");

    for (id obj in provider.requiredFields) {
        XCTAssertTrue([obj isMemberOfClass:[SEProviderField class]], @"Provider fields should be of type SEProviderField");
    }

    NSArray* datesKeys = @[@"createdAt", @"updatedAt", @"deletedAt", @"lastFailAt", @"lastSuccessAt", @"lastRequestAt"];

    for (NSString* key in providerDictionary.allKeys) {
        if (![key isEqualToString:@"required_fields"]) {
            NSString* propertyName = [key se_camelCaseCounterpart];
            id objectValue = [provider valueForKey:propertyName];
            id dictionaryValue = [providerDictionary valueForKey:key];

            if ([datesKeys containsObject:propertyName]) {
                dictionaryValue = [DateUtils dateFromISO8601String:dictionaryValue];
            }

            XCTAssertEqualObjects(objectValue, dictionaryValue, @"Values should be equal");
        }
    }

    [provider.requiredFields enumerateObjectsUsingBlock:^(id field, NSUInteger idx, BOOL* stop) {
        NSDictionary* dictionaryCounterpart = providerDictionary[@"required_fields"][idx];
        for (NSString* key in dictionaryCounterpart.allKeys) {
            NSString* propertyName = [key se_camelCaseCounterpart];

            id objectValue = [field valueForKey:propertyName];
            id dictionaryValue = [dictionaryCounterpart valueForKey:key];

            XCTAssertEqualObjects(objectValue, dictionaryValue, @"Values should be equal");
        }
    }];
}

@end
