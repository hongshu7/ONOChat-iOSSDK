//
//  UIView+Extension.m
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (CGFloat)im_left
{
    return self.frame.origin.x;
}

- (void)setim_left:(CGFloat)left
{
    CGRect frame = self.frame;
    if(frame.origin.x != left)
    {
        frame.origin.x = left;
        self.frame = frame;
    }
}

- (CGFloat)im_top
{
    return self.frame.origin.y;
}

- (void)setim_top:(CGFloat)top
{
    CGRect frame = self.frame;
    if(frame.origin.y != top)
    {
        frame.origin.y = top;
        self.frame = frame;
    }
}

- (CGFloat)im_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setim_right:(CGFloat)right
{
    CGRect frame = self.frame;
    CGFloat newRight = right - frame.size.width;
    if(frame.origin.x != newRight)
    {
        frame.origin.x = newRight;
        self.frame = frame;
    }
}

- (CGFloat)im_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setim_bottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    CGFloat newBottom = bottom - frame.size.height;
    if(frame.origin.y != newBottom)
    {
        frame.origin.y = newBottom;
        self.frame = frame;
    }
}

- (CGFloat)im_centerX
{
    return self.center.x;
}

- (void)setim_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    if(center.x != centerX)
    {
        center.x = centerX;
        self.center = center;
    }
}

- (CGFloat)im_centerY
{
    return self.center.y;
}

- (void)setim_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    if(center.y != centerY)
    {
        center.y = centerY;
        self.center = center;
    }
}

- (CGFloat)im_width
{
    return self.frame.size.width;
}

- (void)setim_width:(CGFloat)width
{
    if (isnan(width))
    {
        width = 0;
    }
    CGRect frame = self.frame;
    if(frame.size.width != width)
    {
        frame.size.width = width;
        self.frame = frame;
    }
}

- (CGFloat)im_height
{
    return self.frame.size.height;
}

- (void)setim_height:(CGFloat)height
{
    if (isnan(height))
    {
        height = 0;
    }
    CGRect frame = self.frame;
    if(frame.size.height != height)
    {
        frame.size.height = height;
        self.frame = frame;
    }
}

- (CGSize)im_size
{
    return self.frame.size;
}

- (void)setim_size:(CGSize)size
{
    CGRect frame = self.frame;
    if(CGSizeEqualToSize(frame.size, size) == NO)
    {
        frame.size = size;
        self.frame = frame;
    }
}

- (CGPoint)im_origin
{
    return self.frame.origin;
}

- (void)setim_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    if(CGPointEqualToPoint(frame.origin, origin) == NO)
    {
        frame.origin = origin;
        self.frame = frame;
    }
}

-(CGPoint)im_center
{
    CGRect frame = self.frame;
    return CGPointMake(frame.size.width/2 + frame.origin.x, frame.size.height/2 + frame.origin.y);
}

-(void)setim_center:(CGPoint)center
{
    CGRect frame = self.frame;
    self.frame = CGRectMake(center.x - frame.size.width / 2, center.y - frame.size.height / 2, frame.size.width, frame.size.height);
}


+ (id)im_loadFromXIB
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

+ (id)im_loadFromXIBName:(NSString *)xibName
{
    return [[[NSBundle mainBundle] loadNibNamed:xibName owner:nil options:nil] lastObject];
}

- (void)im_createBordersWithColor:(UIColor * _Nonnull)color withCornerRadius:(CGFloat)radius andWidth:(CGFloat)width {
    self.layer.borderWidth = width;
    self.layer.cornerRadius = radius;
    self.layer.shouldRasterize = NO;
    self.layer.rasterizationScale = 2;
    self.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    self.clipsToBounds = YES;
    self.layer.masksToBounds = YES;
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGColorRef cgColor = [color CGColor];
    self.layer.borderColor = cgColor;
    CGColorSpaceRelease(space);
}

@end
