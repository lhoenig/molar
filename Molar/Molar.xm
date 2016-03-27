
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <libactivator.h>
#import <dlfcn.h>

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
#define UP_KEY    0x52
#define DOWN_KEY  0x51
#define ENTER_KEY 0x28
#define SHIFT_KEY 0xe5
#define E_KEY     0x8

#define MAGNIFY_FACTOR 2.0
#define SLIDER_LEVELS 20
#define FLASH_VIEW_CORNER_RADIUS 4.0
#define FLASH_VIEW_ANIM_DURATION 1.5

void handle_event(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {}
BOOL darkMode, hideLabels, enabled, switcherOpenedInLandscape, sliderMode, tableViewMode, scrollViewMode, collectionViewMode;
NSString *launcherApp1, *launcherApp2, *launcherApp3, *launcherApp4, *launcherApp5, *launcherApp6, *launcherApp7, *launcherApp8, *launcherApp9, *launcherApp0;
NSTimer *discoverabilityTimer;
NSArray *customShortcuts;
UITableView *selectedTableView;
UITableViewCell *selectedCell;
UICollectionView *selectedCollectionView;
UICollectionViewCell *selectedItem;
int selectedRow, selectedSection, selectedViewIndex;
UIView *fView;
NSString *activeApp;
NSThread *flashViewThread;

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
        else if (usage == E_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"EscKeyDown" object:nil];
        else if (usage == RIGHT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"RightKeyDown" object:nil];
        else if (usage == LEFT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftKeyDown" object:nil];
        else if (usage == UP_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"UpKeyDown" object:nil];
        else if (usage == DOWN_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"DownKeyDown" object:nil];
        else if (usage == ENTER_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterKeyDown" object:nil];
        else if (usage == SHIFT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"ShiftKeyDown" object:nil];
        else if (usage == SHIFT_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"ShiftKeyUp" object:nil];
        NSLog(@"usage: %i     down: %i", usage, down);
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

	enabled =  !cf_enabled ? YES : (cf_enabled == kCFBooleanTrue);
	darkMode = (cf_darkMode == kCFBooleanTrue);
	hideLabels = (cf_hideLabels == kCFBooleanTrue);

	customShortcuts = (NSArray *)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("shortcuts"), CFSTR("de.hoenig.molar")));

	[[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadShortcutsNotification" object:nil];
}

static void updateActiveAppUserApplication(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	activeApp = (NSString *)[(NSDictionary *)userInfo objectForKey:@"app"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateActiveAppUserApplicationNotification" object:nil userInfo:@{@"app": activeApp}];
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
    
    void *libHandle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
	CFNotificationCenterRef (*CFNotificationCenterGetDistributedCenter)() = (CFNotificationCenterRef (*)())dlsym(libHandle, "CFNotificationCenterGetDistributedCenter");
	if(CFNotificationCenterGetDistributedCenter) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), 
										NULL, 
										(CFNotificationCallback)updateActiveAppUserApplication, 
										CFSTR("NewFrontAppNotification"), 
										NULL, 
										CFNotificationSuspensionBehaviorCoalesce);
	}
	dlclose(libHandle);
}


%subclass HighlightThread : NSThread

