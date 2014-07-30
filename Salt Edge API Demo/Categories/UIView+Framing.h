//
//  UIView+Framing.h
//  AOLib
//
//  Created by Olegas on 01/05/2013.
//  Copyright (c)2013 Olegas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Framing)

@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGPoint origin;
@property (nonatomic) CGSize size;
@property (nonatomic, readonly) CGFloat bottomEdge;
@property (nonatomic, readonly) CGFloat rightEdge;
@property (nonatomic) CGFloat xOrigin;
@property (nonatomic) CGFloat yOrigin;

- (void)setSafeCenter:(CGPoint)center;
- (CGPoint)getContentCenter;

@end
