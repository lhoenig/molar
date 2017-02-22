
// Logos by Dustin Howett
// See http://iphonedevwiki.net/index.php/Logos

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <libactivator.h>
#import <dlfcn.h>
#import <SpringBoard/SBIconController.h>
#import <SpringBoard/SBIconListModel.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBFolder.h>
#import <SpringBoard/SBFolderView.h>

#define DegreesToRadians(x) ((x) * M_PI / 180.0)
#define SWITCHER_HEIGHT 140
#define APP_GAP 32
#define SCREEN_BORDER_GAP 10
#define ICON_SIZE 80
#define CORNER_RADIUS 20
#define CORNER_RADIUS_OVERLAY 10
#define OVERLAY_SIZE 125

#define SWITCHER_IOS9_MODE 1
#define SWITCHER_IOS8_MODE 0

#define CMD_KEY     0xe3
#define CMD_KEY_2   0xe7
#define TAB_KEY     0x2b
#define ESC_KEY     0x29
#define RIGHT_KEY   0x4f
#define LEFT_KEY    0x50
#define UP_KEY      0x52
#define DOWN_KEY    0x51
#define ENTER_KEY   0x28
#define SHIFT_KEY   0xe5
#define SHIFT_KEY_2 0xe1
#define T_KEY       0x17
#define E_KEY       0x8
#define R_KEY       0x15

#define MAGNIFY_FACTOR 1.2
#define SB_MAGNIFY_FACTOR 1.2
#define SLIDER_LEVELS 20
#define FLASH_VIEW_CORNER_RADIUS 4.0
#define FLASH_VIEW_ANIM_DURATION 1.5
#define HIGHLIGHT_DURATION 0.15
#define KEY_REPEAT_DELAY 0.4
#define KEY_REPEAT_INTERVAL 0.005
#define KEY_REPEAT_INTERVAL_SLOW 0.1
#define KEY_REPEAT_STEP 3
#define DISCOVERABILITY_DELAY 1.0
#define DISCOVERABILITY_GAP 22.0
#define DISCOVERABILITY_MODIFIER_GAP 28.0
#define DISCOVERABILITY_INSET 30.0
#define DISCOVERABILITY_MODIFIER_WIDTH 70.0
#define DISCOVERABILITY_FONT_SIZE 20.0
#define DISCOVERABILITY_LS_Y_DECREASE 16.0
#define ALERT_DISMISS_RESCAN_DELAY 1.0

#define SBFOLDER_ICONS_X 3
#define SBFOLDER_ICONS_Y 3

#define NEXT_VIEW 1
#define PREV_VIEW 0

#define DEBUG 0

#if DEBUG == 0
#define NSDebug(...)
#elif DEBUG == 1
#define NSDebug(...) NSLog(__VA_ARGS__)
#endif

void handle_event(void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {}

BOOL darkMode,
     hideLabels,
     enabled,
     switcherEnabled,
     switcherMode,
     controlEnabled,
     keySheetEnabled,
     launcherEnabled,
     switcherOpenedInLandscape,
     sliderMode,
     tableViewMode,
     scrollViewMode,
     collectionViewMode,
     actionSheetMode,
     tabIsDown,
     waitingForKeyRepeat,
     transformFinished,
     discoverabilityShown,
     switcherShown,
     sbIconSelected,
     sbDockIconSelected,
     sbFolderIconSelected,
     sbFolderOpened;

NSString *launcherApp1,
         *launcherApp2,
         *launcherApp3,
         *launcherApp4,
         *launcherApp5,
         *launcherApp6,
         *launcherApp7,
         *launcherApp8,
         *launcherApp9,
         *launcherApp0;

NSTimer *discoverabilityTimer,
        *waitForKeyRepeatTimer,
        *keyRepeatTimer;

NSArray *customShortcuts;
NSMutableArray *allKeyCommands;
UITableView *selectedTableView;
UITableViewCell *selectedCell;
UICollectionView *selectedCollectionView;
UICollectionViewCell *selectedItem;
int selectedRow,
    selectedSection,
    selectedViewIndex;
int numThreads;
UIView *fView;
UIView *sbIconOverlay, *sbIconOpenedFolderOverlay;
UIPageControl *pageControl;
UIScrollView *discoverabilityScrollView;
NSString *activeApp;
NSString *selectedSBIconBundleID, *selectedSBIconInOpenedFolderBundleID;
int sbRows,
    sbColumns,
    sbDockIconCount,
    sbSelectedRow,
    sbSelectedColumn,
    sbSelectedPage,
    sbPages,
    sbOpenedFolderSelectedPage,
    sbOpenedFolderSelectedRow,
    sbOpenedFolderSelectedCol,
    sbOpenedFolderPages;
NSArray *sbDockIcons;
UIView *sbIconView, *sbIconOpenedFolderView;
SBFolder *selectedSBFolder;
id selectedSBIcon;
SBApplicationIcon *selectedSBIconInOpenedFolder;


%hookf(void, handle_event, void *target, void *refcon, IOHIDServiceRef service, IOHIDEventRef event) {
    //NSLog(@"handle_event : %d", IOHIDEventGetType(event));
    if (service && event && IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
        int usagePage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsagePage);
        int usage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
        int down = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);
        if (usage == TAB_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TabKeyDown" object:nil];
        else if (usage == TAB_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"TabKeyUp" object:nil];
        else if ((usage == CMD_KEY && down) || (usage == CMD_KEY_2 && down)) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyDown" object:nil];
        else if ((usage == CMD_KEY && !down) || (usage == CMD_KEY_2 && !down)) [[NSNotificationCenter defaultCenter] postNotificationName:@"CmdKeyUp" object:nil];
        else if (usage == ESC_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"EscKeyDown" object:nil userInfo:@{@"sender": activeApp}];
        else if (usage == R_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"RKeyDown" object:nil];
        else if (usage == RIGHT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"RightKeyDown" object:nil];
        else if (usage == RIGHT_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"RightKeyUp" object:nil];
        else if (usage == LEFT_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftKeyDown" object:nil];
        else if (usage == LEFT_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"LeftKeyUp" object:nil];
        else if (usage == UP_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"UpKeyDown" object:nil];
        else if (usage == UP_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"UpKeyUp" object:nil];
        else if (usage == DOWN_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"DownKeyDown" object:nil];
        else if (usage == DOWN_KEY && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"DownKeyUp" object:nil];
        else if (usage == ENTER_KEY && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterKeyDown" object:nil];
        else if ((usage == SHIFT_KEY || usage == SHIFT_KEY_2) && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"ShiftKeyDown" object:nil];
        else if ((usage == SHIFT_KEY || usage == SHIFT_KEY_2) && !down) [[NSNotificationCenter defaultCenter] postNotificationName:@"ShiftKeyUp" object:nil];
        else if (usagePage == 7 && down) [[NSNotificationCenter defaultCenter] postNotificationName:@"GenericKeyDown" object:nil];
        NSDebug(@"page: %i  key: %i  down: %i", usagePage, usage, down);
    }
}

static void loadPrefs() {
    CFPreferencesAppSynchronize(CFSTR("de.hoenig.molar"));

    CFPropertyListRef cf_enabled =            CFPreferencesCopyAppValue(CFSTR("enabled"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_appSwitcherEnabled = CFPreferencesCopyAppValue(CFSTR("appSwitcherEnabled"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_appControlEnabled =  CFPreferencesCopyAppValue(CFSTR("appControlEnabled"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_keySheetEnabled =    CFPreferencesCopyAppValue(CFSTR("keySheetEnabled"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_launcherEnabled =    CFPreferencesCopyAppValue(CFSTR("launcherEnabled"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_darkMode =           CFPreferencesCopyAppValue(CFSTR("darkMode"), CFSTR("de.hoenig.molar"));
    CFPropertyListRef cf_hideLabels =         CFPreferencesCopyAppValue(CFSTR("hideLabels"), CFSTR("de.hoenig.molar"));

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

    enabled = !cf_enabled ? YES : (cf_enabled == kCFBooleanTrue);
    switcherEnabled = !cf_appSwitcherEnabled ? YES : (cf_appSwitcherEnabled == kCFBooleanTrue);
    controlEnabled = !cf_appControlEnabled ? YES : (cf_appControlEnabled == kCFBooleanTrue);
    keySheetEnabled = !cf_keySheetEnabled ? YES : (cf_keySheetEnabled == kCFBooleanTrue);
    launcherEnabled = !cf_launcherEnabled ? YES : (cf_launcherEnabled == kCFBooleanTrue);
    darkMode = (cf_darkMode == kCFBooleanTrue);
    hideLabels = (cf_hideLabels == kCFBooleanTrue);

    customShortcuts = (NSArray *)CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("shortcuts"), CFSTR("de.hoenig.molar")));

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadShortcutsNotification" object:nil];
}

static void updateActiveAppUserApplication(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    activeApp = (NSString *)[(NSDictionary *)userInfo objectForKey:@"app"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateActiveAppUserApplicationNotification" object:nil userInfo:@{@"app": activeApp}];
}

static void updateSwitcherShown(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    switcherShown = YES;
}

static void updateSwitcherNotShown(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    switcherShown = NO;
}

static void updateDiscoverabilityShown(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    discoverabilityShown = YES;
}

static void updateDiscoverabilityNotShown(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    discoverabilityShown = NO;
}

static void hideSwitcherByNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HideSwitcherNotificationLocalNotification" object:nil];
}

static void setupHID() {
    IOHIDEventSystemClientRef ioHIDEventSystem = IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientScheduleWithRunLoop(ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(ioHIDEventSystem, (IOHIDEventSystemClientEventCallback)handle_event, NULL, NULL);
}

static void postDistributedNotification(NSString *notificationNameNSString) {
    CFStringRef notificationName = (CFStringRef)notificationNameNSString;

    void *libHandle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
    CFNotificationCenterRef (*CFNotificationCenterGetDistributedCenter)() = (CFNotificationCenterRef (*)())dlsym(libHandle, "CFNotificationCenterGetDistributedCenter");
    if (CFNotificationCenterGetDistributedCenter) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(),
                                             notificationName,
                                             NULL,
                                             NULL,
                                             YES);
    }
}

%ctor {
    discoverabilityTimer = nil;
    waitForKeyRepeatTimer = nil;
    keyRepeatTimer = nil;
    loadPrefs();

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)loadPrefs,
                                    CFSTR("de.hoenig.molar-preferencesChanged"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);

    void *libHandle = dlopen("/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation", RTLD_LAZY);
    CFNotificationCenterRef (*CFNotificationCenterGetDistributedCenter)() = (CFNotificationCenterRef (*)())dlsym(libHandle, "CFNotificationCenterGetDistributedCenter");
    if (CFNotificationCenterGetDistributedCenter) {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                        NULL,
                                        (CFNotificationCallback)updateActiveAppUserApplication,
                                        CFSTR("NewFrontAppNotification"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                        NULL,
                                        (CFNotificationCallback)updateSwitcherShown,
                                        CFSTR("SwitcherDidAppearNotification"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                        NULL,
                                        (CFNotificationCallback)updateSwitcherNotShown,
                                        CFSTR("SwitcherDidDisappearNotification"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                        NULL,
                                        (CFNotificationCallback)updateDiscoverabilityShown,
                                        CFSTR("DiscoverabilityDidAppearNotification"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                        NULL,
                                        (CFNotificationCallback)updateDiscoverabilityNotShown,
                                        CFSTR("DiscoverabilityDidDisappearNotification"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);

        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
            CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(),
                                NULL,
                                (CFNotificationCallback)hideSwitcherByNotification,
                                CFSTR("HideSwitcherNotification"),
                                NULL,
                                CFNotificationSuspensionBehaviorCoalesce);
        }
    }
    dlclose(libHandle);

    switcherMode = numThreads = 0;
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
    if (!numThreads) {
        if (![self isCancelled]) {
            numThreads++;
            NSDebug(@"MAIN: %@ threads: %i", ((NSThread *)self).description, numThreads);
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
}

%new
- (void)animationDidStop:(CAAnimation *)anim1 finished:(BOOL)flag {
    NSDebug(@"DID STOP: %@ threads: %i", ((NSThread *)self).description, numThreads);
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
    if ([self isCancelled]) { numThreads--; NSDebug(@"Thread cancelled, now %i", numThreads); }
}

%end


%hook UIApplication

- (BOOL)canBecomeFirstResponder {
    return YES;
}

%new
- (BOOL)iPad {
    return [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];
}

%new
- (BOOL)iOS9 {
    return [UIKeyCommand respondsToSelector:@selector(keyCommandWithInput:modifierFlags:action:discoverabilityTitle:)];
}

%new
- (BOOL)iPhonePlus {
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(736, 414)) || CGSizeEqualToSize([UIScreen mainScreen].bounds.size, CGSizeMake(414, 736));
}

%new
- (void)addMolarObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabKeyDown) name:@"TabKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyDown) name:@"CmdKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdKeyUp) name:@"CmdKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(escKeyDown:) name:@"EscKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rightKeyDown) name:@"RightKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(leftKeyDown) name:@"LeftKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genericKeyDown) name:@"GenericKeyDown" object:nil];

    // shortcuts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadShortcuts) name:@"ReloadShortcutsNotification" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_tabDown) name:@"TabKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_tabUp) name:@"TabKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyDown) name:@"ShiftKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shiftKeyUp) name:@"ShiftKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_enterKey) name:@"EnterKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_leftKey) name:@"LeftKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_leftUp) name:@"LeftKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_rightKey) name:@"RightKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_rightUp) name:@"RightKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_upKey) name:@"UpKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_upKeyUp) name:@"UpKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_downKey) name:@"DownKeyDown" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_downKeyUp) name:@"DownKeyUp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ui_rKey) name:@"RKeyDown" object:nil];

    // app updates
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetViews) name:@"ViewDidAppearNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBAppDidBecomeForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBApplicationStateDidChange" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBFrontmostDisplayChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBHomescreenIconsDidAppearNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBIconOpenFolderChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBAppSwitcherModelDidChangeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveApp) name:@"SBDisplayDidLaunchNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateActiveAppProperty:) name:@"UpdateActiveAppUserApplicationNotification" object:nil];

    // switcher
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissAppSwitcher) name:@"HideSwitcherNotificationLocalNotification" object:nil];
}

%new
- (NSUInteger)maxIconsLS {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return 10;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return 8;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 6;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 5;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 4;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 4;
    else return 6;
}

%new
- (NSUInteger)maxIconsP {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return 8;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return 6;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 3;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 3;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 2;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 2;
    else return 5;
}

%new
- (NSUInteger)maxCommandsLS {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return 20;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return 15;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 7;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 6;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 5;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 5;
    else return 5;
}

%new
- (NSUInteger)maxCommandsP {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return 25;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return 20;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return 15;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return 13;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return 10;
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return 7;
    else return 7;
}

%new
- (NSNumber *)maxWidthLS {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return @(1280.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return @(862.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return @(635.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return @(600.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return @(500.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return @(400.0);
    else return @(0.0);
}

%new
- (NSNumber *)maxWidthP {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    if (CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 1366)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1366, 1024))) return @(910.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(768, 1024)) || CGSizeEqualToSize(bounds.size, CGSizeMake(1024, 768))) return @(670.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(414, 736)) || CGSizeEqualToSize(bounds.size, CGSizeMake(736, 414))) return @(300.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(375, 667)) || CGSizeEqualToSize(bounds.size, CGSizeMake(667, 375))) return @(285.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 568)) || CGSizeEqualToSize(bounds.size, CGSizeMake(568, 320))) return @(200.0);
    else if (CGSizeEqualToSize(bounds.size, CGSizeMake(320, 480)) || CGSizeEqualToSize(bounds.size, CGSizeMake(480, 320))) return @(200.0);
    else return @(0.0);
}

