//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class SBAppSwitcherPageView;

@protocol SBAppSwitcherPageViewDelegate <NSObject>
- (struct CGAffineTransform)contentViewTransformForPageView:(SBAppSwitcherPageView *)arg1;
- (long long)resizingPolicyForPageView:(SBAppSwitcherPageView *)arg1;

@optional
- (struct CGSize)contentViewSizeForPageView:(SBAppSwitcherPageView *)arg1;
@end
