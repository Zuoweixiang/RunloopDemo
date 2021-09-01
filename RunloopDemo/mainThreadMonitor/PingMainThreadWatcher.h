//
//  PingMainThreadWatcher.h
//  RunloopDemo
//
//  Created by jmf-mac on 2021/9/1.
//  Copyright © 2021 cimain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PingMainThreadDelegate <NSObject>
-(void)onMainThreadSlow;
@end
@interface PingMainThreadWatcher : NSObject

+(instancetype)sharedInstance;

@property(nonatomic,weak)id<PingMainThreadDelegate>delegate;
-(void)startMonitor;
-(void)endMonitor;
@end

NS_ASSUME_NONNULL_END
