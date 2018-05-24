//
//  ONOImageMessage.h
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOBaseMessage.h"

@interface ONOImageMessage : ONOBaseMessage

@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

@end
