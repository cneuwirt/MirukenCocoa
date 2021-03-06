//
//  MKWhen.m
//  Miruken
//
//  Created by Craig Neuwirt on 6/18/14.
//  Copyright (c) 2014 Craig Neuwirt. All rights reserved.
//

#import "MKWhen.h"
#import "MKTypeOf.h"

@implementation MKWhen

+ (MKWhenPredicate)kindOfClass:(Class)class
{
    if (class == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"class cannot be nil"
                                     userInfo:nil];
    
    return ^(id object) {
        return [object isKindOfClass:class];
    };
}

+ (MKWhenPredicate)memberOfClass:(Class)class
{
    if (class == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"class cannot be nil"
                                     userInfo:nil];
    
    return ^(id object) {
        return [object isMemberOfClass:class];
    };
}

+ (MKWhenPredicate)conformsToProtocol:(Protocol *)protocol
{
    if (protocol == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"protocol cannot be nil"
                                     userInfo:nil];
    return ^(id object) {
        return [object conformsToProtocol:protocol];
    };
}

+ (MKWhenPredicate)error
{
    return [self kindOfClass:NSError.class];
}

+ (MKWhenPredicate)errorInDomain:(NSString *)domain
{
    return ^BOOL(id object) {
        if ([object isKindOfClass:NSError.class])
        {
            NSError *error = object;
            return [error.domain isEqualToString:domain];
        }
        return NO;
    };
}

+ (MKWhenPredicate)errorInDomain:(NSString *)domain code:(NSInteger)code
{
    return ^BOOL(id object) {
        if ([object isKindOfClass:NSError.class])
        {
            NSError *error = object;
            return [error.domain isEqualToString:domain] && (error.code == code);
        }
        return NO;
    };
}

+ (MKWhenPredicate)exception
{
    return [self kindOfClass:NSException.class];
}

+ (MKWhenPredicate)exceptionNamed:(NSString *)name
{
    return ^BOOL(id object) {
        if ([object isKindOfClass:NSException.class])
        {
            NSException *exception = object;
            return [exception.name isEqualToString:name];
        }
        return NO;
    };
}

+ (MKWhenPredicate)predicateFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    MKWhenPredicate when = [self predicate:[NSPredicate predicateWithFormat:format arguments:args]];
    va_end(args);
    return when;
}

+ (MKWhenPredicate)predicate:(NSPredicate *)predicate
{
    return ^BOOL(id object) {
        return [predicate evaluateWithObject:object];
    };
}

+ (MKWhenPredicate)criteria:(id)criteria
{
    if (criteria == nil)
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"criteria cannot be nil"
                                     userInfo:nil];
    
    MKWhenPredicate condition = [self tryCriteria:criteria];
    if (condition) return condition;
    
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:[NSString stringWithFormat:@"Unknown criteria %@", criteria]
                                 userInfo:nil];
}

+ (MKWhenPredicate)tryCriteria:(id)criteria
{
    switch ([MKTypeOf id:criteria]) {
        case MKIdTypeNil:
            return nil;
            
        case MKIdTypeClass:
            return [self kindOfClass:criteria];
            
        case MKIdTypeProtocol:
            return [self conformsToProtocol:criteria];
            
        case MKIdTypeBlock:
            return criteria;
            
        default:
            if ([criteria isKindOfClass:NSString.class])
                return [self predicateFormat:criteria];
            
            if ([criteria isKindOfClass:NSPredicate.class])
                return [self predicate:criteria];
            
            return nil;
    }
}

@end