%new
- (void)setView:(id)value {
	objc_setAssociatedObject(self, @selector(view), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)view {
	return objc_getAssociatedObject(self, @selector(view));
}

- (void)main {
	if (![self isCancelled]) {
		CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
		[anim1 setValue:@"borderColorAnimation1" forKey:@"id"];
		anim1.fromValue = (id)((UIView *)[self view]).layer.borderColor;
		anim1.toValue = (id)[UIColor whiteColor].CGColor;
		((UIView *)[self view]).layer.borderColor = [UIColor whiteColor].CGColor;
		anim1.duration = FLASH_VIEW_ANIM_DURATION;
		anim1.timingFunction = [CATransaction animationTimingFunction];
		anim1.delegate = self;
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
		[((UIView *)[self view]).layer addAnimation:anim1 forKey:@"borderColor"];
	}
}

%new
- (void)animationDidStop:(CAAnimation *)anim1 finished:(BOOL)flag {
	if ([[anim1 valueForKey:@"id"] isEqual:@"borderColorAnimation1"] && ![self isCancelled]) {
		CABasicAnimation *anim2 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
		[anim2 setValue:@"borderColorAnimation2" forKey:@"id"];
		anim2.fromValue = (id)((UIView *)[self view]).layer.borderColor;
		anim2.toValue = (id)[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		((UIView *)[self view]).layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;
		anim2.duration = FLASH_VIEW_ANIM_DURATION;
		anim2.timingFunction = [CATransaction animationTimingFunction];
		anim2.beginTime = anim1.beginTime + anim1.duration;
		anim2.delegate = self;
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
		[((UIView *)[self view]).layer addAnimation:anim2 forKey:@"borderColor"];
	}
	else if ([[anim1 valueForKey:@"id"] isEqual:@"borderColorAnimation2"] && ![self isCancelled]) {
		CABasicAnimation *anim1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
		[anim1 setValue:@"borderColorAnimation1" forKey:@"id"];
		anim1.fromValue = (id)((UIView *)[self view]).layer.borderColor;
		anim1.toValue = (id)[UIColor whiteColor].CGColor;
		((UIView *)[self view]).layer.borderColor = [UIColor whiteColor].CGColor;
		anim1.duration = FLASH_VIEW_ANIM_DURATION;
		anim1.timingFunction = [CATransaction animationTimingFunction];
		anim1.delegate = self;
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:)];
		[((UIView *)[self view]).layer addAnimation:anim1 forKey:@"borderColor"];
	}
}

%end


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
	
				UIWindow *window = [[UIWindow alloc] initWithFrame:((NSUInteger)[self maxIconsLS] == 6) ? contentFrame : bounds];
				window.windowLevel = UIWindowLevelAlert;
				
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
- (void)setShiftDown:(id)value {
	objc_setAssociatedObject(self, @selector(shiftDown), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)shiftDown {
	return objc_getAssociatedObject(self, @selector(shiftDown));
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
- (id)activeAppUserApplication {
	return objc_getAssociatedObject(self, @selector(activeAppUserApplication));
}

%new
- (void)setActiveAppUserApplication:(id)value {
	objc_setAssociatedObject(self, @selector(activeAppUserApplication), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
- (void)shiftKeyDown {
	[self setShiftDown:[NSNull null]];
}

%new
- (void)shiftKeyUp {
	[self setShiftDown:nil];
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

/*%new
- (void)showDiscoverability {
	discoverabilityTimer = nil;
	//NSLog(@"Discoverability!");
}*/

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

%new
- (void)updateActiveApp {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		%c(SpringBoard);
		%c(SBApplication);
		activeApp = [[(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication] bundleIdentifier];

	    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL}; 
    	CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    	CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, 
                                                                  &keyCallbacks, &valueCallbacks);
    	CFDictionaryAddValue(dictionary, CFSTR("app"), (CFStringRef)activeApp);
		
		CFStringRef notificationName = (CFStringRef)@"NewFrontAppNotification";
		
		void *libHandle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
		CFNotificationCenterRef (*CFNotificationCenterGetDistributedCenter)() = (CFNotificationCenterRef (*)())dlsym(libHandle, "CFNotificationCenterGetDistributedCenter");
		if(CFNotificationCenterGetDistributedCenter) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), 
												 notificationName, 
												 NULL, 
												 dictionary, 
												 YES);
		}
	}
}

