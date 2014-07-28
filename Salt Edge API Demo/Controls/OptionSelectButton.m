//
//  OptionSelectButton.m
//  SaltEdge API Demo (No Connect)
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2014 Salt Edge. All rights reserved.
//

#import "OptionSelectButton.h"
#import "PickerTVC.h"
#import "PickerDelegate.h"
#import "SEProviderFieldOption.h"

@interface OptionSelectButton(/* Private */)

@property (nonatomic, strong) NSString* selectedOption;

@end

@implementation OptionSelectButton

+ (instancetype)buttonWithType:(UIButtonType)buttonType options:(NSArray *)optionsArray pickerDelegate:(id<PickerDelegate>)pickerDelegate
{
    OptionSelectButton* button = [super buttonWithType:buttonType];
    button.options = optionsArray;
    button.pickerDelegate = pickerDelegate;
    return button;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSAssert(self.options.count > 1, @"There have to be at least two options");
    NSAssert(self.pickerDelegate != nil, @"Picker delegate can't be nil");

    if ([self.pickerDelegate respondsToSelector:@selector(presentPickerWithOptions:withCompletionBlock:)]) {
        NSArray* options = [self.options valueForKeyPath:@"localizedName"];
        [self.pickerDelegate presentPickerWithOptions:options withCompletionBlock:^(id selectedOption) {
            self.selectedOption = selectedOption;
            [self setTitle:[selectedOption description] forState:UIControlStateNormal];
        }];
    }
    [super touchesEnded:touches withEvent:event];
}

- (BOOL)hasSelectedOption
{
    return self.selectedOption != nil;
}

- (id)selectedOption
{
    return _selectedOption;
}

- (NSNumber*)optionValue
{
    NSNumber* optionValue = nil;
    for (SEProviderFieldOption* option in self.options) {
        if([option.localizedName isEqualToString:self.selectedOption]) {
            optionValue = option.optionValue;
        }
    }
    return optionValue;
}


@end
