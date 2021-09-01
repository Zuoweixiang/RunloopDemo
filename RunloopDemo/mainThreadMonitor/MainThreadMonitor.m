//
//  MainThreadMonitor.m
//  RunloopDemo
//
//  Created by jmf-mac on 2021/8/28.
//  Copyright © 2021 cimain. All rights reserved.
//

#import "MainThreadMonitor.h"

static MainThreadMonitor * sharedMonitor;

@interface MainThreadMonitor(){
    CFRunLoopObserverRef _observerRef;
    dispatch_queue_t _monitorQueue;
    BOOL _isMonitoring;
    dispatch_semaphore_t _semaphore;
    CFRunLoopActivity _runLoopActivity;
}
@end
@implementation MainThreadMonitor
+(instancetype)sharedInstance{
//    static MainThreadMonitor *monitor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMonitor = [[self alloc]init];
    });
    return sharedMonitor;
}
-(instancetype)init{
    if (self = [super init]) {
        _monitorQueue = dispatch_queue_create("com.xzw.runloop.monitor", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)beginMonitor{
    /*
     typedef struct {
         CFIndex    version;
         void *    info;
         const void *(*retain)(const void *info);
         void    (*release)(const void *info);
         CFStringRef    (*copyDescription)(const void *info);
     } CFRunLoopObserverContext;
     */
//    CFRunLoopObserverContext context = (CFRunLoopObserverContext){0,(__bridge void*)self,NULL,NULL,NULL };
    _isMonitoring = YES;
    CFRunLoopObserverContext context = (CFRunLoopObserverContext){0,(__bridge void*)self,contextRetain,contextRelease,NULL };
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, myCFRunLoopObserverCallBack, &context);
    CFRunLoopAddObserver(CFRunLoopGetMain(), observerRef, kCFRunLoopCommonModes);
    _observerRef = observerRef;
    observerRef = nil;
    
    _semaphore = dispatch_semaphore_create(0);
    dispatch_async(self->_monitorQueue, ^{
        do {
            long status = dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, 1000*NSEC_PER_MSEC));
            if (status != 0) {//runloop 状态长时间没更新
                if (self->_runLoopActivity == kCFRunLoopBeforeSources || self->_runLoopActivity == kCFRunLoopAfterWaiting) {    // 发生卡顿,记录卡顿次数
                    NSLog(@" 检查到有卡顿");
                }
            }
        } while (_isMonitoring);
    });
}

-(void)endMonitor{
    _isMonitoring = NO;
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _observerRef, kCFRunLoopCommonModes);
    CFRelease(_observerRef);
    _observerRef = NULL;
   
}
#pragma mark --context callback
const void* contextRetain(const void * info){
    return info;
}
void contextRelease(const void * info){
    NSLog(@"%s",__PRETTY_FUNCTION__);
}
CFStringRef   contextCopyDescription(const void *info){
    
    return CFStringCreateCopy(kCFAllocatorDefault, CFSTR("dfdfdsfd"));
}

#pragma mark --observer callback
void myCFRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    switch(activity)
    {
            // 即将进入Loop
        case kCFRunLoopEntry:
            NSLog(@"run loop entry");
            break;
        case kCFRunLoopBeforeTimers://即将处理 Timer
            NSLog(@"run loop before timers");
            break;
        case kCFRunLoopBeforeSources://即将处理 Source
            NSLog(@"run loop before sources");
            break;
        case kCFRunLoopBeforeWaiting://即将进入休眠
            NSLog(@"run loop before waiting");
            break;
        case kCFRunLoopAfterWaiting://刚从休眠中唤醒
            NSLog(@"run loop after waiting");
            break;
        case kCFRunLoopExit://即将退出Loop
            NSLog(@"run loop exit");
            break;
        default:
            break;
    }
    CFRunLoopObserverContext context = {};
    CFRunLoopObserverGetContext( observer, &context);
    MainThreadMonitor *monitor = (__bridge MainThreadMonitor *)info;
    monitor->_runLoopActivity = activity;
    dispatch_semaphore_t semaphore = monitor->_semaphore;
    dispatch_semaphore_signal(semaphore);
    
    NSLog(@"%s   iswaiting____:%d",__PRETTY_FUNCTION__,CFRunLoopIsWaiting(CFRunLoopGetMain()));
    if (activity == kCFRunLoopBeforeSources || activity == kCFRunLoopAfterWaiting) {
        // 发生卡顿,记录卡顿次数
        NSLog(@"run loop after waiting");

    }

}

@end
