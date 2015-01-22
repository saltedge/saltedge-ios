//
//  TransactionTableViewCell.m
//  Salt Edge API Demo
//
//  Created by nemesis on 9/30/14.
//  Copyright (c) 2015 Salt Edge. All rights reserved.
//

#import "TransactionTableViewCell.h"
#import "SETransaction.h"

@interface TransactionTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *madeOnDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation TransactionTableViewCell

- (void)awakeFromNib
{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)setTransaction:(SETransaction *)transaction
{
    static NSNumberFormatter* amountFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        amountFormatter = [[NSNumberFormatter alloc] init];
        amountFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        amountFormatter.currencyCode = transaction.currencyCode;
    });

    self.descriptionLabel.text = transaction.description;
    self.madeOnDateLabel.text  = [NSDateFormatter localizedStringFromDate:transaction.madeOn
                                                                dateStyle:NSDateFormatterMediumStyle
                                                                timeStyle:NSDateFormatterNoStyle];
    self.amountLabel.text      = [amountFormatter stringFromNumber:transaction.amount];
}

@end
