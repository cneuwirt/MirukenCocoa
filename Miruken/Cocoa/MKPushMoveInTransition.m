//
//  MKPushMoveInTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 4/2/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKPushMoveInTransition.h"

@implementation MKPushMoveInTransition
{
    BOOL               _push;
    MKStartingPosition _startingPosition;
}

+ (instancetype)pushFromPosition:(MKStartingPosition)position;
{
    MKPushMoveInTransition *push = [self new];
    push->_push                  = YES;
    push->_startingPosition      = position;
    return push;
}

+ (instancetype)moveInFromPosition:(MKStartingPosition)position
{
    MKPushMoveInTransition *moveIn = [self new];
    moveIn->_push                  = NO;
    moveIn->_startingPosition      = position;
    return moveIn;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView = [transitionContext containerView];
    UIView *fromView      = fromViewController.view;
    UIView *toView        = toViewController.view;
    
    MKStartingPosition startingPosition = self.isPresenting
                                        ? _startingPosition
                                        : [self inferInverseStartingPosition];
    
    if (fromView)
    {
        fromView.frame = containerView.bounds;
        [containerView addSubview:fromView];
    }
    
    [self setView:toView startingPosition:startingPosition inContainerView:containerView inverse:NO];
    [containerView addSubview:toView];
    [containerView bringSubviewToFront:toView];
    
    [UIView transitionWithView:containerView
                      duration:[self transitionDuration:transitionContext]
                       options:0 animations:^{
                           if ((_push || self.isPresenting == NO) && fromView)
                               [self setView:fromView startingPosition:startingPosition
                                    inContainerView:containerView inverse:YES];
                           toView.frame = containerView.frame;
                       } completion:^(BOOL finished) {
                           if (fromView)
                               [fromView removeFromSuperview];
                           [transitionContext completeTransition:finished];
                       }];
}

- (void)setView:(UIView *)view startingPosition:(MKStartingPosition)startingPosition
    inContainerView:(UIView *)containerView inverse:(BOOL)inverse
{
    CGRect    frame            = view.frame;
    NSInteger inverseMultipier = inverse ? -1 : 1;
    
    switch (startingPosition) {
        case MKStartingPositionLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            break;
            
        case MKStartingPositionRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            break;

        case MKStartingPositionBottom:
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionBottomLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionBottomRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = containerView.frame.size.height * inverseMultipier;
            break;
            
        case MKStartingPositionTop:
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
         
        case MKStartingPositionTopLeft:
            frame.origin.x = -containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;

        case MKStartingPositionTopRight:
            frame.origin.x = containerView.frame.size.width * inverseMultipier;
            frame.origin.y = -containerView.frame.size.height * inverseMultipier;
            break;
    }
    
    frame.size = containerView.frame.size;
    view.frame = frame;
}

- (MKStartingPosition)inferInverseStartingPosition
{
    switch (_startingPosition) {
        case MKStartingPositionLeft:
            return MKStartingPositionRight;
            
        case MKStartingPositionRight:
            return MKStartingPositionLeft;
            
        case MKStartingPositionBottom:
            return MKStartingPositionTop;
            
        case MKStartingPositionBottomLeft:
            return MKStartingPositionTopRight;
            
        case MKStartingPositionBottomRight:
            return MKStartingPositionTopLeft;
            
        case MKStartingPositionTop:
            return MKStartingPositionBottom;
            
        case MKStartingPositionTopLeft:
            return MKStartingPositionBottomRight;
            
        case MKStartingPositionTopRight:
            return MKStartingPositionBottomLeft;
    }
}

@end