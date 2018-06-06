//
//  IMAddNewFriendViewController.m
//  ONOChat_Example
//
//  Created by carrot__lsp on 2018/5/28.
//  Copyright © 2018年 Kevin. All rights reserved.
//

#import "IMAddNewFriendViewController.h"
#import "UIImageView+WebCache.h"
#import "IMToast.h"

#import "ONOIMClient.h"

@interface IMAddNewFriendViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UILabel *searchResultLabel;

@end

@implementation IMAddNewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"好友添加";
}

- (IBAction)searchAction {
    [[ONOIMClient sharedClient] friendSearchByKeyword:self.searchTextField.text onSuccess:^(NSArray<ONOUser *> *userArray) {
        self.dataArray = userArray;
        [self.tableView reloadData];
    } onError:^(int errorCode, NSString *errorMessage) {
        NSLog(@"%@",errorMessage);
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
    
    ONOUser *user = [self.dataArray objectAtIndex:indexPath.row];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.avatar] placeholderImage:[UIImage imageNamed:@"logo_120"]];
    cell.textLabel.text = user.nickname;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
};

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ONOUser *user = [self.dataArray objectAtIndex:indexPath.row];
    
    [[ONOIMClient sharedClient] friendAddWithUserId:user.userId andGreeting:@"你好" onSuccess:^{
        [IMToast showTipMessage:@"好友添加请求发送成功"];
    } onError:^(int errorCode, NSString *errorMessage) {
        [IMToast showTipMessage:errorMessage];
    }];
}


@end
