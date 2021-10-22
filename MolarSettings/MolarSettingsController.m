//
//  MolarSettingsController.m
//  MolarSettings
//
//  Created by Lukas Hönig on 22.03.16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "MolarSettingsController.h"
#import <AppList.h>
#import <IOKit/hid/IOHIDEventSystem.h>
#import <IOKit/hid/IOHIDEventSystemClient.h>
#import <Preferences/PSSpecifier.h>
#import <libactivator.h>
#include <sys/sysctl.h>
#include <sys/types.h>

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

#define kNotificationName @"de.hoenig.molar/ReloadPrefs"
#define kBundleID @"de.hoenig.molar"
#define kShortcutsKey @"shortcuts"
#define kShortcutNamesKey @"shortcutNames"
#define kKeyboardLayoutKey @"keyboardLayout"

#define CMD_KEY 0xe3
#define CMD_KEY_2 0xe7
#define ALT_KEY 0xe6
#define ALT_KEY_2 0xe2
#define CTRL_KEY 0xe4
#define CTRL_KEY_2 0xe0
#define SHIFT_KEY 0xe5
#define SHIFT_KEY_2 0xe1

static void sendReloadNotif() {
    CFStringRef notificationName = (CFStringRef)kNotificationName;
    CFNotificationCenterPostNotification(
                                         CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL,
                                         YES);
    CFRelease(notificationName);
}

@interface AppSelectController : UITableViewController <UITableViewDataSource> {
@private
  ALApplicationTableDataSource *dataSource;
  UITableViewCell *selectedCell;
  HBPreferences *preferences;
}

@property(nonatomic, retain) NSString *settingsKey;

@end

@implementation AppSelectController

