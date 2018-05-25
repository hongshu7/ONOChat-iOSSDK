//
//  IMSessionViewCell.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/25.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMSessionViewCell.h"

@interface IMSessionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation IMSessionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarImageView.layer.cornerRadius = 4;
    self.avatarImageView.clipsToBounds = YES;
}

- (void)setUserModel:(IMUserModel *)userModel {
    _userModel = userModel;
    self.nicknameLabel.text = userModel.name;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
