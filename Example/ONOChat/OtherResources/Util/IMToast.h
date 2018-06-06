//
//  HUDManager.h
//  Mama
//
//  Created by Kevin Lai on 14-6-17.
//  Copyright (c) 2014年 rxwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD/MBProgressHUD.h"

@interface IMToast : NSObject

@property (weak, atomic)UIView* currentHUDView;
@property (nonatomic) BOOL show;


+ (MBProgressHUD *)showLoading;
+ (MBProgressHUD *)showLoadingWithMessage:(NSString *)title;
+ (MBProgressHUD *)showTipMessage:(NSString *)msg;
+ (MBProgressHUD *)showErrorMessage:(NSString *)msg;

+ (void)dismissHUD;
+ (void)dismissHUDDelay:(CGFloat)time;
+ (void)dismissHUDImmediately;

@end