%new
- (void)handleCmdTab:(UIKeyCommand *)keyCommand {

    if (discoverabilityTimer) [discoverabilityTimer invalidate];
    discoverabilityTimer = nil;

    %c(SpringBoard);
    BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
    //NSLog(@"statusBarOrientation: %i", [[SpringBoard sharedApplication] activeInterfaceOrientation]);

    CGRect bounds = [[UIScreen mainScreen] bounds];
    //NSLog(@"Bounds: %@", NSStringFromCGRect(bounds));

    if (![self switcherShown] && !discoverabilityShown && enabled && switcherEnabled && !([self iPad] && [self iOS9])) {

        NSArray *apps = (NSArray *)[(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityRunningApplications];

        if (apps.count) {

            NSMutableArray *appsFiltered = [NSMutableArray new];
            NSMutableArray *switcherItemsFiltered = [NSMutableArray new];
            NSMutableArray *icons = [NSMutableArray new];
            %c(SBAppSwitcherModel);
            if ([(SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance] respondsToSelector:@selector(mainSwitcherDisplayItems)]) {
                switcherMode = SWITCHER_IOS9_MODE;
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
            } else {
                switcherMode = SWITCHER_IOS8_MODE;
                NSArray *switcherItems = [(SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance] snapshotOfFlattenedArrayOfAppIdentifiersWhichIsOnlyTemporary];
                %c(SBApplication);
                %c(SBApplicationIcon);
                for (int i = 0; i < switcherItems.count; ++i) {
                    for (SBApplication *app in apps) {
                        if ([(NSString *)[app bundleIdentifier] isEqualToString:(NSString *)switcherItems[i]]) {
                            [appsFiltered addObject:app];
                            [switcherItemsFiltered addObject:switcherItems[i]];
                            SBApplicationIcon *icon = [[%c(SBApplicationIcon) alloc] initWithApplication:app];
                            [icons addObject:[self image:(UIImage *)[icon generateIconImage:10] scaledToSize:CGSizeMake(ICON_SIZE, ICON_SIZE)]];
                            break;
                        }
                    }
                }
            }

            [self setApps:appsFiltered];
            [self setSwitcherItems:switcherItemsFiltered];

            if (appsFiltered.count) {

                CGRect contentFrame = CGRectMake(0, 0, ls ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width,
                                                       ls ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height);

                ///UIWindow *window = [[UIWindow alloc] initWithFrame:(((NSUInteger)[self maxIconsLS] == 6) || [self iPad]) ? contentFrame : bounds];
                UIWindow *window = [[UIWindow alloc] initWithFrame:contentFrame];
                window.windowLevel = UIWindowLevelAlert;

                CGFloat h = SWITCHER_HEIGHT;
                CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP])) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
                                                                                                 : ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP]) * ICON_SIZE + ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP]) + 1) * APP_GAP);
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
                switcherView.center = ((NSUInteger)[self maxIconsLS] == 6 || [self iPad]) ? CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds)) :
                                                                           CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

                [window addSubview:switcherView];
                [self setSwitcherView:switcherView];
                [self setSwitcherWindow:window];
                [window makeKeyAndVisible];

                [self setSwitcherShown:[NSNull null]];
                switcherOpenedInLandscape = ls;

                postDistributedNotification(@"SwitcherDidAppearNotification");
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
    postDistributedNotification(@"SwitcherDidDisappearNotification");
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
- (UIWindow *)discoverabilityWindow {
    return objc_getAssociatedObject(self, @selector(discoverabilityWindow));
}

%new
- (void)setDiscoverabilityWindow:(UIWindow *)value {
    objc_setAssociatedObject(self, @selector(discoverabilityWindow), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
- (NSMutableArray *)alertActions {
    return objc_getAssociatedObject(self, @selector(alertActions));
}

%new
- (void)setAlertActions:(id)value {
    objc_setAssociatedObject(self, @selector(alertActions), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)actionSheet {
    return objc_getAssociatedObject(self, @selector(actionSheet));
}

%new
- (void)setActionSheet:(id)value {
    objc_setAssociatedObject(self, @selector(actionSheet), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id)flashViewThread {
    return objc_getAssociatedObject(self, @selector(flashViewThread));
}

%new
- (void)setFlashViewThread:(id)value {
    objc_setAssociatedObject(self, @selector(flashViewThread), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (void)activateBundleID:(NSString *)bundleID {
    SBUIController *uicontroller = (SBUIController *)[%c(SBUIController) sharedInstance];
    SBApplicationController *appcontroller = (SBApplicationController *)[%c(SBApplicationController) sharedInstance];
    switcherMode = ([(SBAppSwitcherModel *)[%c(SBAppSwitcherModel) sharedInstance] respondsToSelector:@selector(mainSwitcherDisplayItems)]) ? SWITCHER_IOS9_MODE : SWITCHER_IOS8_MODE;
    if (switcherMode == SWITCHER_IOS9_MODE) {
        [uicontroller activateApplication:[appcontroller applicationWithBundleIdentifier:bundleID]];
    } else {
        [uicontroller activateApplicationAnimated:[appcontroller applicationWithBundleIdentifier:bundleID]];
    }
}

%new
- (void)handleCmdEnter:(UIKeyCommand *)keyCommand {
    if ([self switcherShown]) {
        [self activateBundleID:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
        [self dismissAppSwitcher];
    }
}

%new
- (void)handleCmdEsc:(UIKeyCommand *)keyCommand {
    if (switcherShown) {
        NSDebug(@"DISMISSING SWITCHER");
        postDistributedNotification(@"HideSwitcherNotification");
    } else if (controlEnabled) {
        NSDebug(@"INVOKING UI_ESC");
        [self ui_esc];
    }
}

%new
- (void)handleCmdQ:(UIKeyCommand *)keyCommand {
    if ([self switcherShown] && [((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) pid] > 0) {

        //BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
        BOOL ls = switcherOpenedInLandscape;

        if (switcherMode == SWITCHER_IOS9_MODE) {
            %c(SBDisplayItem);
            SBDisplayItem *di = ((NSArray *)[self switcherItems])[((NSNumber *)[self selectedIcon]).intValue];
            [[%c(SBAppSwitcherModel) sharedInstance] remove:di];
            [[%c(SBApplicationController) sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
        }
        %c(FBApplicationProcess);
        %c(FBProcessManager);
        FBApplicationProcess *process = [(FBProcessManager *)[%c(FBProcessManager) sharedInstance] createApplicationProcessForBundleID:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
        [process killForReason:1 andReport:NO withDescription:@"MolarAppSwitcher"];

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

        BOOL reopen = NO;
        if (switcherMode == SWITCHER_IOS8_MODE && !((NSNumber *)[self selectedIcon]).intValue) reopen = YES;
        [self setSelectedIcon:[NSNumber numberWithInt:((NSNumber *)[self selectedIcon]).intValue - ((((NSNumber *)[self selectedIcon]).intValue >= mLabels.count) ? 1 : 0)]];

        if (reopen) {
            [self activateBundleID:[((SBApplication *)((NSArray *)[self apps])[((NSNumber *)[self selectedIcon]).intValue]) bundleIdentifier]];
        }

        CGFloat h = SWITCHER_HEIGHT;
        CGFloat w = ([((NSArray *)[self apps]) count] < (ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP])) ? ([((NSArray *)[self apps]) count] * ICON_SIZE + ([((NSArray *)[self apps]) count] + 1) * APP_GAP)
                                                                                                 : ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP]) * ICON_SIZE + ((ls ? (NSUInteger)[self maxIconsLS] : (NSUInteger)[self maxIconsP]) + 1) * APP_GAP);
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
            ((UIView *)[self switcherView]).center = (ls && [self maxWidthLS] == @600.0) ? CGPointMake(CGRectGetMidY(((UIWindow *)[self switcherWindow]).bounds),
                                                                      CGRectGetMidX(((UIWindow *)[self switcherWindow]).bounds))
                                                        : CGPointMake(CGRectGetMidX(((UIWindow *)[self switcherWindow]).bounds),
                                                                      CGRectGetMidY(((UIWindow *)[self switcherWindow]).bounds));
            // set overlay view center
            ((UIView *)[self overlayView]).center = CGPointMake(((UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue)]).center.x - ((UIScrollView *)[self scrollView]).contentOffset.x,
                                                                ((UIImageView *)[self imageViews][(((NSNumber *)[self selectedIcon]).intValue)]).center.y - ((UIScrollView *)[self scrollView]).contentOffset.y);
        } completion:^(BOOL completed){
            [killedAppIV removeFromSuperview];
        }];
    }
    else if (enabled && ![self switcherShown] && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if ([self iOS9]) {
            %c(SBDisplayItem);
            [[%c(SBApplicationController) sharedInstance] applicationService:nil suspendApplicationWithBundleIdentifier:[self activeAppUserApplication]];
            %c(FBApplicationProcess);
            %c(FBProcessManager);
            FBApplicationProcess *process = [(FBProcessManager *)[%c(FBProcessManager) sharedInstance] createApplicationProcessForBundleID:[self activeAppUserApplication]];
            [process killForReason:1 andReport:NO withDescription:@"MolarAppSwitcher"];
        } else {
            %c(FBApplicationProcess);
            %c(FBProcessManager);
            FBApplicationProcess *process = [(FBProcessManager *)[%c(FBProcessManager) sharedInstance] createApplicationProcessForBundleID:[self activeAppUserApplication]];
            [process killForReason:1 andReport:NO withDescription:@"MolarAppSwitcher"];
        }
    }
}

%new
- (void)stopDiscoverabilityTimer {
    if (discoverabilityTimer) {
        [discoverabilityTimer invalidate];
        discoverabilityTimer = nil;
    }
}

%new
- (void)handleCmdShiftH:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (sbFolderOpened) {
        sbFolderOpened = NO;
        [sbIconView addSubview:sbIconOverlay];
    }
    //[[%c(SBUIController) sharedInstance] clickedMenuButton];
    LAEvent *event = [LAEvent eventWithName:@"MolarHomeButton" mode:[LASharedActivator currentEventMode]];
    [LASharedActivator assignEvent:event toListenerWithName:@"libactivator.system.homebutton"];
    [LASharedActivator sendEventToListener:event];
    [LASharedActivator unassignEvent:event];
}

%new
- (void)handleCmdShiftP:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    //[[%c(SBUserAgent) sharedUserAgent] lockAndDimDevice];
    LAEvent *event = [LAEvent eventWithName:@"MolarSleepButton" mode:[LASharedActivator currentEventMode]];
    [LASharedActivator assignEvent:event toListenerWithName:@"libactivator.system.sleepbutton"];
    [LASharedActivator sendEventToListener:event];
    [LASharedActivator unassignEvent:event];
}

%new
- (void)handleCmd1:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp1 && ![launcherApp1 isEqualToString:@""]) {
        [self activateBundleID:launcherApp1];
    }
}

