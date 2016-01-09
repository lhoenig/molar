
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define MAX_ICONS_H 3
#define MAX_ICONS_LS 6
#define SWITCHER_HEIGHT 140
#define APP_GAP 32
#define SCREEN_BORDER_GAP 10
#define ICON_SIZE 80
#define CORNER_RADIUS 20
#define CORNER_RADIUS_OVERLAY 10
#define OVERLAY_SIZE 125

#define CMD_KEY 0xe7
#define TAB_KEY 0x2b
#define T_KEY   0x17
    
void handle_event(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {}

%hookf(void, handle_event, void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    //NSLog(@"handle_event : %d", IOHIDEventGetType(event));
    if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int usagePage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsagePage);
        int usage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        int down = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
       	if (usage == TAB_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TabKeyDown"];
       	else if (usage == T_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TKeyDown"];
        else if (usage == CMD_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyDown"];
        else if (usage == CMD_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyUp"];
        NSLog(@"usage: %i     down: %i", usage, down);
    }
}

%hook UIApplication

%new
- (void)handleCmdTab:(UIKeyCommand *)keyCommand {	

	BOOL ls = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

	if (![self switcherShown]) {

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
	
				UIWindow *window = [[UIWindow alloc] initWithFrame:contentFrame];
				window.windowLevel = UIWindowLevelAlert;
				
				CGFloat h = SWITCHER_HEIGHT;
				CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? MAX_ICONS_LS : MAX_ICONS_H)) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
																								 : ((ls ? MAX_ICONS_LS : MAX_ICONS_H) * ICON_SIZE + ((ls ? MAX_ICONS_LS : MAX_ICONS_H) + 1) * APP_GAP);
	 			UIView *switcherView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
	 			switcherView.backgroundColor = [UIColor clearColor];
	 			switcherView.layer.cornerRadius = CORNER_RADIUS;

	 			UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
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
				[self setSelectedIcon:[NSNumber numberWithInt:0]];
				if (labels.count) ((UILabel *)labels[0]).alpha = 1;

	    		UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, OVERLAY_SIZE, OVERLAY_SIZE)];
	    		overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.12];
	    		overlayView.layer.cornerRadius = CORNER_RADIUS_OVERLAY;
	    		overlayView.center = ((UIView *)[iviews firstObject]).center;	
	    		[switcherView insertSubview:overlayView atIndex:1];
	    		[self setOverlayView:overlayView];

	    		[switcherView insertSubview:scrollView atIndex:2];

				if (ls) switcherView.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
				switcherView.center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));

				[window addSubview:switcherView];
				[self setSwitcherWindow:window];
				[window makeKeyAndVisible];
				
				[self setSwitcherShown:[NSNull null]];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SwitcherDidAppearNotification"];
			}
		}
	} 
	else {

		[UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			
			UIImageView *nextImageView = (UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue + 1) % ((NSArray *)[self imageViews]).count];
			int nextImageViewIndex = (((NSNumber *)[self selectedIcon]).intValue + 1) % ((NSArray *)[self imageViews]).count;
			NSLog(@"Next imageview: %i selectedIcon: %i", nextImageViewIndex, ((NSNumber *)[self selectedIcon]).intValue);

			NSLog(@"From: %@", NSStringFromCGPoint(((UIView *)[self overlayView]).center));
			NSLog(@"To:   %@", NSStringFromCGPoint(nextImageView.center));			

			CGRect rectForScrollView = CGRectMake(nextImageView.frame.origin.x - APP_GAP, 0, 2 * APP_GAP + ICON_SIZE, SWITCHER_HEIGHT);

			[(UIScrollView *)[self scrollView] scrollRectToVisible:rectForScrollView animated:NO];
			
			if (nextImageViewIndex <= (ls ? MAX_ICONS_LS : MAX_ICONS_H) - 1) {
				((UIView *)[self overlayView]).center = nextImageView.center;
			}
			((UILabel *)[self appLabels][((NSNumber *)[self selectedIcon]).intValue]).alpha = 0;
			((UILabel *)[self appLabels][nextImageViewIndex]).alpha = 1;
			
			[self setSelectedIcon:[NSNumber numberWithInt:(((NSNumber *)[self selectedIcon]).intValue + 1) % ((NSArray *)[self imageViews]).count]];
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
		%c(SBDisplayItem);
		SBDisplayItem *di = ((NSArray *)[self switcherItems])[((NSNumber *)[self selectedIcon]).intValue];
		[[%c(SBAppSwitcherModel) sharedInstance] remove:di];
		[[%c(SBApplicationController) sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
		
		/*
		NSMutableArray *mSwitcherItems = [NSMutableArray arrayWithArray:(NSArray *)[self switcherItems]];
		[mSwitcherItems removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setSwitcherItems:mSwitcherItems];

		NSMutableArray *mApps = [NSMutableArray arrayWithArray:(NSArray *)[self apps]];
		[mApps removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setApps:mApps];

		[((NSArray *)[((UIScrollView *)[self scrollView]) subviews]) removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		NSMutableArray *mImageViews = [NSMutableArray arrayWithArray:(NSArray *)[self imageViews]];
		[mImageViews removeObjectAtIndex:((NSNumber *)[self selectedIcon]).intValue];
		[self setImageViews:mImageViews];

		BOOL ls = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
		CGFloat h = SWITCHER_HEIGHT;
		CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? MAX_ICONS_LS : MAX_ICONS_H)) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
																								 : ((ls ? MAX_ICONS_LS : MAX_ICONS_H) * ICON_SIZE + ((ls ? MAX_ICONS_LS : MAX_ICONS_H) + 1) * APP_GAP);
		CGRect newSwitcherFrame = CGRectMake(0, 0, w, h);
	    
		// scrollview.frame = newSwitcherframe
	    CGSize newScrollViewContentSize = CGSizeMake(APP_GAP * (((NSArray *)[self apps]).count + 1) + ICON_SIZE * ((NSArray *)[self apps]).count, SWITCHER_HEIGHT);
		
		if (ls) ((UIView *)[((NSArray *)[((UIWindow *)[self switcherWindow]) subviews]) objectAtIndex:0]).transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
		[UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
			((UIView *)[((NSArray *)[((UIWindow *)[self switcherWindow]) subviews]) objectAtIndex:0]).frame = newSwitcherFrame;
			((UIScrollView *)[self scrollView]).contentSize = newScrollViewContentSize;
			for (int i = 0; i < ((NSArray *)[self imageViews]).count; i++) {
				UIImageView *iv = (UIImageView *)[(NSArray *)[self imageViews] objectAtIndex:i];
			    iv.frame = CGRectMake(APP_GAP * (i + 1) + ICON_SIZE * i, (SWITCHER_HEIGHT / 2) - (ICON_SIZE / 2), ICON_SIZE, ICON_SIZE);
			}
			((UIView *)[((NSArray *)[((UIWindow *)[self switcherWindow]) subviews]) objectAtIndex:0]).center = CGPointMake(CGRectGetMidX(((UIWindow *)[self switcherWindow]).bounds), 
																											   			   CGRectGetMidY(((UIWindow *)[self switcherWindow]).bounds));
			((UIView *)[self overlayView]).center = ((UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue)]).center;
		} completion:nil];
		*/
		[self dismissAppSwitcher];
		[self handleCmdTab:nil];
	}
}

%new
- (void)handleShiftH:(UIKeyCommand *)keyCommand {
	[[%c(SBUIController) sharedInstance] clickedMenuButton];
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
- (void)tabKeyDown {
	[self handleKeyStatus:1];
}

%new
- (void)tKeyDown {
	[self handleKeyStatus:1];
}

%new
- (void)cmdKeyDown {
	[self setCmdDown:[NSNull null]];
	[self handleKeyStatus:0];
}

%new
- (void)cmdKeyUp {
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

- (NSArray *)keyCommands {

	NSArray *orig_cmds = %orig;
	NSMutableArray *arr = [NSMutableArray arrayWithArray:orig_cmds];

	UIKeyCommand *cmdQ = [UIKeyCommand keyCommandWithInput:@"q"
                   			  modifierFlags:UIKeyModifierCommand 
                          	  action:@selector(handleCmdQ:)];
	[arr addObject:cmdQ];

	//UIKeyCommand *cmdEsc = [UIKeyCommand keyCommandWithInput:@"w"
	UIKeyCommand *cmdEsc = [UIKeyCommand keyCommandWithInput:UIKeyInputEscape
                   			  modifierFlags:UIKeyModifierCommand
                          	  action:@selector(handleCmdEsc:)];
	[arr addObject:cmdEsc];

	UIKeyCommand *cmdShiftH = [UIKeyCommand keyCommandWithInput:@"h"
                   			  modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
                          	  action:@selector(handleCmdShiftH:)];
	[arr addObject:cmdShiftH];

	if (![self hidSetup]) {
		IOHIDEventSystemClientRef ioHIDEventSystem = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
	    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystem, (IOHIDEventSystemClientEventCallback)handle_event, NULL, NULL);
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabKeyDown) name:@"TabKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tKeyDown) name:@"TKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyDown) name:@"CmdKeyDown" object:nil];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyUp) name:@"CmdKeyUp" object:nil];
	    [self setHidSetup:[NSNull null]];
	}

	return [NSArray arrayWithArray:arr];
}

%end
