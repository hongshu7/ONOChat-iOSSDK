//  Lemeng
//
//  Created by Kevin Lai on 14-8-20.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
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