%new
- (void)updateActiveAppProperty:(NSNotification *)notification {
	[self setActiveAppUserApplication:[notification.userInfo objectForKey:@"app"]];
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
		    
		    // app switcher
		    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabKeyDown) name:@"TabKeyDown" object:nil];
		    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tKeyDown) name:@"TKeyDown" object:nil];
		    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyDown) name:@"CmdKeyDown" object:nil];
		    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyUp) name:@"CmdKeyUp" object:nil];
		   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(escKeyDown) name:@"EscKeyDown" object:nil];
		   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightKeyDown) name:@"RightKeyDown" object:nil];
		   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftKeyDown) name:@"LeftKeyDown" object:nil];
		    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadShortcuts) name:@"ReloadShortcutsNotification" object:nil];
		    
		    // UI control
		 	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabDown) name:@"TabKeyDown" object:nil];
		 	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyDown) name:@"ShiftKeyDown" object:nil];
		 	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyUp) name:@"ShiftKeyUp" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterKey) name:@"EnterKeyDown" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftKey) name:@"LeftKeyDown" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightKey) name:@"RightKeyDown" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(upKey) name:@"UpKeyDown" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downKey) name:@"DownKeyDown" object:nil];
		   	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(escUI) name:@"EscKeyDown" object:nil];

	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetViews) name:@"ViewDidAppearNotification" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBAppDidBecomeForeground" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBApplicationStateDidChange" object:nil];
	 		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveAppProperty:) name:@"UpdateActiveAppUserApplicationNotification" object:nil];

		    [self setHidSetup:[NSNull null]];
		}
	}

	return [NSArray arrayWithArray:arr];
}

%new
- (NSMutableArray *)views {
	return objc_getAssociatedObject(self, @selector(views));
}

