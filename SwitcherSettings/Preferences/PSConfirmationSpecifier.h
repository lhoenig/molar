/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "PSSpecifier.h"

@class NSString;

@interface PSConfirmationSpecifier : PSSpecifier {
	NSString *_title;	// 72 = 0x48
	NSString *_okButton;	// 76 = 0x4c
	NSString *_cancelButton;	// 80 = 0x50
}
@property(readonly, retain) NSString *cancelButton;	// G=0x318afdf0; converted property
@property(readonly, retain) NSString *okButton;	// G=0x318afddc; converted property
@property(retain) NSString *title;	// G=0x318afdc8; S=0x318afd6c; converted property
+ (id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;	// 0x318afb7c
// converted property getter: - (id)cancelButton;	// 0x318afdf0
- (void)dealloc;	// 0x318afe04
// converted property getter: - (id)okButton;	// 0x318afddc
// converted property setter: - (void)setTitle:(id)title;	// 0x318afd6c
- (void)setupWithDictionary:(id)dictionary;	// 0x318afc60
// converted property getter: - (id)title;	// 0x318afdc8
@end