%new
- (void)handleCmd2:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp2 && ![launcherApp2 isEqualToString:@""]) {
        [self activateBundleID:launcherApp2];
    }
}

%new
- (void)handleCmd3:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp3 && ![launcherApp3 isEqualToString:@""]) {
        [self activateBundleID:launcherApp3];
    }
}

%new
- (void)handleCmd4:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp4 && ![launcherApp4 isEqualToString:@""]) {
        [self activateBundleID:launcherApp4];
    }
}

%new
- (void)handleCmd5:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp5 && ![launcherApp5 isEqualToString:@""]) {
        [self activateBundleID:launcherApp5];
    }
}

%new
- (void)handleCmd6:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp6 && ![launcherApp6 isEqualToString:@""]) {
        [self activateBundleID:launcherApp6];
    }
}

%new
- (void)handleCmd7:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp7 && ![launcherApp7 isEqualToString:@""]) {
        [self activateBundleID:launcherApp7];
    }
}

%new
- (void)handleCmd8:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp8 && ![launcherApp8 isEqualToString:@""]) {
        [self activateBundleID:launcherApp8];
    }
}

%new
- (void)handleCmd9:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp9 && ![launcherApp9 isEqualToString:@""]) {
        [self activateBundleID:launcherApp9];
    }
}

%new
- (void)handleCmd0:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    if (launcherApp0 && ![launcherApp0 isEqualToString:@""]) {
        [self activateBundleID:launcherApp0];
    }
}

%new
- (void)handleCustomShortcut:(UIKeyCommand *)keyCommand {
    [self stopDiscoverabilityTimer];
    for (NSDictionary *sc in customShortcuts) {
        if ([keyCommand.input isEqualToString:[sc objectForKey:@"input"]] &&
            keyCommand.modifierFlags == ((NSNumber *)[self modifierFlagsForShortcut:sc]).intValue) {
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
- (void)escKeyDown:(NSNotification *)notif {
    NSDebug(@"ESC DOWN: %@", [notif.userInfo objectForKey:@"sender"]);
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:[notif.userInfo objectForKey:@"sender"]]) {
        if ([self cmdDown]) {
            NSDebug(@"escKeyDown -> handleCmdEsc");
            [self handleCmdEsc:nil];
        }
        else if (enabled) {
            NSDebug(@"escKeyDown -> ui_esc");
            [self ui_esc];
        }
    }
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
    if (enabled && keySheetEnabled) discoverabilityTimer = [NSTimer scheduledTimerWithTimeInterval:DISCOVERABILITY_DELAY
                                                                                            target:self
                                                                                          selector:@selector(showDiscoverability)
                                                                                          userInfo:nil
                                                                                           repeats:NO];
    [self setCmdDown:[NSNull null]];
    [self handleKeyStatus:0];
}

%new
- (void)cmdKeyUp {
    if (discoverabilityTimer) [discoverabilityTimer invalidate];
    else if (discoverabilityShown) {
        [(UIWindow *)[self discoverabilityWindow] setHidden:YES];
        discoverabilityShown = NO;
        postDistributedNotification(@"DiscoverabilityDidDisappearNotification");
    }
    discoverabilityTimer = nil;
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

%new
- (void)genericKeyDown {
    [self stopDiscoverabilityTimer];
}

%new
- (void)recursivelyFindKeyCommands:(UIViewController *)vc {
    if ([vc respondsToSelector:@selector(keyCommands)]) {
        [allKeyCommands addObjectsFromArray:vc.keyCommands];
    }
    // Handling UITabBarController
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)vc;
        [self recursivelyFindKeyCommands:tabBarController.selectedViewController];
    }
    // Handling UINavigationController
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)vc;
        [self recursivelyFindKeyCommands:navigationController.visibleViewController];
    }
    // Handling Modal views
    else if ([vc respondsToSelector:@selector(presentedViewController)] && vc.presentedViewController) {
        UIViewController *presentedViewController = vc.presentedViewController;
        [self recursivelyFindKeyCommands:presentedViewController];
    }
    // Handling UIViewController's added as subviews to some other views.
    else {
        if ([vc respondsToSelector:@selector(view)]) {
            for (UIView *view in [vc.view subviews]) {
                id subViewController = [view nextResponder];
                if (subViewController && [subViewController isKindOfClass:[UIResponder class]]) {
                    [self recursivelyFindKeyCommands:subViewController];
                }
            }
        }
    }
}

%new
- (NSString *)modifierString:(UIKeyCommand *)kc {
    NSMutableString *mStr = [NSMutableString new];
    if (kc.modifierFlags & UIKeyModifierShift)     [mStr appendString:@"⇧ "];
    if (kc.modifierFlags & UIKeyModifierControl)   [mStr appendString:@"⌃ "];
    if (kc.modifierFlags & UIKeyModifierAlternate) [mStr appendString:@"⌥ "];
    if (kc.modifierFlags & UIKeyModifierCommand)   [mStr appendString:@"⌘ "];
    if ([kc.input isEqualToString:UIKeyInputLeftArrow])       [mStr appendString:@"← "];
    else if ([kc.input isEqualToString:UIKeyInputRightArrow]) [mStr appendString:@"→ "];
    else if ([kc.input isEqualToString:UIKeyInputUpArrow])    [mStr appendString:@"↑ "];
    else if ([kc.input isEqualToString:UIKeyInputDownArrow])  [mStr appendString:@"↓ "];
    else if ([kc.input isEqualToString:UIKeyInputEscape])     [mStr appendString:@"ESC"];
    else if ([kc.input isEqualToString:@"   "])     [mStr appendString:@"⇥"];
    else [mStr appendString:kc.input.uppercaseString];
    return mStr;
}

%new
- (UIView *)discoverabilityLabelViewWithTitle:(NSString *)title
                                     shortcut:(NSString *)shortcut
                                     minWidth:(CGFloat)minWidth
                                     maxWidth:(CGFloat)maxWidth {

    CGFloat modifierWidth = DISCOVERABILITY_MODIFIER_WIDTH;

    CGSize size = [(title ? title: @"") sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:DISCOVERABILITY_FONT_SIZE]}];
    CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    if (adjustedSize.width > maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP) adjustedSize = CGSizeMake(maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP, adjustedSize.height);
    else if (adjustedSize.width < minWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP) adjustedSize = CGSizeMake(minWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP, adjustedSize.height);

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, adjustedSize.width, adjustedSize.height)];
    titleLabel.font = [UIFont systemFontOfSize:DISCOVERABILITY_FONT_SIZE];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumFontSize = 14.0f;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    if (darkMode) titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = title;
    //titleLabel.backgroundColor = [UIColor greenColor];

    UILabel *shortcutLabel = [[UILabel alloc] initWithFrame:CGRectMake(adjustedSize.width + DISCOVERABILITY_MODIFIER_GAP, 0, modifierWidth, adjustedSize.height)];
    shortcutLabel.font = [UIFont systemFontOfSize:DISCOVERABILITY_FONT_SIZE];
    if (darkMode) shortcutLabel.textColor = [UIColor whiteColor];
    shortcutLabel.text = shortcut;
    shortcutLabel.textAlignment = NSTextAlignmentRight;
    //shortcutLabel.backgroundColor = [UIColor greenColor];

    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, adjustedSize.width + DISCOVERABILITY_MODIFIER_GAP + modifierWidth, adjustedSize.height)];
    [container addSubview:titleLabel];
    [container addSubview:shortcutLabel];
    //container.backgroundColor = [UIColor yellowColor];
    return container;
}

%new
- (NSNumber *)minimumWidthForKeyCommands:(NSArray *)cmds maxWidth:(CGFloat)maxWidth {
    CGFloat modifierWidth = DISCOVERABILITY_MODIFIER_WIDTH;
    CGFloat max = 0.0;
    if ([self iOS9]) {
        for (UIKeyCommand *kc in cmds) {
            CGSize size = [(kc.discoverabilityTitle ? kc.discoverabilityTitle: @"") sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:DISCOVERABILITY_FONT_SIZE]}];
            CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
            if (adjustedSize.width > maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP) adjustedSize = CGSizeMake(maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP, adjustedSize.height);
            if (adjustedSize.width > max ) max = adjustedSize.width;
        }
    } else {
        for (UIKeyCommand *kc in cmds) {
            CGSize size = [@"" sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:DISCOVERABILITY_FONT_SIZE]}];
            CGSize adjustedSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
            if (adjustedSize.width > maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP) adjustedSize = CGSizeMake(maxWidth - modifierWidth - DISCOVERABILITY_MODIFIER_GAP, adjustedSize.height);
            if (adjustedSize.width > max ) max = adjustedSize.width;
        }
    }
    return @(max + DISCOVERABILITY_MODIFIER_GAP + modifierWidth);
}

%new
- (void)pageChanged {
    CGPoint offset = CGPointMake(pageControl.currentPage * discoverabilityScrollView.frame.size.width, 0);
    [discoverabilityScrollView setContentOffset:offset animated:YES];
}

