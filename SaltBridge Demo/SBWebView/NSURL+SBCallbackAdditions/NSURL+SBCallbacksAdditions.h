//
//  NSURL+SBCallbacksAdditions.h
//  SaltBridge Demo
//
//  Created by nemesis on 7/17/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const SBCallbackScheme = @"saltbridge";
static NSString* const SBCallbackHost   = @"connect";

@interface NSURL (SBCallbacksAdditions)

- (BOOL)sb_isCallbackURL;
- (NSDictionary*)sb_callbackParametersWithError:(NSError**)error;

@end
