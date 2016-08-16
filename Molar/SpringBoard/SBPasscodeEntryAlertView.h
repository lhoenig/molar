//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "SBAlertView.h"

@class SBAppStatusBarSettingsAssertion, SBUIPasscodeViewWithLockScreenStyle, UIView<SBUIPasscodeLockView>;

@interface SBPasscodeEntryAlertView : SBAlertView
{
    SBUIPasscodeViewWithLockScreenStyle *_passcodeView;
    _Bool _dismissing;
    SBAppStatusBarSettingsAssertion *_showStatusBarAssertion;
    id <SBPasscodeEntryAlertViewDelegate> _delegate;
}

@property(nonatomic) id <SBPasscodeEntryAlertViewDelegate> delegate; // @synthesize delegate=_delegate;
- (void)_dismissAnimationCompleted;
- (CDUnknownBlockType)_passcodeViewGenerator;
- (void)layoutForInterfaceOrientation:(long long)arg1;
- (_Bool)isReadyToBeRemovedFromView;
- (void)alertDisplayBecameVisible;
- (void)alertDisplayWillBecomeVisible;
- (void)setPasscodeViewsToVisible:(_Bool)arg1 animated:(_Bool)arg2 completion:(CDUnknownBlockType)arg3;
@property(readonly, nonatomic) UIView<SBUIPasscodeLockView> *passcodeLockView;
- (void)dealloc;
- (id)initWithFrame:(struct CGRect)arg1;

@end

