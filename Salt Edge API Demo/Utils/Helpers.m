//
//  Helpers.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/21/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import "Helpers.h"
#import "Constants.h"
#import "OptionSelectButton.h"
#import "SEProviderField.h"

@implementation Helpers

+ (UIControl*)inputControlFromObject:(SEProviderField *)field
{
    NSString* inputFieldType = field.nature;
    id inputControl;
    if ([inputFieldType isEqualToString:SEProviderFieldTypeText] || [inputFieldType isEqualToString:SEProviderFieldTypePassword]) {
        inputControl = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 35.0)];
        [inputControl setAutocorrectionType:UITextAutocorrectionTypeNo];
        [inputControl setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [inputControl setPlaceholder:field.localizedName];
        [inputControl setBorderStyle:UITextBorderStyleRoundedRect];
        [inputControl setReturnKeyType:UIReturnKeyNext];
        if ([inputFieldType isEqualToString:SEProviderFieldTypePassword]) {
            [inputControl setSecureTextEntry:YES];
        }
    } else if ([inputFieldType isEqualToString:SEProviderFieldTypeSelect]) {
        NSArray* options = field.fieldOptions;
        inputControl = [OptionSelectButton buttonWithType:UIButtonTypeRoundedRect options:options pickerDelegate:nil];
        [inputControl setTitle:field.localizedName forState:UIControlStateNormal];
        [inputControl sizeToFit];
    } else if ([inputFieldType isEqualToString:SEProviderFieldTypeFile]) {
        inputControl = [[UILabel alloc] initWithFrame:CGRectZero];
        [inputControl setText:@"Not implemented yet"];
        [inputControl sizeToFit];
    }
    return inputControl;
}
@end
