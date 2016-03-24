//
//  SwitcherSettingsController.h
//  SwitcherSettings
//
//  Created by Lukas Hönig on 22.03.16.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/Preferences.h>

@interface MolarSettingsController : PSListController <UITableViewDelegate, UITableViewDataSource> {
}

- (id)getValueForSpecifier:(PSSpecifier*)specifier;

@end