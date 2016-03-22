/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "Preferences-Structs.h"
#import "UITextViewLegacyDelegate.h"
#import "PSTableCell.h"

@class PSTextView;

@interface PSTextViewTableCell : PSTableCell <UITextViewLegacyDelegate> {
	PSTextView *_textView;	// 100 = 0x64
}
@property(retain) PSTextView *textView;	// G=0x318b4d74; S=0x318b4d88; converted property
- (BOOL)becomeFirstResponder;	// 0x318b4ce4
- (BOOL)canBecomeFirstResponder;	// 0x318b4d14
- (void)drawTitleInRect:(CGRect)rect selected:(BOOL)selected;	// 0x318b4e0c
- (BOOL)resignFirstResponder;	// 0x318b4d44
// converted property setter: - (void)setTextView:(id)view;	// 0x318b4d88
- (void)setValue:(id)value;	// 0x318b4bb8
// converted property getter: - (id)textView;	// 0x318b4d74
- (void)textViewDidResignFirstResponder:(id)textView;	// 0x318b4c20
@end

