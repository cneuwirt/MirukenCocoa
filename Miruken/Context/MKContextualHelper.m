//
//  ContextualHelper.m
//  Miruken
//
//  Created by Craig Neuwirt on 10/18/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKContextualHelper.h"

@implementation MKContextualHelper

+ (MKContext *)resolveContext:(id)contextual
{
    if ([contextual isKindOfClass:MKContext.class])
        return contextual;
    
    if ([contextual respondsToSelector:@selector(context)])
        return [contextual context];
    
    return nil;
}

+ (MKContext *)requireContext:(id)contextual;
{
    MKContext *context = [self resolveContext:contextual];
    if (context)
        return context;
    
    @throw [NSException
            exceptionWithName:@"ContextNotAvailable"
                       reason:@"The supplied object is not a context or Contextual object"
                     userInfo:nil];
}

+ (MKContext *)contextBoundTo:(id)contextual
{
    return contextual && [contextual respondsToSelector:@selector(context)]
        ? [contextual context]
        : nil;
}

+ (void)endContextBoundTo:(id)contextual
{
    if (contextual &&
        [contextual respondsToSelector:@selector(context)] &&
        [contextual respondsToSelector:@selector(setContext:)])
    {
        MKContext *context = [contextual context];
        if (context)
        {
            @try
            {
                [contextual setContext:nil];
            }
            @finally
            {
                [context end];
            }
        }
    }
}

+ (MKContext *)bindChildContextFrom:(id)parent toChild:(id)child
{
    if ([child respondsToSelector:@selector(context)] == NO)
        return nil;
    
    MKContext *childContext = [child context];
    if (childContext)
        return childContext;
    
    MKContext *context = [self resolveContext:parent];
    if (context && [child respondsToSelector:@selector(setContext:)])
    {
        childContext = [context newChildContext];
        [child setContext:childContext];
    }

    return childContext;
}

@end