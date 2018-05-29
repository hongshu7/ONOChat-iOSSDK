//
//  UINavigationController+HM.m
//  GirlLive
//
//  Created by carrot__lsp on 16/4/18.
//  Copyright © 2016年 highma. All rights reserved.
//

#import "UINavigationController+IM.h"

@implementation UINavigationController (IM)

-(void) im_pushViewController:(UIViewController *)viewController {
    viewController.hidesBottomBarWhenPushed = YES;
    [self pushViewController:viewController animated:YES];
}

-(void) im_pop {
    [self popViewControllerAnimated:YES];
}




@end
