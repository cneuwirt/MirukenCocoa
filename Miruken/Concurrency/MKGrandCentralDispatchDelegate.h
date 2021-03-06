//
//  MKGrandCentralDispatchDelegate.h
//  Miruken
//
//  Created by Craig Neuwirt on 4/16/13.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKAsyncDelegate_Subclassing.h"

/**
  Defines the concurrency strategy for executing an invocation using GCD.
 */

@interface MKGrandCentralDispatchDelegate : MKAsyncDelegate

+ (instancetype)dispatchMainQueue;

+ (instancetype)dispatchGlobalQueue;

+ (instancetype)dispatchGlobalQueueWithPriority:(long)priority;

+ (instancetype)dispatchGlobalQueueWithDelay:(NSTimeInterval)delay;

+ (instancetype)dispatchQueue:(dispatch_queue_t)queue;

+ (instancetype)barrierQueue:(dispatch_queue_t)queue;

@end
