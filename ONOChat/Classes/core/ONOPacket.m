//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import "ONOPacket.h"

@implementation ONOPacket


- (instancetype)initWithType:(ONOPacketType)type andData:(NSData *)data
{
    if (self = [super init]) {
        _type = type;
        _data = data;
    }
    return self;
}

@end
