//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "SBLockScreenViewControllerBase.h"

#import "ISPlayerViewDelegate.h"
#import "SBLockScreenBatteryChargingViewControllerDelegate.h"
#import "SBLockScreenInfoOverlayDelegate.h"
#import "SBLockScreenNotificationListDelegate.h"
#import "SBLockScreenPluginControllerDelegate.h"
#import "SBLockScreenSlideUpToAppControllerDelegate.h"
#import "SBLockScreenTimerViewControllerDelegate.h"
#import "SBLockScreenViewDelegate.h"
#import "SBUIPasscodeLockViewDelegate_Internal.h"
#import "SBWallpaperObserver.h"
#import "UIGestureRecognizerDelegate.h"
#import "_UISettingsKeyObserver.h"

@class MPUSystemMediaControlsViewController, NSMutableArray, NSString, SBAppStatusBarSettingsAssertion, SBDisableAppStatusBarUserInteractionChangesAssertion, SBIrisWallpaperSettings, SBLockOverlayContext, SBLockScreenActionContext, SBLockScreenBatteryChargingViewController, SBLockScreenBuddyViewController, SBLockScreenDateViewController, SBLockScreenDeviceBlockViewController, SBLockScreenEmergencyCallViewController, SBLockScreenFullscreenBulletinViewController, SBLockScreenHintManager, SBLockScreenInfoOverlayViewController, SBLockScreenModalAlertViewController, SBLockScreenNotificationListController, SBLockScreenNowPlayingPluginController, SBLockScreenPasscodeOverlayViewController, SBLockScreenPluginController, SBLockScreenResetRestoreViewController, SBLockScreenSlideUpToAppController, SBLockScreenStatusTextViewController, SBLockScreenTemperatureWarningViewController, SBLockScreenTimerViewController;

@interface SBLockScreenViewController : SBLockScreenViewControllerBase <SBLockScreenViewDelegate, SBLockScreenTimerViewControllerDelegate, SBLockScreenNotificationListDelegate, SBUIPasscodeLockViewDelegate_Internal, SBLockScreenBatteryChargingViewControllerDelegate, SBLockScreenInfoOverlayDelegate, SBWallpaperObserver, SBLockScreenPluginControllerDelegate, SBLockScreenSlideUpToAppControllerDelegate, UIGestureRecognizerDelegate, ISPlayerViewDelegate, _UISettingsKeyObserver>
{
    _Bool _isInScreenOffMode;
    SBLockScreenDeviceBlockViewController *_blockedController;
    SBLockScreenDateViewController *_dateViewController;
    SBLockScreenStatusTextViewController *_statusTextViewController;
    SBLockScreenTimerViewController *_timerViewController;
    SBLockScreenNotificationListController *_notificationController;
    SBLockScreenSlideUpToAppController *_cameraController;
    SBLockScreenSlideUpToAppController *_bottomLeftAppController;
    MPUSystemMediaControlsViewController *_mediaControlsViewController;
    _Bool _ignoreFirstMediaToggle;
    SBLockScreenModalAlertViewController *_modalAlertController;
    SBLockScreenBatteryChargingViewController *_chargingViewController;
    _Bool _attemptingPasscodeUnlock;
    _Bool _chargingViewControllerVisible;
    _Bool _wasAutoUnlocked;
    _Bool _forcePasscodeWhileInCall;
    _Bool _isHidingPasscodeWhileInCall;
    _Bool _nextUnlockShouldReturnToCall;
    SBLockScreenPluginController *_pluginController;
    SBLockScreenNowPlayingPluginController *_nowPlayingController;
    SBLockScreenBuddyViewController *_buddyController;
    SBLockOverlayContext *_buddyOverlayContext;
    NSMutableArray *_prioritizedOverlays;
    SBLockOverlayContext *_fullScreenOverlayContext;
    SBLockOverlayContext *_blockedOverlayContext;
    SBLockScreenFullscreenBulletinViewController *_fullscreenBulletinController;
    SBLockOverlayContext *_fullScreenBulletinOverlayContext;
    SBLockScreenInfoOverlayViewController *_infoOverlayController;
    SBLockOverlayContext *_infoOverlayContext;
    SBLockScreenTemperatureWarningViewController *_thermalWarningController;
    SBLockOverlayContext *_thermalWarningContext;
    SBLockScreenResetRestoreViewController *_resetRestoreViewController;
    SBLockOverlayContext *_resetRestoreOverlayContext;
    SBLockScreenPasscodeOverlayViewController *_passcodeOverlayViewController;
    SBLockOverlayContext *_passcodeOverlayContext;
    SBLockScreenEmergencyCallViewController *_emergencyCallController;
    _Bool _retryingEmergencyDialerCreationWhileBlocked;
    _Bool _suppressWallpaperAlphaChangeOnScroll;
    SBLockScreenActionContext *_bioLockScreenActionContext;
    _Bool _disabledMesaForPhoneCall;
    SBLockScreenActionContext *_slideUpControllerActionContext;
    SBLockScreenHintManager *_hintManager;
    SBDisableAppStatusBarUserInteractionChangesAssertion *_statusBarUserInteractionAssertion;
    SBAppStatusBarSettingsAssertion *_hideStatusBarAssertion;
    SBIrisWallpaperSettings *_irisWallpaperSettings;
    _Bool _irisPlayerIsInteracting;
    _Bool _shouldTransitionIrisWallpaperToStillWhenPlaybackFinishes;
    _Bool _hasAuthenticatedForNotificationAction;
}