%new
- (void)showDiscoverability {
    discoverabilityTimer = nil;
    if (enabled && [self isActive] && ![self switcherShown] && !([self iPad] && [self iOS9])) {

        int addedKeyCommands = 13 + customShortcuts.count;
        allKeyCommands = [NSMutableArray array];
        [self recursivelyFindKeyCommands:self.keyWindow.rootViewController];
        NSMutableArray *commands = allKeyCommands;
        NSMutableArray *selfCommands = [NSMutableArray arrayWithArray:self.keyCommands];
        [selfCommands removeObjectsInRange:NSMakeRange(self.keyCommands.count - 1 - addedKeyCommands, addedKeyCommands)];
        for (UIKeyCommand *kc in selfCommands) {
            if (![commands containsObject:kc]) [commands addObject:kc];
        }
        for (int i = 0; i < commands.count; i++) {
            UIKeyCommand *kc = commands[i];
            if ([self iOS9]) {
                if (!kc.discoverabilityTitle &&
                    kc.modifierFlags == UIKeyModifierCommand &&
                    ([kc.input isEqualToString:@"+"] || [kc.input.uppercaseString isEqualToString:@"-"] || [kc.input isEqualToString:@"0"])) {
                    [commands removeObject:kc];
                }
            } else {
                if (kc.modifierFlags == UIKeyModifierCommand &&
                    ([kc.input isEqualToString:@"+"] || [kc.input.uppercaseString isEqualToString:@"-"] || [kc.input isEqualToString:@"0"])) {
                    [commands removeObject:kc];
                }
            }
        }
        for (int i = 0; i < commands.count; i++) {
            UIKeyCommand *kc = commands[i];
            if ([self iOS9]) {
                if (!kc.discoverabilityTitle && [[self modifierString:kc] isEqualToString:@"⌘ -"]) [commands removeObjectAtIndex:i];
            } else {
                if ([[self modifierString:kc] isEqualToString:@"⌘ -"]) [commands removeObjectAtIndex:i];
            }
        }

        if (commands.count) {

            //BOOL ls = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].keyWindow.rootViewController.interfaceOrientation);
            //UIInterfaceOrientation orient = [UIDevice currentDevice].orientation;
            //UIInterfaceOrientation orient = (UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation];
            UIInterfaceOrientation orient = [UIApplication sharedApplication].statusBarOrientation;
            BOOL ls = UIInterfaceOrientationIsLandscape(orient);

            CGRect bounds = [[UIScreen mainScreen] bounds];
            CGRect contentFrame = CGRectMake(0, 0, ls ? bounds.size.height : bounds.size.width,
                                                   ls ? bounds.size.width  : bounds.size.height);

            if ([self iPad] && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
                contentFrame = CGRectMake(contentFrame.origin.x, contentFrame.origin.y, contentFrame.size.height, contentFrame.size.width);
            }

            CGRect discRect = CGRectInset(((NSUInteger)[self maxIconsLS] == 6 && ![self iPhonePlus]) ? contentFrame : bounds, 15.0f, 15.0f);

            UIWindow *window = [[UIWindow alloc] initWithFrame:((NSUInteger)[self maxIconsLS] == 6 && ![self iPhonePlus]) || ([self iPad] && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) ? contentFrame : bounds];
            window.windowLevel = UIWindowLevelAlert;

            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:darkMode ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = discRect;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            blurEffectView.layer.cornerRadius = CORNER_RADIUS;
            blurEffectView.clipsToBounds = YES;

            [self setDiscoverabilityWindow:window];

            if ([self iPhonePlus] && ls) {
                blurEffectView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
            }
            else if (ls && ![self iPad] ||
                (ls && [self iPad] && [[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]))
                blurEffectView.transform = orient == UIInterfaceOrientationLandscapeLeft ?
                                                CGAffineTransformMakeRotation(DegreesToRadians(270)) :
                                                CGAffineTransformMakeRotation(DegreesToRadians(90));
            else if (orient == UIInterfaceOrientationPortraitUpsideDown && ![self iPad]) {
                blurEffectView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
            }

            CGFloat maxWLS = ((NSNumber *)[self maxWidthLS]).doubleValue;
            CGFloat maxWP  = ((NSNumber *)[self maxWidthP]).doubleValue;

            if (ls) {
                int iconsPerPage = (NSUInteger)[self maxCommandsLS];
                if (commands.count > iconsPerPage) {
                    int pages = (int)ceil((double)commands.count / (iconsPerPage * 2));
                    int cmdsLeft = commands.count;
                    UILabel *testLabel = [self discoverabilityLabelViewWithTitle:@"Test"
                                                                           shortcut:@"Test"
                                                                           minWidth:maxWP
                                                                           maxWidth:maxWP];

                    blurEffectView.frame = CGRectInset(blurEffectView.frame, DISCOVERABILITY_LS_Y_DECREASE, 0.0f);
                    discoverabilityScrollView = [[UIScrollView alloc] initWithFrame:[self iPad] ? blurEffectView.frame : ([self iPhonePlus] ?
                                                                                    CGRectMake(0, 0,
                                                                                                blurEffectView.frame.size.width,
                                                                                                blurEffectView.frame.size.height) :
                                                                                     CGRectMake(0, 0,
                                                                                                blurEffectView.frame.size.height,
                                                                                                blurEffectView.frame.size.width))];
                    discoverabilityScrollView.contentSize = CGSizeMake(discoverabilityScrollView.frame.size.width * pages, discoverabilityScrollView.frame.size.height);
                    discoverabilityScrollView.pagingEnabled = YES;
                    discoverabilityScrollView.bounces = NO;
                    discoverabilityScrollView.showsHorizontalScrollIndicator = NO;
                    discoverabilityScrollView.userInteractionEnabled = NO;
                    NSUInteger idx = 0;
                    for (int i = 0; i < pages; i++) {
                        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(i * discoverabilityScrollView.frame.size.width,
                                                                                0,
                                                                                discoverabilityScrollView.frame.size.width,
                                                                                discoverabilityScrollView.frame.size.height)];
                        for (int col = 0; col < 2; col++) {
                            for (int l = 0; l < iconsPerPage; l++) {
                                if (!cmdsLeft) break;
                                UIKeyCommand *kc = commands[idx];
                                UIView *label = [self discoverabilityLabelViewWithTitle:[self iOS9] ? kc.discoverabilityTitle : @""
                                                                               shortcut:[self modifierString:kc]
                                                                               minWidth:maxWLS/2 - 25
                                                                               maxWidth:maxWLS/2 - 25];
                                label.frame = CGRectMake(!col ? DISCOVERABILITY_INSET : DISCOVERABILITY_INSET + maxWLS/2 + 5,
                                                         DISCOVERABILITY_INSET + ((double)l * (DISCOVERABILITY_GAP + label.frame.size.height)),
                                                         label.frame.size.width,
                                                         label.frame.size.height);
                                [page addSubview:label];
                                idx++;
                                cmdsLeft--;
                            }
                        }
                        [discoverabilityScrollView addSubview:page];
                        if (!cmdsLeft) break;
                    }
                    [blurEffectView addSubview:discoverabilityScrollView];
                    if (pages > 1) {
                        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, blurEffectView.frame.size.height, 15)];
                        pageControl.userInteractionEnabled = NO;
                        pageControl.numberOfPages = pages;
                        pageControl.frame = CGRectMake(0, 0, [pageControl sizeForNumberOfPages:pages].width, [pageControl sizeForNumberOfPages:pages].height);
                        pageControl.center = CGPointMake(CGRectGetMidX(blurEffectView.frame) - ([self iPhonePlus] ? pageControl.frame.size.width - 5 : DISCOVERABILITY_LS_Y_DECREASE), CGRectGetMidY(blurEffectView.frame) + ([self iPhonePlus] ? (blurEffectView.frame.size.height / 2) - 40 : 109));
                        [pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
                        [blurEffectView addSubview:pageControl];
                    }
                } else {
                    NSMutableArray *labels = [NSMutableArray array];
                    CGFloat maxWidth = 0;
                    CGFloat minWidth = ((NSNumber *)[self minimumWidthForKeyCommands:commands maxWidth:maxWLS]).floatValue;
                    for (UIKeyCommand *kc in commands) {
                        UIView *l = [self discoverabilityLabelViewWithTitle:[self iOS9] ? kc.discoverabilityTitle : @""
                                                                   shortcut:[self modifierString:kc]
                                                                   minWidth:minWidth
                                                                   maxWidth:maxWLS];
                        [labels addObject:l];
                        if (l.frame.size.width > maxWidth) maxWidth = l.frame.size.width;
                    }

                    blurEffectView.frame = [self iPad] && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"] ? CGRectMake(0, 0,
                                                                    maxWidth + (DISCOVERABILITY_INSET * 2),
                                                                     (((UIView *)labels[0]).frame.size.height * labels.count) +
                                                                     (DISCOVERABILITY_GAP * (labels.count - 1)) +
                                                                     (2 * DISCOVERABILITY_INSET)) : ([self iPhonePlus] ?
                                                                     CGRectMake(0, 0,
                                                                        maxWidth + (DISCOVERABILITY_INSET * 2),
                                                                        (((UIView *)labels[0]).frame.size.height * labels.count) +
                                                                        (DISCOVERABILITY_GAP * (labels.count - 1)) +
                                                                        (2 * DISCOVERABILITY_INSET)) :
                                                                     CGRectMake(0, 0,
                                                                        (((UIView *)labels[0]).frame.size.height * labels.count) +
                                                                        (DISCOVERABILITY_GAP * (labels.count - 1)) +
                                                                        (2 * DISCOVERABILITY_INSET),
                                                                        maxWidth + (DISCOVERABILITY_INSET * 2)));
                    NSUInteger index = 0;
                    for (UIView *label in labels) {
                        label.frame = CGRectMake(DISCOVERABILITY_INSET,
                                                 DISCOVERABILITY_INSET + ((double)index * (DISCOVERABILITY_GAP + label.frame.size.height)),
                                                 label.frame.size.width,
                                                 label.frame.size.height);
                        [blurEffectView addSubview:label];
                        index++;
                    }
                }
            } else {
                int iconsPerPage = (NSUInteger)[self maxCommandsP];
                if (commands.count > iconsPerPage) {
                    int pages = (int)ceil((double)commands.count / iconsPerPage);
                    int cmdsLeft = commands.count;
                    UILabel *testLabel = [self discoverabilityLabelViewWithTitle:@"Test"
                                                                           shortcut:@"Test"
                                                                           minWidth:maxWP
                                                                           maxWidth:maxWP];
                    blurEffectView.frame = CGRectMake(0, 0,
                                                      blurEffectView.frame.size.width,
                                                      (testLabel.frame.size.height * iconsPerPage) +
                                                        (DISCOVERABILITY_GAP * (iconsPerPage - 1)) +
                                                        (2 * DISCOVERABILITY_INSET));
                    discoverabilityScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                              blurEffectView.frame.size.width,
                                                                                              blurEffectView.frame.size.height)];
                    discoverabilityScrollView.contentSize = CGSizeMake(discoverabilityScrollView.frame.size.width * pages, discoverabilityScrollView.frame.size.height);
                    discoverabilityScrollView.pagingEnabled = YES;
                    discoverabilityScrollView.bounces = NO;
                    discoverabilityScrollView.showsHorizontalScrollIndicator = NO;
                    discoverabilityScrollView.userInteractionEnabled = NO;
                    NSUInteger idx = 0;
                    for (int i = 0; i < pages; i++) {
                        UIView *page = [[UIView alloc] initWithFrame:CGRectMake(i * discoverabilityScrollView.frame.size.width,
                                                                                0,
                                                                                discoverabilityScrollView.frame.size.width,
                                                                                discoverabilityScrollView.frame.size.height)];
                        for (int l = 0; l < iconsPerPage; l++) {
                            if (!cmdsLeft) break;
                            UIKeyCommand *kc = commands[idx];
                            UIView *label = [self discoverabilityLabelViewWithTitle:[self iOS9] ? kc.discoverabilityTitle : @""
                                                                           shortcut:[self modifierString:kc]
                                                                           minWidth:maxWP
                                                                           maxWidth:maxWP];
                            label.frame = CGRectMake(DISCOVERABILITY_INSET,
                                                     DISCOVERABILITY_INSET + ((double)l * (DISCOVERABILITY_GAP + label.frame.size.height)),
                                                     label.frame.size.width,
                                                     label.frame.size.height);
                            [page addSubview:label];
                            idx++;
                            cmdsLeft--;
                        }
                        [discoverabilityScrollView addSubview:page];
                        if (!cmdsLeft) break;
                    }
                    [blurEffectView addSubview:discoverabilityScrollView];
                    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, blurEffectView.frame.size.width, 15)];
                    pageControl.userInteractionEnabled = NO;
                    pageControl.numberOfPages = pages;
                    pageControl.frame = CGRectMake(0, 0, [pageControl sizeForNumberOfPages:pages].width, [pageControl sizeForNumberOfPages:pages].height);
                    pageControl.center = CGPointMake(CGRectGetMidX(blurEffectView.frame), blurEffectView.frame.size.height - 17);
                    [pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
                    [blurEffectView addSubview:pageControl];
                } else {
                    NSMutableArray *labels = [NSMutableArray array];
                    CGFloat minWidth = ((NSNumber *)[self minimumWidthForKeyCommands:commands maxWidth:maxWP]).floatValue;
                    for (UIKeyCommand *kc in commands) {
                        UIView *l = [self discoverabilityLabelViewWithTitle:[self iOS9] ? kc.discoverabilityTitle : @""
                                                                   shortcut:[self modifierString:kc]
                                                                   minWidth:minWidth
                                                                   maxWidth:maxWP];
                        [labels addObject:l];
                    }
                    blurEffectView.frame = CGRectMake(0, 0,
                                                      minWidth + (DISCOVERABILITY_INSET * 2),
                                                      (((UIView *)labels[0]).frame.size.height * labels.count) +
                                                        (DISCOVERABILITY_GAP * (labels.count - 1)) +
                                                        (2 * DISCOVERABILITY_INSET));
                    NSUInteger index = 0;
                    for (UIView *label in labels) {
                        label.frame = CGRectMake(DISCOVERABILITY_INSET,
                                                 DISCOVERABILITY_INSET + ((double)index * (DISCOVERABILITY_GAP + label.frame.size.height)),
                                                 label.frame.size.width,
                                                 label.frame.size.height);
                        [blurEffectView addSubview:label];
                        index++;
                    }
                }
            }

            blurEffectView.center = ((NSUInteger)[self maxIconsLS] == 6 || ([self iPad] && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"])) ? CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds)) :
                                                                                          CGPointMake(CGRectGetMidX(contentFrame), CGRectGetMidY(contentFrame));
            NSDebug(@"\nLS: %i\nWINDOW: %@\nBOUNDS: %@\nCONTENT FRAME: %@\nBLUR FRAME: %@\nROTATION: %@", ls, NSStringFromCGRect(window.frame), NSStringFromCGRect(bounds), NSStringFromCGRect(contentFrame), NSStringFromCGRect(blurEffectView.frame), NSStringFromCGAffineTransform(blurEffectView.transform));

            [window addSubview:blurEffectView];
            [window makeKeyAndVisible];
            discoverabilityShown = YES;
            postDistributedNotification(@"DiscoverabilityDidAppearNotification");
        }
    }
}

%new
- (NSNumber *)modifierFlagsForShortcut:(NSDictionary *)sc {
    int mFlags = 0;
    if (((NSNumber *)[sc objectForKey:@"cmd"]).boolValue)   mFlags |= UIKeyModifierCommand;
    if (((NSNumber *)[sc objectForKey:@"ctrl"]).boolValue)  mFlags |= UIKeyModifierControl;
    if (((NSNumber *)[sc objectForKey:@"alt"]).boolValue)   mFlags |= UIKeyModifierAlternate;
    if (((NSNumber *)[sc objectForKey:@"shift"]).boolValue) mFlags |= UIKeyModifierShift;
    return @(mFlags);
}

%new
- (void)reloadShortcuts {
    if ([self respondsToSelector:@selector(_updateSerializableKeyCommandsForResponder:)]) {
        [self _updateSerializableKeyCommandsForResponder:((UIWindow *)[UIWindow keyWindow]).rootViewController];
    }
}

