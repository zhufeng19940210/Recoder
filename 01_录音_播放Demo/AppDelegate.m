//
//  AppDelegate.m
//  01_录音_播放Demo
//
//  Created by bailing on 2017/12/27.
//  Copyright © 2017年 zhufeng. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ZFTestRecoderController.h"
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    ZFTestRecoderController *testRecoderVc = [[ZFTestRecoderController alloc]init];
    //ViewController *homeVc = [[ViewController alloc]init];
    self.window.rootViewController = testRecoderVc;
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
  
}
- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}


@end
