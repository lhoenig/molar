#line 1 "/Users/lukas/Downloads/AppSwitcher 2/AppSwitcher/AppSwitcher.xm"




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

#include <logos/logos.h>
#include <substrate.h>
@class SBApplicationIcon; @class SBUIController; @class SBDisplayItem; @class SBApplicationController; @class SBApplication; @class UIApplication; @class SBAppSwitcherModel; 
static void _logos_method$_ungrouped$UIApplication$handleCmdTab$(UIApplication*, SEL, UIKeyCommand *); static void _logos_method$_ungrouped$UIApplication$dismissAppSwitcher(UIApplication*, SEL); static id _logos_method$_ungrouped$UIApplication$switcherShown(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setSwitcherShown$(UIApplication*, SEL, id); static UIWindow * _logos_method$_ungrouped$UIApplication$switcherWindow(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setSwitcherWindow$(UIApplication*, SEL, UIWindow *); static NSArray * _logos_method$_ungrouped$UIApplication$imageViews(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setImageViews$(UIApplication*, SEL, NSArray *); static NSNumber * _logos_method$_ungrouped$UIApplication$selectedIcon(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setSelectedIcon$(UIApplication*, SEL, NSNumber *); static UIView * _logos_method$_ungrouped$UIApplication$overlayView(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setOverlayView$(UIApplication*, SEL, UIView *); static NSArray * _logos_method$_ungrouped$UIApplication$apps(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setApps$(UIApplication*, SEL, NSArray *); static NSArray * _logos_method$_ungrouped$UIApplication$switcherItems(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setSwitcherItems$(UIApplication*, SEL, NSArray *); static UIView * _logos_method$_ungrouped$UIApplication$scrollView(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setScrollView$(UIApplication*, SEL, UIView *); static NSArray * _logos_method$_ungrouped$UIApplication$appLabels(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setAppLabels$(UIApplication*, SEL, NSArray *); static void _logos_method$_ungrouped$UIApplication$setCmdDown$(UIApplication*, SEL, id); static id _logos_method$_ungrouped$UIApplication$cmdDown(UIApplication*, SEL); static id _logos_method$_ungrouped$UIApplication$hidSetup(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$setHidSetup$(UIApplication*, SEL, id); static void _logos_method$_ungrouped$UIApplication$handleCmdEnter$(UIApplication*, SEL, UIKeyCommand *); static void _logos_method$_ungrouped$UIApplication$handleCmdEsc$(UIApplication*, SEL, UIKeyCommand *); static void _logos_method$_ungrouped$UIApplication$handleCmdQ$(UIApplication*, SEL, UIKeyCommand *); static void _logos_method$_ungrouped$UIApplication$handleShiftH$(UIApplication*, SEL, UIKeyCommand *); static UIImage * _logos_method$_ungrouped$UIApplication$image$scaledToSize$(UIApplication*, SEL, UIImage*, CGSize); static void _logos_method$_ungrouped$UIApplication$tabKeyDown(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$tKeyDown(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$cmdKeyDown(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$cmdKeyUp(UIApplication*, SEL); static void _logos_method$_ungrouped$UIApplication$handleKeyStatus$(UIApplication*, SEL, int); static NSArray * (*_logos_orig$_ungrouped$UIApplication$keyCommands)(UIApplication*, SEL); static NSArray * _logos_method$_ungrouped$UIApplication$keyCommands(UIApplication*, SEL); 
static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBAppSwitcherModel(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBAppSwitcherModel"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBApplicationController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBApplicationController"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBDisplayItem(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBDisplayItem"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBApplication(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBApplication"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBApplicationIcon(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBApplicationIcon"); } return _klass; }static __inline__ __attribute__((always_inline)) Class _logos_static_class_lookup$SBUIController(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBUIController"); } return _klass; }
#line 27 "/Users/lukas/Downloads/AppSwitcher 2/AppSwitcher/AppSwitcher.xm"
_disused static void (*_logos_orig$_ungrouped$handle_event)(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event); static void _logos_function$_ungrouped$handle_event(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    
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




static void _logos_method$_ungrouped$UIApplication$handleCmdTab$(UIApplication* self, SEL _cmd, UIKeyCommand * keyCommand) {	

	BOOL ls = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);

	if (![self switcherShown]) {

		NSArray *apps = (NSArray *)[(SBApplicationController *)[_logos_static_class_lookup$SBApplicationController() sharedInstance] runningApplications];
		
		if (apps.count) {
			
			NSMutableArray *appsFiltered = [NSMutableArray new];			
			NSMutableArray *switcherItemsFiltered = [NSMutableArray new];
			NSMutableArray *icons = [NSMutableArray new];
			_logos_static_class_lookup$SBAppSwitcherModel();
			NSArray *switcherItems = [(SBAppSwitcherModel *)[_logos_static_class_lookup$SBAppSwitcherModel() sharedInstance] mainSwitcherDisplayItems];
			_logos_static_class_lookup$SBApplication();
			_logos_static_class_lookup$SBApplicationIcon();
			for (int i = 0; i < switcherItems.count; ++i) {
				for (SBApplication *app in apps) {
					if ([(NSString *)[app bundleIdentifier] isEqualToString:(NSString *)[switcherItems[i] displayIdentifier]]) {
						[appsFiltered addObject:app];
						[switcherItemsFiltered addObject:switcherItems[i]];
						SBApplicationIcon *icon = [[_logos_static_class_lookup$SBApplicationIcon() alloc] initWithApplication:app];
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


static void _logos_method$_ungrouped$UIApplication$dismissAppSwitcher(UIApplication* self, SEL _cmd) {
	[[self switcherWindow] setHidden:YES];
	[self setSwitcherShown:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SwitcherDidDisappearNotification"];
}


static id _logos_method$_ungrouped$UIApplication$switcherShown(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(switcherShown));
}


static void _logos_method$_ungrouped$UIApplication$setSwitcherShown$(UIApplication* self, SEL _cmd, id value) {
	objc_setAssociatedObject(self, @selector(switcherShown), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static UIWindow * _logos_method$_ungrouped$UIApplication$switcherWindow(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(switcherWindow));
}


static void _logos_method$_ungrouped$UIApplication$setSwitcherWindow$(UIApplication* self, SEL _cmd, UIWindow * value) {
	objc_setAssociatedObject(self, @selector(switcherWindow), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSArray * _logos_method$_ungrouped$UIApplication$imageViews(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(imageViews));
}


static void _logos_method$_ungrouped$UIApplication$setImageViews$(UIApplication* self, SEL _cmd, NSArray * value) {
	objc_setAssociatedObject(self, @selector(imageViews), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSNumber * _logos_method$_ungrouped$UIApplication$selectedIcon(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(selectedIcon));
}


static void _logos_method$_ungrouped$UIApplication$setSelectedIcon$(UIApplication* self, SEL _cmd, NSNumber * value) {
	objc_setAssociatedObject(self, @selector(selectedIcon), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static UIView * _logos_method$_ungrouped$UIApplication$overlayView(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(overlayView));
}


static void _logos_method$_ungrouped$UIApplication$setOverlayView$(UIApplication* self, SEL _cmd, UIView * value) {
	objc_setAssociatedObject(self, @selector(overlayView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSArray * _logos_method$_ungrouped$UIApplication$apps(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(apps));
}


static void _logos_method$_ungrouped$UIApplication$setApps$(UIApplication* self, SEL _cmd, NSArray * value) {
	objc_setAssociatedObject(self, @selector(apps), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSArray * _logos_method$_ungrouped$UIApplication$switcherItems(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(switcherItems));
}


static void _logos_method$_ungrouped$UIApplication$setSwitcherItems$(UIApplication* self, SEL _cmd, NSArray * value) {
	objc_setAssociatedObject(self, @selector(switcherItems), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static UIView * _logos_method$_ungrouped$UIApplication$scrollView(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(scrollView));
}


static void _logos_method$_ungrouped$UIApplication$setScrollView$(UIApplication* self, SEL _cmd, UIView * value) {
	objc_setAssociatedObject(self, @selector(scrollView), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static NSArray * _logos_method$_ungrouped$UIApplication$appLabels(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(appLabels));
}


static void _logos_method$_ungrouped$UIApplication$setAppLabels$(UIApplication* self, SEL _cmd, NSArray * value) {
	objc_setAssociatedObject(self, @selector(appLabels), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static void _logos_method$_ungrouped$UIApplication$setCmdDown$(UIApplication* self, SEL _cmd, id value) {
	objc_setAssociatedObject(self, @selector(cmdDown), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static id _logos_method$_ungrouped$UIApplication$cmdDown(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(cmdDown));
}


static id _logos_method$_ungrouped$UIApplication$hidSetup(UIApplication* self, SEL _cmd) {
	return objc_getAssociatedObject(self, @selector(hidSetup));
}


static void _logos_method$_ungrouped$UIApplication$setHidSetup$(UIApplication* self, SEL _cmd, id value) {
	objc_setAssociatedObject(self, @selector(hidSetup), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static void _logos_method$_ungrouped$UIApplication$handleCmdEnter$(UIApplication* self, SEL _cmd, UIKeyCommand * keyCommand) {
	if ([self switcherShown]) {
		SBUIController *uicontroller = (SBUIController *)[_logos_static_class_lookup$SBUIController() sharedInstance];
		SBApplicationController *appcontroller = (SBApplicationController *)[_logos_static_class_lookup$SBApplicationController() sharedInstance];
		[uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]]];
		[self dismissAppSwitcher];
	}
}


static void _logos_method$_ungrouped$UIApplication$handleCmdEsc$(UIApplication* self, SEL _cmd, UIKeyCommand * keyCommand) {
	if ([self switcherShown]) {
		[self dismissAppSwitcher];
		[self setSwitcherShown:nil];
	}
}


static void _logos_method$_ungrouped$UIApplication$handleCmdQ$(UIApplication* self, SEL _cmd, UIKeyCommand * keyCommand) {
	if ([self switcherShown] && [((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) pid] > 0) {
		_logos_static_class_lookup$SBDisplayItem();
		SBDisplayItem *di = ((NSArray *)[self switcherItems])[((NSNumber *)[self selectedIcon]).intValue];
		[[_logos_static_class_lookup$SBAppSwitcherModel() sharedInstance] remove:di];
		[[_logos_static_class_lookup$SBApplicationController() sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
		
		



































		[self dismissAppSwitcher];
		[self handleCmdTab:nil];
	}
}


static void _logos_method$_ungrouped$UIApplication$handleShiftH$(UIApplication* self, SEL _cmd, UIKeyCommand * keyCommand) {
	[[_logos_static_class_lookup$SBUIController() sharedInstance] clickedMenuButton];
}


static UIImage * _logos_method$_ungrouped$UIApplication$image$scaledToSize$(UIApplication* self, SEL _cmd, UIImage* originalImage, CGSize size) {
    
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }

    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);

    
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];

    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    
    return image;	 
}


static void _logos_method$_ungrouped$UIApplication$tabKeyDown(UIApplication* self, SEL _cmd) {
	[self handleKeyStatus:1];
}


static void _logos_method$_ungrouped$UIApplication$tKeyDown(UIApplication* self, SEL _cmd) {
	[self handleKeyStatus:1];
}


static void _logos_method$_ungrouped$UIApplication$cmdKeyDown(UIApplication* self, SEL _cmd) {
	[self setCmdDown:[NSNull null]];
	[self handleKeyStatus:0];
}


static void _logos_method$_ungrouped$UIApplication$cmdKeyUp(UIApplication* self, SEL _cmd) {
	[self setCmdDown:nil];
	[self handleKeyStatus:0];
}


static void _logos_method$_ungrouped$UIApplication$handleKeyStatus$(UIApplication* self, SEL _cmd, int tabDown) {
	if (![self cmdDown]) {
		[self handleCmdEnter:nil];
	}
	else if (tabDown) {
		[self handleCmdTab:nil];
	}
}

static NSArray * _logos_method$_ungrouped$UIApplication$keyCommands(UIApplication* self, SEL _cmd) {

	NSArray *orig_cmds = _logos_orig$_ungrouped$UIApplication$keyCommands(self, _cmd);
	NSMutableArray *arr = [NSMutableArray arrayWithArray:orig_cmds];

	UIKeyCommand *cmdQ = [UIKeyCommand keyCommandWithInput:@"q"
                   			  modifierFlags:UIKeyModifierCommand 
                          	  action:@selector(handleCmdQ:)];
	[arr addObject:cmdQ];

	
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


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$UIApplication = objc_getClass("UIApplication"); { char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIKeyCommand *), strlen(@encode(UIKeyCommand *))); i += strlen(@encode(UIKeyCommand *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleCmdTab:), (IMP)&_logos_method$_ungrouped$UIApplication$handleCmdTab$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(dismissAppSwitcher), (IMP)&_logos_method$_ungrouped$UIApplication$dismissAppSwitcher, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(switcherShown), (IMP)&_logos_method$_ungrouped$UIApplication$switcherShown, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setSwitcherShown:), (IMP)&_logos_method$_ungrouped$UIApplication$setSwitcherShown$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIWindow *), strlen(@encode(UIWindow *))); i += strlen(@encode(UIWindow *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(switcherWindow), (IMP)&_logos_method$_ungrouped$UIApplication$switcherWindow, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIWindow *), strlen(@encode(UIWindow *))); i += strlen(@encode(UIWindow *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setSwitcherWindow:), (IMP)&_logos_method$_ungrouped$UIApplication$setSwitcherWindow$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(imageViews), (IMP)&_logos_method$_ungrouped$UIApplication$imageViews, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setImageViews:), (IMP)&_logos_method$_ungrouped$UIApplication$setImageViews$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSNumber *), strlen(@encode(NSNumber *))); i += strlen(@encode(NSNumber *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(selectedIcon), (IMP)&_logos_method$_ungrouped$UIApplication$selectedIcon, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSNumber *), strlen(@encode(NSNumber *))); i += strlen(@encode(NSNumber *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setSelectedIcon:), (IMP)&_logos_method$_ungrouped$UIApplication$setSelectedIcon$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIView *), strlen(@encode(UIView *))); i += strlen(@encode(UIView *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(overlayView), (IMP)&_logos_method$_ungrouped$UIApplication$overlayView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIView *), strlen(@encode(UIView *))); i += strlen(@encode(UIView *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setOverlayView:), (IMP)&_logos_method$_ungrouped$UIApplication$setOverlayView$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(apps), (IMP)&_logos_method$_ungrouped$UIApplication$apps, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setApps:), (IMP)&_logos_method$_ungrouped$UIApplication$setApps$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(switcherItems), (IMP)&_logos_method$_ungrouped$UIApplication$switcherItems, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setSwitcherItems:), (IMP)&_logos_method$_ungrouped$UIApplication$setSwitcherItems$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIView *), strlen(@encode(UIView *))); i += strlen(@encode(UIView *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(scrollView), (IMP)&_logos_method$_ungrouped$UIApplication$scrollView, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIView *), strlen(@encode(UIView *))); i += strlen(@encode(UIView *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setScrollView:), (IMP)&_logos_method$_ungrouped$UIApplication$setScrollView$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(appLabels), (IMP)&_logos_method$_ungrouped$UIApplication$appLabels, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(NSArray *), strlen(@encode(NSArray *))); i += strlen(@encode(NSArray *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setAppLabels:), (IMP)&_logos_method$_ungrouped$UIApplication$setAppLabels$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setCmdDown:), (IMP)&_logos_method$_ungrouped$UIApplication$setCmdDown$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(cmdDown), (IMP)&_logos_method$_ungrouped$UIApplication$cmdDown, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(hidSetup), (IMP)&_logos_method$_ungrouped$UIApplication$hidSetup, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(setHidSetup:), (IMP)&_logos_method$_ungrouped$UIApplication$setHidSetup$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIKeyCommand *), strlen(@encode(UIKeyCommand *))); i += strlen(@encode(UIKeyCommand *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleCmdEnter:), (IMP)&_logos_method$_ungrouped$UIApplication$handleCmdEnter$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIKeyCommand *), strlen(@encode(UIKeyCommand *))); i += strlen(@encode(UIKeyCommand *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleCmdEsc:), (IMP)&_logos_method$_ungrouped$UIApplication$handleCmdEsc$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIKeyCommand *), strlen(@encode(UIKeyCommand *))); i += strlen(@encode(UIKeyCommand *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleCmdQ:), (IMP)&_logos_method$_ungrouped$UIApplication$handleCmdQ$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIKeyCommand *), strlen(@encode(UIKeyCommand *))); i += strlen(@encode(UIKeyCommand *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleShiftH:), (IMP)&_logos_method$_ungrouped$UIApplication$handleShiftH$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UIImage *), strlen(@encode(UIImage *))); i += strlen(@encode(UIImage *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIImage*), strlen(@encode(UIImage*))); i += strlen(@encode(UIImage*)); memcpy(_typeEncoding + i, @encode(CGSize), strlen(@encode(CGSize))); i += strlen(@encode(CGSize)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(image:scaledToSize:), (IMP)&_logos_method$_ungrouped$UIApplication$image$scaledToSize$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(tabKeyDown), (IMP)&_logos_method$_ungrouped$UIApplication$tabKeyDown, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(tKeyDown), (IMP)&_logos_method$_ungrouped$UIApplication$tKeyDown, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(cmdKeyDown), (IMP)&_logos_method$_ungrouped$UIApplication$cmdKeyDown, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(cmdKeyUp), (IMP)&_logos_method$_ungrouped$UIApplication$cmdKeyUp, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = 'i'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$UIApplication, @selector(handleKeyStatus:), (IMP)&_logos_method$_ungrouped$UIApplication$handleKeyStatus$, _typeEncoding); }MSHookMessageEx(_logos_class$_ungrouped$UIApplication, @selector(keyCommands), (IMP)&_logos_method$_ungrouped$UIApplication$keyCommands, (IMP*)&_logos_orig$_ungrouped$UIApplication$keyCommands); MSHookFunction((void *)handle_event, (void *)&_logos_function$_ungrouped$handle_event, (void **)&_logos_orig$_ungrouped$handle_event);} }
#line 458 "/Users/lukas/Downloads/AppSwitcher 2/AppSwitcher/AppSwitcher.xm"
