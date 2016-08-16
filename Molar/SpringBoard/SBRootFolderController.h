//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "SBFolderController.h"

@class SBRootFolder, SBRootFolderView, UIWindow;

@interface SBRootFolderController : SBFolderController
{
    _Bool _managesStatusBarWidth;
    UIWindow *_dockAnimationWindow;
}

+ (Class)listViewClass;
@property(nonatomic) _Bool managesStatusBarWidth; // @synthesize managesStatusBarWidth=_managesStatusBarWidth;
@property(retain, nonatomic) UIWindow *dockAnimationWindow; // @synthesize dockAnimationWindow=_dockAnimationWindow;
- (void)didRotateFromInterfaceOrientation:(long long)arg1;
- (void)willAnimateRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
- (void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
- (struct UIEdgeInsets)statusBarInsetsForOrientation:(long long)arg1;
- (void)_configureAppStatusBarInsetsForOrientation:(long long)arg1;
- (void)_configureAppStatusBarInsets;
- (void)_configureAppStatusBarInsetsAnimated:(_Bool)arg1;
- (void)_configureViewForOrientationWithoutAnimation:(long long)arg1;
- (void)_configureDockViewForOrientationWithoutAnimation:(long long)arg1;
- (void)_configureDockViewForOrientationDuringAnimation:(long long)arg1;
- (_Bool)_dockLayoutReversedForInterfaceOrientation:(long long)arg1;
- (unsigned long long)_dockEdgeForInterfaceOrientation:(long long)arg1;
- (_Bool)_shouldUseDockAnimationWindowForRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
- (_Bool)_shouldSlideDockOutDuringRotationFromOrientation:(long long)arg1 toOrientation:(long long)arg2;
- (_Bool)_isDockSwitchedForOrientation:(long long)arg1;
- (void)prepareToClose;
- (void)prepareToOpen;
- (void)addAdditionalInnerFolderAnimations;
- (_Bool)popFolderAnimated:(_Bool)arg1 completion:(CDUnknownBlockType)arg2;
- (_Bool)pushFolder:(id)arg1 animated:(_Bool)arg2 completion:(CDUnknownBlockType)arg3;
- (_Bool)_listIndexIsVisible:(unsigned long long)arg1;
- (struct CGRect)_autoscrollExclusionRegion;
@property(nonatomic) unsigned long long dockEdge;
- (void)setDockVerticalStretch:(double)arg1;
- (void)setDockOffscreenFraction:(double)arg1;
- (id)dockListView;
- (_Bool)isDisplayingIcon:(id)arg1;
- (void)setIdleText:(id)arg1;
- (_Bool)setCurrentPageIndex:(long long)arg1 animated:(_Bool)arg2;
- (id)folderControllers;
- (unsigned long long)_depth;
- (Class)_contentViewClass;
- (void)dealloc;
- (id)initWithFolder:(id)arg1 orientation:(long long)arg2 viewMap:(id)arg3;

// Remaining properties
@property(readonly, retain, nonatomic) SBRootFolderView *contentView; // @dynamic contentView;
@property(retain, nonatomic) SBRootFolder *folder; // @dynamic folder;

@end

