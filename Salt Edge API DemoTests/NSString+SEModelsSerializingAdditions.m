//
//  NSString+SEModelsSerializingAdditions.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/24/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+SEModelsSerializingAdditions.h"

@interface NSString_SEModelsSerializingAdditionsTests : XCTestCase

@end

@implementation NSString_SEModelsSerializingAdditionsTests

- (void)testCamelCaseCounterpart
{
    NSString* complexKey = @"last_success_at";
    NSString* complexKeyCounterpart = [complexKey se_camelCaseCounterpart];

    XCTAssertEqualObjects(complexKeyCounterpart, @"lastSuccessAt", @"se_camelCaseCounterpart should properly convert underscores to leading capitalized words");

    NSString* simpleKey = @"country_code";
    NSString* simpleKeyCounterpart = [simpleKey se_camelCaseCounterpart];

    XCTAssertEqualObjects(simpleKeyCounterpart, @"countryCode", @"se_camelCaseCounterpart should properly convert underscores to leading capitalized words");

    NSString* word = @"id";
    NSString* wordCounterpart = [word se_camelCaseCounterpart];

    XCTAssertEqualObjects(wordCounterpart, @"id", @"se_camelCaseCounterpart should ignore strings which don't have any underscores");
}

- (void)testUppercaseFirstCharacter
{
    NSString* string = @"thisIsMyString";

    XCTAssertEqualObjects([string se_uppercaseFirstCharacter], @"ThisIsMyString", @"se_uppercaseFirstCharacter should uppercase first character");

    NSString* otherString = @"The";

    XCTAssertEqualObjects([otherString se_uppercaseFirstCharacter], @"The", @"se_uppercaseFirstCharacter should leave the character as is if it's already in uppercase");
}

@end
