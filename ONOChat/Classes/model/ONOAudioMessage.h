//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import "ONOMessage.h"

@interface ONOAudioMessage : ONOMessage

@property (nonatomic, strong) NSString *audio;
@property (nonatomic, assign) int duration;

@end
