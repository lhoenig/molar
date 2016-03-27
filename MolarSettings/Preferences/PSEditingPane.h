/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import <UIKit/UIView.h>

@class PSSpecifier;

@interface PSEditingPane : UIView {
	PSSpecifier *_specifier;	// 32 = 0x20
	id _delegate;	// 36 = 0x24
	unsigned _requiresKeyboard : 1;	// 40 = 0x28
}
@property(retain) id preferenceSpecifier;	// G=0x318b6da4; S=0x318b6d40; converted property
@property(retain) id preferenceValue;	// G=0x318b6dbc; S=0x318b6db8; converted property
+ (id)defaultBackgroundColor;	// 0x318b6ddc
+ (CGSize)defaultSize;	// 0x318b6b50
- (id)initWithFrame:(CGRect)frame;	// 0x318b6ab4
- (void)addNewValue;	// 0x318b70a8
- (BOOL)changed;	// 0x318b70bc
- (CGRect)contentRect;	// 0x318b6bf8
- (void)dealloc;	// 0x318b6ccc
- (void)doneEditing;	// 0x318b70b0
- (BOOL)drawLabel;	// 0x318b6bf0
- (void)drawLabelInRect:(CGRect)rect;	// 0x318b6ea8
- (void)drawPinstripesInRect:(CGRect)rect;	// 0x318b6e24
- (void)drawRect:(CGRect)rect;	// 0x318b7028
- (void)editMode;	// 0x318b70ac
- (BOOL)handlesDoneButton;	// 0x318b70b4
// converted property getter: - (id)preferenceSpecifier;	// 0x318b6da4
// converted property getter: - (id)preferenceValue;	// 0x318b6dbc
- (BOOL)requiresKeyboard;	// 0x318b6dc4
- (void)setDelegate:(id)delegate;	// 0x318b6d2c
// converted property setter: - (void)setPreferenceSpecifier:(id)specifier;	// 0x318b6d40
// converted property setter: - (void)setPreferenceValue:(id)value;	// 0x318b6db8
- (id)specifierLabel;	// 0x318b6e7c
- (BOOL)wantsNewButton;	// 0x318b70a0
@end
