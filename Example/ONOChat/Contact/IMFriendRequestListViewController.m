//
//  IMFriendRequestListViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/5.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMFriendRequestListViewController.h"
#import "UIImageView+WebCache.h"
#import "IMFriendRequestCell.h"
#import "UIView+Extension.h"
#import "IMToast.h"

#import "ONOIMClient.h"

@interface IMFriendRequestListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation IMFriendRequestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadRequestData];
    self.navigationItem.title = @"好友请求";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadRequestData {
    [[ONOIMClient sharedClient] friendRequestListWithLimit:100 andOffset:[self currentTimeStr] onSuccess:^(NSArray<ONOFriendRequest *> *friendRequest) {
        self.dataArray = friendRequest;
        [self.tableView reloadData];
    } onError:^(int errorCode, NSString *errorMessage) {
        
    }];
}

//获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}


#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"IMFriendRequestCell";
    
    IMFriendRequestCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [IMFriendRequestCell im_loadFromXIB];
    }
    
    ONOFriendRequest *friendRequest = [self.dataArray objectAtIndex:indexPath.row];
    
    cell.friendRequest = friendRequest;
    
    __weak typeof(self) weakSelf = self;
    cell.acceptDidClicked = ^(ONOFriendRequest *friendRequest) {
        [[ONOIMClient sharedClient] friendAgreeWithUserId:friendRequest.user.userId onSuccess:^{
            [IMToast showTipMessage:@"成功接受"];
            [weakSelf loadRequestData];
        } onError:^(int errorCode, NSString *errorMessage) {
            [IMToast showTipMessage:errorMessage];
        }];
    };
    
    cell.ignoreDidClicked = ^(ONOFriendRequest *friendRequest) {
        [[ONOIMClient sharedClient] friendIgnoreWithUserId:friendRequest.user.userId onSuccess:^{
            [IMToast showTipMessage:@"成功忽略"];
            [weakSelf loadRequestData];
        } onError:^(int errorCode, NSString *errorMessage) {
            [IMToast showTipMessage:errorMessage];
        }];
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


@end
