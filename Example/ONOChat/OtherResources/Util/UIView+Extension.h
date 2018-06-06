//
//  UIView+Extension.h
//  MJRefreshExample
//
//  Created by MJ Lee on 14-5-28.
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic) CGFloat im_left;

@property (nonatomic) CGFloat im_top;

@property (nonatomic) CGFloat im_right;

@property (nonatomic) CGFloat im_bottom;

@property (nonatomic) CGFloat im_width;

@property (nonatomic) CGFloat im_height;

@property (nonatomic) CGFloat im_centerX;

@property (nonatomic) CGFloat im_centerY;

@property (nonatomic) CGPoint im_origin;

@property (nonatomic) CGSize im_size;

@property (nonatomic) CGPoint im_center;



+ (id)im_loadFromXIB;

+ (id)im_loadFromXIBName:(NSString *)xibName;

- (void)im_createBordersWithColor:(UIColor * _Nonnull)color withCornerRadius:(CGFloat)radius andWidth:(CGFloat)width;

@end
