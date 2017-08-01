//
//  SingleLoginAttemptTVC.h
//  Salt Edge API Demo
//
//  Created by Constantin Lungu on 2/4/16.
//  Copyright (c) 2017 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SELoginAttempt;

@interface SingleLoginAttemptTVC : UITableViewController

@property (nonatomic, strong) SELoginAttempt* attempt;
@property (nonatomic, strong) NSString* loginSecret;

@end