@property(nonatomic) _Bool hasAuthenticatedForNotificationAction; // @synthesize hasAuthenticatedForNotificationAction=_hasAuthenticatedForNotificationAction;
@property(readonly, retain, nonatomic) SBLockScreenPluginController *pluginController; // @synthesize pluginController=_pluginController;
@property(retain, nonatomic, setter=_setBioLockScreenActionContext:) SBLockScreenActionContext *_bioLockScreenActionContext; // @synthesize _bioLockScreenActionContext;
- (void)_incrementIrisPlayCount;
- (void)settings:(id)arg1 changedValueForKey:(id)arg2;
- (void)_actuallyUpdateUIForIrisPlaying:(_Bool)arg1;
- (void)_actuallyUpdateUIForIrisNotPlaying;
- (void)_actuallyUpdateUIForIrisPlaying;
- (void)_updateUIForPlaying:(_Bool)arg1 immediately:(_Bool)arg2;
- (void)playerViewIsInteractingDidChange:(id)arg1;
- (void)playerViewPlaybackStateDidChange:(id)arg1;
- (_Bool)gestureRecognizerShouldBegin:(id)arg1;
- (_Bool)gestureRecognizer:(id)arg1 shouldRecognizeSimultaneouslyWithGestureRecognizer:(id)arg2;
- (_Bool)gestureRecognizer:(id)arg1 shouldReceiveTouch:(id)arg2;
- (_Bool)_didNotificationsPassTopGrabber;
- (void)_setStationaryContentAlpha:(double)arg1;
- (void)_translateTopGrabber;
- (_Bool)_isAnimatingNotificationListView;
- (void)_translateNotificationListView;
- (_Bool)hasNotifications;
- (id)_wallpaperLegibilitySettings;
- (id)_pluginLegibilitySettings;
- (id)_overlayLegibilitySettings;
- (id)_notificationListLegibilitySettings;
- (id)_effectiveLegibilitySettings;
- (void)_updateLegibility;
- (void)updateLegibility;
- (id)legibilitySettings;
- (_Bool)lockScreenIsActive;
- (id)viewControllerToUseAsParent;
- (void)passcodeViewDidBecomeActive:(_Bool)arg1 forController:(id)arg2;
- (void)setUnlockActionContext:(id)arg1;
- (_Bool)isAnotherSlideUpControllerBlockingController:(id)arg1;
- (_Bool)controllerShouldInvertVerticalPadding:(id)arg1;
- (_Bool)controllerShouldUseAdditionalTopPadding:(id)arg1;
- (void)adjustWallpaperForVerticalScrollPercentage:(double)arg1;
- (id)grabberViewInLockScreenView:(id)arg1 forController:(id)arg2;
- (void)addGrabberView:(id)arg1 toLockScreenView:(id)arg2 forController:(id)arg3;
- (long long)presentingControllerIdentifierForController:(id)arg1;
- (void)prepareForSlideUpAppLaunchAnimated:(_Bool)arg1;
- (id)lockScreenBottomLeftAppController;
- (id)lockScreenCameraController;
- (void)wallpaperDidChangeForVariant:(long long)arg1;
- (void)wallpaperLegibilitySettingsDidChange:(id)arg1 forVariant:(long long)arg2;
- (void)_buddyDidFinish:(id)arg1;
- (void)_removeBuddyBackground;
- (void)_addOrRemoveBuddyBackgroundIfNecessary;
- (void)biometricEventMonitorDidAuthenticate:(id)arg1;
- (void)_updateGrabbersForIdentityManagerAuthentication;
- (void)_updateMediaControlsForScreenMode;
- (void)_mediaControlsDidHideOrShow:(id)arg1;
- (void)setShowingMediaControls:(_Bool)arg1;
- (_Bool)isShowingMediaControls;
- (void)_setMediaControlsVisible:(_Bool)arg1;
- (void)_toggleMediaControls;
- (id)_notificationController;
- (void)pluginController:(id)arg1 activePluginDidChange:(id)arg2;
- (void)_setNowPlayingControllerEnabled:(_Bool)arg1;
- (void)_removeActivePluginView;
- (void)_resetActivePlugin;
- (_Bool)allowAnimatedDismissalForLockScreenPlugin;
- (void)updateCustomSubtitleTextForAwayViewPlugin:(id)arg1;
- (void)adjustLockScreenContentByOffset:(double)arg1 forPluginController:(id)arg2 withAnimationDuration:(double)arg3;
- (struct CGRect)defaultContentRegionForPluginController:(id)arg1 withOrientation:(long long)arg2;
- (void)disableLockScreenBundleWithName:(id)arg1 deactivationContext:(id)arg2 auxiliaryDeactivationAnimationBlock:(CDUnknownBlockType)arg3;
- (void)enableLockScreenBundleWithName:(id)arg1 activationContext:(id)arg2 auxiliaryActivationAnimationBlock:(CDUnknownBlockType)arg3;
- (id)activeLockScreenPluginController;
- (_Bool)isLockScreenPluginViewVisible;
- (void)deactivateCardItem:(id)arg1;
- (void)updateCardItem:(id)arg1;
- (void)activateCardItem:(id)arg1 animated:(_Bool)arg2;
- (id)allPendingAlertItems;
- (_Bool)hasSuperModalAlertItems;
- (id)dequeueAllPendingSuperModalAlertItems;
- (id)currentAlertItem;
- (void)cleanupAlertItemsForDeactivation;
- (void)deactivateAlertItem:(id)arg1 animated:(_Bool)arg2;
- (_Bool)hasAlertItem:(id)arg1;
- (_Bool)activateAlertItem:(id)arg1 animated:(_Bool)arg2;
- (_Bool)wantsToHandleAlert:(id)arg1;
- (_Bool)canHandleAlerts;
- (_Bool)shouldPendAlertItemsWhileActive;
- (void)chargingViewControllerFadedOutContent:(id)arg1;
- (void)_cleanupBatteryChargingViewWithAnimationDuration:(double)arg1;
- (void)_fadeViewsForIrisPlaying:(_Bool)arg1;
- (void)_fadeViewsForChargingViewVisible:(_Bool)arg1;
- (void)_powerStatusChanged:(id)arg1;
- (void)_updateBatteryChargingViewAnimated:(_Bool)arg1;
- (void)authenticateForNotificationActionWithCompletion:(CDUnknownBlockType)arg1;
- (void)_dismissFullscreenBulletinAlertAnimated:(_Bool)arg1;
- (void)dismissFullscreenBulletinAlertWithItem:(id)arg1;
- (void)modifyFullscreenBulletinAlertWithItem:(id)arg1;
- (void)presentFullscreenBulletinAlertWithItem:(id)arg1;
- (void)_removeFullscreenBulletinViewAnimated:(_Bool)arg1;
- (void)_addFullscreenBulletinViewWithItem:(id)arg1;
- (id)lockScreenScrollView;
- (void)notificationListBecomingVisible:(_Bool)arg1;
- (void)attemptToUnlockUIFromNotification;
- (void)_dismissNotificationCenterToRevealPasscode;
- (void)bannerEnablementChanged;
- (void)timerControllerDidStopTimer:(id)arg1;
- (void)timerControllerDidStartTimer:(id)arg1;
- (void)_clearHideStatusBarAssertion;
- (void)_updateDateTimerStatusBarAndLockSlider;
- (_Bool)_shouldShowChargingText;
- (_Bool)_shouldShowDate;
- (double)_effectiveVisibleStatusBarAlpha;
- (id)_effectiveCustomSlideToUnlockText;
- (double)_effectiveOpacityForVisibleDateView;
- (_Bool)isMakingEmergencyCall;
- (void)emergencyDialerExitedWithError:(id)arg1;
- (void)exitEmergencyDialerAnimated:(_Bool)arg1;
- (void)_destroyEmergencyDialerAnimated:(_Bool)arg1;
- (void)launchEmergencyDialer;
- (void)_adjustIdleTimerForEmergencyDialerActive:(_Bool)arg1;
- (void)passcodeLockViewKeypadKeyUp:(id)arg1;
- (void)passcodeLockViewKeypadKeyDown:(id)arg1;
- (void)passcodeLockViewEmergencyCallButtonPressed:(id)arg1;
- (void)passcodeLockViewCancelButtonPressed:(id)arg1;
- (void)passcodeLockViewPasscodeEnteredViaMesa:(id)arg1;
- (void)passcodeLockViewPasscodeEntered:(id)arg1;
- (void)passcodeLockViewPasscodeDidChange:(id)arg1;
- (void)_endTimedPasscodeHysteresis;
- (void)_beginTimedPasscodeHysteresis;
- (void)_togglePasscodeEmergencyCallButtonIfNecessary;
- (_Bool)__shouldHidePasscodeForActiveCall;
- (void)_evaluateLockUIForActiveCalls;
- (_Bool)isHidingPasscodeViewDuringCall;
- (void)_passcodeStateChanged;
- (_Bool)_wantsToAnimateFromPasscodeLockOnFailedPasscodeAttemptAndBlocked;
- (_Bool)isPasscodeLockVisible;
- (void)setPasscodeLockVisible:(_Bool)arg1 animated:(_Bool)arg2 withUnlockSource:(int)arg3 andOptions:(id)arg4;
- (void)setPasscodeLockVisible:(_Bool)arg1 animated:(_Bool)arg2 completion:(CDUnknownBlockType)arg3;
- (void)_callCountChanged:(id)arg1;
- (void)_callInfoChanged:(id)arg1;
- (void)_handlePasscodePolicyChanged;
- (void)_handlePasscodeLockStateChanged;
- (void)_handleBacklightLevelChanged:(id)arg1;
- (void)_handleBacklightFadeEnded;
- (void)_handleDisplayTurnedOnWhileUILocked:(id)arg1;
- (void)_handleDisplayWillUndim;
- (void)_handleDisplayTurnedOff;
- (void)noteModalBannerIsVisible:(_Bool)arg1;
- (void)noteResetRestoreStateUpdated;
- (void)noteDeviceBlockedStatusUpdated;
- (void)_removePasscodeOverlayWithCompletion:(CDUnknownBlockType)arg1;
- (void)_addPasscodeOverlayWithCompletion:(CDUnknownBlockType)arg1;
- (void)_unsupportedChargingAccessoryStateChanged:(id)arg1;
- (void)infoOverlayWantsDismissal;
- (void)_removeInfoOverlayViewAnimated:(_Bool)arg1;
- (void)_addInfoOverlayViewWithTitle:(id)arg1;
- (void)overlay:(id)arg1 wantsStyleChange:(unsigned long long)arg2;
- (void)removeOverlay:(id)arg1 transitionIfNecessary:(_Bool)arg2 animated:(_Bool)arg3 completion:(CDUnknownBlockType)arg4;
- (void)removeOverlay;
- (void)addOverlay:(id)arg1 transitionIfNecessary:(_Bool)arg2 animated:(_Bool)arg3 completion:(CDUnknownBlockType)arg4;
- (void)__transitionOverlayAnimated:(_Bool)arg1 from:(id)arg2 to:(id)arg3 completion:(CDUnknownBlockType)arg4;
- (void)_removeAllOverlays;
- (_Bool)_shouldDismissSwitcherOnActivation;
- (_Bool)hasTranslucentBackground;
- (void)didRotateFromInterfaceOrientation:(long long)arg1;
- (void)willRotateToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
- (void)willAnimateRotationToInterfaceOrientation:(long long)arg1 duration:(double)arg2;
- (unsigned long long)supportedInterfaceOrientations;
- (long long)preferredInterfaceOrientationForPresentation;
- (_Bool)shouldAutorotate;
- (_Bool)_forcesPortraitOrientation;
- (_Bool)suppressesControlCenter;
- (_Bool)suppressesNotificationCenter;
- (_Bool)suppressesBanners;
- (_Bool)handleHeadsetButtonPressed:(_Bool)arg1;
- (_Bool)handleVolumeDownButtonPressed;
- (_Bool)handleVolumeUpButtonPressed;
- (_Bool)handleLockButtonPressed;
- (_Bool)handleMenuButtonHeld;
- (_Bool)handleMenuButtonTap;
- (_Bool)handleMenuButtonDoubleTap;
- (_Bool)showsSpringBoardStatusBar;
- (_Bool)allowsStackingOfAlert:(id)arg1;
- (int)statusBarStyleOverridesToCancel;
- (long long)statusBarStyle;
- (void)alertDisplayWillBecomeVisible;
- (id)alertDisplayViewWithSize:(struct CGSize)arg1;
- (void)_notificationCenterDidPresent:(id)arg1;
- (void)_notificationCenterWillPresent:(id)arg1;
- (void)viewDidDisappear:(_Bool)arg1;
- (void)viewWillDisappear:(_Bool)arg1;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (void)_setStatusBarUserInteractionEnabledForTopGrabber:(_Bool)arg1;
- (void)displayDidDisappear;
- (void)willBeginDeactivationForTransitionToApps:(id)arg1 animated:(_Bool)arg2;
- (void)deactivate;
- (void)activate;
- (_Bool)allowSystemGestureAtLocation:(struct CGPoint)arg1;
- (void)shakeSlideToUnlockTextWithCustomText:(id)arg1;
- (void)prepareForMesaUnlockWithCompletion:(CDUnknownBlockType)arg1;
- (_Bool)lockScreenIsShowingBulletins;
- (_Bool)wantsToShowStatusBarTime;
- (_Bool)shouldShowStatusBarOnDeactivation;
- (_Bool)shouldShowLockStatusBarTime;
- (_Bool)_isFadeInAnimationInProgress;
- (void)_startFadeInAnimationForBatteryView:(_Bool)arg1;
- (void)startLockScreenFadeInAnimationForSource:(int)arg1;
- (void)noteExitingLostMode;
- (void)prepareToEnterLostMode;
- (_Bool)isShowingOverheatUI;
- (void)noteNextUnlockShouldReturnToCallIfPossible:(_Bool)arg1;
- (void)noteStartingPhoneCallWhileUILocked;
- (void)activateCameraAnimated:(_Bool)arg1;
- (void)finishUIUnlockFromSource:(int)arg1;
- (void)prepareForUIUnlock;
- (void)prepareForExternalUIUnlock;
- (_Bool)canBeDeactivatedForUIUnlockFromSource:(int)arg1;
- (_Bool)requiresPasscodeInputForUIUnlockFromSource:(int)arg1 withOptions:(id)arg2;
- (id)_effectiveLockScreenActionContext;
- (id)currentLockScreenActionContext;
- (void)setForcesPasscodeViewDuringCall:(_Bool)arg1;
- (void)setInScreenOffMode:(_Bool)arg1 forAutoUnlock:(_Bool)arg2;
- (void)setInScreenOffMode:(_Bool)arg1;
- (void)_updateGrabbersForScreenOffMode;
- (_Bool)isInScreenOffMode;
- (_Bool)isLockScreenVisible;
- (_Bool)isAllowingWallpaperBlurUpdates;
- (_Bool)lockScreenViewIsCurrentlyBeingDisplayed;
- (_Bool)shouldShowSlideToUnlockTextImmediately;
- (void)addCoordinatedPresentingController:(id)arg1;
- (void)removeCoordinatedPresentingController:(id)arg1;
- (id)effectiveCustomSlideToUnlockText;
- (_Bool)lockScreenViewPhonePluginIsActive;
- (void)lockScreenView:(id)arg1 didEndScrollingOnPage:(long long)arg2;
- (void)lockScreenViewWillEndDraggingWithPercentScrolled:(double)arg1 percentScrolledVelocity:(double)arg2 targetScrollPercentage:(double)arg3;
- (void)lockScreenViewDidScrollWithNewScrollPercentage:(double)arg1 tracking:(_Bool)arg2;
- (void)_adjustLockScreenWallpaperAlphaForPercentScrolled:(double)arg1 scrollViewTracking:(_Bool)arg2;
- (void)lockScreenViewDidBeginScrolling:(id)arg1;
- (void)lockScreenView:(id)arg1 didScrollToPage:(long long)arg2;
- (void)_postPasscodeLockNotification:(long long)arg1;
- (void)_setHintManagerEnabledIfPossible:(_Bool)arg1;
- (void)_setHintManagerEnabledIfPossible:(_Bool)arg1 removingLockScreenView:(_Bool)arg2;
- (_Bool)isBounceEnabledForPresentingController:(id)arg1 locationInWindow:(struct CGPoint)arg2;
- (_Bool)isPresentationEnabledForPresentingController:(id)arg1 locationInWindow:(struct CGPoint)arg2;
- (_Bool)isSystemGesturePermittedForPresentingController:(id)arg1;
- (unsigned long long)hintEdgeForController:(id)arg1;
- (double)hintDisplacementForController:(id)arg1;
- (void)_handleSuggestedAppChanged:(id)arg1;
- (_Bool)_disableIdleTimer:(_Bool)arg1;
- (_Bool)wasAutoUnlocked;
- (void)_removeMediaControls;
- (void)_addMediaControls;
- (void)_removeBatteryChargingView;
- (void)_addBatteryChargingViewAndShowBattery:(_Bool)arg1;
- (void)_removeNotificationView;
- (void)_addNotificationView;
- (void)_removeModalAlertView;
- (void)_addModalAlertView;
- (void)_removeTimerView;
- (void)_addTimerView;
- (void)_addTimerViewIfNecessary;
- (void)_removeStatusTextView;
- (void)_addStatusTextView;
- (void)_removeDateView;
- (void)_addDateView;
- (void)_addRemoveOrChangePasscodeViewIfNecessary;
- (void)_removeRestoreView:(_Bool)arg1;
- (void)_addOrRemoveResetRestoreViewIfNecessary:(_Bool)arg1;
- (id)_currentTextForResetOrRestoreState;
- (void)_removeThermalTrapView:(_Bool)arg1;
- (void)_addOrRemoveThermalTrapViewIfNecessary:(_Bool)arg1;
- (void)_removeModalBannerOverlay:(_Bool)arg1;
- (void)_addOrRemoveModalBannerOverlay:(_Bool)arg1;
- (void)_removeBlockedView:(_Bool)arg1;
- (void)_addOrRemoveBlockedViewIfNecessary:(_Bool)arg1;
- (void)_addBottomLeftGrabberIfNecessaryForAutoUnlock:(_Bool)arg1;
- (void)_addCameraGrabberIfNecessary;
- (void)_createCameraControllerIfNecessary;
- (void)_prepareWallpaperForUnlockedMode;
- (void)_prepareWallpaperForLockedMode;
- (id)lockScreenHintManager;
- (id)_lockScreenViewCreatingIfNecessary;
- (id)lockScreenView;
- (void)_releaseLockScreenView;
- (void)loadView;
- (void)dealloc;
- (id)initWithNibName:(id)arg1 bundle:(id)arg2;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end

