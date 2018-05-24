//
//  IMViewController.m
//  ONOChat
//
//  Created by Kevin on 05/24/2018.
//  Copyright (c) 2018 Kevin. All rights reserved.
//

#import "IMViewController.h"
#import "IMClient.h"

@interface IMViewController ()

@end

@implementation IMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[IMClient sharedInstance] setupWithHost:@"101.201.236.225" port:3001];
    [[IMClient sharedInstance] loginWithToken:@"ju9es1b7w6kproa32ghqvdt0xzmfycin" onSuccess:^(UserLoginResponse *msg) {
        NSLog(@"user logined with name:%@", msg.user.name);
    } onError:^(ErrorResponse *msg) {
        NSLog(@"error %d, %@", msg.code, msg.message);
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
