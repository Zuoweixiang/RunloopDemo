//
//  PingMainThreadWatcher.m
//  RunloopDemo
//
//  Created by jmf-mac on 2021/9/1.
//  Copyright © 2021 cimain. All rights reserved.
//
#include <signal.h>
#include <pthread.h>
#import "PingMainThreadWatcher.h"
#import <UIKit/UIKit.h>
@interface PingMainThreadWatcher()
{
    pthread_t _mainThread ;
}
@property (nonatomic, strong) dispatch_source_t pingTimer;
@property (nonatomic, strong) dispatch_source_t pongTimer;
@property (nonatomic, strong) dispatch_queue_t pingQueue;

@end
@implementation PingMainThreadWatcher

void signalHander(int sig){
    static int count = 1;
    count++;
    //收到主线程消息回调
    if (sig != SIGUSR1) {
        return;
    }
//    if (count>50) {
//        UIAlertView *view = [[UIAlertView alloc]initWithTitle:@"主线程超时" message:[NSString stringWithFormat:@"sig:%d,count:%d",sig,count] delegate:nil cancelButtonTitle:@"" otherButtonTitles:@"success" , nil];
//        [view show];
//        
//    }
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSAllLibrariesDirectory, NSUserDomainMask, YES);
   NSString *path = paths[0];
   path = [path stringByAppendingPathComponent:@"main_thread_monitor.log"];
    if (![NSFileManager.defaultManager fileExistsAtPath:path]) {
        [NSFileManager.defaultManager createFileAtPath:path contents:nil attributes:nil];
    }

   NSString *info = [NSString stringWithFormat:@"\ntime:%ld,sig:%d,count:%d\n",(NSInteger)NSDate.date.timeIntervalSince1970*1000,sig,count];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    if (@available(iOS 13.0, *)) {
        [handle seekToEndReturningOffset:NULL error:NULL];
    } else {
        // Fallback on earlier versions
        [handle seekToEndOfFile];
    }
    [handle writeData:[info dataUsingEncoding:NSUTF8StringEncoding]];
   // [info writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"recieve siguser1:%d",sig);
    
}

+(instancetype)sharedInstance{
    static PingMainThreadWatcher *watcher = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        watcher = [[PingMainThreadWatcher alloc]init];
        watcher.pingQueue = dispatch_queue_create("com.ping.queue", DISPATCH_QUEUE_SERIAL);
    });
    return watcher;
}

-(void)startMonitor{
    if (pthread_main_np()==0) {
        NSLog(@" should call on main thread");
        return;
    }
    self->_mainThread = pthread_self();
    //每秒ping一次
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.pingQueue);
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1* NSEC_PER_SEC, 0.01* NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        //在子线程 ping
        [self pingMainThread];
        NSInteger ms = NSDate.date.timeIntervalSince1970*1000;
        NSLog(@"handle ==========:%ld",ms);
    });
    dispatch_resume(timer);
    self.pingTimer = timer;
    //注册用户信号
    signal(SIGUSR1, signalHander);
}
-(void)endMonitor{
    signal(SIGUSR1, SIG_DFL);
    if (self.pingTimer) {
        dispatch_cancel(self.pingTimer);
    }
    if (self.pongTimer) {
        dispatch_cancel(self.pongTimer);
    }
}

-(void)pingMainThread{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.pingQueue);
    //16 ms pong 一次
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.016 * NSEC_PER_SEC, 0.0000016 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [self onPongTimeout];
    });
    dispatch_resume(timer);
    self.pongTimer = timer;
    dispatch_async(dispatch_get_main_queue(), ^{
        //主线程 pong
        [self pong];
    });
}

-(void)pong{
    if (self.pongTimer) {
        dispatch_cancel(self.pongTimer);
        _pongTimer = nil;
    }
}

-(void)onPongTimeout{
    //超时给主线程发 SIGUSR1 消息
    pthread_kill(self->_mainThread, SIGUSR1);

    
    
}

@end