%new
- (void)updateActiveApp {
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        %c(SpringBoard);
        %c(SBApplication);
        activeApp = [[(SpringBoard *)[%c(SpringBoard) sharedApplication] _accessibilityFrontMostApplication] bundleIdentifier];
        if (!activeApp) activeApp = @"com.apple.springboard";

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

        if (launcherEnabled) {
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
        }

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
    }

    if (![self hidSetup]) {
        setupHID();
        [self addMolarObservers];
        [self setHidSetup:[NSNull null]];
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
- (void)scrollSBToPage:(int)page {
    %c(SBRootFolderView);
    %c(SBRootFolderController);
    [(SBRootFolderView *)[(SBRootFolderController *)[[%c(SBIconController) sharedInstance] _rootFolderController] contentView] setCurrentPageIndex:page animated:YES];
}

%new
- (void)scrollOpenedSBFolderToPage:(int)page {
    [[[[%c(SBIconController) sharedInstance ] _currentFolderController] contentView] setCurrentPageIndex:page animated:YES];
}

%new
- (void)ui_leftKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && ![self switcherShown] && !discoverabilityShown && [self isActive]) {
            [self stopDiscoverabilityTimer];
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
            if (sliderMode) {
                UISlider *slider = (UISlider *)[self selectedView];
                float dec = (slider.maximumValue - slider.minimumValue) / SLIDER_LEVELS;
                [slider setValue:slider.value-dec animated:YES];
                [slider sendActionsForControlEvents:UIControlEventValueChanged];
                if (!keyRepeatTimer) {
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"left"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
            }
            else if (scrollViewMode) {
                UIScrollView *scrollView = (UIScrollView *)[self selectedView];
                CGPoint newOffset;
                if ([self cmdDown]) {
                    newOffset = CGPointMake(0,
                                            scrollView.contentOffset.y);
                } else {
                    if (keyRepeatTimer) {
                        newOffset = CGPointMake(scrollView.contentOffset.x - KEY_REPEAT_STEP,
                                                scrollView.contentOffset.y);

                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x - ((scrollView.frame.size.width) / 3),
                                                scrollView.contentOffset.y);
                    }
                    if (newOffset.x <  0) newOffset.x = 0;
                }
                if (!keyRepeatTimer) {
                    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"left"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
                [scrollView setContentOffset:newOffset animated:!keyRepeatTimer];
            }
        }
        else if (enabled && [self isActive] && discoverabilityShown) {
            pageControl.currentPage--;
            [self pageChanged];
        }
    } else if (enabled && [self iOS9]) {
        if (sbFolderOpened) {
            if (sbOpenedFolderSelectedCol > 0) {

                sbOpenedFolderSelectedCol--;
                [self selectSBIconInOpenedFolder];

            } else {
                if (sbOpenedFolderSelectedPage > 0) {

                    sbOpenedFolderSelectedPage--;
                    sbOpenedFolderSelectedCol = SBFOLDER_ICONS_X - 1;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                        sbOpenedFolderSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] / (double)SBFOLDER_ICONS_X) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X) + SBFOLDER_ICONS_X) {
                        sbOpenedFolderSelectedCol = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] % SBFOLDER_ICONS_X) - 1;
                    }

                    [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                    [self selectSBIconInOpenedFolder];

                } else {

                    sbOpenedFolderSelectedPage = sbOpenedFolderPages - 1;
                    sbOpenedFolderSelectedCol = SBFOLDER_ICONS_X - 1;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X) + SBFOLDER_ICONS_X) {
                        sbOpenedFolderSelectedCol = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] % SBFOLDER_ICONS_X) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                        sbOpenedFolderSelectedRow = 0;
                    }

                    [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                    [self selectSBIconInOpenedFolder];
                }
            }
        }
        else if (!sbIconSelected) {

            if (sbDockIconSelected) {
                if (sbSelectedColumn > 0) {
                    sbSelectedColumn--;
                    [self selectSBDockIcon:sbSelectedColumn];
                } else {
                    sbSelectedColumn = sbDockIconCount - 1;
                    [self selectSBDockIcon:sbSelectedColumn];
                }
            } else {

                BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
                if (ls) {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                } else {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                }
                sbDockIcons = (NSArray *)[[[[%c(SBIconController) sharedInstance] rootFolder] dock] icons];
                sbDockIconCount = sbDockIcons.count;

                sbPages = [(SBFolder *)[[%c(SBIconController) sharedInstance] rootFolder] listCount];

                NSDebug(@"R: %i C: %i D: %i", sbRows, sbColumns, sbDockIconCount);

                sbSelectedColumn = sbSelectedRow = sbSelectedPage = 0;
                sbIconSelected = YES;
                sbDockIconSelected = NO;

                [self scrollSBToPage:sbSelectedPage];
                [self selectSBIcon];
            }
        } else {
            if (sbSelectedColumn > 0) {

                sbSelectedColumn--;
                [self selectSBIcon];

            } else {
                if (sbSelectedPage > 0) {

                    sbSelectedPage--;
                    sbSelectedColumn = sbColumns - 1;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns) + sbColumns) {
                        sbSelectedColumn = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns) - 1;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];

                } else {

                    sbSelectedPage = sbPages - 1;
                    sbSelectedColumn = sbColumns - 1;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns) + sbColumns) {
                        sbSelectedColumn = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = 0;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];
                }
            }
        }
    }
}

%new
- (void)ui_leftUp {
    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
    else [keyRepeatTimer invalidate];
    keyRepeatTimer = nil;
    waitingForKeyRepeat = NO;
}

%new
- (void)ui_rightKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && ![self switcherShown] && !discoverabilityShown && [self isActive]) {
            [self stopDiscoverabilityTimer];
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
            if (sliderMode) {
                UISlider *slider = (UISlider *)[self selectedView];
                float inc = (slider.maximumValue - slider.minimumValue) / SLIDER_LEVELS;
                [slider setValue:slider.value+inc animated:YES];
                [slider sendActionsForControlEvents:UIControlEventValueChanged];
                if (!keyRepeatTimer) {
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"right"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
            }
            else if (scrollViewMode) {
                UIScrollView *scrollView = (UIScrollView *)[self selectedView];
                CGPoint newOffset;
                if ([self cmdDown]) {
                    newOffset = CGPointMake(scrollView.contentSize.width - scrollView.frame.size.width,
                                            scrollView.contentOffset.y);
                } else {
                    if (keyRepeatTimer) {
                        newOffset = CGPointMake(scrollView.contentOffset.x + KEY_REPEAT_STEP,
                                                scrollView.contentOffset.y);
                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x + ((scrollView.frame.size.width) / 3),
                                                scrollView.contentOffset.y);
                    }
                    if (newOffset.x > (scrollView.contentSize.width - scrollView.frame.size.width))
                        newOffset.x = scrollView.contentSize.width - scrollView.frame.size.width;
                }
                if (!keyRepeatTimer) {
                    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"right"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
                [scrollView setContentOffset:newOffset animated:!keyRepeatTimer];
            }
        }
        else if (enabled && [self isActive] && discoverabilityShown) {
            pageControl.currentPage++;
            [self pageChanged];
        }
    } else if (enabled && [self iOS9] && sbFolderOpened) {

        if (sbOpenedFolderSelectedCol < SBFOLDER_ICONS_X - 1) {

            if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] > (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X) + sbOpenedFolderSelectedCol + 1) {

                sbOpenedFolderSelectedCol++;

                [self selectSBIconInOpenedFolder];

            } else if (sbOpenedFolderSelectedPage == sbOpenedFolderPages - 1) {

                sbOpenedFolderSelectedPage = 0;
                sbOpenedFolderSelectedCol = 0;
                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                    sbOpenedFolderSelectedRow = 0;
                }

                [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                [self selectSBIconInOpenedFolder];
            }

            else {

                sbOpenedFolderSelectedPage++;
                sbOpenedFolderSelectedCol = 0;
                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                    sbOpenedFolderSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] / (double)SBFOLDER_ICONS_X) - 1;
                }

                [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                [self selectSBIconInOpenedFolder];
            }

        } else {
            if (sbOpenedFolderSelectedPage < sbOpenedFolderPages - 1) {

                sbOpenedFolderSelectedPage++;
                sbOpenedFolderSelectedCol = 0;
                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                    sbOpenedFolderSelectedRow = 0;
                }

                [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                [self selectSBIconInOpenedFolder];

            } else {

                sbOpenedFolderSelectedPage = 0;
                sbOpenedFolderSelectedCol = 0;
                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] < (sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X)) {
                    sbOpenedFolderSelectedRow = 0;
                }

                [self scrollOpenedSBFolderToPage:sbOpenedFolderSelectedPage];
                [self selectSBIconInOpenedFolder];
            }
        }

    } else if (enabled && [self iOS9]) {
        if (!sbIconSelected) {

            if (sbDockIconSelected) {
                if (sbSelectedColumn < sbDockIconCount - 1) {
                    sbSelectedColumn++;
                    [self selectSBDockIcon:sbSelectedColumn];
                } else {
                    sbSelectedColumn = 0;
                    [self selectSBDockIcon:sbSelectedColumn];
                }
            }
            else {

                BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
                if (ls) {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                } else {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                }
                sbDockIcons = (NSArray *)[[[[%c(SBIconController) sharedInstance] rootFolder] dock] icons];
                sbDockIconCount = sbDockIcons.count;

                sbPages = [(SBFolder *)[[%c(SBIconController) sharedInstance] rootFolder] listCount];

                NSDebug(@"R: %i C: %i D: %i", sbRows, sbColumns, sbDockIconCount);

                sbSelectedColumn = sbSelectedRow = sbSelectedPage = 0;
                sbIconSelected = YES;
                sbDockIconSelected = NO;

                [self scrollSBToPage:sbSelectedPage];
                [self selectSBIcon];

            }
        } else {
            if (sbSelectedColumn < sbColumns - 1) {

                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] > (sbSelectedRow * sbColumns) + sbSelectedColumn + 1) {

                    sbSelectedColumn++;

                    [self selectSBIcon];

                } else if (sbSelectedPage == sbPages - 1) {

                    sbSelectedPage = 0;
                    sbSelectedColumn = 0;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = 0;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];
                }
                else {

                    sbSelectedPage++;
                    sbSelectedColumn = 0;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];
                }

            } else {
                if (sbSelectedPage < sbPages - 1) {

                    sbSelectedPage++;
                    sbSelectedColumn = 0;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = 0;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];

                } else {

                    sbSelectedPage = 0;
                    sbSelectedColumn = 0;
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = 0;
                    }

                    [self scrollSBToPage:sbSelectedPage];
                    [self selectSBIcon];
                }
            }
        }
    }
}

%new
- (void)ui_rightUp {
    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
    else [keyRepeatTimer invalidate];
    keyRepeatTimer = nil;
    waitingForKeyRepeat = NO;
}

%new
- (void)ui_downKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self isActive]) {
            [self stopDiscoverabilityTimer];
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
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
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
                    @try { [selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES]; }
                    @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                    selectedCell.transform = CGAffineTransformConcat(selectedCell.transform,
                                                                     CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                } completion:nil];
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
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
                    UICollectionViewCell *cell = [selectedCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
                    cell.selected = YES;
                    selectedItem = cell;
                }
                CGAffineTransform backupTransform = selectedItem.transform;
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
                    @try { [selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow
                                                                 inSection:selectedSection]
                                                          atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally
                                                                  animated:YES];
                    } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                    selectedItem.transform = CGAffineTransformConcat(selectedItem.transform,
                    CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                } completion:nil];
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
                    selectedItem.transform = backupTransform;
                } completion:nil];
            }

            else if (scrollViewMode) {
                UIScrollView *scrollView = (UIScrollView *)[self selectedView];
                CGPoint newOffset;
                UIViewController *topVC = (UIViewController *)[self topMostViewController];
                CGRect navBar;
                if ([topVC isKindOfClass:UINavigationController.class]) navBar = ((UINavigationController *)topVC).navigationBar.frame;
                if ([self cmdDown]) {
                    if ([topVC isKindOfClass:UINavigationController.class] && !((UINavigationController *)topVC).navigationBar.hidden) {
                        navBar = ((UINavigationController *)topVC).navigationBar.frame;
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                                scrollView.contentSize.height - scrollView.frame.size.height + (navBar.origin.y + navBar.size.height));
                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                                scrollView.contentSize.height - scrollView.frame.size.height);
                    }
                } else {
                    if (keyRepeatTimer) {
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                            scrollView.contentOffset.y + KEY_REPEAT_STEP);
                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                            scrollView.contentOffset.y + (scrollView.frame.size.height / 3));
                    }
                    if ([topVC isKindOfClass:UINavigationController.class] && !((UINavigationController *)topVC).navigationBar.hidden) {
                        if (newOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) + (navBar.origin.y + navBar.size.height)) {
                            newOffset.y = (scrollView.contentSize.height - scrollView.frame.size.height) + (navBar.origin.y + navBar.size.height);
                        }
                    } else {
                        if (newOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height))
                            newOffset.y = scrollView.contentSize.height - scrollView.frame.size.height;
                    }
                }
                [scrollView setContentOffset:newOffset animated:!keyRepeatTimer];
            }

            else {
                UIView *scrollableView = [self findFirstScrollableView];
                if (scrollableView) [self highlightView:scrollableView];
            }

            if (tableViewMode || collectionViewMode || scrollViewMode) {
                if (!keyRepeatTimer) {
                    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"down"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
            }
        }
    } else if (enabled && [self iOS9]) {
        if (sbFolderOpened) {

            if (sbOpenedFolderSelectedRow < SBFOLDER_ICONS_Y - 1 && [(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] >= SBFOLDER_ICONS_X * (sbOpenedFolderSelectedRow + 1) + sbOpenedFolderSelectedCol + 1) {
                sbOpenedFolderSelectedRow++;
                [self selectSBIconInOpenedFolder];
            } else {
                sbOpenedFolderSelectedRow = 0;
                [self selectSBIconInOpenedFolder];
            }
        }
        else if (!sbIconSelected) {

            if (sbDockIconSelected) {

                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] >= sbSelectedColumn + 1) {
                    sbSelectedRow = 0;
                } else {
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns) + sbColumns) {
                        sbSelectedColumn = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns) - 1;
                    }
                }

                [self selectSBIcon];
            } else {

                BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
                if (ls) {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                } else {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                }
                sbDockIcons = (NSArray *)[[[[%c(SBIconController) sharedInstance] rootFolder] dock] icons];
                sbDockIconCount = sbDockIcons.count;

                sbPages = [(SBFolder *)[[%c(SBIconController) sharedInstance] rootFolder] listCount];

                NSDebug(@"R: %i C: %i D: %i", sbRows, sbColumns, sbDockIconCount);

                sbSelectedColumn = sbSelectedRow = sbSelectedPage = 0;
                sbIconSelected = YES;
                sbDockIconSelected = NO;

                [self scrollSBToPage:sbSelectedPage];
                [self selectSBIcon];
            }

        } else {
            if (sbSelectedRow < sbRows - 1 && [(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] >= sbColumns * (sbSelectedRow + 1) + sbSelectedColumn + 1) {
                sbSelectedRow++;
                [self selectSBIcon];
            } else {
                [self selectSBDockIcon:sbSelectedColumn];
            }
        }
    }
}

