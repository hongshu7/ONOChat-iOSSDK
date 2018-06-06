//
//  IMContactCell.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMContactCell.h"
#import "UIImageView+WebCache.h"

@interface IMContactCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation IMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setUser:(ONOUser *)user {
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    self.nicknameLabel.text = user.nickname;
}

@end
