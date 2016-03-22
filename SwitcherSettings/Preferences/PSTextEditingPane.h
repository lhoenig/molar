/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import "PSEditingPane.h"

@class UITextField;

@interface PSTextEditingPane : PSEditingPane {
	UITextField *_textField;	// 44 = 0x2c
}
@property(retain) id preferenceValue;	// G=0x318b7384; S=0x318b7358; converted property
+ (CGSize)defaultSize;	// 0x318b70c4
- (id)initWithFrame:(CGRect)frame;	// 0x318b715c
- (BOOL)becomeFirstResponder;	// 0x318b7328
- (BOOL)drawLabel;	// 0x318b7154
// converted property getter: - (id)preferenceValue;	// 0x318b7384
- (void)setPreferenceSpecifier:(id)specifier;	// 0x318b73b0
// converted property setter: - (void)setPreferenceValue:(id)value;	// 0x318b7358
@end