%new
- (void)ui_downKeyUp {
    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
    else [keyRepeatTimer invalidate];
    keyRepeatTimer = nil;
    waitingForKeyRepeat = NO;
}

%new
- (void)ui_upKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self isActive]) {
            [self stopDiscoverabilityTimer];
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
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
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
                    @try { [selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionMiddle animated:YES]; }
                    @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                    selectedCell.transform = CGAffineTransformConcat(selectedCell.transform,
                                                                     CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                } completion:nil];
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
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
                    UICollectionViewCell *cell = [selectedCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
                    cell.selected = YES;
                    selectedItem = cell;
                }
                CGAffineTransform backupTransform = selectedItem.transform;
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
                    @try { [selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow
                                                                 inSection:selectedSection]
                                                          atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally
                                                                  animated:YES];
                    } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                    selectedItem.transform = CGAffineTransformConcat(selectedItem.transform,
                    CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                } completion:nil];
                [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
                    selectedItem.transform = backupTransform;
                } completion:nil];
            }

            else if (scrollViewMode) {
                UIScrollView *scrollView = (UIScrollView *)[self selectedView];
                CGPoint newOffset;
                UIViewController *topVC = (UIViewController *)[self topMostViewController];
                CGRect navBar;
                if ([topVC isKindOfClass:UINavigationController.class]) navBar = ((UINavigationController *)topVC).navigationBar.frame;
                if ([self cmdDown]) {
                    if ([topVC isKindOfClass:UINavigationController.class] && !((UINavigationController *)topVC).navigationBar.hidden) {
                        navBar = ((UINavigationController *)topVC).navigationBar.frame;
                        newOffset = CGPointMake(scrollView.contentOffset.x, -(navBar.origin.y + navBar.size.height));
                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x, 0);
                    }
                } else {
                    if (keyRepeatTimer) {
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                                scrollView.contentOffset.y - KEY_REPEAT_STEP);
                    } else {
                        newOffset = CGPointMake(scrollView.contentOffset.x,
                                                scrollView.contentOffset.y - (scrollView.frame.size.height / 3));
                    }
                    if ([topVC isKindOfClass:UINavigationController.class] && !((UINavigationController *)topVC).navigationBar.hidden) {
                        if (newOffset.y < (-(navBar.origin.y + navBar.size.height))) {
                            newOffset.y = (-(navBar.origin.y + navBar.size.height));
                        }
                    } else {
                        if (newOffset.y < 0) newOffset.y = 0;
                    }
                }
                [scrollView setContentOffset:newOffset animated:!keyRepeatTimer];
            }

            else {
                UIView *scrollableView = [self findFirstScrollableView];
                if (scrollableView) [self highlightView:scrollableView];
            }

            if (tableViewMode || collectionViewMode || scrollViewMode) {
                if (!keyRepeatTimer) {
                    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
                     waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                              target:self
                                                                            selector:@selector(keyRepeat:)
                                                                            userInfo:@{@"key": @"up"}
                                                                             repeats:NO];
                    waitingForKeyRepeat = YES;
                } else waitingForKeyRepeat = NO;
            }
        }
    } else if (enabled && [self iOS9]) {
        if (sbFolderOpened) {

            if (sbOpenedFolderSelectedRow > 0) {
                sbOpenedFolderSelectedRow--;
                [self selectSBIconInOpenedFolder];
            } else {
                sbOpenedFolderSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] / (double)SBFOLDER_ICONS_X) - 1;
                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] count] % SBFOLDER_ICONS_X < sbOpenedFolderSelectedCol + 1) sbOpenedFolderSelectedRow--;
                [self selectSBIconInOpenedFolder];
            }

        }
        else if (!sbIconSelected) {

            if (sbDockIconSelected) {

                if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] >= sbSelectedColumn + 1) {
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns &&
                        [(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns < sbSelectedColumn + 1 &&
                        sbSelectedRow == (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1) sbSelectedRow--;
                } else {
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns)) {
                        sbSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1;
                    }
                    if ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] < (sbSelectedRow * sbColumns) + sbColumns) {
                        sbSelectedColumn = ([(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] % sbColumns) - 1;
                    }
                }

                [self selectSBIcon];
            }
            else {

                BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
                if (ls) {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
                } else {
                    sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                    sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                                [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
                }
                sbDockIcons = (NSArray *)[[[[%c(SBIconController) sharedInstance] rootFolder] dock] icons];
                sbDockIconCount = sbDockIcons.count;

                sbPages = [(SBFolder *)[[%c(SBIconController) sharedInstance] rootFolder] listCount];

                NSDebug(@"R: %i C: %i D: %i", sbRows, sbColumns, sbDockIconCount);

                sbSelectedColumn = sbSelectedRow = sbSelectedPage = 0;
                sbIconSelected = YES;
                sbDockIconSelected = NO;

                [self scrollSBToPage:sbSelectedPage];
                [self selectSBIcon];
            }
        } else {
            if (sbSelectedRow > 0) {
                sbSelectedRow--;
                [self selectSBIcon];
            } else {
                sbSelectedRow = (int)ceil((double)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] count] / (double)sbColumns) - 1;
                [self selectSBDockIcon:sbSelectedColumn];
            }
        }
    }
}

%new
- (void)ui_upKeyUp {
    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
    else [keyRepeatTimer invalidate];
    keyRepeatTimer = nil;
    waitingForKeyRepeat = NO;
}

%new
- (void)ui_rKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self isActive] && [self cmdDown] && [self shiftDown]) {
            if ([[self selectedView] isKindOfClass:[UITableView class]]) {
                for (UIView *v in (NSArray *)[self views]) {
                    if ([v isKindOfClass:[UIRefreshControl class]]) {
                        if (v.superview == [self selectedView]) {
                            NSDebug(@"RELOADING TABLE");
                            [(UIRefreshControl *)v sendActionsForControlEvents:UIControlEventValueChanged];
                            return;
                        }
                    }
                }
            }
        }
    }
}

