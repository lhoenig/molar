
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <libactivator.h>

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define SWITCHER_HEIGHT 140
#define APP_GAP 32
#define SCREEN_BORDER_GAP 10
#define ICON_SIZE 80
#define CORNER_RADIUS 20
#define CORNER_RADIUS_OVERLAY 10
#define OVERLAY_SIZE 125

#define CMD_KEY   0xe3
#define CMD_KEY_2 0xe7
#define TAB_KEY   0x2b
#define T_KEY     0x17
#define ESC_KEY   0x29
#define RIGHT_KEY 0x4f
#define LEFT_KEY  0x50

void handle_event(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {}
BOOL darkMode, hideLabels, enabled, switcherOpenedInLandscape;
NSString *launcherApp1, *launcherApp2, *launcherApp3, *launcherApp4, *launcherApp5, *launcherApp6, *launcherApp7, *launcherApp8, *launcherApp9, *launcherApp0;
NSTimer *discoverabilityTimer;
NSArray *customShortcuts;

%hookf(void, handle_event, void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    //NSLog(@"handle_event : %d", IOHIDEventGetType(event));
    if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int usagePage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsagePage);
        int usage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        int down = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
       	if (usage == TAB_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TabKeyDown" object:nil];
       	else if (usage == T_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TKeyDown" object:nil];
        else if ((usage == CMD_KEY && down) || (usage == CMD_KEY_2 && down)) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyDown" object:nil];
        else if ((usage == CMD_KEY && !down) || (usage == CMD_KEY_2 && !down)) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyUp" object:nil];
        else if (usage == ESC_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"EscKeyDown" object:nil];
        else if (usage == RIGHT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"RightKeyDown" object:nil];
        else if (usage == LEFT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftKeyDown" object:nil];
        //NSLog(@"usage: %i     down: %i", usage, down);
    }
}

static void loadPrefs() {
	CFPreferencesAppSynchronize(CFSTR("de.hoenig.molar"));
	
	CFPropertyListRef cf_enabled = CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.hoenig.molar"));
	CFPropertyListRef cf_darkMode = CFPreferencesCopyAppValue(CFSTR("darkMode"), CFSTR("de.hoenig.molar"));
	CFPropertyListRef cf_hideLabels = CFPreferencesCopyAppValue(CFSTR("hideLabels"), CFSTR("de.hoenig.molar"));
	
	launcherApp1 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp1"), CFSTR("de.hoenig.molar"));
	launcherApp2 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp2"), CFSTR("de.hoenig.molar"));
	launcherApp3 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp3"), CFSTR("de.hoenig.molar"));
	launcherApp4 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp4"), CFSTR("de.hoenig.molar"));
	launcherApp5 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp5"), CFSTR("de.hoenig.molar"));
	launcherApp6 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp6"), CFSTR("de.hoenig.molar"));
	launcherApp7 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp7"), CFSTR("de.hoenig.molar"));
	launcherApp8 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp8"), CFSTR("de.hoenig.molar"));
	launcherApp9 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp9"), CFSTR("de.hoenig.molar"));
	launcherApp0 = (NSString *)CFPreferencesCopyAppValue(CFSTR("launcherApp0"), CFSTR("de.hoenig.molar"));

	enabled = (cf_enabled == kCFBooleanTrue);
	darkMode = (cf_darkMode == kCFBooleanTrue);
	hideLabels = (cf_hideLabels == kCFBooleanTrue);

	customShortcuts = (NSArray *)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("shortcuts"), CFSTR("de.hoenig.molar")));

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadShortcutsNotification" object:nil];
}
 
%ctor {
	discoverabilityTimer = nil;
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), 
    								NULL, 
    								(CFNotificationCallback)loadPrefs, 
    								CFSTR("de.hoenig.molar-preferencesChanged"),
    								NULL, 
    								CFNotificationSuspensionBehaviorCoalesce);
}

%hook UIApplication

%new
- (NSUInteger)maxIconsLS {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 6;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 5;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 4;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 4;
	else return 4;
}

%new
- (NSUInteger)maxIconsH {
	CGRect bounds = [[UIScreen mainScreen] bounds];
	if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 3;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 3;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 2;
	else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 2;
	else return 2;
}

