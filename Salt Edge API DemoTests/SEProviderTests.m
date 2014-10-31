//
//  SEProviderTests.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/25/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SEProvider.h"

@interface SEProviderTests : XCTestCase

@end

@implementation SEProviderTests

- (void)testIsEqualToProvider
{
    SEProvider* firstProvider = [[SEProvider alloc] init];
    firstProvider.code = @"first_provider";
    SEProvider* secondProvider = [[SEProvider alloc] init];
    secondProvider.code = firstProvider.code;
    SEProvider* thirdProvider = [[SEProvider alloc] init];
    thirdProvider.code = @"third_provider";

    XCTAssertTrue([firstProvider isEqualToProvider:secondProvider], @"Two providers should be equal when their codes are equal");
    XCTAssertFalse([firstProvider isEqualToProvider:thirdProvider], @"Two providers shouldn't be equal when their codes aren't equal");
}

- (void)testIsOAuth
{
    SEProvider* provider = [[SEProvider alloc] init];
    provider.mode = @"oauth";
    XCTAssertTrue(provider.isOAuth, @"Provider with mode \"oauth\" should return TRUE on invocation of `isOAuth`");
    provider.mode = @"wer";
    XCTAssertFalse(provider.isOAuth, @"Provider with mode other than \"oauth\" should return FALSE on invocation of `isOAuth`");
}

@end