@synthesize settingsKey;

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  if ([[dataSource displayIdentifierForIndexPath:indexPath]
          isEqualToString:(NSString *)[preferences objectForKey:settingsKey]]) {
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    selectedCell = cell;
  } else {
    cell.accessoryType = UITableViewCellAccessoryNone;
  }
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return [dataSource tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [dataSource numberOfSectionsInTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section {
  return [dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView
    titleForFooterInSection:(NSInteger)section {
  return [dataSource tableView:tableView titleForFooterInSection:section];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableView.dataSource = self;
  dataSource.tableView = self.tableView;
  self.title = @"Select App";
}

- (void)viewDidUnload {
  dataSource.tableView = nil;
  [super viewDidUnload];
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    dataSource = [[ALApplicationTableDataSource alloc] init];
    dataSource.sectionDescriptors =
        [ALApplicationTableDataSource standardSectionDescriptors];
    selectedCell = nil;
    preferences = [[HBPreferences alloc] initWithIdentifier:kBundleID];
  }
  return self;
}

- (void)dealloc {
  dataSource.tableView = nil;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if ([tableView cellForRowAtIndexPath:indexPath] == selectedCell) {
    [preferences setObject:@"" forKey:settingsKey];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType =
        UITableViewCellAccessoryNone;
    selectedCell = nil;
  } else {
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    NSString *displayIdentifier =
        [dataSource displayIdentifierForIndexPath:indexPath];
    [preferences setObject:displayIdentifier forKey:settingsKey];
    [tableView cellForRowAtIndexPath:indexPath].accessoryType =
        UITableViewCellAccessoryCheckmark;
    selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  }

  sendReloadNotif();

  [self.navigationController popViewControllerAnimated:YES];
}

@end

@interface CreateShortcutController
    : UITableViewController <UITableViewDataSource>
@property(nonatomic, retain) NSNumber *shortcutIndex;
@end

@implementation CreateShortcutController {
  UITextField *modifierTextField;
  UITextField *inputTextField;
  BOOL cmdDown, ctrlDown, altDown, shiftDown, shortcutSet, cmdSet, ctrlSet,
      altSet, shiftSet;
  NSString *inputChar;
  HBPreferences *preferences;
}

@synthesize shortcutIndex;

void handle_event(void *target, void *refcon, IOHIDServiceRef service,
                  IOHIDEventRef event);

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForFooterInSection:(NSInteger)section {
  if (section == 0)
    return @"     Press one or more keys on your Bluetooth keyboard";
  else
    return nil;
}

void handle_event(void *target, void *refcon, IOHIDServiceRef service,
                  IOHIDEventRef event) {
  if (IOHIDEventGetType(event) == kIOHIDEventTypeKeyboard) {
    int page =
        IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsagePage);
    int usage = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardUsage);
    int down = IOHIDEventGetIntegerValue(event, kIOHIDEventFieldKeyboardDown);

    if ((usage == CMD_KEY || usage == CMD_KEY_2) && down)
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SC_CmdKeyDown"
                        object:nil];
    if ((usage == CMD_KEY || usage == CMD_KEY_2) && !down)
      [[NSNotificationCenter defaultCenter] postNotificationName:@"SC_CmdKeyUp"
                                                          object:nil];
    else if ((usage == CTRL_KEY || usage == CTRL_KEY_2) && down)
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SC_CtrlKeyDown"
                        object:nil];
    else if ((usage == CTRL_KEY || usage == CTRL_KEY_2) && !down)
      [[NSNotificationCenter defaultCenter] postNotificationName:@"SC_CtrlKeyUp"
                                                          object:nil];
    else if ((usage == ALT_KEY || usage == ALT_KEY_2) && down)
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SC_AltKeyDown"
                        object:nil];
    else if ((usage == ALT_KEY || usage == ALT_KEY_2) && !down)
      [[NSNotificationCenter defaultCenter] postNotificationName:@"SC_AltKeyUp"
                                                          object:nil];
    else if ((usage == SHIFT_KEY || usage == SHIFT_KEY_2) && down)
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SC_ShiftKeyDown"
                        object:nil];
    else if ((usage == SHIFT_KEY || usage == SHIFT_KEY_2) && !down)
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"SC_ShiftKeyUp"
                        object:nil];
    else if (down && page == 7)
      [[NSNotificationCenter defaultCenter] postNotificationName:@"SC_KeyDown"
                                                          object:nil
                                                        userInfo:@{
                                                          @"key" : @(usage)
                                                        }];
    // NSLog(@"KEY: %i page %i", usage, page);
  }
}

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    preferences = [[HBPreferences alloc] initWithIdentifier:kBundleID];
    modifierTextField =
        [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 165, 70)];
    modifierTextField.font = [UIFont systemFontOfSize:40];
    modifierTextField.textAlignment = NSTextAlignmentRight;
    modifierTextField.layer.borderColor =
        [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    modifierTextField.layer.borderWidth = 2;
    modifierTextField.layer.cornerRadius = 10;
    modifierTextField.enabled = NO;
    modifierTextField.layer.sublayerTransform =
        CATransform3DMakeTranslation(-8, 0, 0);

    inputTextField =
        [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 165, 70)];
    inputTextField.font = [UIFont systemFontOfSize:40];
    inputTextField.textAlignment = NSTextAlignmentLeft;
    inputTextField.layer.borderColor =
        [[UIColor blackColor] colorWithAlphaComponent:0.3].CGColor;
    inputTextField.layer.borderWidth = 2;
    inputTextField.layer.cornerRadius = 10;
    inputTextField.layer.sublayerTransform =
        CATransform3DMakeTranslation(8, 0, 0);
    inputTextField.enabled = NO;

    UIView *headerView = [[UIView alloc]
        initWithFrame:CGRectMake(0, 100, self.tableView.frame.size.width, 130)];
    [headerView addSubview:modifierTextField];
    [headerView addSubview:inputTextField];

    IOHIDEventSystemClientRef ioHIDEventSystem =
        IOHIDEventSystemClientCreate(kCFAllocatorDefault);
    IOHIDEventSystemClientScheduleWithRunLoop(
        ioHIDEventSystem, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    IOHIDEventSystemClientRegisterEventCallback(
        ioHIDEventSystem, (IOHIDEventSystemClientEventCallback)handle_event,
        NULL, NULL);

    self.tableView.tableHeaderView = headerView;

    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPad"]) {
      modifierTextField.center =
          CGPointMake((modifierTextField.frame.size.width / 2) + 30, 80);
      inputTextField.center =
          CGPointMake(modifierTextField.frame.size.width + 40 +
                          (inputTextField.frame.size.width / 2),
                      80);
    } else {
      modifierTextField.center =
          CGPointMake(headerView.frame.size.width / 2 -
                          (modifierTextField.frame.size.width / 2) - 5,
                      80);
      inputTextField.center =
          CGPointMake(headerView.frame.size.width / 2 +
                          (modifierTextField.frame.size.width / 2) + 5,
                      80);
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cmdDown)
                                                 name:@"SC_CmdKeyDown"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cmdUp)
                                                 name:@"SC_CmdKeyUp"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ctrlDown)
                                                 name:@"SC_CtrlKeyDown"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ctrlUp)
                                                 name:@"SC_CtrlKeyUp"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(altDown)
                                                 name:@"SC_AltKeyDown"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(altUp)
                                                 name:@"SC_AltKeyUp"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shiftDown)
                                                 name:@"SC_ShiftKeyDown"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shiftUp)
                                                 name:@"SC_ShiftKeyUp"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyDown:)
                                                 name:@"SC_KeyDown"
                                               object:nil];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                             target:self
                             action:@selector(saveShortcut)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"New Shortcut";
}