%new
- (void)handleCmdTab:(UIKeyCommand *)keyCommand {	

	//[discoverabilityTimer invalidate];

	%c(SpringBoard);
	BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
	//NSLog(@"statusBarOrientation: %i", [[SpringBoard sharedApplication] activeInterfaceOrientation]);

    CGRect bounds = [[UIScreen mainScreen] bounds];
    //NSLog(@"Bounds: %@", NSStringFromCGRect(bounds));

	if (![self switcherShown] && enabled) {

		NSArray *apps = (NSArray *)[(SBApplicationController *)[%c(SBApplicationController) sharedInstance] runningApplications];
		
		if (apps.count) {
			
			NSMutableArray *appsFiltered = [NSMutableArray new];			
			NSMutableArray *switcherItemsFiltered = [NSMutableArray new];
			NSMutableArray *icons = [NSMutableArray new];
			%c(SBAppSwitcherModel);
			NSArray *switcherItems = [(SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance] mainSwitcherDisplayItems];
			%c(SBApplication);
			%c(SBApplicationIcon);
			for (int i = 0; i < switcherItems.count; ++i) {
				for (SBApplication *app in apps) {
					if ([(NSString *)[app bundleIdentifier] isEqualToString:(NSString *)[switcherItems[i] displayIdentifier]]) {
						[appsFiltered addObject:app];
						[switcherItemsFiltered addObject:switcherItems[i]];
						SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
						[icons addObject:[self image:(UIImage *)[icon getIconImage:8] scaledToSize:CGSizeMake(ICON_SIZE, ICON_SIZE)]];
						break;
					}
				}
			}
			[self setApps:appsFiltered];
			[self setSwitcherItems:switcherItemsFiltered];

			if (appsFiltered.count) {
				
				CGRect contentFrame = CGRectMake(0, 0, ls ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width,
													   ls ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height);
	
				//UIWindow *window = [[UIWindow alloc] initWithFrame:contentFrame];
				UIWindow *window = [[UIWindow alloc] initWithFrame:((NSUInteger)[self maxIconsLS] == 6) ? contentFrame : bounds];
				window.windowLevel = UIWindowLevelAlert;
				
				/*UIView *colorView = [[UIView alloc] initWithFrame:bounds];
				colorView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
				[window addSubview:colorView];*/
				
				CGFloat h = SWITCHER_HEIGHT;
				CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH])) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
																								 : ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH]) * ICON_SIZE + ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH]) + 1) * APP_GAP);
	 			UIView *switcherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	 			switcherView.backgroundColor = [UIColor clearColor];
	 			switcherView.layer.cornerRadius = CORNER_RADIUS;

	 			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:darkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
	    		UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	    		blurEffectView.frame = switcherView.bounds;
	    		blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	    		blurEffectView.layer.cornerRadius = CORNER_RADIUS;
	    		blurEffectView.clipsToBounds = YES;

	    		[switcherView addSubview:blurEffectView];

	    		UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:switcherView.frame];
	    		scrollView.backgroundColor = [UIColor clearColor];
	    		scrollView.layer.cornerRadius = CORNER_RADIUS;
	    		scrollView.contentSize = CGSizeMake(APP_GAP * (appsFiltered.count + 1) + ICON_SIZE * appsFiltered.count, SWITCHER_HEIGHT);
	    		scrollView.scrollEnabled = NO;
	    		scrollView.showsHorizontalScrollIndicator = NO;
	    		[self setScrollView:scrollView];

				NSMutableArray *iviews = [NSMutableArray new];
	    		NSMutableArray *labels = [NSMutableArray new];
	    		for (int i = 0; i < icons.count; ++i) {
	    			UIImageView *iconView = [[UIImageView alloc] initWithImage:icons[i]];
	    			iconView.frame = CGRectMake(APP_GAP * (i + 1) + ICON_SIZE * i, (SWITCHER_HEIGHT / 2) - (ICON_SIZE / 2), ICON_SIZE, ICON_SIZE);
	    			[iviews addObject:iconView];
	    			[scrollView addSubview:iconView];

	    			UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ICON_SIZE, 15)];
	    			appName.center = iconView.center;
	    			appName.frame = CGRectMake(appName.frame.origin.x, appName.frame.origin.y + ICON_SIZE / 2 + 10, appName.frame.size.width, appName.frame.size.height);
	    			appName.text = [(SBApplication *)appsFiltered[i] displayName];
	    			appName.textAlignment = NSTextAlignmentCenter;
	    			appName.font = [UIFont systemFontOfSize:12];
	    			appName.textColor = [UIColor whiteColor];
	    			appName.alpha = 0;
	    			[labels addObject:appName];
	    			[scrollView addSubview:appName];
	    		}

	    		[self setAppLabels:labels];
				[self setImageViews:iviews];
				if (labels.count > 1 && [(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication]) [self setSelectedIcon:[NSNumber numberWithInt:1]];
				else [self setSelectedIcon:[NSNumber numberWithInt:0]];
				if (labels.count && !hideLabels) ((UILabel *)labels[((NSNumber *)[self selectedIcon]).intValue]).alpha = 1;

	    		UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, OVERLAY_SIZE, OVERLAY_SIZE)];
	    		overlayView.backgroundColor = darkMode ? [[UIColor whiteColor] colorWithAlphaComponent:0.15] : [[UIColor blackColor] colorWithAlphaComponent:0.12];
	    		overlayView.layer.cornerRadius = CORNER_RADIUS_OVERLAY;
	    		overlayView.center = ((UIView *)[iviews objectAtIndex:((NSNumber *)[self selectedIcon]).intValue]).center;	
	    		[switcherView insertSubview:overlayView atIndex:1];
	    		[self setOverlayView:overlayView];

	    		[switcherView insertSubview:scrollView atIndex:2];

				if (ls) switcherView.transform = (UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation] == UIInterfaceOrientationLandscapeLeft ? 
													CGAffineTransformMakeRotation(DegreesToRadians(270)) :
													CGAffineTransformMakeRotation(DegreesToRadians(90));
				else if ((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
					switcherView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
				}
				switcherView.center = (NSUInteger)[self maxIconsLS] == 6 ? CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds)) :
																		   CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
																		   
				[window addSubview:switcherView];
				[self setSwitcherView:switcherView];
				[self setSwitcherWindow:window];
				[window makeKeyAndVisible];
				
				[self setSwitcherShown:[NSNull null]];
				switcherOpenedInLandscape = ls; 
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SwitcherDidAppearNotification"];
			}
		}
	} 
	else if (((NSArray *)[self apps]).count > 1) {

		[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			
			int nextImageViewIndex = (((NSNumber *)[self selectedIcon]).intValue + 1) % ((NSArray *)[self imageViews]).count;

			UIImageView *nextImageView = (UIImageView *)[self imageViews][nextImageViewIndex];

			CGRect rectForScrollView = CGRectMake(nextImageView.frame.origin.x - APP_GAP, 0, 2 * APP_GAP + ICON_SIZE, SWITCHER_HEIGHT);

			[(UIScrollView *)[self scrollView] scrollRectToVisible:rectForScrollView animated:NO];
			
			((UIView *)[self overlayView]).center = CGPointMake(nextImageView.center.x - ((UIScrollView *)[self scrollView]).contentOffset.x,
																nextImageView.center.y - ((UIScrollView *)[self scrollView]).contentOffset.y);

			if (!hideLabels) {
				((UILabel *)[self appLabels][((NSNumber *)[self selectedIcon]).intValue]).alpha = 0;
				((UILabel *)[self appLabels][nextImageViewIndex]).alpha = 1;
			}
		
			[self setSelectedIcon:[NSNumber numberWithInt:nextImageViewIndex]];
		} completion:nil];
	}
}

