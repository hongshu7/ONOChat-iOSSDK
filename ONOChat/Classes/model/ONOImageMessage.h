//
//  ONOImageMessage.h
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import "ONOMessage.h"

@interface ONOImageMessage : ONOMessage

@property (nonatomic, strong) NSString *image;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;

@end
