//
//  SEAccountTests.m
//  Salt Edge API Demo
//
//  Created by nemesis on 7/25/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SEAccount.h"

@interface SEAccountTests : XCTestCase

@end

@implementation SEAccountTests

- (void)testIsEqualToAccount
{
    SEAccount* firstAccount = [[SEAccount alloc] init];
    firstAccount.id = @1;
    SEAccount* secondAccount = [[SEAccount alloc] init];
    secondAccount.id = firstAccount.id;
    SEAccount* thirdAccount = [[SEAccount alloc] init];
    thirdAccount.id = @2;

    XCTAssertTrue([firstAccount isEqualToAccount:secondAccount], @"Two accounts should be equal when their ids are equal");
    XCTAssertFalse([firstAccount isEqualToAccount:thirdAccount], @"Two accounts shouldn't be equal when their ids aren't equal");
}

@end