%new
- (void)handleCmdLeft {

	if (((NSArray *)[self apps]).count > 1) {

		BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);

		[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			
			int nextImageViewIndex = (((NSNumber *)[self selectedIcon]).intValue - 1) < 0 ? (((NSArray *)[self imageViews]).count - 1) :
									 ((((NSNumber *)[self selectedIcon]).intValue - 1) % ((NSArray *)[self imageViews]).count);
			
			UIImageView *nextImageView = (UIImageView *)[self imageViews][nextImageViewIndex];

			CGRect rectForScrollView = CGRectMake(nextImageView.frame.origin.x - APP_GAP, 0, 2 * APP_GAP + ICON_SIZE, SWITCHER_HEIGHT);

			[(UIScrollView *)[self scrollView] scrollRectToVisible:rectForScrollView animated:NO];
			
			((UIView *)[self overlayView]).center = CGPointMake(nextImageView.center.x - ((UIScrollView *)[self scrollView]).contentOffset.x,
																nextImageView.center.y - ((UIScrollView *)[self scrollView]).contentOffset.y);

			if (!hideLabels) {
				((UILabel *)[self appLabels][((NSNumber *)[self selectedIcon]).intValue]).alpha = 0;
				((UILabel *)[self appLabels][nextImageViewIndex]).alpha = 1;
			}
	
			[self setSelectedIcon:[NSNumber numberWithInt:nextImageViewIndex]];
		} completion:nil];
	}
}

