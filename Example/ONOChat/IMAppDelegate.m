//
//  IMAppDelegate.m
//  ONOChat
//
//  Created by Kevin on 05/24/2018.
//  Copyright (c) 2018 Kevin. All rights reserved.
//

#import "IMAppDelegate.h"
#import "IMConversationViewController.h"
#import "IMContactViewController.h"

@implementation IMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    
    
    UITabBarItem *item1 = [[UITabBarItem alloc] initWithTitle:@"会话"
                                                        image:[[UIImage imageNamed:@"tabbar_icon_chat_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                selectedImage:[[UIImage imageNamed:@"tabbar_icon_chat_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    UITabBarItem *item2 = [[UITabBarItem alloc] initWithTitle:@"通讯录"
                                                        image:[[UIImage imageNamed:@"tabbar_icon_contact_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                selectedImage:[[UIImage imageNamed:@"tabbar_icon_contact_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    
    IMConversationViewController *conversationViewController = [[IMConversationViewController alloc] init];
    conversationViewController.tabBarItem = item1;
    UINavigationController *conversationNav = [[UINavigationController alloc] initWithRootViewController:conversationViewController];
  
    
    IMContactViewController *contactViewController = [[IMContactViewController alloc] init];
    contactViewController.tabBarItem = item2;
    UINavigationController *contactNav = [[UINavigationController alloc] initWithRootViewController:contactViewController];
    
    tabbar.viewControllers = @[conversationNav,contactNav];
    tabbar.selectedIndex = 0;
    
    self.window.rootViewController = tabbar;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
