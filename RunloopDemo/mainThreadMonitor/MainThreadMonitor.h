//
//  MainThreadMonitor.h
//  RunloopDemo
//
//  Created by jmf-mac on 2021/8/28.
//  Copyright © 2021 cimain. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 runloop 官方文档
 https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW1
 
 yykit 大神博客
 https://blog.ibireme.com/2015/05/18/runloop/
 
 //知乎上的另一套方案
 https://github.com/music4kid/PMainThreadWatcher
 */
NS_ASSUME_NONNULL_BEGIN

@interface MainThreadMonitor : NSObject
+(instancetype)sharedInstance;
-(void)beginMonitor;
-(void)endMonitor;
@end

NS_ASSUME_NONNULL_END
