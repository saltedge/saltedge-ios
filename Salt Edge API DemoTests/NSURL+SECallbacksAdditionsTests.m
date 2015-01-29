//
//  NSURL+SECallbacksAdditionsTests.m
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSURL+SECallbacksAdditions.h"

@interface NSURL_SECallbacksAdditionsTests : XCTestCase

@end

@implementation NSURL_SECallbacksAdditionsTests

static NSURL* homeURL, *emptyCallbackURL;

- (void)setUp
{
    [super setUp];
    // A usual URL - the SaltEdge home page
    homeURL = [[NSURL alloc] initWithScheme:@"https" host:@"www.saltedge.com" path:@"/"];

    // A simple SaltBridge callback URL with no data
    emptyCallbackURL = [[NSURL alloc] initWithScheme:SECallbackScheme host:SECallbackHost path:@"/"];
}

- (void)tearDown
{
    homeURL = nil;
    emptyCallbackURL = nil;
    [super tearDown];
}

- (void)testSe_isCallbackURL
{
    NSURL* badHostCallbackURL   = [[NSURL alloc] initWithScheme:SECallbackScheme host:@"www.saltedge.com" path:@"/"];
    NSURL* badSchemeCallbackURL = [[NSURL alloc] initWithScheme:@"https" host:SECallbackHost path:@"/"];

    XCTAssertTrue(emptyCallbackURL.se_isCallbackURL, @"URL having the callback scheme should be a SaltBridge callback URL");
    XCTAssertFalse(homeURL.se_isCallbackURL, @"Usual URL without the callback scheme shouldn't be a SaltBridge callback URL");
    XCTAssertFalse(badHostCallbackURL.se_isCallbackURL, @"URL with host not being connect shouldn't be a SaltBridge callback URL");
    XCTAssertFalse(badSchemeCallbackURL.se_isCallbackURL, @"URL with scheme not being saltbridge shouldn't be a SaltBridge callback URL");
}

- (void)testSe_callbackParameters
{
    NSError* error = nil;
    NSURL* successCallbackURL = [[NSURL alloc] initWithScheme:SECallbackScheme host:SECallbackHost path:@"/{\"data\":{\"login_id\":22, \"state\":\"success\"}}"];
    NSURL* badCallbackURL = [[NSURL alloc] initWithScheme:SECallbackScheme host:SECallbackHost path:@"/Not a valid JSON string"];
    NSDictionary* expectedCallbackParameters = @{ @"data" : @{ @"login_id": @22, @"state" : @"success" } };
    BOOL successCallbacksEqual = [[successCallbackURL se_callbackParametersWithError:&error] isEqualToDictionary:expectedCallbackParameters];

    // Succcess callback URL
    XCTAssertNil(error, @"Error should be nil due to success of successful callback parameters serialization");
    XCTAssertTrue(successCallbacksEqual, @"The parameters should be equal to those given in the path string");

    // Home URL
    XCTAssertNil([homeURL se_callbackParametersWithError:&error], @"Usual URL without the callback scheme should not have any callback parameters in it");
    XCTAssertNil(error, @"Error should be nil due to the fact that the URL isn't a SaltBridge callback URL");

    // Empty callback URL
    XCTAssertNil([emptyCallbackURL se_callbackParametersWithError:&error], @"The empty callback URL should have an empty parameter list in it's path");
    XCTAssertNil(error, @"Error should be empty due to the fact that callback parameters string is empty");

    // Bad callback URL
    XCTAssertNil([badCallbackURL se_callbackParametersWithError:&error], @"An invalid JSON string in the callback parameters should return nil");
    XCTAssertNotNil(error, @"Error shouldn't be nil due to the fact that the JSON string couldn't be serialized into an object");
    XCTAssertEqual(error.code, 3840, @"The error code should be a NSPropertyListReadCorruptError");
    XCTAssertEqual(error.domain, NSCocoaErrorDomain, @"Error's domain should be NSCocoaErrorDomain");
}

@end
