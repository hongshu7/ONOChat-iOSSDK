//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//


#import "IMGlobalData.h"
#import "IMChatManager.h"
#import "IMLoginViewController.h"

@implementation IMGlobalData


+ (IMGlobalData *)sharedData {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[IMGlobalData alloc] init];
    });
    return _sharedObject;
}

- (void)logout {
    self.token = nil;
    self.user = nil;
    [[IMChatManager sharedChatManager] stopListenOtherMessage];
    [[ONOIMClient sharedClient] logout];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    window.rootViewController = [IMLoginViewController new];
    
}

@end
