//
//  SERequestHandlerURLSessionDelegate.h
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 6/9/16.
//  Copyright (c) 2017 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SERequestHandlerURLSessionDelegate : NSObject <NSURLSessionDelegate>

+ (instancetype)sharedInstance;

@end
