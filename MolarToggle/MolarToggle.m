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
#import "HBPreferences.h"

#define kNotificationName @"de.hoenig.molar/ReloadPrefs"
#define kMolarBundleIdentifier @"de.hoenig.molar"

static void sendReloadNotif() {
    CFStringRef notificationName = (CFStringRef)kNotificationName;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
    CFRelease(notificationName);
}

@interface MolarToggle : NSObject<LAListener> {
    @private HBPreferences *prefs;
}
@end

@implementation MolarToggle

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event {
    if (!prefs) {
        prefs = [[HBPreferences alloc] initWithIdentifier:kMolarBundleIdentifier];
    }
    [prefs setBool:![prefs boolForKey:@"enabled"] forKey:@"enabled"];
    sendReloadNotif();
    [event setHandled:YES];
}

+ (void)load {
	@autoreleasepool {
		[[LAActivator sharedInstance] registerListener:[self new] forName:@"de.hoenig.MolarToggle"];
	}
}

@end