%new
- (void)dismissAppSwitcher {
	[[self switcherWindow] setHidden:YES];
	[self setSwitcherShown:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SwitcherDidDisappearNotification"];
}

%new
- (id)switcherShown {
	return objc_getAssociatedObject(self, @selector(switcherShown));
}

%new
- (void)setSwitcherShown:(id)value {
	objc_setAssociatedObject(self, @selector(switcherShown), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIView *)switcherView {
	return objc_getAssociatedObject(self, @selector(switcherView));
}

%new
- (void)setSwitcherView:(UIView *)value {
	objc_setAssociatedObject(self, @selector(switcherView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIWindow *)switcherWindow {
	return objc_getAssociatedObject(self, @selector(switcherWindow));
}

%new
- (void)setSwitcherWindow:(UIWindow *)value {
	objc_setAssociatedObject(self, @selector(switcherWindow), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSArray *)imageViews {
	return objc_getAssociatedObject(self, @selector(imageViews));
}

%new
- (void)setImageViews:(NSArray *)value {
	objc_setAssociatedObject(self, @selector(imageViews), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSNumber *)selectedIcon {
	return objc_getAssociatedObject(self, @selector(selectedIcon));
}

%new
- (void)setSelectedIcon:(NSNumber *)value {
	objc_setAssociatedObject(self, @selector(selectedIcon), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIView *)overlayView {
	return objc_getAssociatedObject(self, @selector(overlayView));
}

%new
- (void)setOverlayView:(UIView *)value {
	objc_setAssociatedObject(self, @selector(overlayView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSArray *)apps {
	return objc_getAssociatedObject(self, @selector(apps));
}

%new
- (void)setApps:(NSArray *)value {
	objc_setAssociatedObject(self, @selector(apps), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSArray *)switcherItems {
	return objc_getAssociatedObject(self, @selector(switcherItems));
}

%new
- (void)setSwitcherItems:(NSArray *)value {
	objc_setAssociatedObject(self, @selector(switcherItems), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIView *)scrollView {
	return objc_getAssociatedObject(self, @selector(scrollView));
}

%new
- (void)setScrollView:(UIView *)value {
	objc_setAssociatedObject(self, @selector(scrollView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (NSArray *)appLabels {
	return objc_getAssociatedObject(self, @selector(appLabels));
}

%new
- (void)setAppLabels:(NSArray *)value {
	objc_setAssociatedObject(self, @selector(appLabels), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (void)setCmdDown:(id)value {
	objc_setAssociatedObject(self, @selector(cmdDown), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)cmdDown {
	return objc_getAssociatedObject(self, @selector(cmdDown));
}

%new
- (id)hidSetup {
	return objc_getAssociatedObject(self, @selector(hidSetup));
}

%new
- (void)setHidSetup:(id)value {
	objc_setAssociatedObject(self, @selector(hidSetup), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (void)handleCmdEnter:(UIKeyCommand *)keyCommand {
	if ([self switcherShown]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]]];
		[self dismissAppSwitcher];
	}
}

%new
- (void)handleCmdEsc:(UIKeyCommand *)keyCommand {
	if ([self switcherShown]) {
		[self dismissAppSwitcher];
		[self setSwitcherShown:nil];
	}

}

%new
- (void)handleCmdQ:(UIKeyCommand *)keyCommand {
	if ([self switcherShown] && [((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) pid] > 0) {
		
		//BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
		BOOL ls = switcherOpenedInLandscape;

		%c(SBDisplayItem);
		SBDisplayItem *di = ((NSArray *)[self switcherItems])[((NSNumber *)[self selectedIcon]).intValue];
		[[%c(SBAppSwitcherModel) sharedInstance] remove:di];
		[[%c(SBApplicationController) sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
	
		if (!((NSNumber *)[self selectedIcon]).intValue && ((NSArray *)[self switcherItems]).count == 1) {
			[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
				((UIView *)[self switcherView]).transform = CGAffineTransformConcat(((UIView *)[self switcherView]).transform, CGAffineTransformMakeScale(0.001, 0.001));
			} completion:^(BOOL completed){
				[self dismissAppSwitcher];		
				[self setSwitcherShown:nil];
			}];
			return;
		}

		NSMutableArray *mSwitcherItems = [NSMutableArray arrayWithArray:(NSArray *)[self switcherItems]];
		[mSwitcherItems removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setSwitcherItems:mSwitcherItems];

		NSMutableArray *mApps = [NSMutableArray arrayWithArray:(NSArray *)[self apps]];
		[mApps removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setApps:mApps];

		NSMutableArray *mLabels = [NSMutableArray arrayWithArray:(NSArray *)[self appLabels]];
		[(UIView *)[mLabels objectAtIndex:((NSNumber *)[self selectedIcon]).intValue] removeFromSuperview];
		[mLabels removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		((UIView *)[mLabels objectAtIndex:(((NSNumber *)[self selectedIcon]).intValue >= mLabels.count) ? mLabels.count - 1 : ((NSNumber *)[self selectedIcon]).intValue]).alpha = 1;
		[self setAppLabels:mLabels];
	

		[((NSArray *)[((UIScrollView *)[self scrollView]) subviews]) removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		NSMutableArray *mImageViews = [NSMutableArray arrayWithArray:(NSArray *)[self imageViews]];
		UIImageView *killedAppIV = [mImageViews objectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[mImageViews removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setImageViews:mImageViews];

		[self setSelectedIcon:[NSNumber numberWithInt:((NSNumber *)[self selectedIcon]).intValue - ((((NSNumber *)[self selectedIcon]).intValue >= mLabels.count) ? 1 : 0)]];

		CGFloat h = SWITCHER_HEIGHT;	
		CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH])) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
																								 : ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH]) * ICON_SIZE + ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsH]) + 1) * APP_GAP);
		CGRect newSwitcherFrame = CGRectMake(0, 0, ls ? h : w, ls ? w : h);
	    
	    CGSize newScrollViewContentSize = CGSizeMake(APP_GAP * (((NSArray *)[self apps]).count + 1) + ICON_SIZE * ((NSArray *)[self apps]).count, SWITCHER_HEIGHT);
		
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			// switcher view frame adjustment 
			((UIView *)[self switcherView]).frame = newSwitcherFrame;
			// scroll view content size
			((UIScrollView *)[self scrollView]).contentSize = newScrollViewContentSize;
			// animate killed app out
			if (((NSNumber *)[self selectedIcon]).intValue) killedAppIV.frame = CGRectMake(killedAppIV.frame.origin.x - ICON_SIZE, 
										   												   killedAppIV.frame.origin.y, 
										   												   killedAppIV.frame.size.width, 
										   												   killedAppIV.frame.size.height);
			killedAppIV.transform = CGAffineTransformMakeScale(0.001, 0.001);
			killedAppIV.alpha = 0;
			// adjust image view frames
			for (int i = 0; i < ((NSArray *)[self imageViews]).count; i++) {
				UIImageView *iv = (UIImageView *)[(NSArray *)[self imageViews] objectAtIndex:i];
			    iv.frame = CGRectMake(APP_GAP * (i + 1) + ICON_SIZE * i, 
			    					  (SWITCHER_HEIGHT / 2) - (ICON_SIZE / 2), 
			    					  ICON_SIZE, 
			    					  ICON_SIZE);
				UILabel *l = (UILabel *)[(NSArray *)[self appLabels] objectAtIndex:i];
				l.center = iv.center;
				l.frame = CGRectMake(l.frame.origin.x, 
									 l.frame.origin.y + ICON_SIZE / 2 + 10, 
									 l.frame.size.width, 
									 l.frame.size.height);
			}
			// set switcher view center
			((UIView *)[self switcherView]).center = CGPointMake(CGRectGetMidX(((UIWindow *)[self switcherWindow]).bounds), 
																 CGRectGetMidY(((UIWindow *)[self switcherWindow]).bounds));
			// set overlay view center
			((UIView *)[self overlayView]).center = CGPointMake(((UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue)]).center.x - ((UIScrollView *)[self scrollView]).contentOffset.x,
																((UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue)]).center.y - ((UIScrollView *)[self scrollView]).contentOffset.y);
		} completion:^(BOOL completed){
			[killedAppIV removeFromSuperview];
		}];
	}
}

%new
- (void)handleCmdShiftH:(UIKeyCommand *)keyCommand {
	[[%c(SBUIController) sharedInstance] clickedMenuButton];
}

%new
- (void)handleCmdShiftP:(UIKeyCommand *)keyCommand {
	[[%c(SBUserAgent) sharedUserAgent] lockAndDimDevice];
}

%new
- (void)handleCmd1:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp1]];
	}
}

%new
- (void)handleCmd2:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp2]];
	}
}

