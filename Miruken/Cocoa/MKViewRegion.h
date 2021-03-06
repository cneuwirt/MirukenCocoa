//
//  ViewRegion.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/27/13.
//  Copyright (c) 2013 Craig Neuwirt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKPromise.h"

/**
  This protocol represents a region on the screen where a view controller can
  be rendered.  It enables compositional view controllers.
 */

@protocol MKViewRegion <NSObject>

@optional
- (MKPromise)presentViewController:(UIViewController *)viewController;

@end

#define MKViewRegion(handler)  ((id<MKViewRegion>)(handler))
