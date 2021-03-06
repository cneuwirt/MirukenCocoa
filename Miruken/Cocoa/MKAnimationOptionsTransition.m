//
//  MKAnimationOptionsTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 3/26/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#define kViewAnimationOptionsTransitionsMask  (7 << 20)

#import "MKAnimationOptionsTransition.h"

@implementation MKAnimationOptionsTransition
{
    UIViewAnimationOptions  _animationOptions;
}

+ (instancetype)transitionWithOptions:(UIViewAnimationOptions)options
{
    MKAnimationOptionsTransition *transition = [self new];
    transition->_animationOptions            = options;
    return transition;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;

    UIViewAnimationOptions animationOptions = self.isPresenting
                         ? _animationOptions
                         : [self inferInverseAnimationOptions];
    
    if (fromView && toView)
    {
        [containerView addSubview:fromView];
        [containerView insertSubview:toView belowSubview:fromView];
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView transitionFromView:fromView
                                toView:toView
                              duration:[self transitionDuration:transitionContext]
                               options:animationOptions
                            completion:^(BOOL finished) {
                                BOOL cancelled = [transitionContext transitionWasCancelled];
                                [transitionContext completeTransition:!cancelled];
                            }];
        });
    }
    else if ([self _shouldPerformTransitionWithOptions:animationOptions])
    {
        [UIView transitionWithView:containerView
                          duration:[self transitionDuration:transitionContext]
                           options:animationOptions animations:^{
                               if (self.isPresenting)
                                   [containerView addSubview:toView];
                               else
                                   [fromView removeFromSuperview];
                           } completion:^(BOOL finished) {
                               BOOL cancelled = [transitionContext transitionWasCancelled];
                               [transitionContext completeTransition:!cancelled];
                           }];
    }
    else
        [transitionContext completeTransition:YES];
}

- (UIViewAnimationOptions)inferInverseAnimationOptions
{
    UIViewAnimationOptions options    = (_animationOptions & ~kViewAnimationOptionsTransitionsMask);
    UIViewAnimationOptions transition = (_animationOptions & kViewAnimationOptionsTransitionsMask);
    
    switch (transition)
    {
        case UIViewAnimationOptionTransitionFlipFromTop:
            options |= UIViewAnimationOptionTransitionFlipFromBottom;
            break;
            
        case UIViewAnimationOptionTransitionFlipFromBottom:
            options |= UIViewAnimationOptionTransitionFlipFromTop;
            break;
            
        case UIViewAnimationOptionTransitionFlipFromLeft:
            options |= UIViewAnimationOptionTransitionFlipFromRight;
            break;
            
        case UIViewAnimationOptionTransitionFlipFromRight:
            options |= UIViewAnimationOptionTransitionFlipFromLeft;
            break;
            
        case UIViewAnimationOptionTransitionCurlDown:
            options |= UIViewAnimationOptionTransitionCurlUp;
            break;

        case UIViewAnimationOptionTransitionCurlUp:
            options |= UIViewAnimationOptionTransitionCurlDown;
            break;
            
        default:
            options = _animationOptions;
            break;
    }
    
    return options;
}

- (BOOL)_shouldPerformTransitionWithOptions:(UIViewAnimationOptions)options
{
    UIViewAnimationOptions transition = (options & kViewAnimationOptionsTransitionsMask);
    
    return self.isPresenting
         ? transition != UIViewAnimationOptionTransitionCurlUp
         : transition != UIViewAnimationOptionTransitionCurlDown;
}

@end