%new
- (void)handleCmd3:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp3]];
	}
}

%new
- (void)handleCmd4:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp4]];
	}
}

%new
- (void)handleCmd5:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp5]];
	}
}

%new
- (void)handleCmd6:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp6]];
	}
}

%new
- (void)handleCmd7:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp7]];
	}
}

%new
- (void)handleCmd8:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp8]];
	}
}

%new
- (void)handleCmd9:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp9]];
	}
}

%new
- (void)handleCmd0:(UIKeyCommand *)keyCommand {
	if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
		SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:launcherApp0]];
	}
}

%new
- (void)handleCustomShortcut:(UIKeyCommand *)keyCommand {
	for (NSDictionary *sc in customShortcuts) {
		if ([keyCommand.input isEqualToString:[sc objectForKey:@"input"]] && 
			keyCommand.modifierFlags == ((NSNumber *)[self modifierFlagsForShortcut:sc]).intValue) {
			//NSLog(@"GOT THE SHORTCUT!");
			LAEvent *event = [LAEvent eventWithName:[sc objectForKey:@"eventName"] mode:[LASharedActivator currentEventMode]];
        	[LASharedActivator sendEventToListener:event];
		}
	}
}

%new
- (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size {
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }

    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);

    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];

    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    //return image
    return image;	 
}