%new
- (void)setViews:(NSMutableArray *)value {
	objc_setAssociatedObject(self, @selector(views), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIView *)selectedView {
	return objc_getAssociatedObject(self, @selector(selectedView));
}

%new
- (void)setSelectedView:(UIView *)value {
	objc_setAssociatedObject(self, @selector(selectedView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new 
- (void)leftKey {
	if (sliderMode) {
		UISlider *slider = (UISlider *)[self selectedView];
		float dec = (slider.maximumValue - slider.minimumValue) / SLIDER_LEVELS;
		[slider setValue:slider.value-dec animated:YES];
		[slider sendActionsForControlEvents:UIControlEventValueChanged];	
	}
	else if (scrollViewMode) {
		if (fView) {
			[fView removeFromSuperview];
			fView = nil;
		}
		UIScrollView *scrollView = (UIScrollView *)[self selectedView];
		CGPoint newOffset;
		if ([self cmdDown]) {
			newOffset = CGPointMake(0,
									scrollView.contentOffset.y);
		} else {
			newOffset = CGPointMake(scrollView.contentOffset.x - ((scrollView.frame.size.width) / 3),
									scrollView.contentOffset.y);
			if (newOffset.x <  0) newOffset.x = 0;
		} 
		[scrollView setContentOffset:newOffset animated:YES];
	}
}

%new
- (void)rightKey {
	if (sliderMode) {
		UISlider *slider = (UISlider *)[self selectedView];
		float inc = (slider.maximumValue - slider.minimumValue) / SLIDER_LEVELS;
		[slider setValue:slider.value+inc animated:YES];
		[slider sendActionsForControlEvents:UIControlEventValueChanged];
	}
	else if (scrollViewMode) {
		if (fView) {
			[fView removeFromSuperview];
			fView = nil;
		}
		UIScrollView *scrollView = (UIScrollView *)[self selectedView];
		CGPoint newOffset;
		if ([self cmdDown]) {
			newOffset = CGPointMake(scrollView.contentSize.width - scrollView.frame.size.width,
									scrollView.contentOffset.y);
		} else {
			newOffset = CGPointMake(scrollView.contentOffset.x + ((scrollView.frame.size.width) / 3),
									scrollView.contentOffset.y);
			if (newOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width)) 
				newOffset.x = scrollView.contentSize.width - scrollView.frame.size.width;
		}
		[scrollView setContentOffset:newOffset animated:YES];
	}
}

%new
- (void)downKey {
	if (tableViewMode) {
		if ([self cmdDown]) {
			selectedSection = [selectedTableView numberOfSections] - 1;
			selectedRow = [selectedTableView numberOfRowsInSection:selectedSection] - 1;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			selectedCell = cell;
		} else if ([selectedTableView numberOfRowsInSection:selectedSection] > selectedRow + 1) {
			if (selectedCell) {
				selectedCell.selected = NO;
			}
			selectedRow++;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedCell = cell;
		} else if ([selectedTableView numberOfSections] > selectedSection + 1) {
			if (selectedCell) {
				selectedCell.selected = NO;
			}
			selectedRow = 0;
			selectedSection++;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedCell = cell;
		}
		CGAffineTransform backupTransform = selectedCell.transform;
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			[selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];		
			selectedCell.transform = CGAffineTransformConcat(selectedCell.transform, 
			CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
		} completion:nil];
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			selectedCell.transform = backupTransform;
		} completion:^(BOOL completed){
			selectedCell.selected = YES;
		}];
	}
	else if (collectionViewMode) {
		if ([selectedCollectionView numberOfItemsInSection:selectedSection] > selectedRow + 1) {
			if (selectedItem) {
				selectedItem.selected = NO;
			}
			selectedRow++;
			UICollectionViewCell *cell = [selectedCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedItem = cell;
		} else if ([selectedCollectionView numberOfSections] > selectedSection + 1) {
			if (selectedItem) {
				selectedItem.selected = NO;
			}
			selectedRow = 0;
			selectedSection++;
			UICollectionViewCell *cell = [selectedTableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedItem = cell;
		}
		CGAffineTransform backupTransform = selectedItem.transform;
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			[selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];		
			selectedItem.transform = CGAffineTransformConcat(selectedItem.transform, 
			CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
		} completion:nil];
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			selectedItem.transform = backupTransform;
		} completion:nil];
	}
	else if (scrollViewMode) {
		if (fView) {
			[fView removeFromSuperview];
			fView = nil;
		}
		UIScrollView *scrollView = (UIScrollView *)[self selectedView];
		CGPoint newOffset;
		if ([self cmdDown]) {
			newOffset = CGPointMake(scrollView.contentOffset.x,
									scrollView.contentSize.height - scrollView.frame.size.height);
		} else {
			newOffset = CGPointMake(scrollView.contentOffset.x,
									scrollView.contentOffset.y + (scrollView.frame.size.height / 3));
			if (newOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)) 
				newOffset.y = scrollView.contentSize.height - scrollView.frame.size.height;
		} 
		[scrollView setContentOffset:newOffset animated:YES];
	}
}

%new
- (void)upKey {
	if (tableViewMode) {
		if ([self cmdDown]) {
			selectedRow = selectedSection = 0;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedCell = cell;
		} else if ((selectedRow - 1) >= 0) {
			if (selectedCell) {
				selectedCell.selected = NO;
			}
			selectedRow--;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedCell = cell;
		} else if (selectedSection > 0) {
			if (selectedCell) {
				selectedCell.selected = NO;
			}
			selectedSection--;
			selectedRow = [selectedTableView numberOfRowsInSection:selectedSection] - 1;
			UITableViewCell *cell = [selectedTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedCell = cell;
		}
		CGAffineTransform backupTransform = selectedCell.transform;
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			[selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];		
			selectedCell.transform = CGAffineTransformConcat(selectedCell.transform, 
															 CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
		} completion:nil];
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			selectedCell.transform = backupTransform;
		} completion:^(BOOL completed){
			selectedCell.selected = YES;
		}];
	}
	else if (collectionViewMode) {
		if ((selectedRow - 1) >= 0) {
			if (selectedItem) {
				selectedItem.selected = NO;
			}
			selectedRow--;
			UICollectionViewCell *cell = [selectedCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedItem = cell;
		} else if (selectedSection > 0) {
			if (selectedItem) {
				selectedItem.selected = NO;
			}
			selectedSection--;
			selectedRow = [selectedCollectionView numberOfItemsInSection:selectedSection] - 1;
			UICollectionViewCell *cell = [selectedTableView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
			cell.selected = YES;
			selectedItem = cell;
		}
		CGAffineTransform backupTransform = selectedItem.transform;
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			[selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];		
			selectedItem.transform = CGAffineTransformConcat(selectedItem.transform, 
			CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
		} completion:nil];
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			selectedItem.transform = backupTransform;
		} completion:nil];
	}
	else if (scrollViewMode) {
		if (fView) {
			[fView removeFromSuperview];
			fView = nil;
		}
		UIScrollView *scrollView = (UIScrollView *)[self selectedView];
		CGPoint newOffset;
		if ([self cmdDown]) {
			newOffset = CGPointMake(scrollView.contentOffset.x, 0);
		} else {
			newOffset = CGPointMake(scrollView.contentOffset.x,
									scrollView.contentOffset.y - (scrollView.frame.size.height / 3));
			if (newOffset.y < 0) newOffset.y = 0;
		} 
		[scrollView setContentOffset:newOffset animated:YES];
	}
}

