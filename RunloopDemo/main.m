//
//  main.m
//  RunloopDemo
//
//  Created by ChenMan on 2018/5/17.
//  Copyright © 2018年 cimain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MainThreadMonitor.h"
int main(int argc, char * argv[]) {
    @autoreleasepool {
//        [[MainThreadMonitor sharedInstance] beginMonitor];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
