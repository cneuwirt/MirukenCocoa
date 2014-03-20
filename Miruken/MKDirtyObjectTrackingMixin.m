//
//  MKDirtyTrackingMixin.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/12/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKDirtyObjectTrackingMixin.h"
#import "MKDirtyMixin.h"
#import "EXTScope.h"
#import <objc/runtime.h>

static int             kDirtyTrackingContext;
static NSString *const kIsDirtyProperty = @"isDirty";

@implementation MKDirtyObjectTrackingMixin

- (NSMutableArray *)MKDirtyObjectTracking_trackings
{
    return objc_getAssociatedObject(self, @selector(MKDirtyObjectTracking_trackings));
}

#pragma mark - DirtyTracking

- (MKDirtyUntrackObject)trackObject:(NSObject *)object
{
    if (object == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"object cannot be nil"
                                     userInfo:nil];
    
    if ([object respondsToSelector:@selector(isDirty)] == NO)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"object must respond to isDirty"
                                     userInfo:nil];
    
    if ([self respondsToSelector:@selector(objectBecameDirty:)])
    {
        NSMutableArray *trackings = [self MKDirtyObjectTracking_trackings];
        if (trackings == nil)
        {
            trackings = [NSMutableArray new];
            objc_setAssociatedObject(self, @selector(MKDirtyObjectTracking_trackings), trackings,
                                     OBJC_ASSOCIATION_RETAIN);
        }
        else
        {
            for (NSObject *tracking in trackings)
                if (tracking == object)
                    return nil;
        }

        [object addObserver:self forKeyPath:kIsDirtyProperty options:0 context:&kDirtyTrackingContext];
        [trackings addObject:object];
        
        if ([self respondsToSelector:@selector(didBeginTrackingObject:)])
            [self didBeginTrackingObject:object];
        
        @weakify(self);
        return ^{
            @strongify(self);
            [self untrackObject:object];
        };
    }
    return ^{};
}

- (void)trackObjects:(id<NSFastEnumeration>)objects
{
    for (NSObject *object in objects)
        [self trackObject:object];
}

- (void)untrackObject:(NSObject *)object
{
    if (object == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"object cannot be nil"
                                     userInfo:nil];

    NSMutableArray *trackings = [self MKDirtyObjectTracking_trackings];
    for (NSInteger idx = 0; idx < trackings.count; ++idx)
        if (trackings[idx] == object)
        {
            [object removeObserver:self forKeyPath:kIsDirtyProperty context:&kDirtyTrackingContext];
            [trackings removeObjectAtIndex:idx];
            
            if ([self respondsToSelector:@selector(didEndTrackingObject:)])
                [self didEndTrackingObject:object];
        }
}

- (void)untrackObjects:(id<NSFastEnumeration>)objects
{
    for (NSObject *object in objects)
        [self untrackObject:object];
}

- (void)untrackAllObjects
{
    BOOL notifyEnd            = [self respondsToSelector:@selector(didEndTrackingObject:)];
    NSMutableArray *trackings = [self MKDirtyObjectTracking_trackings];
    for (NSObject *tracking in trackings)
    {
        [tracking removeObserver:self forKeyPath:kIsDirtyProperty context:&kDirtyTrackingContext];
        if (notifyEnd)
            [self didEndTrackingObject:tracking];
    }
    [trackings removeAllObjects];
}

- (void)swizzleDirtyTracking_observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                                             change:(NSDictionary *)change context:(void *)context
{
    if (context == &kDirtyTrackingContext)
    {
        if ([keyPath isEqualToString:kIsDirtyProperty])
            [self objectBecameDirty:object];
    }
    else
        [self swizzleDirtyTracking_observeValueForKeyPath:keyPath ofObject:object
                                                   change:change context:context];
}

- (void)swizzleDirtyTracking_dealloc
{
    [self untrackAllObjects];
    [self swizzleDirtyTracking_dealloc];
}

@end