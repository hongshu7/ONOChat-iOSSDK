//
//  ONOAudioMesssage.m
//  ONOChat
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOAudioMesssage.h"

@implementation ONOAudioMesssage

- (NSInteger)type {
    return 3;
}

- (NSString *)content {
    return @"[语音]";
}

- (NSString *)data {
    return [NSString stringWithFormat:@"%@,%d", self.audio, self.duration];
}

@end
