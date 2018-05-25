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

- (NSString *)encode {
    return [NSString stringWithFormat:@"%@,%d,%d", self.image, self.width, self.height];
}

- (void)decode:(NSString *)data {
    NSArray<NSString *> *arrays = [data componentsSeparatedByString:@","];
    self.image = arrays[0];
    self.width = arrays[1].intValue;
    self.height = arrays[2].intValue;
}

- (NSString *)description {
    return @"[图片]";
}

@end
