//
//  SERequestHandlerURLSessionDelegate.h
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 6/9/16.
//  Copyright © 2016 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SERequestHandlerURLSessionDelegate : NSObject <NSURLSessionDelegate>

+ (instancetype)sharedInstance;

@end