- (void)saveShortcut {

  NSMutableArray *shortcuts = [NSMutableArray
      arrayWithArray:(NSArray *)[preferences objectForKey:kShortcutsKey
                                                  default:@[]]];
  NSMutableArray *shortcutNames = [NSMutableArray
      arrayWithArray:(NSArray *)[preferences objectForKey:kShortcutNamesKey
                                                  default:@[]]];
  if (!shortcuts)
    shortcuts = [NSMutableArray new];
  if (!shortcutNames)
    shortcutNames = [NSMutableArray new];

  NSString *shortcutKey =
      [@"shortcut-" stringByAppendingFormat:@"%@", [[NSUUID UUID] UUIDString]];
  NSString *eventName = [kBundleID stringByAppendingFormat:@".%@", shortcutKey];

  NSDictionary *shortcut = @{
    @"cmd" : @(cmdSet),
    @"ctrl" : @(ctrlSet),
    @"alt" : @(altSet),
    @"shift" : @(shiftSet),
    @"input" : inputChar,
    @"eventName" : eventName
  };
  [shortcuts setObject:shortcut atIndexedSubscript:shortcutIndex.intValue];

  if ([[LAActivator sharedInstance]
          assignedListenerNameForEvent:[LAEvent eventWithName:eventName]]) {
    NSString *shortcutName = [[LAActivator sharedInstance]
        localizedTitleForListenerName:
            [[LAActivator sharedInstance]
                assignedListenerNameForEvent:[LAEvent
                                                 eventWithName:eventName]]];
    [shortcutNames setObject:shortcutName
          atIndexedSubscript:shortcutIndex.intValue];
  }

  [preferences setObject:shortcuts forKey:kShortcutsKey];
  [preferences setObject:shortcutNames forKey:kShortcutNamesKey];

  sendReloadNotif();

  [self.navigationController popViewControllerAnimated:YES];
}

