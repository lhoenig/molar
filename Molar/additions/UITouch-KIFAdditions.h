//
//  UITouch-KIFAdditions.h
//  KIF
//
//  Created by Eric Firestone on 5/20/11.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "FixCategoryBug.h"
#import "IOHIDEvent+KIF.h"
#import <UIKit/UIKit.h>

KW_FIX_CATEGORY_BUG_H(UITouch_KIFAdditions)

@interface UITouch ()

- (void)setWindow:(UIWindow *)window;
- (void)setView:(UIView *)view;
- (void)setTapCount:(NSUInteger)tapCount;
- (void)setIsTap:(BOOL)isTap;
- (void)setTimestamp:(NSTimeInterval)timestamp;
- (void)setPhase:(UITouchPhase)touchPhase;
- (void)setGestureView:(UIView *)view;
- (void)_setLocationInWindow:(CGPoint)location
               resetPrevious:(BOOL)resetPrevious;
- (void)_setIsFirstTouchForView:(BOOL)firstTouchForView;

- (void)_setHidEvent:(IOHIDEventRef)event;
- (void)_setPressure:(double)pressure resetPrevious:(bool)reset;
- (void)_setHasForceUpdate:(BOOL)upd;
- (void)_setNeedsForceUpdate:(BOOL)upd;
- (BOOL)_supportsForce;
- (IOHIDEventRef)_hidEvent;

@end

@interface UITouch (KIFAdditions)

- (id)initInView:(UIView *)view;
- (id)initAtPoint:(CGPoint)point inView:(UIView *)view;
- (id)initAtPoint:(CGPoint)point inWindow:(UIWindow *)window;
- (id)initAtPoint:(CGPoint)point
         inWindow:(UIWindow *)window
        withForce:(double)force;
- (id)initTouch;
- (void)resetTouch;

- (void)setLocationInWindow:(CGPoint)location;
- (void)setPhaseAndUpdateTimestamp:(UITouchPhase)phase;

@end