%new
- (void)rightKeyDown {
	if ([self switcherShown] && [self cmdDown]) [self handleCmdTab:nil];
}

%new
- (void)leftKeyDown {
	if ([self switcherShown] && [self cmdDown]) [self handleCmdLeft];
}

%new
- (void)escKeyDown {
	if ([self cmdDown]) [self handleCmdEsc:nil];
}

%new
- (void)tabKeyDown {
	[self handleKeyStatus:1];
}

%new
- (void)tKeyDown {
	[self handleKeyStatus:1];
}

%new
- (void)cmdKeyDown {
	/*discoverabilityTimer = [NSTimer scheduledTimerWithTimeInterval:1 
															target:self 
														  selector:@selector(showDiscoverability) 
													      userInfo:nil 
														   repeats:NO];*/
	[self setCmdDown:[NSNull null]];
	[self handleKeyStatus:0];
}

%new
- (void)cmdKeyUp {
	if (discoverabilityTimer) [discoverabilityTimer invalidate];
	[self setCmdDown:nil];
	[self handleKeyStatus:0];
}

%new
- (void)handleKeyStatus:(int)tabDown {
	if (![self cmdDown]) {
		[self handleCmdEnter:nil];
	}
	else if (tabDown) {
		[self handleCmdTab:nil];
	}
}

%new
- (void)showDiscoverability {
	discoverabilityTimer = nil;
	//NSLog(@"Discoverability!");
}

%new
- (NSNumber *)modifierFlagsForShortcut:(NSDictionary *)sc {
	int mFlags = 0;
	if (((NSNumber *)[sc objectForKey:@"cmd"]).boolValue) mFlags |= UIKeyModifierCommand;
	if (((NSNumber *)[sc objectForKey:@"ctrl"]).boolValue) mFlags |= UIKeyModifierControl;
	if (((NSNumber *)[sc objectForKey:@"alt"]).boolValue) mFlags |= UIKeyModifierAlternate;
	if (((NSNumber *)[sc objectForKey:@"shift"]).boolValue) mFlags |= UIKeyModifierShift;
	return @(mFlags);
}

%new
- (void)reloadShortcuts {
	[self _updateSerializableKeyCommandsForResponder:((UIWindow *)[UIWindow keyWindow]).rootViewController];
}

