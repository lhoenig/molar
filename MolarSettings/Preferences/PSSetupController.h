/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import "PSRootController.h"

@class NSDictionary;

@interface PSSetupController : PSRootController {
	NSDictionary *_rootInfo;	// 52 = 0x34
	id<PSBaseView> _parentController;	// 56 = 0x38
}
@property(retain) id parentController;	// G=0x318bb1c0; S=0x318bbb1c; converted property
+ (BOOL)isOverlay;	// 0x318bc17c
- (id)initForContentSize:(CGSize)contentSize;	// 0x318bb100
- (id)controller;	// 0x318bbb30
- (void)dealloc;	// 0x318bb148
- (void)didFinishTransition;	// 0x318bb47c
- (void)dismiss;	// 0x318bbb88
- (void)forwardInvocation:(id)invocation;	// 0x318bc214
- (id)methodSignatureForSelector:(SEL)selector;	// 0x318bc184
- (void)navigationBar:(id)bar buttonClicked:(int)clicked;	// 0x318bbfec
// converted property getter: - (id)parentController;	// 0x318bb1c0
- (void)popControllerOnParent;	// 0x318bbf10
- (void)pushController:(id)controller;	// 0x318bb538
- (void)pushControllerOnParentWithSpecifier:(id)specifier;	// 0x318bbd14
// converted property setter: - (void)setParentController:(id)controller;	// 0x318bbb1c
- (void)setPrompt:(id)prompt;	// 0x318bc14c
- (void)setupRootListForSize:(CGSize)size;	// 0x318bb06c
- (void)showNavigationBarButtons:(id)buttons :(id)arg2;	// 0x318bc108
- (void)updateNavButtons;	// 0x318bc010
- (id)view;	// 0x318bb1a8
- (void)viewWillBecomeVisible:(void *)view;	// 0x318bb1d4
@end