+ (NSArray *)characters {
  HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:kBundleID];
  NSString *activeLayout = (NSString *)[prefs objectForKey:kKeyboardLayoutKey];

  if ([activeLayout isEqualToString:@"en"]) {
    return
        @[
          @"",  @"",  @"",  @"",  @"A", @"B", @"C", @"D", @"E", @"F",
          @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
          @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z",
          @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",
          @"⏎", @"",  @"⌫", @"⇥", @"␣", @"-", @"=", @"[", @"]", @"|",
          @"",  @";", @"'", @"`", @",", @".", @"/"
        ];
  }

  else if ([activeLayout isEqualToString:@"de"]) {
    return
        @[
          @"",  @"",  @"",  @"",  @"A", @"B", @"C", @"D", @"E", @"F",
          @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
          @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Z", @"Y",
          @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",
          @"⏎", @"",  @"⌫", @"⇥", @"␣", @"ß", @"´", @"Ü", @"+", @"#",
          @"",  @"Ö", @"Ä", @"<", @",", @".", @"-"
        ];
  }

  else
    return
        @[
          @"",  @"",  @"",  @"",  @"A", @"B", @"C", @"D", @"E", @"F",
          @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P",
          @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Z", @"Y",
          @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"0",
          @"⏎", @"",  @"⌫", @"⇥", @"␣", @"ß", @"´", @"Ü", @"+", @"#",
          @"",  @"Ö", @"Ä", @"<", @",", @".", @"-"
        ];
}

- (void)updateModifierText {
  NSMutableString *mText = [NSMutableString new];
  if (shiftDown)
    [mText appendString:@"⇧"];
  if (ctrlDown)
    [mText appendString:@"⌃"];
  if (altDown)
    [mText appendString:@"⌥"];
  if (cmdDown)
    [mText appendString:@"⌘"];
  modifierTextField.text = mText;
}

- (void)cmdDown {
  cmdDown = YES;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)cmdUp {
  cmdDown = NO;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)ctrlDown {
  ctrlDown = YES;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)ctrlUp {
  ctrlDown = NO;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)altDown {
  altDown = YES;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)altUp {
  altDown = NO;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)shiftDown {
  shiftDown = YES;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)shiftUp {
  shiftDown = NO;
  if (!shortcutSet)
    [self updateModifierText];
}

- (void)keyDown:(NSNotification *)notification {
  int key = ((NSNumber *)[notification.userInfo objectForKey:@"key"]).intValue;
  if (key <= [CreateShortcutController characters].count - 1 &&
      ![[[CreateShortcutController characters] objectAtIndex:key]
          isEqualToString:@""]) {
    inputChar = [[CreateShortcutController characters] objectAtIndex:key];
    inputTextField.text = inputChar;
    shortcutSet = YES;
    cmdSet = cmdDown;
    ctrlSet = ctrlDown;
    altSet = altDown;
    shiftSet = shiftDown;
    [self updateModifierText];
    self.navigationItem.rightBarButtonItem.enabled = YES;
  }
}

@end

@interface ShortcutsController
    : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
  NSMutableArray *shortcuts;
  HBPreferences *preferences;
}
@end

@implementation ShortcutsController

