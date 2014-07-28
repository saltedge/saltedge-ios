//
//  UIView+Framing.m
//  AOLib
//
//  Created by Olegas on 01/05/2013.
//  Copyright (c)2013 Olegas. All rights reserved.
//

#import "UIView+Framing.h"

@implementation UIView (Framing)

- (CGFloat)height{
    return self.frame.size.height;
}

- (CGFloat)width{
    return self.frame.size.width;
}

- (CGSize)size{
    return self.frame.size;
}

- (CGPoint)origin{
    return self.frame.origin;
}

- (CGFloat)bottomEdge{
    return (self.frame.origin.y + self.frame.size.height);
}

- (CGFloat)rightEdge{
    return (self.frame.origin.x + self.frame.size.width);
}

- (CGFloat)xOrigin{
    return self.frame.origin.x;
}

- (CGFloat)yOrigin{
    return self.frame.origin.y;
}

- (void)setOrigin:(CGPoint)origin{
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setSize:(CGSize)size{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

- (void)setSafeCenter:(CGPoint)center{
    self.center = center;
    self.frame = CGRectIntegral(self.frame);
}

- (void)setWidth:(CGFloat)width{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, self.frame.size.height);
}

- (void)setHeight:(CGFloat)height{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (void)setXOrigin:(CGFloat)xOrigin{
    self.frame = CGRectMake(xOrigin, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setYOrigin:(CGFloat)yOrigin{
    self.frame = CGRectMake(self.frame.origin.x, yOrigin, self.frame.size.width, self.frame.size.height);
}

- (CGPoint)getContentCenter{
    CGPoint value = CGPointMake(floorf(self.frame.size.width/2), floorf(self.frame.size.height/2));
    return value;
}

@end
