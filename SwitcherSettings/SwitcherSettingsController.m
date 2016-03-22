//
//  SwitcherSettingsController.m
//  SwitcherSettings
//
//  Created by Lukas Hönig on 22.03.16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "SwitcherSettingsController.h"
#import <Preferences/PSSpecifier.h>
#import <AppList.h>

#define kPrefs_Path @"/var/mobile/Library/Preferences"
#define kPrefs_KeyName_Key @"key"
#define kPrefs_KeyName_Defaults @"defaults"

#define kNotificationName @"de.hoenig.AppSwitcher-preferencesChanged"
#define kBundleID @"de.hoenig.AppSwitcher"
#define kPrefsFile @"/var/mobile/Library/Preferences/de.hoenig.AppSwitcher.plist"

@interface AppSelectController : UITableViewController <UITableViewDataSource> {
@private
    ALApplicationTableDataSource *dataSource;
    UITableViewCell *selectedCell;
}

@property (nonatomic, retain) NSString *settingsKey;

@end


@implementation AppSelectController

@synthesize settingsKey;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([[dataSource displayIdentifierForIndexPath:indexPath] isEqualToString:(__bridge NSString*)CFPreferencesCopyAppValue((CFStringRef)settingsKey, (CFStringRef)kBundleID)]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        selectedCell = cell;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource tableView:tableView numberOfRowsInSection:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [dataSource numberOfSectionsInTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [dataSource tableView:tableView titleForFooterInSection:section];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.tableView.dataSource = dataSource;
    self.tableView.dataSource = self;
    dataSource.tableView = self.tableView;
}

- (void)viewDidUnload
{
    dataSource.tableView = nil;
    [super viewDidUnload];
}

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        dataSource = [[ALApplicationTableDataSource alloc] init];
        dataSource.sectionDescriptors = [ALApplicationTableDataSource standardSectionDescriptors];
        selectedCell = nil;
    }
    return self;
}

- (void)dealloc {
    dataSource.tableView = nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    //NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsFile];
    if ([tableView cellForRowAtIndexPath:indexPath] == selectedCell) {
        //[settings setObject:@"" forKey:settingsKey];
        CFPreferencesSetValue((CFStringRef)settingsKey, (CFStringRef)@"", (CFStringRef)kBundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
        selectedCell = nil;
    } else {
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        NSString *displayIdentifier = [dataSource displayIdentifierForIndexPath:indexPath];
        CFPreferencesSetValue((CFStringRef)settingsKey, (CFStringRef)displayIdentifier, (CFStringRef)kBundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        //[settings setObject:displayIdentifier forKey:settingsKey];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    }
    //CFPreferencesSetMultiple((CFDictionaryRef)settings, nil, (CFStringRef)kBundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPreferencesSynchronize((CFStringRef)kBundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    
    CFStringRef notificationName = (CFStringRef)kNotificationName;
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
}

@end


@implementation SwitcherSettingsController

- (id)getValueForSpecifier:(PSSpecifier*)specifier
{
	id value = @"";
	
	NSDictionary *specifierProperties = [specifier properties];
	NSString *specifierKey = [specifierProperties objectForKey:kPrefs_KeyName_Key];
	
    // get 'value' from 'defaults' plist (if 'defaults' key and file exists)
    NSMutableString *plistPath = [[NSMutableString alloc] initWithString:[specifierProperties objectForKey:kPrefs_KeyName_Defaults]];
    if (plistPath)
    {
        NSDictionary *dict = (NSDictionary*)[self initDictionaryWithFile:&plistPath asMutable:NO];
        
        id objectValue = [dict objectForKey:specifierKey];
        
        if (objectValue) value = [NSString stringWithFormat:@"%@", objectValue];
    }

	return value;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 1;
    else if (section == 1) return 2;
    else if (section == 2) return 10;
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.detailTextLabel.text = [[ALApplicationList sharedApplicationList].applications objectForKey:cell.detailTextLabel.text];
        tableView.allowsSelection = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        AppSelectController *asc = [[AppSelectController alloc] initWithStyle:UITableViewStyleGrouped];
        asc.settingsKey = [[[[self specifiersInGroup:2] objectAtIndex:(int)indexPath.row + 1] properties] objectForKey:kPrefs_KeyName_Key];
        NSLog(@"Settings key: %@", asc.settingsKey);
        
        [self pushController:asc animate:YES];
    }
}

static void sendReloadNotification() {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"de.hoenig.AppSwitcher-preferencesChanged-nc" object:nil];
}

- (void)reloadTable {
    NSLog(@"Reloading table");
    CFPreferencesSynchronize((CFStringRef)kBundleID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    [self reload];
    [self reloadSpecifiers];
}

- (id)initDictionaryWithFile:(NSMutableString**)plistPath asMutable:(BOOL)asMutable
{
	if ([*plistPath hasPrefix:@"/"])
		*plistPath = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@.plist", *plistPath]];
	else
		*plistPath = [NSMutableString stringWithString:[NSString stringWithFormat:@"%@/%@.plist", kPrefs_Path, *plistPath]];
	
	Class class;
	if (asMutable)
		class = [NSMutableDictionary class];
	else
		class = [NSDictionary class];
	
	id dict;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:*plistPath])
		dict = [[class alloc] initWithContentsOfFile:*plistPath];	
	else
		dict = [[class alloc] init];
	
	return dict;
}

- (id)specifiers
{
	if (_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"SwitcherSettings" target:self];
	}
    
	return _specifiers;
}

- (id)init
{
	if ((self = [super init]))
	{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"de.hoenig.AppSwitcher-preferencesChanged-nc" object:nil];
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)sendReloadNotification,
                                        CFSTR("de.hoenig.AppSwitcher-preferencesChanged"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorCoalesce);
	}
	
	return self;
}

@end