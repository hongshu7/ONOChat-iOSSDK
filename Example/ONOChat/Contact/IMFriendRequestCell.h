//
//  IMFriendRequestCell.h
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/6.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ONOFriendRequest.h"

@interface IMFriendRequestCell : UITableViewCell

@property (nonatomic, strong) ONOFriendRequest *friendRequest;

@property (nonatomic, copy) void (^acceptDidClicked)(ONOFriendRequest *friendRequest);

@property (nonatomic, copy) void (^ignoreDidClicked)(ONOFriendRequest *friendRequest);

@end
