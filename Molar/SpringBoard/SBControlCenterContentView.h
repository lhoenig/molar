//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "UIView.h"

#import "SBControlCenterObserver.h"

@class NSString, SBCCQuickLaunchSectionController, SBCCSettingsSectionController, SBControlCenterGrabberView, SBControlCenterSectionViewController, UIViewController;

@interface SBControlCenterContentView : UIView <SBControlCenterObserver>
{
    UIViewController *_viewController;
    SBControlCenterGrabberView *_grabberView;
    SBCCSettingsSectionController *_settingsSection;
    SBControlCenterSectionViewController *_brightnessSection;
    SBControlCenterSectionViewController *_mediaControlsSection;
    SBControlCenterSectionViewController *_airplaySection;
    SBCCQuickLaunchSectionController *_quickLaunchSection;
}

+ (double)defaultBreadthForOrientation:(long long)arg1;
@property(retain, nonatomic) SBCCQuickLaunchSectionController *quickLaunchSection; // @synthesize quickLaunchSection=_quickLaunchSection;
@property(retain, nonatomic) SBControlCenterSectionViewController *airplaySection; // @synthesize airplaySection=_airplaySection;
@property(retain, nonatomic) SBControlCenterSectionViewController *mediaControlsSection; // @synthesize mediaControlsSection=_mediaControlsSection;
@property(retain, nonatomic) SBControlCenterSectionViewController *brightnessSection; // @synthesize brightnessSection=_brightnessSection;
@property(retain, nonatomic) SBCCSettingsSectionController *settingsSection; // @synthesize settingsSection=_settingsSection;
@property(retain, nonatomic) SBControlCenterGrabberView *grabberView; // @synthesize grabberView=_grabberView;
@property(nonatomic) UIViewController *viewController; // @synthesize viewController=_viewController;
- (void)controlCenterDidFinishTransition;
- (void)controlCenterWillBeginTransition;
- (void)controlCenterDidDismiss;
- (void)controlCenterWillPresent;
- (void)layoutSubviews;
- (void)_iPhone_layoutSubviewsInBounds:(struct CGRect)arg1 orientation:(long long)arg2;
- (void)_iPad_layoutSubviewsInBounds:(struct CGRect)arg1 orientation:(long long)arg2;
- (void)updateSectionVisibility:(id)arg1 animated:(_Bool)arg2;
- (void)updateEnabledSections;
- (void)_removeSectionController:(id)arg1;
- (void)_addSectionController:(id)arg1;
- (double)contentHeightForOrientation:(long long)arg1;
- (id)_allSections;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

