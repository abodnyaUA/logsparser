//
//  MethodSwizzle.m
//  LogsParser
//
//  Created by Aleksey Bodnya on 8/21/17.
//  Copyright © 2017 Aleksey Bodnya. All rights reserved.
//

#import "MethodSwizzle.h"
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

@implementation MethodSwizzle

+ (void)swizzle {
    [MethodSwizzle classMethodSwizzle:[NSColor class] originalSelector:@selector(alternateSelectedControlColor) alternativeSelector:@selector(my_alternateSelectedControlColor) newOriginalSelector:@selector(original_alternateSelectedControlColor)];
    [MethodSwizzle classMethodSwizzle:[NSColor class] originalSelector:@selector(alternateSelectedControlTextColor) alternativeSelector:@selector(my_alternateSelectedControlTextColor) newOriginalSelector:@selector(original_alternateSelectedControlTextColor)];
}

+ (void)methodSwizzle:(Class)aClass originalSelector:(SEL)originalSelector alternativeSelector:(SEL)alternativeSelector newOriginalSelector:(SEL)newOriginalSelector{
    Method originalMethod = nil, alternativeMethod = nil;
    // First, look for the methods
    originalMethod = class_getInstanceMethod(aClass, originalSelector);
    alternativeMethod = class_getInstanceMethod(aClass, alternativeSelector);

    [self swizzleMethodsWithClass:aClass originalSelector:originalSelector originalMethod:originalMethod alternativeMethod:alternativeMethod newOriginalSelector:newOriginalSelector];
}

+ (void)classMethodSwizzle:(Class)aClass originalSelector:(SEL)originalSelector alternativeSelector:(SEL)alternativeSelector newOriginalSelector:(SEL)newOriginalSelector{
    Method originalMethod = nil, alternativeMethod = nil;
    // First, look for the methods
    Class classObject = object_getClass((id)aClass);
    originalMethod = class_getClassMethod(classObject, originalSelector);
    alternativeMethod = class_getClassMethod(classObject, alternativeSelector);

    [self swizzleMethodsWithClass:classObject originalSelector:originalSelector originalMethod:originalMethod alternativeMethod:alternativeMethod newOriginalSelector:newOriginalSelector];
}

+ (void)swizzleMethodsWithClass:(Class)aClass originalSelector:(SEL)originalSelector originalMethod:(Method)originalMethod alternativeMethod:(Method)alternativeMethod newOriginalSelector:(SEL)newOriginalSelector {
    // If both are found, swizzle them
    if (originalMethod) {
        if (newOriginalSelector) {
            class_replaceMethod(aClass, newOriginalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }
        if (alternativeMethod) {
            class_replaceMethod(aClass, originalSelector, method_getImplementation(alternativeMethod), method_getTypeEncoding(alternativeMethod));
        }
    }
}

@end

@interface NSColor (swizzle)

@end

@implementation NSColor (swizzle)

+ (NSColor *)my_alternateSelectedControlColor {
    return [NSColor colorWithRed:186 / 255.0 green:214 / 255.0 blue:253 / 255.0 alpha:1.0];
}

+ (NSColor *)original_alternateSelectedControlColor {
    return nil;
}

+ (NSColor *)my_alternateSelectedControlTextColor {
    return [NSColor blackColor];
}

+ (NSColor *)original_alternateSelectedControlTextColor {
    return nil;
}

@end
