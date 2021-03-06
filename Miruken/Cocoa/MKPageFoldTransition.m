//
//  MKPageFoldTransition.m
//  Miruken
//
//  Created by Craig Neuwirt on 5/3/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//
//  Based on work by Colin Eberhardt on 09/09/2013.
//  Copyright (c) 2013 Colin Eberhardt. All rights reserved.
//

#import "MKPageFoldTransition.h"

#define kDefaultPageFolds    2
#define kDefaultPerspective  (-1.0 / 200.0f)

@implementation MKPageFoldTransition

+ (instancetype)folds:(NSUInteger)folds
{
    MKPageFoldTransition *folded = [self new];
    folded->_folds               = folds;
    return folded;
}

- (id)init
{
    if (self = [super init])
    {
        _folds       = kDefaultPageFolds;
        _perspective = kDefaultPerspective;
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
       fromViewController:(UIViewController *)fromViewController
         toViewController:(UIViewController *)toViewController
{
    UIView *containerView   = [transitionContext containerView];
    UIView *fromView        = fromViewController.view;
    UIView *toView          = toViewController.view;
    
    if (fromView == nil || toView == nil)
    {
        [self completeTransition:transitionContext];
        return;
    }
    
    // move offscreen
    toView.frame            = CGRectOffset(toView.frame, toView.frame.size.width, 0);
    [containerView addSubview:toView];
    
    // Add a perspective transform
    CATransform3D transform               = CATransform3DIdentity;
    transform.m34                         = _perspective;
    containerView.layer.sublayerTransform = transform;
    
    CGSize  size            = toView.frame.size;
    CGFloat foldWidth       = size.width * 0.5 / (CGFloat)self.folds;
    
    // arrays that hold the snapshot views
    NSMutableArray *fromViewFolds = [NSMutableArray new];
    NSMutableArray *toViewFolds   = [NSMutableArray new];
    
    // create the folds for the form- and to- views
    for (NSInteger foldIdx = 0; foldIdx < self.folds; ++foldIdx)
    {
        CGFloat offset                   = (CGFloat)foldIdx * foldWidth * 2;
        
        // the left and right side of the fold for the from- view, with identity transform and 0.0 alpha
        // on the shadow, with each view at its initial position
        UIView *leftFromViewFold         = [self _createSnapshotFromView:fromView afterUpdates:NO
                                                                location:offset left:YES];
        leftFromViewFold.layer.position  = CGPointMake(offset, size.height / 2);
        [fromViewFolds addObject:leftFromViewFold];
        [leftFromViewFold.subviews[1] setAlpha:0.0];
        
        UIView *rightFromViewFold        = [self _createSnapshotFromView:fromView afterUpdates:NO
                                                                location:offset + foldWidth left:NO];
        rightFromViewFold.layer.position = CGPointMake(offset + foldWidth * 2, size.height/2);
        [fromViewFolds addObject:rightFromViewFold];
        [rightFromViewFold.subviews[1] setAlpha:0.0];
        
        // the left and right side of the fold for the to- view, with a 90-degree transform and 1.0 alpha
        // on the shadow, with each view positioned at the very edge of the screen
        UIView *leftToViewFold           = [self _createSnapshotFromView:toView afterUpdates:YES
                                                                location:offset left:YES];
        leftToViewFold.layer.position    = CGPointMake(self.isPresenting ? 0.0 : size.width, size.height / 2);
        leftToViewFold.layer.transform   = CATransform3DMakeRotation(M_PI_2, 0.0, 1.0, 0.0);
        [toViewFolds addObject:leftToViewFold];
        
        UIView *rightToViewFold          = [self _createSnapshotFromView:toView afterUpdates:YES
                                                                location:offset + foldWidth left:NO];
        rightToViewFold.layer.position   = CGPointMake(self.isPresenting ? 0.0 : size.width, size.height/2);
        rightToViewFold.layer.transform  = CATransform3DMakeRotation(-M_PI_2, 0.0, 1.0, 0.0);
        [toViewFolds addObject:rightToViewFold];
    }
    
    // move the from- view off screen
    fromView.frame          = CGRectOffset(fromView.frame, fromView.frame.size.width, 0);
    
    // create the animation
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:duration animations:^{
        // set the final state for each fold
        for (NSInteger foldIdx = 0; foldIdx < self.folds; ++foldIdx)
        {
            CGFloat offset               = (CGFloat)foldIdx * foldWidth * 2;
            
            // the left and right side of the fold for the from- view, with 90 degree transform and 1.0 alpha
            // on the shadow, with each view positioned at the edge of thw screen.
            UIView *leftFromView         = fromViewFolds[foldIdx * 2];
            leftFromView.layer.position  = CGPointMake(self.isPresenting ? size.width : 0.0, size.height/2);
            leftFromView.layer.transform = CATransform3DRotate(transform, M_PI_2, 0.0, 1.0, 0);
            [leftFromView.subviews[1] setAlpha:1.0];
            
            UIView *rightFromView         = fromViewFolds[foldIdx * 2 + 1];
            rightFromView.layer.position  = CGPointMake(self.isPresenting ? size.width : 0.0, size.height/2);
            rightFromView.layer.transform = CATransform3DRotate(transform, -M_PI_2, 0.0, 1.0, 0);
            [rightFromView.subviews[1] setAlpha:1.0];
            
            // the left and right side of the fold for the to- view, with identity transform and 0.0 alpha
            // on the shadow, with each view at its final position
            UIView *leftToView            = toViewFolds[foldIdx * 2];
            leftToView.layer.position     = CGPointMake(offset, size.height / 2);
            leftToView.layer.transform    = CATransform3DIdentity;
            [leftToView.subviews[1] setAlpha:0.0];
            
            UIView *rightToView           = toViewFolds[foldIdx * 2 + 1];
            rightToView.layer.position    = CGPointMake(offset + foldWidth * 2, size.height / 2);
            rightToView.layer.transform   = CATransform3DIdentity;
            [rightToView.subviews[1] setAlpha:0.0];
        }
    }
    completion:^(BOOL finished) {
        // remove the snapshot views
        for (UIView *view in [toViewFolds arrayByAddingObjectsFromArray:fromViewFolds])
            [view removeFromSuperview];
            
        // restore the to- and from- to the initial location
        toView.frame   = containerView.bounds;
        fromView.frame = containerView.bounds;
        
        containerView.layer.sublayerTransform = CATransform3DIdentity;
        BOOL cancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!cancelled];
    }];
}

