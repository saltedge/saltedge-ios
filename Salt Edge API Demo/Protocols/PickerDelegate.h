//
//  PickerDelegate.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PickerCompletionBlock)(id);

@class PickerTableViewController;

@protocol PickerDelegate <NSObject>

- (void)presentPickerWithOptions:(NSArray*)options withCompletionBlock:(PickerCompletionBlock)completionBlock;

@end
