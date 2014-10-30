//
//  NSURL+SEQueryArgmuentsAdditionsTests.m
//  Salt Edge API Demo
//
//  Created by nemesis on 10/30/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+SEQueryArgmuentsAdditions.h"

@interface NSURL_SEQueryArgmuentsAdditionsTests : XCTestCase

@end

@implementation NSURL_SEQueryArgmuentsAdditionsTests

- (void)testSe_queryParameters
{
    NSURL* urlWithEmptyQuery = [NSURL URLWithString:@"https://example.com/"];
    XCTAssertEqualObjects(urlWithEmptyQuery.se_queryParameters, @{}, @"URL with an empty query should return empty parameters dictionary");

    NSURL* urlWithMalformedParameters = [NSURL URLWithString:@"https://example.com/path/to/resource?arg=val&arg2=&test"];
    NSDictionary* expectedResult = @{ @"arg" : @"val" };
    XCTAssertEqualObjects(urlWithMalformedParameters.se_queryParameters, expectedResult, @"se_queryParameters should return a proper representation of all the valid parameters in the URL query");

    NSURL* expectedValidURL = [NSURL URLWithString:@"https://example.com/path/to/resource?arg=val&arg2=val2"];
    expectedResult = @{ @"arg" : @"val", @"arg2" : @"val2" };
    XCTAssertEqualObjects(expectedValidURL.se_queryParameters, expectedResult, @"A valid URL query should be parsed properly returning a valid dictionary all existing arguments.");

}

@end