// creates a snapshot for the gives view
- (UIView *)_createSnapshotFromView:(UIView *)view afterUpdates:(BOOL)afterUpdates
                           location:(CGFloat)offset left:(BOOL)left
{
    CGSize  size          = view.frame.size;
    UIView *containerView = view.superview;
    CGFloat foldWidth     = size.width * 0.5 / (CGFloat)self.folds;
    
    UIView *snapshotView;
    
    if (afterUpdates == NO)
    {
        // create a regular snapshot
        CGRect snapshotRegion = CGRectMake(offset, 0.0, foldWidth, size.height);
        snapshotView          = [view resizableSnapshotViewFromRect:snapshotRegion
                                                 afterScreenUpdates:afterUpdates
                                                      withCapInsets:UIEdgeInsetsZero];
    }
    else
    {
        // for the to- view for some reason the snapshot takes a while to create.
        // Here we place the snapshot within
        // another view, with the same bckground color, so that it is less noticeable
        // when the snapshot initially renders
        snapshotView                 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, foldWidth, size.height)];
        snapshotView.backgroundColor = view.backgroundColor;
        CGRect  snapshotRegion       = CGRectMake(offset, 0.0, foldWidth, size.height);
        UIView *snapshotView2        = [view resizableSnapshotViewFromRect:snapshotRegion
                                                        afterScreenUpdates:afterUpdates
                                                             withCapInsets:UIEdgeInsetsZero];
        [snapshotView addSubview:snapshotView2];
    }
    
    // create a shadow
    UIView *snapshotWithShadowView   = [self _addShadowToView:snapshotView reverse:left];
    
    // add to the container
    [containerView addSubview:snapshotWithShadowView];
    
    // set the anchor to the left or right edge of the view
    snapshotWithShadowView.layer.anchorPoint = CGPointMake( left ? 0.0 : 1.0, 0.5);
    return snapshotWithShadowView;
}

// adds a gradient to an image by creating a containing UIView with both the given view
// and the gradient as subviews
- (UIView *)_addShadowToView:(UIView*)view reverse:(BOOL)reverse
{
    // create a view with the same frame
    UIView          *viewWithShadow = [[UIView alloc] initWithFrame:view.frame];
    
    // create a shadow
    UIView          *shadowView     = [[UIView alloc] initWithFrame:viewWithShadow.bounds];
    CAGradientLayer *gradient       = [CAGradientLayer layer];
    gradient.frame                  = shadowView.bounds;
    gradient.colors                 = @[ (id)[UIColor colorWithWhite:0.0 alpha:0.0].CGColor,
                                         (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor ];
    gradient.startPoint             = CGPointMake(reverse ? 0.0 : 1.0, reverse ? 0.2 : 0.0);
    gradient.endPoint               = CGPointMake(reverse ? 1.0 : 0.0, reverse ? 0.0 : 1.0);
    [shadowView.layer insertSublayer:gradient atIndex:1];
    
    // add the original view into our new view
    view.frame = view.bounds;
    [viewWithShadow addSubview:view];
    
    // place the shadow on top
    [viewWithShadow addSubview:shadowView];
    return viewWithShadow;
}

@end
