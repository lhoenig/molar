/**
 * This header is generated by class-dump-z 0.2a.
 * class-dump-z is Copyright (C) 2009 by KennyTM~, licensed under GPLv3.
 *
 * Source: /System/Library/PrivateFrameworks/Preferences.framework/Preferences
 */

#import "PSSpecifier.h"

@class NSString;

@interface PSTextFieldSpecifier : PSSpecifier {
	SEL bestGuess;	// 72 = 0x48
@private
	NSString *_placeholder;	// 76 = 0x4c
	NSString *_suffix;	// 80 = 0x50
}
@property(retain) NSString *placeholder;	// G=0x318afb00; S=0x318afaac; converted property
@property(retain) NSString *suffix;	// G=0x318afb68; S=0x318afb14; converted property
+ (id)preferenceSpecifierNamed:(id)named target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(int)cell edit:(Class)edit;	// 0x318af94c
- (void)dealloc;	// 0x318afa30
// converted property getter: - (id)placeholder;	// 0x318afb00
// converted property setter: - (void)setPlaceholder:(id)placeholder;	// 0x318afaac
// converted property setter: - (void)setSuffix:(id)suffix;	// 0x318afb14
// converted property getter: - (id)suffix;	// 0x318afb68
@end

