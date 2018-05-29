//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//


#import "IMGlobalData.h"

@implementation IMGlobalData


+ (IMGlobalData *)sharedData {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[IMGlobalData alloc] init];
    });
    return _sharedObject;
}


@end
