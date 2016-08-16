//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

#import "_UISettingsKeyObserver.h"

@class NSMutableDictionary, NSString, SBLockScreenPlugin, SBLockScreenPluginLoader, SBLockScreenPluginTransitionFactory, SBLockScreenTestPluginSettings, SBLockScreenViewController, UIWindow;

@interface SBLockScreenPluginController : NSObject <_UISettingsKeyObserver>
{
    SBLockScreenPluginLoader *_pluginLoader;
    NSMutableDictionary *_plugins;
    SBLockScreenPlugin *_activePlugin;
    SBLockScreenPlugin *_displayedPlugin;
    SBLockScreenPluginTransitionFactory *_transitionFactory;
    id <SBLockScreenPluginControllerDelegate> _delegate;
    SBLockScreenViewController *_lockScreenViewController;
    _Bool _pluginControllerReceivedViewWillDisappear;
    _Bool _pluginControllerReceivedViewDidDisappear;
    UIWindow *_previousWindow;
    _Bool _removedDisplayedPluginTemporarily;
    SBLockScreenTestPluginSettings *_testSettings;
    _Bool _lockScreenHasNotifications;
    _Bool _allowDisplayOfPlugins;
    double _fadeDuration;
}

@property double fadeDuration; // @synthesize fadeDuration=_fadeDuration;
@property(nonatomic) _Bool allowDisplayOfPlugins; // @synthesize allowDisplayOfPlugins=_allowDisplayOfPlugins;
@property(nonatomic) _Bool lockScreenHasNotifications; // @synthesize lockScreenHasNotifications=_lockScreenHasNotifications;
@property(nonatomic) id <SBLockScreenPluginControllerDelegate> delegate; // @synthesize delegate=_delegate;
@property(retain, nonatomic) SBLockScreenPluginLoader *pluginLoader; // @synthesize pluginLoader=_pluginLoader;
@property(nonatomic) SBLockScreenViewController *lockScreenViewController; // @synthesize lockScreenViewController=_lockScreenViewController;
- (void)settings:(id)arg1 changedValueForKey:(id)arg2;
- (void)_passcodeLockedStateChanged:(id)arg1;
- (_Bool)_pluginHidesNotificationList:(id)arg1;
- (void)_updateNotificationListForNewlyActivatedPlugin;
- (void)_transitionFromNotificationListToExclusionaryPlugin;
- (void)_transitionFromExclusionaryPluginToNotificationList;
- (void)_notifyDisplayedPluginRemovedFromWindow;
- (void)_notifyDisplayedPluginAddedToWindow;
- (void)_lockScreenDidMoveToWindow;
- (void)_lockScreenWillMoveToWindow;
- (void)_disablePluginsPassingTest:(CDUnknownBlockType)arg1 withReason:(id)arg2;
- (void)_removeActivePlugin;
- (void)_removeDisplayedPluginPermanently:(_Bool)arg1;
- (void)_handleUIRelock;
- (void)handleLockScreenTemporarilyDismissed;
- (void)handleUIUnlock;
- (id)_pluginForName:(id)arg1 controller:(id)arg2;
- (_Bool)_loadLockScreenPluginWithName:(id)arg1 activationContext:(id)arg2;
- (void)_handleApplicationExit:(id)arg1;
- (_Bool)disableLockScreenBundleWithName:(id)arg1 deactivationContext:(id)arg2 auxiliaryDeactivationAnimationBlock:(CDUnknownBlockType)arg3;
- (void)_handlePluginDisable:(id)arg1;
- (void)_handleUpdatePluginLegibilitySettings:(id)arg1;
- (id)_transitionContextWithOldPlugin:(id)arg1 newPlugin:(id)arg2;
- (void)_updateCallPluginPresentationStyle;
- (void)_setEffectivePresentationStyleForDisplayedPluginIfNecessary;
- (void)_setDisplayedPlugin:(id)arg1;
- (void)_setActivePlugin:(id)arg1;
- (_Bool)isPhonePluginVisible;
- (_Bool)isPhonePluginActive;
- (void)_refreshLockScreenPlugin;
- (void)reset;
- (_Bool)enableLockScreenBundleWithName:(id)arg1 activationContext:(id)arg2 auxiliaryActivationAnimationBlock:(CDUnknownBlockType)arg3;
- (id)_pluginView;
- (id)_lockScreenView;
- (_Bool)handleHeadsetButtonPressed:(_Bool)arg1;
- (_Bool)handleVolumeDownButtonPressed;
- (_Bool)handleVolumeUpButtonPressed;
- (_Bool)handleLockButtonPressed;
- (_Bool)handleMenuButtonHeld;
- (_Bool)wantsMenuButtonHeldEvent;
- (_Bool)handleMenuButtonDoubleTap;
- (_Bool)handleMenuButtonTap;
- (_Bool)sendEventToPlugin:(CDUnknownBlockType)arg1;
- (id)_highestPriorityPluginIgnoringViewDisplay:(_Bool)arg1;
- (_Bool)pluginControllerShouldAnimateOthersResumption;
- (struct CGRect)defaultContentRegionForPluginController:(id)arg1 withOrientation:(long long)arg2;
- (_Bool)activePluginHidesNotificationList;
- (id)activePluginBundleName;
- (id)displayedPlugin;
- (id)activePlugin;
- (_Bool)isPluginVisible;
- (void)dealloc;
- (void)_addObservers;
- (id)initWithLockScreenViewController:(id)arg1;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

