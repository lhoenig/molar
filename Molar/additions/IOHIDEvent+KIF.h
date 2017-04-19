//
//  IOHIDEvent+KIF.h
//  testAnything
//
//  Created by PugaTang on 16/4/1.
//  Copyright © 2016年 PugaTang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef struct __IOHIDEvent *IOHIDEventRef;
IOHIDEventRef kif_IOHIDEventWithTouches(NSArray *touches) CF_RETURNS_RETAINED;
IOHIDEventRef kif_IOHIDEventWith3DTouches(NSArray *touches,
                                          CGFloat pressure) CF_RETURNS_RETAINED;