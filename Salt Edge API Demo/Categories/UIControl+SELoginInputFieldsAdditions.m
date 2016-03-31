//
//  UIControl+SELoginInputFieldsAdditions.m
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import "UIControl+SELoginInputFieldsAdditions.h"
#import "OptionSelectButton.h"

@import QuartzCore;

@implementation UIControl (SELoginInputFieldsAdditions)

- (BOOL)se_hasInputData
{
    if ([self isMemberOfClass:UITextField.class]) {
        NSString* text = [self valueForKey:@"text"];
        return text.length > 0;
    } else if ([self isMemberOfClass:OptionSelectButton.class]) {
        OptionSelectButton* optionSelf = (OptionSelectButton*) self;
        return [optionSelf hasSelectedOption];
    }
    return YES;
}

- (id)se_inputValue
{
    if ([self isMemberOfClass:UITextField.class]) {
        return [self valueForKey:@"text"];
    } else if ([self isMemberOfClass:OptionSelectButton.class]) {
        OptionSelectButton* optionSelf = (OptionSelectButton*) self;
        return [optionSelf optionValue];
    }
    return nil;
}

- (void)se_highlight
{
    UIColor* initialControlColor = self.backgroundColor;
    CATransform3D initialTransform = self.layer.transform;
    [UIView animateWithDuration:0.25f delay:0.0 usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5f];
        self.layer.transform = CATransform3DMakeScale(1.05, 1.05, 1.0);
    } completion:^(BOOL finished){
        [UIView animateWithDuration:0.25f delay:0.0 usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.backgroundColor = initialControlColor;
            self.layer.transform = initialTransform;
        } completion:nil];
    }];
}

@end
