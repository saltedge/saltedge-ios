//
//  UIControl+SELoginInputFieldsAdditions.h
//  SaltEdge API Demo
//
//  Created by nemesis on 7/22/14.
//  Copyright (c) 2016 Salt Edge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (SELoginInputFieldsAdditions)

- (BOOL)se_hasInputData;
- (id)se_inputValue;
- (void)se_highlight;

@end
