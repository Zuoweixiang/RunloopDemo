//
//  PingThread.m
//  RunloopDemo
//
//  Created by jmf-mac on 2021/8/30.
//  Copyright © 2021 cimain. All rights reserved.
//

#import "PingThread.h"
@interface PingThread()
@property (strong,nonatomic)NSLock *lock;
@property (assign,nonatomic)NSTimeInterval timeoutInterval;
@property (assign,atomic)NSInteger sleepCount;

@end
@implementation PingThread
@synthesize sleepCount = _sleepCount;
-(instancetype)init{
    if (self = [super init]) {
        _lock = [[NSLock alloc]init];
        _timeoutInterval = 0.5;//500 ms 唤起一次
        self.sleepCount = 0;
    }
    return  self;
}
-(void)main{
    while (!self.isCancelled) {
        @autoreleasepool {
            //子线程被唤醒
            dispatch_async(dispatch_get_main_queue(), ^{
               //主线程开始响应
                self.sleepCount = 0;
            });
            if (self.sleepCount >= 2) {//
                NSLog(@"超时%ld次",(long)self.sleepCount);
            }
            self.sleepCount = self.sleepCount +1;
            //子线程开始休眠
            [NSThread sleepForTimeInterval: self.timeoutInterval];
        }
    }
}
//
//-(void)setSleepCount:(NSInteger)sleepCount{
//    [_lock lock];
//    _sleepCount = sleepCount;
//    NSLog(@"setSleepCount:%ld",(long)sleepCount);
//    [_lock unlock];
//}
//
//-(NSInteger)sleepCount{
//    NSInteger count = 0;
//    [_lock lock];
//    count = _sleepCount;
//    [_lock unlock];
//    return count;
//}

@end
