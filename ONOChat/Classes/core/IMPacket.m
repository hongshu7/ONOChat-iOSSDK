//  Lemeng
//
//  Created by Kevin Lai on 14-8-20.
//  Copyright (c) 2014年 Xiamen justit. All rights reserved.
//

#import "IMPacket.h"

@implementation IMPacket


- (instancetype)initWithType:(IMPacketType)type andData:(NSData *)data
{
    if (self = [super init]) {
        _type = type;
        _data = data;
    }
    return self;
}

@end
