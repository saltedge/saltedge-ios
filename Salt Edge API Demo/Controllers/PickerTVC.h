//
//  PickerTVC.h 
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PickerCompletionBlock)(id);

@interface PickerTVC : UITableViewController

+ (UINavigationController*)pickerWithItems:(NSArray*)items completionBlock:(PickerCompletionBlock)completion;

@end