- (id)initWithStyle:(UITableViewStyle)style {
  if ((self = [super initWithStyle:style])) {
    self.tableView.delegate = self;
    preferences = [[HBPreferences alloc] initWithIdentifier:kBundleID];

    shortcuts = [NSMutableArray
        arrayWithArray:(NSArray *)[preferences objectForKey:kShortcutsKey
                                                    default:@[]]];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(reloadTable)
               name:@"libactivator.assignments.changed"
             object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Shortcuts";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadTable];
}

- (void)setShortcutNames {
    shortcuts = [NSMutableArray
                 arrayWithArray:(NSArray *)[preferences objectForKey:kShortcutsKey
                                                             default:@[]]];
    NSMutableArray *shortcutNames =
    [NSMutableArray arrayWithCapacity:shortcuts.count];
    for (int i = 0; i < shortcuts.count; i++) {
        if ([[LAActivator sharedInstance]
             assignedListenerNameForEvent:
             [LAEvent
              eventWithName:[shortcuts[i] objectForKey:@"eventName"]]]) {
                 NSString *shortcutName = [[LAActivator sharedInstance]
                                           localizedTitleForListenerName:
                                           [[LAActivator sharedInstance]
                                            assignedListenerNameForEvent:
                                            [LAEvent eventWithName:[shortcuts[i]
                                                                    objectForKey:@"eventName"]]]];
                 [shortcutNames
                  insertObject:(shortcutName
                                ? ([shortcutName isEqualToString:@"No Title"]
                                   ? @"NOLISTENER"
                                   : shortcutName)
                                : @"NOLISTENER")
                  atIndex:i];
             } else {
                 [shortcutNames insertObject:@"NOLISTENER" atIndex:i];
             }
    }
    [preferences setObject:shortcutNames forKey:kShortcutNamesKey];
}

- (void)reloadTable {
  [self setShortcutNames];
  sendReloadNotif();
  [self.tableView reloadData];
}

- (NSString *)labelTextForShortcut:(NSDictionary *)shortcut {
  NSMutableString *labelText = [NSMutableString new];
  if (((NSNumber *)[shortcut objectForKey:@"ctrl"]).boolValue)
    [labelText appendString:@"⌃"];
  if (((NSNumber *)[shortcut objectForKey:@"alt"]).boolValue)
    [labelText appendString:@"⌥"];
  if (((NSNumber *)[shortcut objectForKey:@"cmd"]).boolValue)
    [labelText appendString:@"⌘"];
  if (((NSNumber *)[shortcut objectForKey:@"shift"]).boolValue)
    [labelText appendString:@"⇧"];
  [labelText appendString:[shortcut objectForKey:@"input"]];
  return labelText;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return !shortcuts ? 1 : shortcuts.count + 1;
  else
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = nil;
  if (indexPath.section == 0 &&
      indexPath.row ==
          [self tableView:tableView numberOfRowsInSection:indexPath.section] -
              1) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:@"CreateShortcutCell"];
    cell.textLabel.text = @"Create new shortcut";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier:@"ShortcutCell"];
    cell.textLabel.text =
        [self labelTextForShortcut:[shortcuts objectAtIndex:indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [[LAActivator sharedInstance]
        localizedTitleForListenerName:
            [[LAActivator sharedInstance]
                assignedListenerNameForEvent:
                    [LAEvent
                        eventWithName:[[shortcuts objectAtIndex:indexPath.row]
                                          objectForKey:@"eventName"]]]];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  if ([[self tableView:tableView cellForRowAtIndexPath:indexPath]
              .reuseIdentifier isEqualToString:@"CreateShortcutCell"]) {

    CreateShortcutController *css = [[CreateShortcutController alloc]
        initWithStyle:UITableViewStyleGrouped];
    css.shortcutIndex = @([shortcuts count]);

    [self.navigationController pushViewController:css animated:YES];
  } else {
    LAEventSettingsController *vc = [[LAEventSettingsController alloc]
        initWithModes:[NSArray
                          arrayWithObjects:@"springboard", @"application", nil]
            eventName:[[shortcuts objectAtIndex:indexPath.row]
                          objectForKey:@"eventName"]];
    [self.navigationController pushViewController:vc animated:YES];
  }
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSArray *shortcutNames = (NSArray *)[preferences objectForKey:kShortcutNamesKey];
  if (![shortcutNames[indexPath.row] isEqualToString:@"NOLISTENER"]) {
      [LASharedActivator unassignEvent:[LAEvent eventWithName:[shortcuts[indexPath.row] objectForKey:@"eventName"]]];
  }
  [shortcuts removeObjectAtIndex:indexPath.row];
  [preferences setObject:shortcuts forKey:kShortcutsKey];
  [self setShortcutNames];
  sendReloadNotif();
  [tableView deleteRowsAtIndexPaths:@[indexPath]
                   withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([[self tableView:tableView cellForRowAtIndexPath:indexPath]
              .reuseIdentifier isEqualToString:@"CreateShortcutCell"])
    return UITableViewCellEditingStyleNone;
  else
    return UITableViewCellEditingStyleDelete;
}

@end

@implementation MolarSettingsController

- (id)getValueForSpecifier:(PSSpecifier *)specifier {
  id value = @"";

  NSDictionary *specifierProperties = [specifier properties];
  NSString *specifierKey =
      [specifierProperties objectForKey:kPrefs_KeyName_Key];

  id objectValue = [preferences objectForKey:specifierKey];

  if (objectValue)
    value = [NSString stringWithFormat:@"%@", objectValue];

  return value;
}

- (NSString *)platform {
  size_t size;
  sysctlbyname("hw.machine", NULL, &size, NULL, 0);
  char *machine = malloc(size);
  sysctlbyname("hw.machine", machine, &size, NULL, 0);
  NSString *platform = [NSString stringWithUTF8String:machine];
  free(machine);
  return platform;
}

- (BOOL)iPad {
  return [[[UIDevice currentDevice] model] isEqualToString:@"iPad"];
}

- (BOOL)iPadMini {
  NSString *pf = [self platform];
  if ([pf isEqualToString:@"iPad2,5"] || [pf isEqualToString:@"iPad2,6"] ||
      [pf isEqualToString:@"iPad2,7"])
    return YES;
  return NO;
}

- (BOOL)iOS9 {
  return [[[UIDevice currentDevice] systemVersion] hasPrefix:@"9"];
}

- (BOOL)iOS10 {
  return [[[UIDevice currentDevice] systemVersion] hasPrefix:@"10"];
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  if (section == 0)
    return 1;
  else if (section == 1)
    return 6;
  else if (section == 2)
    return 1;
  else if (section == 3)
    return 1;
  else if (section == 4)
    return 1;
  else if (section == 5)
    return 1;
  else if (section == 6)
    return 1;
  else if (section == 7)
    return 1;
  else if (section == 8)
      return 1;
  else if (section == 9)
    return 1;
  else if (section == 10)
    return 2;
  else if (section == 11)
    return 10;
  else if (section == 12)
    return 1;
  else
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [super tableView:tableView cellForRowAtIndexPath:indexPath];
  if (indexPath.section == 1 && ([self iPad] && ![self iPadMini]) &&
      ([self iOS9] || [self iOS10])) {
    if (indexPath.row == 0 || indexPath.row == 3) {
      ((UISwitch *)cell.accessoryView).on = NO;
      ((UISwitch *)cell.accessoryView).enabled = NO;
    }
  }
  if (indexPath.section == 11) {
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.detailTextLabel.text =
        [[ALApplicationList sharedApplicationList].applications
            objectForKey:cell.detailTextLabel.text];
    tableView.allowsSelection = YES;
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

  [tableView deselectRowAtIndexPath:indexPath animated:YES];

  if (indexPath.section == 7 || indexPath.section == 8) {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
  } else if (indexPath.section == 11) {
    AppSelectController *asc =
        [[AppSelectController alloc] initWithStyle:UITableViewStyleGrouped];
    asc.settingsKey =
        [[[[self specifiersInGroup:11] objectAtIndex:(int)indexPath.row + 1]
            properties] objectForKey:kPrefs_KeyName_Key];
    [self pushController:asc animate:YES];
  } else if (indexPath.section == 12 && indexPath.row == 0) {
    ShortcutsController *scc =
        [[ShortcutsController alloc] initWithStyle:UITableViewStyleGrouped];
    [self pushController:scc];
  }
}

/*
static void sendReloadNotification() {
  [[NSNotificationCenter defaultCenter]
      postNotificationName:@"de.hoenig.molar-preferencesChanged-nc"
                    object:nil];
}
*/

- (void)reloadTable {
  [self reload];
  [self reloadSpecifiers];
}

- (id)specifiers {
  if (_specifiers == nil) {
    _specifiers =
        [self loadSpecifiersFromPlistName:@"MolarSettings" target:self];
  }
  return _specifiers;
}

- (id)init {
  if ((self = [super init])) {
    preferences = [[HBPreferences alloc] initWithIdentifier:kBundleID];
    [preferences registerPreferenceChangeBlock:^{
      [self reload];
      [self reloadSpecifiers];
    }];

    /*
    CFNotificationCenterAddObserver(
        CFNotificationCenterGetDarwinNotifyCenter(), NULL,
        (CFNotificationCallback)sendReloadNotification,
        CFSTR("de.hoenig.molar/ReloadPrefs"), NULL,
        CFNotificationSuspensionBehaviorCoalesce);
    */
  }

  return self;
}

@end
