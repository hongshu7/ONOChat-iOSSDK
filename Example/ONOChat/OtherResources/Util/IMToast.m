//
//  HUDManager.m
//  Mama
//
//  Created by Kevin Lai on 14-6-17.
//  Copyright (c) 2014年 rxwang. All rights reserved.
//

#import "IMToast.h"



@implementation IMToast {
    MBProgressHUD *hud;
}


+(IMToast*)sharedToast;
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
    });
    return _sharedObject;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (MBProgressHUD *)showLoading {
    return [self showLoadingWithMessage:@""];
}

- (MBProgressHUD *)showLoadingWithMessage:(NSString *)title {
    if (hud == nil || hud.tag != 1) {
        if (hud != nil) {
            [hud hideAnimated:NO];
        }
        UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
        hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
    }
    hud.label.text = title;
    return hud;
}


- (void)dismissHUD {
    [self dismissHUDDelay:0.6];
}

-(void)dismissHUDDelay:(CGFloat)time {
    if (hud != nil) {
        [self performSelector:@selector(dismissHUDImmediately) withObject:nil afterDelay:time];
    }
}

- (void)dismissHUDImmediately {
    if (hud != nil) {
        hud.customView.tag = 0;
        [hud hideAnimated:YES];
        hud = nil;
    }
    
}

- (BOOL)isShowing {
    return hud != nil;
}

-(void)cancelDismissHUD {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


// 提示相关
- (MBProgressHUD *)showMessage:(NSString *)title {
    if (hud == nil || hud.tag != 4) {
        if (hud != nil) {
            [self cancelDismissHUD];
            [hud hideAnimated:NO];
        }
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.tag = 4;
        
    }
    
    hud.label.text = title;
    [self dismissHUDDelay:1.5f];
    return hud;
}


+ (MBProgressHUD *)showLoading {
    return [[self sharedToast] showLoading];
}

+ (MBProgressHUD *)showLoadingWithMessage:(NSString *)title {
    return [[self sharedToast] showLoadingWithMessage:title];
}

+ (MBProgressHUD *)showTipMessage:(NSString *)msg {
    return [[self sharedToast] showMessage:msg];
}

+ (MBProgressHUD *)showErrorMessage:(NSString *)msg {
    return [[self sharedToast] showMessage:msg];
}

+ (void)dismissHUD {
    return [[self sharedToast] dismissHUD];
}

+ (void)dismissHUDDelay:(CGFloat)time {
    return [[self sharedToast] dismissHUDDelay:time];
}

+ (void)dismissHUDImmediately {
    return [[self sharedToast] dismissHUDImmediately];
}



@end
