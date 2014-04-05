//
//  MKCallbackHandler+Presentation.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/23/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler+Presentation.h"
#import "MKPresentationPolicyHandler.h"
#import "MKCascadeCallbackHandler.h"

@implementation MKCallbackHandler (Presentation)

#pragma mark - Modal presentations

- (MKModalPresentationScope *)modal
{
    return [MKModalPresentationScope for:self];
}

- (MKAnimatedTransitionScope *)transition
{
    return [MKAnimatedTransitionScope for:self];
}

- (instancetype)transition:(id<UIViewControllerTransitioningDelegate>)transition
{
    MKPresentationPolicy *presentationPolicy = [MKPresentationPolicy new];
    presentationPolicy.transitionDelegate = transition;
    return [self usePresentationPolicy:presentationPolicy];
}

- (instancetype)usePresentationPolicy:(MKPresentationPolicy *)policy
{
    MKPresentationPolicyHandler *policyHandler =
        [MKPresentationPolicyHandler handlerWithPresentationPolicy:policy];
    return [MKCascadeCallbackHandler withHandler:policyHandler cascadeTo:self];
}

@end