%new
- (void)enterKey {
	/*[self setViews:((UIView *)[self selectedView]).subviews];
	selectedViewIndex = -1;
	NSLog(@"New subviews:\n%@", ((NSArray *)[self views]).description);*/

	if ([self isActive]) {
		NSLog(@"Activating %@", ((UIView *)[self selectedView]).description);
		//NSLog(@"Subviews: %@", ((UIView *)[self selectedView]).subviews.description);
		if ([[self selectedView] isKindOfClass:[UITextField class]] || 
			[[self selectedView] isKindOfClass:[UITextView class]]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignTextFieldsNotification" object:nil];
		}
		if (tableViewMode) {
				if (selectedTableView.delegate && [selectedTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
					[selectedTableView.delegate tableView:selectedTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
		} else if (collectionViewMode) {
				if (selectedCollectionView.delegate && [selectedCollectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
					[selectedCollectionView.delegate collectionView:selectedCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
				// what if delegate doesnt respond
				//else [[self selectedView] sendActionsForControlEvents:UIControlEventTouchUpInside];
		} else {
			// text controls
			if ([[self selectedView] isKindOfClass:[UITextField class]] || 
				[[self selectedView] isKindOfClass:[UITextView class]]) {
				if ([(UIView *)[self selectedView] isFirstResponder]) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignTextFieldsNotification" object:nil];
				} else [[self selectedView] becomeFirstResponder];
			} else {
				[[self selectedView] becomeFirstResponder];
				if ([[self selectedView] isKindOfClass:[UIControl class]]) {
					// switch
					if ([[self selectedView] isKindOfClass:[UISwitch class]]) {
						[[self selectedView] sendActionsForControlEvents:UIControlEventValueChanged];
						((UISwitch *)[self selectedView]).on = !((UISwitch *)[self selectedView]).on;
					}
					// slider
					else if ([[self selectedView] isKindOfClass:[UISlider class]]) {
						sliderMode = YES;
						// maybe set to middle value
					}
					// stepper
					else if ([NSStringFromClass(((UIView *)[self selectedView]).class) isEqualToString:@"_UIStepperButton"]) {
						BOOL plus = ((NSArray *)[self views]).count > selectedViewIndex ? !([NSStringFromClass(((UIView *)[(NSArray *)[self views] objectAtIndex:selectedViewIndex + 1]).class) isEqualToString:@"_UIStepperButton"]) : YES;
						if (plus) {
							UIStepper *stepper = (UIStepper *)[(NSArray *)[self views] objectAtIndex:selectedViewIndex - 2];
							if (stepper.wraps && (stepper.value + stepper.stepValue) > stepper.maximumValue) stepper.value = stepper.minimumValue;
							else stepper.value += stepper.stepValue;
							[stepper sendActionsForControlEvents:UIControlEventValueChanged];
						} else {
							UIStepper *stepper = (UIStepper *)[(NSArray *)[self views] objectAtIndex:selectedViewIndex - 1];
							if (stepper.wraps && (stepper.value - stepper.stepValue) < stepper.minimumValue) stepper.value = stepper.maximumValue;
							else stepper.value -= stepper.stepValue;
							[stepper sendActionsForControlEvents:UIControlEventValueChanged];	
						}
					}
					// segmented control
					else if ([[self selectedView] isKindOfClass:[UISegmentedControl class]]) {
						if (!((UISegmentedControl *)[self selectedView]).momentary) {
							((UISegmentedControl *)[self selectedView]).selectedSegmentIndex = (((UISegmentedControl *)[self selectedView]).selectedSegmentIndex + 1) % 
																								((UISegmentedControl *)[self selectedView]).numberOfSegments;
							[[self selectedView] sendActionsForControlEvents:UIControlEventValueChanged];
						}
					}
					// page control
					else if ([[self selectedView] isKindOfClass:[UIPageControl class]]) {
						UIPageControl *pageControl = (UIPageControl *)[self selectedView];
						pageControl.currentPage = (pageControl.currentPage + 1) % pageControl.numberOfPages;
						[[self selectedView] sendActionsForControlEvents:UIControlEventValueChanged];
					}
					// other
					else [[self selectedView] sendActionsForControlEvents:UIControlEventTouchUpInside];
				}
			}
		}
	}
}

%new
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
   if ([rootViewController isKindOfClass:[UINavigationController class]]) {
       UINavigationController* navigationController = (UINavigationController*)rootViewController;
       return navigationController;
   }
   // Handling UITabBarController
   else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
       UITabBarController* tabBarController = (UITabBarController*)rootViewController;
       return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
   }
   // Handling Modal views
   else if (rootViewController.presentedViewController) {
       UIViewController* presentedViewController = rootViewController.presentedViewController;
       return [self topViewControllerWithRootViewController:presentedViewController];
   }
   // Handling UIViewController's added as subviews to some other views.
   else {
       for (UIView *view in [rootViewController.view subviews])
       {
           id subViewController = [view nextResponder];    // Key property which most of us are unaware of / rarely use.
           if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
           {
               return [self topViewControllerWithRootViewController:subViewController];
           }
       }
       return rootViewController;
   }
}

%new
- (void)escUI {
	UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
	if ([firstResponder isKindOfClass:[UITextField class]] || [firstResponder isKindOfClass:[UITextView class]]) {
		NSLog(@"RESIGNING TEXT FIELD");
		[firstResponder resignFirstResponder];
	} else {
		UIViewController *vc = [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
		if ([vc isKindOfClass:[UINavigationController class]]) {
			NSLog(@"TOP NAVIGATION CONTROLLER!");
			if ([self cmdDown] && ![self switcherShown]) {
				[vc popToRootViewControllerAnimated:YES];
			} else {
				[vc popViewControllerAnimated:YES];
			}
		} else {
			NSLog(@"TOP VC: %@", NSStringFromClass([vc class]));
		}
	}
}

%new
- (void)tabDown {
	if ([self shiftDown]) {
		[self highlightView:0];
	} else {
		[self highlightView:1];
	}
}

%new
- (BOOL)isActive {
	return [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:[self activeAppUserApplication]];
}

%new
- (void)highlightView:(int)next {
	if ([self isActive]) {
		if ([self views]) {
			if (next) {
				do {
					selectedViewIndex = (selectedViewIndex + 1) % ((NSArray *)[self views]).count;
				} while ([[(NSArray *)[self views] objectAtIndex:selectedViewIndex] isKindOfClass:[UIStepper class]]);
			}
			else {
				do {
					selectedViewIndex--;
					if (selectedViewIndex < 0) selectedViewIndex = ((NSArray *)[self views]).count - 1;
				} while ([[(NSArray *)[self views] objectAtIndex:selectedViewIndex] isKindOfClass:[UIStepper class]]);
			}
			if (((NSArray *)[self views]).count) {
				
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignTextFieldsNotification" object:nil];
				if (flashViewThread) [flashViewThread cancel];
				if (fView) [fView removeFromSuperview];

				if (tableViewMode) selectedCell.selected = NO;

				[self setSelectedView:[(NSArray *)[self views] objectAtIndex:selectedViewIndex]];
				//[(UIView *)[self selectedView] becomeFirstResponder];

				if ([[self selectedView] isKindOfClass:[UISlider class]]) sliderMode = YES;
				else sliderMode = NO;

				if ([[self selectedView] isKindOfClass:[UITableView class]]) {
					UITableView *tView = (UITableView *)[self selectedView];
					if ([tView numberOfSections] && [tView numberOfRowsInSection:0]) {
						selectedRow = selectedSection = 0;
						[self setSelectedView:[tView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]]];
						tableViewMode = YES;
						selectedCell = (UITableViewCell *)[self selectedView];
						selectedCell.selected = YES;
						selectedTableView = tView;
					}
				} else if ([[self selectedView] isKindOfClass:[UICollectionView class]]) {
					UICollectionView *cView = (UICollectionView *)[self selectedView];
					if ([cView numberOfSections] && [cView numberOfItemsInSection:0]) {
						selectedRow = selectedSection = 0;
						[self setSelectedView:[cView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]]];
						collectionViewMode = YES;
						selectedItem = (UICollectionViewCell *)[self selectedView];
						selectedItem.selected = YES;
						selectedCollectionView = cView;
					}
				} else {
					tableViewMode = NO;
					collectionViewMode = NO;
					if ([[self selectedView] isKindOfClass:[UIScrollView class]]) {
						scrollViewMode = YES;
					} else scrollViewMode = NO;
				}

				NSLog(@"View %i: %@", selectedViewIndex, ((UIView *)[self selectedView]).description);

				UIView *flashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 
																			 ((UIView *)[self selectedView]).frame.size.width,
																			 ((UIView *)[self selectedView]).frame.size.height)];
				flashView.backgroundColor = [UIColor whiteColor];
				flashView.layer.cornerRadius = (((UIView *)[self selectedView]).layer.cornerRadius != 0.0f) ? 
												((UIView *)[self selectedView]).layer.cornerRadius : FLASH_VIEW_CORNER_RADIUS;
				flashView.clipsToBounds = YES;
				flashView.userInteractionEnabled = NO;
				[(UIView *)[self selectedView] addSubview:flashView];
				[(UIView *)[self selectedView] bringSubviewToFront:flashView];

				CGAffineTransform backupTransform = ((UIView *)[self selectedView]).transform;
				flashView.transform = backupTransform;

				flashView.layer.borderWidth = 2.0f;
				flashView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;

				fView = flashView;

				[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
					((UIView *)[self selectedView]).transform = CGAffineTransformConcat(((UIView *)[self selectedView]).transform, 
																						CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
					flashView.transform = CGAffineTransformConcat(flashView.transform, 
																	  CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
				} completion:nil];
				[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
					((UIView *)[self selectedView]).transform = backupTransform;
					flashView.transform = backupTransform;
					flashView.backgroundColor = [UIColor clearColor]; //[UIColor colorWithWhite:0.65 alpha:0.5];
				} completion:^(BOOL completed){
					if (tableViewMode || collectionViewMode) [fView removeFromSuperview];
					else {
						HighlightThread *ht = (HighlightThread *)[%c(HighlightThread) new];
						flashViewThread = (NSThread *)ht;
						[ht setView:flashView];
						[ht start];
					}
				}];
			}
		}
	}
}

