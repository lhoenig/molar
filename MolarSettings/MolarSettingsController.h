//
//  SwitcherSettingsController.h
//  SwitcherSettings
//
//  Created by Lukas Hönig on 22.03.16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import "HBPreferences.h"

@interface MolarSettingsController
    : PSListController <UITableViewDelegate, UITableViewDataSource> {
  HBPreferences *preferences;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier;

@end