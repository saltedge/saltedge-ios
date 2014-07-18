//
//  NSURL+SBCallbacksAdditions.m
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "NSURL+SBCallbacksAdditions.h"

@implementation NSURL (SBCallbacksAdditions)

- (BOOL)sb_isCallbackURL
{
    return [self.scheme isEqualToString:SBCallbackScheme] && [self.host isEqualToString:SBCallbackHost];
}

- (NSDictionary*)sb_callbackParametersWithError:(NSError**)error
{
    if (!self.sb_isCallbackURL) { return nil; }
    NSString* jsonString = [self.path substringFromIndex:1];
    if (!jsonString.length) { return nil; }
    NSData* jsonStringData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:jsonStringData options:0 error:error];
}

@end