%new
- (void)addSubviews:(UIView *)view {
    if (![view.subviews count]) return;
    for (UIView *subview in view.subviews) {
	   	[(NSMutableArray *)[self views] addObject:subview];
        [self addSubviews:subview];
    }
}

%new
- (NSArray *)rootViews {
	NSArray *rootViews = ((UIWindow *)[UIWindow keyWindow]).subviews;
	if (rootViews && 
		rootViews.count && 
		[[rootViews objectAtIndex:0] isMemberOfClass:[%c(UILayoutContainerView) class]] && rootViews.count == 1) {
		rootViews = ((UIView *)[rootViews objectAtIndex:0]).subviews;
	}
	return rootViews;
}

%new
- (NSArray *)blockedClasses {
	return @[@"UITableViewIndex",
			 @"UITableViewWrapperView"];
}

%new
- (NSArray *)filterViews:(NSArray *)views {
	NSMutableArray *filteredViews = [NSMutableArray new];
	for (UIView *view in views) {
		if ([view isKindOfClass:[UIControl class]] || 
			[view isKindOfClass:[UITextView class]] || 
			[view isKindOfClass:[UIScrollView class]]) {
			if (![(NSArray *)[self blockedClasses] containsObject:NSStringFromClass(view.class)]) {
				[filteredViews addObject:view];
			}
		}
	}
	return filteredViews;
}

