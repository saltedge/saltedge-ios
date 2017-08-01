//
//  TransactionTableViewCell.h
//  Salt Edge API Demo
//
//  Created by nemesis on 9/30/14.
//  Copyright (c) 2017 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SETransaction;

#define TRANSACTION_CELL_HEIGHT 75.0f

@interface TransactionTableViewCell : UITableViewCell

- (void)setTransaction:(SETransaction*)transaction;

@end
