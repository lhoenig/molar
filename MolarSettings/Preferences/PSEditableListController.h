/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import "PSListController.h"


@interface PSEditableListController : PSListController {
	BOOL _editable;	// 96 = 0x60
}
@property(assign) BOOL editable;	// G=0x318bc634; S=0x318bc648; converted property
- (id)initForContentSize:(CGSize)contentSize;	// 0x318bc248
- (void)_updateNavigationBar:(BOOL)bar;	// 0x318bc2b8
// converted property getter: - (BOOL)editable;	// 0x318bc634
- (void)navigationBarButtonClicked:(int)clicked;	// 0x318bc5c4
- (BOOL)performDeletionActionForSpecifier:(id)specifier;	// 0x318bc7a4
- (void)pushController:(id)controller;	// 0x318bc568
// converted property setter: - (void)setEditable:(BOOL)editable;	// 0x318bc648
- (BOOL)table:(id)table canDeleteRow:(int)row;	// 0x318bc748
- (BOOL)table:(id)table canSelectRow:(int)row;	// 0x318bc6c0
- (void)table:(id)table deleteRow:(int)row;	// 0x318bc918
- (void)viewWillBecomeVisible:(void *)view;	// 0x318bc4bc
- (void)viewWillRedisplay;	// 0x318bc514
@end

