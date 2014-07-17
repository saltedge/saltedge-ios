//
//  NSURL+SBCallbacksAdditionsTests.m
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+SBCallbacksAdditions.h"

@interface NSURL_SBCallbacksAdditionsTests : XCTestCase

@end

@implementation NSURL_SBCallbacksAdditionsTests

static NSURL* homeURL, *emptyCallbackURL;

- (void)setUp
{
    [super setUp];
    // A usual URL - the SaltEdge home page
    homeURL = [[NSURL alloc] initWithScheme:@"https" host:@"www.saltedge.com" path:@"/"];

    // A simple SaltBridge callback URL with no data
    emptyCallbackURL = [[NSURL alloc] initWithScheme:SBCallbackScheme host:SBCallbackHost path:@"/"];
}

- (void)tearDown
{
    homeURL = nil;
    emptyCallbackURL = nil;
    [super tearDown];
}

- (void)testSb_isCallbackURL
{
    NSURL* badHostCallbackURL   = [[NSURL alloc] initWithScheme:SBCallbackScheme host:@"www.saltedge.com" path:@"/"];
    NSURL* badSchemeCallbackURL = [[NSURL alloc] initWithScheme:@"https" host:SBCallbackHost path:@"/"];

    XCTAssertTrue(emptyCallbackURL.sb_isCallbackURL, @"URL having the callback scheme should be a SaltBridge callback URL");
    XCTAssertFalse(homeURL.sb_isCallbackURL, @"Usual URL without the callback scheme shouldn't be a SaltBridge callback URL");
    XCTAssertFalse(badHostCallbackURL.sb_isCallbackURL, @"URL with host not being connect shouldn't be a SaltBridge callback URL");
    XCTAssertFalse(badSchemeCallbackURL.sb_isCallbackURL, @"URL with scheme not being saltbridge shouldn't be a SaltBridge callback URL");
}

- (void)testSb_callbackParameters
{
    NSError* error = nil;
    NSURL* successCallbackURL = [[NSURL alloc] initWithScheme:SBCallbackScheme host:SBCallbackHost path:@"/{\"login_id\":22, \"state\":\"success\"}"];
    NSURL* badCallbackURL = [[NSURL alloc] initWithScheme:SBCallbackScheme host:SBCallbackHost path:@"/Not a valid JSON string"];
    NSDictionary* expectedCallbackParameters = @{ @"login_id": @22, @"state" : @"success" };
    BOOL successCallbacksEqual = [[successCallbackURL sb_callbackParametersWithError:&error] isEqualToDictionary:expectedCallbackParameters];

    // Succcess callback URL
    XCTAssertNil(error, @"Error should be nil due to success of successful callback parameters serialization");
    XCTAssertTrue(successCallbacksEqual, @"The parameters should be equal to those given in the path string");

    // Home URL
    XCTAssertNil([homeURL sb_callbackParametersWithError:&error], @"Usual URL without the callback scheme should not have any callback parameters in it");
    XCTAssertNil(error, @"Error should be nil due to the fact that the URL isn't a SaltBridge callback URL");

    // Empty callback URL
    XCTAssertNil([emptyCallbackURL sb_callbackParametersWithError:&error], @"The empty callback URL should have an empty parameter list in it's path");
    XCTAssertNil(error, @"Error should be empty due to the fact that callback parameters string is empty");

    // Bad callback URL
    XCTAssertNil([badCallbackURL sb_callbackParametersWithError:&error], @"An invalid JSON string in the callback parameters should return nil");
    XCTAssertNotNil(error, @"Error shouldn't be nil due to the fact that the JSON string couldn't be serialized into an object");
    XCTAssertEqual(error.code, 3840, @"The error code should be a NSPropertyListReadCorruptError");
    XCTAssertEqual(error.domain, NSCocoaErrorDomain, @"Error's domain should be NSCocoaErrorDomain");
}

@end
