//
//  ONO Chat SDK
//
//  Created by Kevin Lai on 18/5.
//  Copyright (c) 2018 ONO Team. All rights reserved.
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
