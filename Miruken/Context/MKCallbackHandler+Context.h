//
//  MKCallbackHandler+Context.h
//  Miruken
//
//  Created by Craig Neuwirt on 2/21/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKCallbackHandler.h"
#import "MKContext.h"

@interface MKCallbackHandler (Context)

- (MKContext *)context;

- (id)forNotification;

@end
