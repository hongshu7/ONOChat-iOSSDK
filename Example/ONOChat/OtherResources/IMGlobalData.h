//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ONOIMClient.h"

#define iPhoneX (CGSizeEqualToSize(CGSizeMake(375.f, 812.f), [UIScreen mainScreen].bounds.size) || CGSizeEqualToSize(CGSizeMake(812.f, 375.f), [UIScreen mainScreen].bounds.size))



@interface IMGlobalData : NSObject

+ (IMGlobalData *)sharedData;

@property (nonatomic, strong) ONOUser *user;

@end

