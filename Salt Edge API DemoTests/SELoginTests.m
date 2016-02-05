//
//  SELoginTests.m
//  Salt Edge API Demo
//
//  Created by nemesis on 7/25/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SELogin.h"

@interface SELoginTests : XCTestCase

@end

@implementation SELoginTests

- (void)testIsEqualToLogin
{
    SELogin* firstLogin = [[SELogin alloc] init];
    firstLogin.id = @1;
    SELogin* secondLogin = [[SELogin alloc] init];
    secondLogin.id = firstLogin.id;
    SELogin* thirdLogin = [[SELogin alloc] init];
    thirdLogin.id = @2;

    XCTAssertTrue([firstLogin isEqual:secondLogin], @"Two logins should be equal if their ids are equal");
    XCTAssertFalse([firstLogin isEqual:thirdLogin], @"Two logins shouldn't be equal if their ids are not equal");
}

@end
