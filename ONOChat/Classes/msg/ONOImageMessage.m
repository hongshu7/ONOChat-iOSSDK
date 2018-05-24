//
//  ONOImageMessage.m
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOImageMessage.h"

@implementation ONOImageMessage

- (NSInteger)type {
    return 2;
}

- (NSString *)content {
    return @"[图片]";
}

- (NSString *)data {
    return [NSString stringWithFormat:@"%@,%d,%d", self.image, self.width, self.height];
}

@end