- (NSArray *)keyCommands {

	NSArray *orig_cmds = %orig;
	NSMutableArray *arr = [NSMutableArray arrayWithArray:orig_cmds];

	if (enabled) {
		//NSLog(@"ORIGINAL KEY COMMANDS: ---------- %i ------------\n%@", orig_cmds.count, orig_cmds.description);

		UIKeyCommand *cmdQ = [UIKeyCommand keyCommandWithInput:@"q"
	                   			  modifierFlags:UIKeyModifierCommand 
	                          	  action:@selector(handleCmdQ:)];
		[arr addObject:cmdQ];

		UIKeyCommand *cmdShiftH = [UIKeyCommand keyCommandWithInput:@"h"
	                   			  modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
	                          	  action:@selector(handleCmdShiftH:)];
		[arr addObject:cmdShiftH];

		UIKeyCommand *cmdShiftP = [UIKeyCommand keyCommandWithInput:@"p"
	                   			  modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
	                          	  action:@selector(handleCmdShiftP:)];
		[arr addObject:cmdShiftP];

		UIKeyCommand *cmd1 = [UIKeyCommand keyCommandWithInput:@"1"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd1:)];
		[arr addObject:cmd1];

		UIKeyCommand *cmd2 = [UIKeyCommand keyCommandWithInput:@"2"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd2:)];
		[arr addObject:cmd2];

		UIKeyCommand *cmd3 = [UIKeyCommand keyCommandWithInput:@"3"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd3:)];
		[arr addObject:cmd3];

		UIKeyCommand *cmd4 = [UIKeyCommand keyCommandWithInput:@"4"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd4:)];
		[arr addObject:cmd4];

		UIKeyCommand *cmd5 = [UIKeyCommand keyCommandWithInput:@"5"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd5:)];
		[arr addObject:cmd5];

		UIKeyCommand *cmd6 = [UIKeyCommand keyCommandWithInput:@"6"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd6:)];
		[arr addObject:cmd6];

		UIKeyCommand *cmd7 = [UIKeyCommand keyCommandWithInput:@"7"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd7:)];
		[arr addObject:cmd7];

		UIKeyCommand *cmd8 = [UIKeyCommand keyCommandWithInput:@"8"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd8:)];
		[arr addObject:cmd8];

		UIKeyCommand *cmd9 = [UIKeyCommand keyCommandWithInput:@"9"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd9:)];
		[arr addObject:cmd9];

		UIKeyCommand *cmd0 = [UIKeyCommand keyCommandWithInput:@"0"
	                   			  modifierFlags:UIKeyModifierCommand
	                          	  action:@selector(handleCmd0:)];
		[arr addObject:cmd0];

		CFPreferencesAppSynchronize(CFSTR("de.hoenig.molar"));
		customShortcuts = (NSArray *)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("shortcuts"), CFSTR("de.hoenig.molar")));
		for (NSDictionary *shortcut in customShortcuts) {
			NSString *input = [shortcut objectForKey:@"input"];
			if ([input isEqualToString:@"⏎"]) input = @"\n";
			else if ([input isEqualToString:@"⇥"]) input = @"\t";
			else if ([input isEqualToString:@"⌫"]) input = @"\b";
			else if ([input isEqualToString:@"␣"]) input = @" ";
			UIKeyCommand *customCommand = [UIKeyCommand keyCommandWithInput:input
															  modifierFlags:((NSNumber *)[self modifierFlagsForShortcut:shortcut]).intValue
																	 action:@selector(handleCustomShortcut:)];
			[arr addObject:customCommand];
	}

	if (![self hidSetup]) {
		IOHIDEventSystemClientRef ioHIDEventSystem = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
	    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystem, (IOHIDEventSystemClientEventCallback)handle_event, NULL, NULL);
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabKeyDown) name:@"TabKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tKeyDown) name:@"TKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyDown) name:@"CmdKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyUp) name:@"CmdKeyUp" object:nil];
	   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(escKeyDown) name:@"EscKeyDown" object:nil];
	   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightKeyDown) name:@"RightKeyDown" object:nil];
	   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftKeyDown) name:@"LeftKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadShortcuts) name:@"ReloadShortcutsNotification" object:nil];
	    [self setHidSetup:[NSNull null]];
	}

	}

	return [NSArray arrayWithArray:arr];
}

%end

/*
%hook UIViewController

- (NSArray *)keyCommands {
	NSArray *cmds = %orig();
	NSLog(@"KEY COMMANDS: %i\n%@", cmds.count, cmds.description);
	return cmds;
}

%end
*/