%new
- (NSArray *)controlViews {
	[self setViews:[NSMutableArray array]];
	for (UIView *view in (NSArray *)[self rootViews]) {
		[self addSubviews:view];
	}
	return [self filterViews:[self views]];
}

%new
- (void)resetViews {
	//[self setViews:(NSArray *)[self rootViews]];
	[self setViews:(NSArray *)[self controlViews]];
 	//NSLog(@"New views:\n%@", ((NSArray *)[self views]).description);
 	selectedViewIndex = -1;
}

%end


%hook UIViewController
/*
%new
- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
   // Handling UITabBarController
   if ([rootViewController isKindOfClass:[UITabBarController class]]) {
       UITabBarController* tabBarController = (UITabBarController*)rootViewController;
       return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
   }
   // Handling UINavigationController
   else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
       UINavigationController* navigationController = (UINavigationController*)rootViewController;
       return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
   }
   // Handling Modal views
   else if (rootViewController.presentedViewController) {
       UIViewController* presentedViewController = rootViewController.presentedViewController;
       return [self topViewControllerWithRootViewController:presentedViewController];
   }
   // Handling UIViewController's added as subviews to some other views.
   else {
       for (UIView *view in [rootViewController.view subviews])
       {
           id subViewController = [view nextResponder];    // Key property which most of us are unaware of / rarely use.
           if ( subViewController && [subViewController isKindOfClass:[UIViewController class]])
           {
               return [self topViewControllerWithRootViewController:subViewController];
           }
       }
       return rootViewController;
   }
}

%new
- (UIViewController*)topMostViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (NSArray *)keyCommands {
	NSLog(@"UIViewController keyCommands");
	NSArray *cmds = %orig();
	
	//NSLog(@"KEY COMMANDS: %i\n%@", cmds.count, cmds.description);

	return cmds;
}
*/

%new
- (void)resignTextFields {
	[self.view endEditing:YES];
	/*UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
	UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
	if ([firstResponder isKindOfClass:[UITextField class]] || [firstResponder isKindOfClass:[UITextView class]]) {
		NSLog(@"RESIGNING TEXT FIELD");
		[firstResponder resignFirstResponder];
	}*/
}

- (void)viewDidLoad {
	%orig();
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignTextFields) name:@"ResignTextFieldsNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	%orig();
 	NSLog(@"DID APPEAR: %@", NSStringFromClass([self class]));
 	if (![NSStringFromClass([self class]) isEqualToString:@"UICompatibilityInputViewController"] &&
 		![NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
 		[[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearNotification" object:nil];
 		[self.view endEditing:NO];
 	}
}

%end
