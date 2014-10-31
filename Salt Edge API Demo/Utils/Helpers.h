//
//  Helpers.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestOperationManager, SEProviderField;

@interface Helpers : NSObject

+ (UIControl*)inputControlFromObject:(SEProviderField*)dictionary;

@end
