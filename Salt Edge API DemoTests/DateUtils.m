//
//  DateUtils.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/24/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DateUtils.h"

@interface DateUtilsTests : XCTestCase

@end

@implementation DateUtilsTests

- (void)testDateFromISO8601String
{
    NSString* dateString = @"1970-01-01T00:00:00Z";
    NSDate* date = [DateUtils dateFromISO8601String:dateString];

    XCTAssertEqualObjects(date, [NSDate dateWithTimeIntervalSince1970:0], @"dateFromISO8601String should properly convert a legit ISO 8601 string to a date object");
}

- (void)testDateFromYMDString
{
    NSString* dateString = @"1970-01-01";
    NSDate* date = [DateUtils dateFromYMDString:dateString];

    XCTAssertEqualObjects(date, [NSDate dateWithTimeIntervalSince1970:0], @"dateFromYMDString should properly convert a YMD date string to a date object");
}

@end
