//
//  ConfigurationCallbackHandler.m
//  MirukenTests
//
//  Created by Craig Neuwirt on 9/11/12.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "ConfigurationCallbackHandler.h"
#import "Configuration.h"
#import "MKDeferred.h"

@implementation ConfigurationCallbackHandler

- (void)populateConfiguration:(Configuration *)config
{
    config.url = @"mail.google.com";
    [config.tags addObject:@"primary"];   
}

- (BOOL)handleConfiguration:(Configuration *)config
{
    [self populateConfiguration:config];
    return YES;
}

- (id<MKPromise>)provideConfiguration
{
    Configuration *config = [Configuration new];
    [self populateConfiguration:config];
    return [[MKDeferred resolved:config] promise];
}

@end
