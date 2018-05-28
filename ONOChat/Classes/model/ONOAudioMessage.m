//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
//

#import "ONOAudioMessage.h"

@implementation ONOAudioMessage


- (NSInteger)type {
    return 3;
}

- (NSString *)encode {
    return [NSString stringWithFormat:@"%@,%d", self.audio, self.duration];
}

- (void)decode:(NSString *)data {
    NSArray<NSString *> *arrays = [data componentsSeparatedByString:@","];
    self.audio = arrays[0];
    self.duration = arrays[1].intValue;
}

- (NSString *)description {
    return @"[语音]";
}

@end
