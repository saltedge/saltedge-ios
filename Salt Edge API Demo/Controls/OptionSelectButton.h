//
//  OptionSelectButton.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/23/14.
//  Copyright (c) 2017 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerDelegate;

@interface OptionSelectButton : UIButton

@property (nonatomic, weak) id <PickerDelegate> pickerDelegate;
@property (nonatomic, strong) NSArray* options;

+ (instancetype)buttonWithType:(UIButtonType)buttonType options:(NSArray*)optionsArray pickerDelegate:(id<PickerDelegate>)pickerDelegate;

- (BOOL)hasSelectedOption;
- (id)selectedOption;
- (NSNumber*)optionValue;

@end
