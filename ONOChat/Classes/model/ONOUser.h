//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ONOUser : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic) int gender;


@end
