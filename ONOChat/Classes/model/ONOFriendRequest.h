//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 5/6.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ONOUser;

@interface ONOFriendRequest : NSObject

@property (nonatomic, strong) ONOUser *user;
@property (nonatomic, strong) NSString *greeting;

@end
