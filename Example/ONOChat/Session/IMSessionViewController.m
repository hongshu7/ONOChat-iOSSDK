//
//  IMSessionViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/25.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMSessionViewController.h"
#import "IMUserModel.h"
#import "IMSessionViewCell.h"
#import "IMChatViewController.h"

#import "ONOIMClient.h"
#import "ONOTextMessage.h"


@interface IMSessionViewController ()

@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IMSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 模拟两个用户
    IMUserModel *userOne = [[IMUserModel alloc] init];
    userOne.userId = @"carrot";
    userOne.token = @"ju9es1b7w6kproa32ghqvdt0xzmfycin";
    
    IMUserModel *userTwo = [[IMUserModel alloc] init];
    userTwo.userId = @"carrot2";
    userTwo.token = @"jkdlpx7830zuan4gr5o1f9sivmwbq2he";
    
// 7d98kx2b5qulfzgsv4ma3rjnhwic06p1    carrot3
    
    // iPhoneX
    self.dataArray = @[userTwo];
    [self LoginByUser:userOne];
    
    
    // iPhone8P
//    self.dataArray = @[userOne];
//    [self LoginByUser:userTwo];
    
    [self.tableView reloadData];
}

- (void)LoginByUser:(IMUserModel *)userModel {
    [[ONOIMClient sharedClient] setupWithHost:@"101.201.236.225" port:3001];
    [[ONOIMClient sharedClient] loginWithToken:userModel.token onSuccess:^(UserLoginResponse *msg) {
        NSLog(@"user logined with name:%@", msg.user.name);
    } onError:^(ErrorResponse *msg) {
        NSLog(@"error %d, %@", msg.code, msg.message);
    }];
    
    self.navigationItem.title = userModel.userId;
}

#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IMSessionViewCell";
    
    IMSessionViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([IMSessionViewCell class]) owner:nil options:nil] lastObject];
    }
    cell.userModel = [self.dataArray objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IMChatViewController *vc = [[IMChatViewController alloc] init];
    vc.toUserModel = [self.dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