%new
- (void)ui_enterKey {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self isActive]) {
            @synchronized(self) {
                if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
                if (fView) {
                    [fView removeFromSuperview];
                    fView = nil;
                }
                if ([UIApplication sharedApplication].keyWindow.rootViewController &&
                    [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController &&
                    [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
                    UIAlertController *ac = (UIAlertController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
                    if (ac.preferredStyle == UIAlertControllerStyleAlert) {
                        if (ac.preferredAction) {
                            NSDebug(@"ENTER ALERT: Dismissing preferredAction");
                            [self performSelector:@selector(resetViews) withObject:0 afterDelay:ALERT_DISMISS_RESCAN_DELAY];
                        }
                        else if (collectionViewMode) {
                            NSString *title = ((UIAlertAction *)[((UIView *)selectedItem.subviews[0]).subviews[0] valueForKey:@"action"]).title;
                            NSUInteger idx = 0;
                            if ([self alertActions]) {
                                NSDebug(@"ALERT ACTION COUNT: %i", ((NSMutableArray *)[self alertActions]).count);
                                for (NSDictionary *dict in (NSMutableArray *)[self alertActions]) {
                                    if ([[dict objectForKey:@"title"] isEqualToString:title]) {
                                        void (^handler)(UIAlertAction *action) = (void (^)(UIAlertAction *action))[dict objectForKey:@"handler"];
                                        NSDebug(@"ENTER ALERT: Dismissing Handler %i at %p: %@", idx, handler, title);
                                        handler((UIAlertAction *)ac.actions[idx]);
                                        [ac dismissViewControllerAnimated:YES completion:^{
                                            [self performSelector:@selector(resetViews) withObject:0 afterDelay:ALERT_DISMISS_RESCAN_DELAY];
                                        }];
                                        break;
                                    }
                                    idx++;
                                }
                            }
                        } else if (((UIAlertAction *)[ac.actions objectAtIndex:0]).style == UIAlertActionStyleDefault) {
                            NSDebug(@"ENTER ALERT: Dismissing Default");
                            [ac dismissViewControllerAnimated:YES completion:^{
                                [self performSelector:@selector(resetViews) withObject:0 afterDelay:ALERT_DISMISS_RESCAN_DELAY];
                            }];
                        }
                    } else if (collectionViewMode) {
                        NSUInteger idx = 0;
                        if ([self alertActions] && !actionSheetMode) {
                            for (NSDictionary *dict in (NSMutableArray *)[self alertActions]) {
                                NSString *title = ((UIAlertAction *)[((UIView *)selectedItem.subviews[0]).subviews[0] valueForKey:@"action"]).title;
                                if ([[dict objectForKey:@"title"] isEqualToString:title]) {
                                    NSDebug(@"ENTER ACTION SHEET: Dismissing Handler");
                                    void (^handler)(UIAlertAction *action) = (void (^)(UIAlertAction *action))[dict objectForKey:@"handler"];
                                    [ac dismissViewControllerAnimated:YES completion:^{
                                        [self performSelector:@selector(resetViews) withObject:0 afterDelay:ALERT_DISMISS_RESCAN_DELAY];
                                    }];
                                    handler((UIAlertAction *)ac.actions[idx]);
                                    break;
                                }
                                idx++;
                            }
                        } else if (actionSheetMode) {
                            if ([self actionSheet] && ((UIActionSheet *)[self actionSheet]).delegate) {
                                [((UIActionSheet *)[self actionSheet]).delegate actionSheet:(UIActionSheet *)[self actionSheet]
                                                                                                  clickedButtonAtIndex:selectedRow];
                            }
                            NSDebug(@"ENTER ACTION SHEET: Dismissing actionSheetMode");
                            [(UIActionSheet *)[self actionSheet] dismissWithClickedButtonIndex:selectedRow animated:YES];
                            [self setActionSheet:nil];
                            actionSheetMode = NO;
                            [self performSelector:@selector(resetViews) withObject:0 afterDelay:ALERT_DISMISS_RESCAN_DELAY];
                        }
                    }
                } else {
                    //NSLog(@"Activating %@", ((UIView *)[self selectedView]).description);
                    //NSLog(@"Subviews: %@", ((UIView *)[self selectedView]).subviews.description);
                    if ([[self selectedView] isKindOfClass:[UITextField class]] ||
                        [[self selectedView] isKindOfClass:[UITextView class]]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResignTextFieldsNotification" object:nil];
                    }
                    if (tableViewMode) {
                            if (selectedTableView.delegate && [selectedTableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
                                selectedCell.selected = NO;
                                [selectedTableView.delegate tableView:selectedTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
                            }
                    } else if (collectionViewMode) {
                            if (selectedCollectionView.delegate && [selectedCollectionView.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)]) {
                                selectedItem.selected = NO;
                                [selectedCollectionView.delegate collectionView:selectedCollectionView didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
                            }
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
        }
    } else if (enabled) {
        if (sbFolderOpened) {
            [self activateBundleID:selectedSBIconInOpenedFolderBundleID];
        } else if (sbFolderIconSelected) {
            [sbIconOverlay removeFromSuperview];
            [[[%c(SBIconController) sharedInstance ] _rootFolderController] pushFolder:selectedSBFolder animated:YES completion:^(BOOL completed){
                sbFolderOpened = YES;
                sbOpenedFolderSelectedRow = sbOpenedFolderSelectedCol = sbOpenedFolderSelectedPage = 0;
                [self selectSBIconInOpenedFolder];
            }];
        }
        else if (sbIconSelected || sbDockIconSelected) {
            if (sbDockIconSelected) {
                [[[[[%c(SBIconController) sharedInstance] rootFolder] dock] iconAtIndex:sbSelectedColumn] launchFromLocation:0 context:0];
            } else {
                [self activateBundleID:selectedSBIconBundleID];
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
- (void)ui_esc {
    if (controlEnabled && ![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self isActive] && ![self switcherShown]) {
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
            if ([UIApplication sharedApplication].keyWindow.rootViewController &&
                [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController &&
                [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
                UIAlertController *ac = (UIAlertController *)[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
                if (ac.preferredStyle == UIAlertControllerStyleAlert) {
                    if (((UIAlertAction *)[ac.actions objectAtIndex:0]).style == UIAlertActionStyleDefault) {
                        NSDebug(@"ESCAPE ALERT: Dismissing Default");
                        [ac dismissViewControllerAnimated:YES completion:^{
                            [self resetViews];
                        }];
                    }
                } else {
                    for (UIAlertAction *action in ac.actions) {
                        if (action.style == UIAlertActionStyleCancel) {
                            NSDebug(@"ESCAPE ALERT: Dismissing Cancel");
                            [ac dismissViewControllerAnimated:YES completion:^{
                                [self resetViews];
                            }];
                        }
                    }
                }
            } else {
                UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
                UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
                if ([firstResponder isKindOfClass:[UITextField class]] || [firstResponder isKindOfClass:[UITextView class]]) {
                    NSDebug(@"RESIGNING TEXT FIELD");
                    [firstResponder resignFirstResponder];
                } else {
                    NSDebug(@"UI_ESC 3");
                    UIViewController *vc = [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
                    if ([vc isKindOfClass:[UINavigationController class]]) {
                        if ([self cmdDown] && ![self switcherShown]) {
                            [vc popToRootViewControllerAnimated:YES];
                        } else {
                            [vc popViewControllerAnimated:YES];
                        }
                    } else {
                        NSDebug(NSStringFromClass(vc.class));
                    }
                }
            }
        }
    } else if ([[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (sbFolderOpened) {
            sbFolderOpened = NO;
            [[[%c(SBIconController) sharedInstance ] _rootFolderController] popFolderAnimated:YES completion:^(BOOL completed) {
                [sbIconView addSubview:sbIconOverlay];
            }];
        } else if (sbIconSelected) {
            [sbIconOverlay removeFromSuperview];
            sbIconSelected = NO;
            selectedSBIcon = nil;
            sbSelectedColumn = sbSelectedRow = 0;
        }
    }
}

%new
- (void)ui_tabDown {
    if (![[self activeAppUserApplication] isEqualToString:@"com.apple.springboard"]) {
        if (enabled && controlEnabled && [self shiftDown] && ![self cmdDown] && ![self switcherShown]) {
            [self highlightView:PREV_VIEW animated:YES force:NO];
            if (!keyRepeatTimer) {
                 waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                          target:self
                                                                        selector:@selector(keyRepeat:)
                                                                        userInfo:@{@"key": @"tab"}
                                                                         repeats:NO];
                waitingForKeyRepeat = YES;
            } else waitingForKeyRepeat = NO;
        } else if (enabled && controlEnabled && ![self cmdDown] && ![self switcherShown]) {
            [self highlightView:NEXT_VIEW animated:YES force:NO];
            if (!keyRepeatTimer) {
                if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
                 waitForKeyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:KEY_REPEAT_DELAY
                                                                          target:self
                                                                        selector:@selector(keyRepeat:)
                                                                        userInfo:@{@"key": @"tab"}
                                                                         repeats:NO];
                waitingForKeyRepeat = YES;
            } else waitingForKeyRepeat = NO;
        }
    }
}

%new
- (void)ui_tabUp {
    if (waitingForKeyRepeat) [waitForKeyRepeatTimer invalidate];
    else [keyRepeatTimer invalidate];
    keyRepeatTimer = nil;
    waitingForKeyRepeat = NO;
}

%new
- (void)keyRepeat:(NSNotification *)notification {
    waitingForKeyRepeat = NO;
    SEL keySelector;
    if ([(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"tab"]) keySelector = @selector(ui_tabDown);
    else if ([(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"up"]) keySelector = @selector(ui_upKey);
    else if ([(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"down"]) keySelector = @selector(ui_downKey);
    else if ([(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"left"]) keySelector = @selector(ui_leftKey);
    else if ([(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"right"]) keySelector = @selector(ui_rightKey);
    keyRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:(tableViewMode ||
                                                              collectionViewMode ||
                                                              sliderMode ||
                                                              [(NSString *)[notification.userInfo objectForKey:@"key"] isEqualToString:@"tab"])
                                                              ? KEY_REPEAT_INTERVAL_SLOW : KEY_REPEAT_INTERVAL
                                                      target:self
                                                    selector:keySelector
                                                    userInfo:nil
                                                     repeats:YES];
}

%new
- (BOOL)isActive {
    return [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:[self activeAppUserApplication]];
}

%new
- (void)highlightView:(UIView *)view {
    @synchronized(self) {
        selectedViewIndex = [(NSArray *)[self views] indexOfObject:view];

        if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
        if (fView) {
            [fView removeFromSuperview];
            fView = nil;
        }
        if (tableViewMode) selectedCell.selected = NO;
        else if (collectionViewMode) selectedItem.selected = NO;

        [self setSelectedView:[(NSArray *)[self views] objectAtIndex:selectedViewIndex]];
        //[(UIView *)[self selectedView] becomeFirstResponder];

        if ([[self selectedView] isKindOfClass:[UISlider class]]) sliderMode = YES;
        else sliderMode = NO;

        UIView *animView = (UIView *)[self selectedView];
        if ([[self selectedView] isKindOfClass:[UITableView class]]) {
            UITableView *tView = (UITableView *)[self selectedView];
            if ([tView numberOfSections] && [tView numberOfRowsInSection:0]) {
                selectedRow = selectedSection = 0;
                tableViewMode = YES;
                collectionViewMode = NO;
                scrollViewMode = NO;
                selectedCell = [tView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
                selectedCell.selected = YES;
                selectedTableView = tView;
                animView = selectedCell;
                @try {
                    [selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
            }
        } else if ([[self selectedView] isKindOfClass:[UICollectionView class]]) {
            UICollectionView *cView = (UICollectionView *)[self selectedView];
            if ([cView numberOfSections] && [cView numberOfItemsInSection:0]) {
                selectedRow = selectedSection = 0;
                collectionViewMode = YES;
                tableViewMode = NO;
                scrollViewMode = NO;
                selectedItem = [cView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
                selectedItem.selected = YES;
                selectedCollectionView = cView;
                animView = selectedItem;
                @try { [selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]
                                                      atScrollPosition:UICollectionViewScrollPositionTop
                                                              animated:YES];
                } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
            }
        } else {
            tableViewMode = NO;
            collectionViewMode = NO;
            if ([[self selectedView] isKindOfClass:[UIScrollView class]]) {
                scrollViewMode = YES;
            } else scrollViewMode = NO;
        }
        NSDebug(@"VIEW %i: %@", selectedViewIndex, ((UIView *)[self selectedView]).description);
        fView = nil;
    }
}

%new
- (void)highlightView:(int)next animated:(BOOL)animated force:(BOOL)force {
    if (enabled && controlEnabled && ([self isActive] || force)) {
        @synchronized(self) {
            if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
            if (fView) {
                [fView removeFromSuperview];
                fView = nil;
            }
            if ([self views] && ((NSArray *)[self views]).count) {
                if (next) {
                    do {
                        selectedViewIndex = (selectedViewIndex + 1) % ((NSArray *)[self views]).count;
                    } while ([(NSArray *)[self skipClasses] containsObject:NSStringFromClass(((UIView *)[(NSArray *)[self views] objectAtIndex:selectedViewIndex]).class)]);
                }
                else {
                    do {
                        selectedViewIndex--;
                        if (selectedViewIndex < 0) selectedViewIndex = ((NSArray *)[self views]).count - 1;
                    } while ([(NSArray *)[self skipClasses] containsObject:NSStringFromClass(((UIView *)[(NSArray *)[self views] objectAtIndex:selectedViewIndex]).class)]);
                }
                if (((NSArray *)[self views]).count) {

                    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ResignTextFieldsNotification" object:nil];

                    if (tableViewMode) selectedCell.selected = NO;
                    else if (collectionViewMode) selectedItem.selected = NO;

                    [self setSelectedView:[(NSArray *)[self views] objectAtIndex:selectedViewIndex]];
                    //[(UIView *)[self selectedView] becomeFirstResponder];

                    if ([[self selectedView] isKindOfClass:[UISlider class]]) sliderMode = YES;
                    else sliderMode = NO;

                    UIView *animView = (UIView *)[self selectedView];
                    if ([[self selectedView] isKindOfClass:[UITableView class]]) {
                        UITableView *tView = (UITableView *)[self selectedView];
                        if ([tView numberOfSections] && [tView numberOfRowsInSection:0]) {
                            selectedRow = selectedSection = 0;
                            tableViewMode = YES;
                            collectionViewMode = NO;
                            scrollViewMode = NO;
                            selectedCell = [tView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection]];
                            // TODO fix for iPad preferences: Left section disappearing on tab (search controller gets activated)
                            /*if ([[tView firstResponder] isMemberOfClass:[%c(UISearchBarTextField) class]]) {
                                [selectedCell becomeFirstResponder];
                            }*/
                            selectedCell.selected = YES;
                            selectedTableView = tView;
                            animView = selectedCell;
                            @try {
                                [selectedTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedRow inSection:selectedSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                        }
                    } else if ([[self selectedView] isKindOfClass:[UICollectionView class]]) {
                        UICollectionView *cView = (UICollectionView *)[self selectedView];
                        if ([cView numberOfSections] && [cView numberOfItemsInSection:0]) {
                            selectedRow = selectedSection = 0;
                            collectionViewMode = YES;
                            tableViewMode = NO;
                            scrollViewMode = NO;
                            selectedItem = [cView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]];
                            selectedItem.selected = YES;
                            selectedCollectionView = cView;
                            animView = selectedItem;
                            @try { [selectedCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:selectedRow inSection:selectedSection]
                                                                  atScrollPosition:UICollectionViewScrollPositionTop
                                                                          animated:YES];
                            } @catch (NSException *e) { NSLog(@"Exception occured: %@", e); }
                        }
                    } else {
                        tableViewMode = NO;
                        collectionViewMode = NO;
                        if ([[self selectedView] isKindOfClass:[UIScrollView class]]) {
                            scrollViewMode = YES;
                        } else scrollViewMode = NO;
                    }

                    NSDebug(@"VIEW %i: %@", selectedViewIndex, ((UIView *)[self selectedView]).description);

                    if (animated) {
                        UIView *flashView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                     animView.frame.size.width,
                                                                                     animView.frame.size.height)];
                        flashView.backgroundColor = [UIColor whiteColor];
                        flashView.layer.cornerRadius = (animView.layer.cornerRadius != 0.0f) ?
                                                        animView.layer.cornerRadius : FLASH_VIEW_CORNER_RADIUS;
                        flashView.clipsToBounds = YES;
                        flashView.userInteractionEnabled = NO;
                        [animView addSubview:flashView];
                        [animView bringSubviewToFront:flashView];

                        CGAffineTransform backupTransform = animView.transform;
                        flashView.transform = backupTransform;

                        flashView.layer.borderWidth = 2.0f;
                        flashView.layer.borderColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0].CGColor;

                        fView = flashView;

                        [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
                            animView.transform = CGAffineTransformConcat(animView.transform,
                                                                         CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                            flashView.transform = CGAffineTransformConcat(flashView.transform,
                                                                          CGAffineTransformMakeScale(MAGNIFY_FACTOR, MAGNIFY_FACTOR));
                        } completion:nil];
                        [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
                            animView.transform = backupTransform;
                            flashView.transform = backupTransform;
                            flashView.backgroundColor = [UIColor clearColor];
                        } completion:^(BOOL completed){
                            if (tableViewMode || collectionViewMode) [fView removeFromSuperview];
                            else {
                                if ([self flashViewThread]) { [(NSThread *)[self flashViewThread] cancel]; [self setFlashViewThread:nil]; }
                                /*HighlightThread *ht = (HighlightThread *)[%c(HighlightThread) new];
                                [self setFlashViewThread:(NSThread *)ht];
                                [ht setView:flashView];
                                [ht setThreadPriority:0.0];
                                [hx start];*/
                            }
                        }];
                    } else {
                        fView = nil;
                    }
                }
            }
        }
    }
}

%new
- (NSNumber *)sbIconCornerRadius {
    if ([self iPad]) return @17.0f;
    else return @13.0f;
}

%new
- (void)selectSBIcon {

    sbIconSelected = YES;
    sbDockIconSelected = NO;

    if (sbIconOverlay) [sbIconOverlay removeFromSuperview];

    selectedSBIcon = [(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] objectAtIndex:(sbSelectedRow * sbColumns) + sbSelectedColumn];
    if ([selectedSBIcon isKindOfClass:[%c(SBApplicationIcon) class]]) {

        selectedSBIconBundleID = [[selectedSBIcon application] bundleIdentifier];

        sbFolderIconSelected = NO;

    } else if ([selectedSBIcon isKindOfClass:[%c(SBFolderIcon) class]]) {

        selectedSBFolder = [[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] icons] objectAtIndex:(sbSelectedRow * sbColumns) + sbSelectedColumn] folder];
        %c(SBFolderView);
        sbOpenedFolderPages = [selectedSBFolder listCount];
        sbFolderIconSelected = YES;
    }

    sbIconView = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbSelectedPage inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] viewForIcon:selectedSBIcon] _iconImageView];

    sbIconOverlay = [[UIView alloc] initWithFrame:CGRectMake(1, 1, sbIconView.frame.size.width - 2, sbIconView.frame.size.height - 2)];
    sbIconOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    sbIconOverlay.layer.cornerRadius = [[self sbIconCornerRadius] doubleValue];
    sbIconOverlay.clipsToBounds = YES;
    [sbIconView addSubview:sbIconOverlay];

    CGAffineTransform backupTransform = sbIconView.transform;
    [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
        sbIconView.transform = CGAffineTransformConcat(sbIconView.transform,
                                                       CGAffineTransformMakeScale(SB_MAGNIFY_FACTOR, SB_MAGNIFY_FACTOR));
    } completion:nil];
    [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
        sbIconView.transform = backupTransform;
    } completion:^(BOOL completed){
    }];

    NSDebug(@"%@", selectedSBIconBundleID);
}

%new
- (void)selectSBDockIcon:(int)col {

    if (sbDockIconCount >= col + 1) {

        sbIconSelected = NO;
        sbDockIconSelected = YES;

        if (sbIconOverlay) [sbIconOverlay removeFromSuperview];

        SBApplicationIcon *selectedSBIcon = [[[[%c(SBIconController) sharedInstance] rootFolder] dock] iconAtIndex:col];

        selectedSBIconBundleID = [[selectedSBIcon application] bundleIdentifier];

        sbIconView = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] viewForIcon:selectedSBIcon] _iconImageView];

        sbIconOverlay = [[UIView alloc] initWithFrame:CGRectMake(1, 1, sbIconView.frame.size.width - 2, sbIconView.frame.size.height - 2)];
        sbIconOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        sbIconOverlay.layer.cornerRadius = 13.0f;
        sbIconOverlay.clipsToBounds = YES;
        [sbIconView addSubview:sbIconOverlay];

        CGAffineTransform backupTransform = sbIconView.transform;
        [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
            sbIconView.transform = CGAffineTransformConcat(sbIconView.transform,
                                                           CGAffineTransformMakeScale(SB_MAGNIFY_FACTOR, SB_MAGNIFY_FACTOR));
        } completion:nil];
        [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
            sbIconView.transform = backupTransform;
        } completion:^(BOOL completed){
        }];

        NSDebug(@"%@", selectedSBIconBundleID);
    }
}

%new
- (void)selectSBIconInOpenedFolder {

    if (sbIconOpenedFolderOverlay) [sbIconOpenedFolderOverlay removeFromSuperview];

    selectedSBIconInOpenedFolder = (SBApplicationIcon *)[(NSArray *)[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] icons] objectAtIndex:(sbOpenedFolderSelectedRow * SBFOLDER_ICONS_X) + sbOpenedFolderSelectedCol];

    selectedSBIconInOpenedFolderBundleID = [[selectedSBIconInOpenedFolder application] bundleIdentifier];

    sbIconOpenedFolderView = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:sbOpenedFolderSelectedPage inFolder:selectedSBFolder createIfNecessary:YES] viewForIcon:selectedSBIconInOpenedFolder] _iconImageView];

    sbIconOpenedFolderOverlay = [[UIView alloc] initWithFrame:CGRectMake(1, 1, sbIconOpenedFolderView.frame.size.width - 2, sbIconOpenedFolderView.frame.size.height - 2)];
    sbIconOpenedFolderOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
    sbIconOpenedFolderOverlay.layer.cornerRadius = 13.0f;
    sbIconOpenedFolderOverlay.clipsToBounds = YES;
    [sbIconOpenedFolderView addSubview:sbIconOpenedFolderOverlay];

    CGAffineTransform backupTransform = sbIconOpenedFolderView.transform;
    [UIView animateWithDuration:HIGHLIGHT_DURATION delay:0 options:0 animations:^{
        sbIconOpenedFolderView.transform = CGAffineTransformConcat(sbIconView.transform,
                                                       CGAffineTransformMakeScale(SB_MAGNIFY_FACTOR, SB_MAGNIFY_FACTOR));
    } completion:nil];
    [UIView animateWithDuration:HIGHLIGHT_DURATION delay:HIGHLIGHT_DURATION options:0 animations:^{
        sbIconOpenedFolderView.transform = backupTransform;
    } completion:^(BOOL completed){
    }];

    NSDebug(@"%@", selectedSBIconInOpenedFolderBundleID);

}

