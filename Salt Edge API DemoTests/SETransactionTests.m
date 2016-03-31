//
//  SETransactionTests.m
//  Salt Edge API Demo
//
//  Created by nemesis on 7/25/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SETransaction.h"

@interface SETransactionTests : XCTestCase

@end

@implementation SETransactionTests

- (void)testIsEqualToTransaction
{
    SETransaction* firstTransaction = [[SETransaction alloc] init];
    firstTransaction.id = @1;
    SETransaction* secondTransaction = [[SETransaction alloc] init];
    secondTransaction.id = firstTransaction.id;
    SETransaction* thirdTransaction = [[SETransaction alloc] init];
    thirdTransaction.id = @2;

    XCTAssertTrue([firstTransaction isEqualToTransaction:secondTransaction], @"Two transactions should be equal when their ids are equal");
    XCTAssertFalse([firstTransaction isEqualToTransaction:thirdTransaction], @"Two transactions shouldn't be equal when their ids aren't equal");
}

@end
