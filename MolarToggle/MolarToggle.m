//
//  MolarToggle.m
//  MolarToggle
//
//  Created by Lukas Hönig on 09.04.19.
//  Copyright (c) 2019 ___ORGANIZATIONNAME___. All rights reserved.
//

// LibActivator by Ryan Petrich
// See https://github.com/rpetrich/libactivator

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

#error iOSOpenDev post-project creation from template requirements (remove these lines after completed) -- \
 Link to libactivator.dylib: \
 (1) go to TARGETS > Build Phases > Link Binary With Libraries and add /opt/iOSOpenDev/lib/libactivator.dylib

@interface MolarToggle : NSObject<LAListener, UIAlertViewDelegate> {
@private
	UIAlertView *av;
}
@end

@implementation MolarToggle

- (BOOL)dismiss
{
	if (av)
	{
		[av dismissWithClickedButtonIndex:[av cancelButtonIndex] animated:YES];
		return YES;
	}
	return NO;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if (![self dismiss])
	{
		av = [[UIAlertView alloc] initWithTitle:@"MolarToggle" message:[event name] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[av show];
		[event setHandled:YES];
	}
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
	// Called when event is escalated to higher event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator otherListenerDidHandleEvent:(LAEvent *)event
{
	// Called when other listener receives an event
	[self dismiss];
}

- (void)activator:(LAActivator *)activator receiveDeactivateEvent:(LAEvent *)event
{
	// Called when the home button is pressed.
	// If showing UI, then dismiss it and call setHandled:.
	if ([self dismiss])
		[event setHandled:YES];
}


+ (void)load
{
	@autoreleasepool
	{
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"de.hoenig.MolarToggle"];
	}
}

@end