%new
- (UIView *)findFirstScrollableView {
    UIView *scrollableView = nil;
    for (int i = 0; i < ((NSArray *)[self views]).count; i++) {
        UIView *v = ((NSArray *)[self views])[i];
        if ([v isKindOfClass:UIScrollView.class]) {
            scrollableView = v;
            break;
        }
    }
    return scrollableView;
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
    if ([UIApplication sharedApplication].keyWindow.rootViewController &&
        [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController &&
        [[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController isKindOfClass:[UIAlertController class]]) {
        return @[[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController.view];
    }
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
             @"UITableViewWrapperView",
             @"_MFSearchAtomFieldEditor",
             @"_UIToolbarNavigationButton",
             @"UICompatibilityInputViewController",
             @"UIInputWindowController",
             @"SKUIProxyScrollView",
             @"_UIAlertControllerShadowedScrollView"];
}

%new
- (NSArray *)skipClasses {
    return @[@"UIStepper",
             @"UIRefreshControl"];
}

%new
- (NSArray *)filterViews:(NSArray *)views {
    NSMutableArray *filteredViews = [NSMutableArray new];
    for (UIView *view in views) {
        if ([view isKindOfClass:[UIControl class]] ||
            [view isKindOfClass:[UITextView class]] ||
            [view isKindOfClass:[UIScrollView class]]) {
            if (![(NSArray *)[self blockedClasses] containsObject:NSStringFromClass(view.class)]) {
                if ([view isKindOfClass:[UIButton class]] && !((UIButton *)view).userInteractionEnabled) continue;
                else if ([view isKindOfClass:[UITextView class]] && !((UITextView *)view).userInteractionEnabled) continue;
                [filteredViews addObject:view];
            }
        } else if (view.userInteractionEnabled == YES) {
            //NSDebug(@"REJECTED INTERACTION VIEW: %@", view.description);
        }
    }
    return filteredViews;
}

%new
- (NSArray *)postProcessViews:(NSArray *)views {
    NSMutableArray *processedViews = [NSMutableArray arrayWithArray:views];
    NSUInteger index = 0;
    NSUInteger tableViews = 0;
    NSUInteger scrollViews = 0;
    NSUInteger collectionViews = 0;
    NSUInteger tabBarButtons = 0;
    for (; index < processedViews.count; index++) {
        UIView *v = [processedViews objectAtIndex:index];
        if ([v isKindOfClass:UITableView.class]) {
            [processedViews removeObjectAtIndex:index];
            [processedViews insertObject:v atIndex:tableViews];
            NSDebug(@"Moved tableView to pos %i: %@", tableViews, v.description);
            tableViews++;
        }
    }
    index = tableViews;
    for (; index < processedViews.count; index++) {
        UIView *v = [processedViews objectAtIndex:index];
        if ([v isKindOfClass:UIScrollView.class] && ![v isKindOfClass:UICollectionView.class]) {
            [processedViews removeObjectAtIndex:index];
            [processedViews insertObject:v atIndex:tableViews + scrollViews];
            NSDebug(@"Moved scroll view to pos %i: %@", tableViews + scrollViews, v.description);
            scrollViews++;
        }
    }
    index = tableViews + scrollViews;
    for (; index < processedViews.count; index++) {
        UIView *v = [processedViews objectAtIndex:index];
        if ([v isKindOfClass:UICollectionView.class]) {
            [processedViews removeObjectAtIndex:index];
            [processedViews insertObject:v atIndex:tableViews + scrollViews + collectionViews];
            NSDebug(@"Moved collection view to pos %i: %@", tableViews + scrollViews + collectionViews, v.description);
            collectionViews++;
        }
    }
    index = tableViews + scrollViews + collectionViews;
    for (; index < processedViews.count; index++) {
        UIView *v = [processedViews objectAtIndex:index];
        if ([NSStringFromClass(v.class) isEqualToString:@"UITabBarButton"]) {
            [processedViews removeObjectAtIndex:index];
            [processedViews insertObject:v atIndex:tableViews + scrollViews + collectionViews + tabBarButtons];
            NSDebug(@"Moved tab bar button to pos %i: %@", tableViews + scrollViews + collectionViews, v.description);
            tabBarButtons++;
        }
    }
    if (processedViews.count >= 2 &&
        [NSStringFromClass(((UIView *)processedViews[0]).class) isEqualToString:@"SPUISearchTableView"] &&
        [((UIView *)processedViews[1]) isKindOfClass:[UIScrollView class]]) {
        [processedViews exchangeObjectAtIndex:0 withObjectAtIndex:1];
    }
    return processedViews;
}

%new
- (NSArray *)controlViews {
    [self setViews:[NSMutableArray array]];
    for (UIView *view in (NSArray *)[self rootViews]) {
        [self addSubviews:view];
    }
    return [self postProcessViews:[self filterViews:[self views]]];
}

%new
- (void)resetViews {
    [self setViews:(NSArray *)[self controlViews]];
    NSDebug(@"RESET VIEWS");
    //NSLog(@"NEW VIEWS:\n%@", ((NSArray *)[self views]).description);
    selectedViewIndex = -1;
    tableViewMode = collectionViewMode = scrollViewMode = sliderMode = NO;
    if ([self flashViewThread]) [(NSThread *)[self flashViewThread] cancel];
    if (fView) {
            [fView removeFromSuperview];
            fView = nil;
    }
    [self setSelectedView:nil];
    /*if (enabled && controlEnabled &&
        ((NSArray *)[self views]).count && [(UIView *)((NSArray *)[self views])[0] isKindOfClass:UIScrollView.class])
        [self highlightView:NEXT_VIEW animated:NO force:YES];
    }*/
}

%new
- (UIViewController *)topMostViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}


%end


%hook UIViewController

%new
- (void)resignTextFields {
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    %orig();
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignTextFields) name:@"ResignTextFieldsNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    %orig();
    NSDebug(@"DID APPEAR: %@", NSStringFromClass([self class]));
    if (![NSStringFromClass([self class]) isEqualToString:@"UICompatibilityInputViewController"] &&
        ![NSStringFromClass([self class]) isEqualToString:@"UIInputWindowController"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewDidAppearNotification" object:nil];
        //[self.view endEditing:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation {
    %orig();

    if (sbIconSelected || sbDockIconSelected) {

        BOOL ls = UIInterfaceOrientationIsLandscape((UIInterfaceOrientation)[(SpringBoard *)[%c(SpringBoard) sharedApplication] activeInterfaceOrientation]);
        if (ls) {
            sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
            sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                        [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:0];
        } else {
            sbRows = [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
            sbColumns = [[[[%c(SBIconController) sharedInstance] iconListViewAtIndex:0 inFolder:[[%c(SBIconController) sharedInstance] rootFolder] createIfNecessary:YES] model] maxNumberOfIcons] /
                        [[%c(SBIconController) sharedInstance] maxRowCountForListInRootFolderWithInterfaceOrientation:1];
        }
        sbDockIcons = (NSArray *)[[[[%c(SBIconController) sharedInstance] rootFolder] dock] icons];
        sbDockIconCount = sbDockIcons.count;

        sbPages = [(SBFolder *)[[%c(SBIconController) sharedInstance] rootFolder] listCount];

        NSDebug(@"R: %i C: %i D: %i", sbRows, sbColumns, sbDockIconCount);

        sbSelectedColumn = sbSelectedRow = sbSelectedPage = 0;
        sbIconSelected = YES;
        sbDockIconSelected = NO;

        [[UIApplication sharedApplication] scrollSBToPage:sbSelectedPage];
        [[UIApplication sharedApplication] selectSBIcon];
    }
}

%end


%hook UIAlertController

+ (id)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(UIAlertControllerStyle)preferredStyle {
    NSDebug(@"NEW ALERT CONTROLLER: %@ %@ %i", title, message, preferredStyle);
    [[UIApplication sharedApplication] setAlertActions:[NSMutableArray array]];
    return %orig;
}

- (id)init {
    [[UIApplication sharedApplication] setAlertActions:[NSMutableArray array]];
    return %orig();
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig();
    NSDebug(@"ALERT CONTROLLER DID DISAPPEAR");
    [[UIApplication sharedApplication] performSelector:@selector(resetViews) withObject:nil afterDelay:ALERT_DISMISS_RESCAN_DELAY];
}

- (void)addAction:(UIAlertAction *)action {
    %orig();
    if (action.title && [action valueForKey:@"handler"]) {
        if (![[UIApplication sharedApplication] alertActions]) [[UIApplication sharedApplication] setAlertActions:[NSMutableArray array]];
        [(NSMutableArray *)[[UIApplication sharedApplication] alertActions] addObject:@{@"title": action.title,
                                                                                        @"handler": [[action valueForKey:@"handler"] copy]}];
        NSDebug(@"ADD ACTION: %@", action.title);
    }
}

%end


%hook UIAlertAction

+ (id)actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction *action))handler {
    if (title && handler) {
        if (![[UIApplication sharedApplication] alertActions]) [[UIApplication sharedApplication] setAlertActions:[NSMutableArray array]];
        [(NSMutableArray *)[[UIApplication sharedApplication] alertActions] addObject:@{@"title": title,
                                                                                        @"handler": [handler copy]}];
        NSDebug(@"NEW ACTION: \"%@\"", title);
    }
    return %orig;
}

%end


%hook UIActionSheet

+ (id)alloc {
    UIActionSheet *sheet = %orig;
    [[UIApplication sharedApplication] setAlertActions:[NSMutableArray array]];
    [[UIApplication sharedApplication] setActionSheet:sheet];
    actionSheetMode = YES;
    return sheet;
}

%end