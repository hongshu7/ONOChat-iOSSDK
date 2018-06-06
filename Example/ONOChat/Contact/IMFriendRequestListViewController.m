//
//  IMFriendRequestListViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/6/5.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMFriendRequestListViewController.h"
#import "UIImageView+WebCache.h"

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)loadRequestData {
    [[ONOIMClient sharedClient] friendRequestListWithLimit:100 andOffset:@"" onSuccess:^(NSArray<ONOFriendRequest *> *friendRequest) {
        self.dataArray = friendRequest;
        [self.tableView reloadData];
    } onError:^(int errorCode, NSString *errorMessage) {
        
    }];
}

#pragma mark - tableView about

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"UITableViewCell";
    
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    ONOFriendRequest *friendRequest = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:friendRequest.user.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    cell.textLabel.text = friendRequest.user.nickname;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


@end
