//
//  IOHIDEvent+KIF.m
//  testAnything
//
//  Created by PugaTang on 16/4/1.
//  Copyright © 2016年 PugaTang. All rights reserved.
//

#import "IOHIDEvent+KIF.h"
#import <UIKit/UIKit.h>
#import <mach/mach_time.h>
#import "IOKit/hid/IOHIDEventTypes.h"
#define IOHIDEventFieldBase(type) (type << 16)
#ifdef __LP64__
typedef double IOHIDFloat;
#else
typedef float IOHIDFloat;
#endif
typedef UInt32 IOOptionBits;
typedef uint32_t IOHIDDigitizerTransducerType;
typedef uint32_t IOHIDEventField;
typedef uint32_t IOHIDEventType;

void IOHIDEventAppendEvent(IOHIDEventRef event, IOHIDEventRef childEvent);
void IOHIDEventSetIntegerValue(IOHIDEventRef event, IOHIDEventField field,
                               int value);
void IOHIDEventSetFloatValue(IOHIDEventRef event, IOHIDEventField field,
                             IOHIDFloat value);
void IOHIDEventSetSenderID(IOHIDEventRef event, uint64_t sender);

IOHIDEventRef IOHIDEventCreateDigitizerEvent(
    CFAllocatorRef allocator, AbsoluteTime timeStamp,
    IOHIDDigitizerTransducerType type, uint32_t index, uint32_t identity,
    uint32_t eventMask, uint32_t buttonMask, IOHIDFloat x, IOHIDFloat y,
    IOHIDFloat z, IOHIDFloat tipPressure, IOHIDFloat barrelPressure,
    Boolean range, Boolean touch, IOOptionBits options);
IOHIDEventRef IOHIDEventCreateDigitizerFingerEventWithQuality(
    CFAllocatorRef allocator, AbsoluteTime timeStamp, uint32_t index,
    uint32_t identity, uint32_t eventMask, IOHIDFloat x, IOHIDFloat y,
    IOHIDFloat z, IOHIDFloat tipPressure, IOHIDFloat twist,
    IOHIDFloat minorRadius, IOHIDFloat majorRadius, IOHIDFloat quality,
    IOHIDFloat density, IOHIDFloat irregularity, Boolean range, Boolean touch,
    IOOptionBits options);

IOHIDEventRef kif_IOHIDEventWithTouches(NSArray *touches) {
    uint64_t abTime = mach_absolute_time();
    AbsoluteTime timeStamp;
    timeStamp.hi = (UInt32)(abTime >> 32);
    timeStamp.lo = (UInt32)(abTime);
    IOHIDEventRef handEvent = IOHIDEventCreateDigitizerEvent(
        kCFAllocatorDefault,               // allocator 内存分配器
        timeStamp,                         // timestamp 时间戳
        kIOHIDDigitizerTransducerTypeHand, // type
        0,                                 // index
        0,                                 // identity
        kIOHIDDigitizerEventTouch,         // eventMask
        0,                                 // buttonMask
        0,                                 // x
        0,                                 // y
        0,                                 // z
        0,                                 // tipPressure
        0,                                 // barrelPressure
        0,                                 // range
        true,                              // touch
        0);                                // options
    IOHIDEventSetIntegerValue(
        handEvent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);
    for (UITouch *touch in touches) {
        uint32_t eventMask =
            (touch.phase == UITouchPhaseMoved)
                ? kIOHIDDigitizerEventPosition
                : (kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch);
        uint32_t isTouching = (touch.phase == UITouchPhaseEnded) ? 0 : 1;
        CGPoint touchLocation = [touch locationInView:touch.window];
        IOHIDEventRef fingerEvent =
            IOHIDEventCreateDigitizerFingerEventWithQuality(
                kCFAllocatorDefault,                       // allocator
                timeStamp,                                 // timestamp
                (UInt32)[touches indexOfObject:touch] + 1, // index
                2,                                         // identity
                eventMask,                                 // eventMask
                (IOHIDFloat)touchLocation.x,               // x
                (IOHIDFloat)touchLocation.y,               // y
                0.0,                                       // z
                0,                                         // tipPressure
                0,                                         // twist
                5.0,                                       // minor radius
                5.0,                                       // major radius
                1.0,                                       // quality
                1.0,                                       // density
                1.0,                                       // irregularity
                (IOHIDFloat)isTouching,                    // range
                (IOHIDFloat)isTouching,                    // touch
                0);                                        // options
        IOHIDEventSetIntegerValue(
            fingerEvent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, 1);
        IOHIDEventAppendEvent(handEvent, fingerEvent);
        CFRelease(fingerEvent);
    }
    return handEvent;
}

IOHIDEventRef kif_IOHIDEventWith3DTouches(NSArray *touches, CGFloat pressure) {
    uint64_t abTime = mach_absolute_time();
    AbsoluteTime timeStamp;
    timeStamp.hi = (UInt32)(abTime >> 32);
    timeStamp.lo = (UInt32)(abTime);
    IOHIDEventRef handEvent = IOHIDEventCreateDigitizerEvent(
        kCFAllocatorDefault,               // allocator 内存分配器
        timeStamp,                         // timestamp 时间戳
        kIOHIDDigitizerTransducerTypeHand, // type
        0,                                 // index
        0,                                 // identity
        kIOHIDDigitizerEventTouch,         // eventMask
        0,                                 // buttonMask
        0,                                 // x
        0,                                 // y
        0,                                 // z
        pressure,                          // tipPressure
        0,                                 // barrelPressure
        0,                                 // range
        true,                              // touch
        0);                                // options
    IOHIDEventSetIntegerValue(
        handEvent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, true);
    for (UITouch *touch in touches) {
        uint32_t eventMask =
            (touch.phase == UITouchPhaseMoved)
                ? kIOHIDDigitizerEventPosition
                : (kIOHIDDigitizerEventRange | kIOHIDDigitizerEventTouch);
        uint32_t isTouching = (touch.phase == UITouchPhaseEnded) ? 0 : 1;
        CGPoint touchLocation = [touch locationInView:touch.window];
        IOHIDEventRef fingerEvent =
            IOHIDEventCreateDigitizerFingerEventWithQuality(
                kCFAllocatorDefault,                       // allocator
                timeStamp,                                 // timestamp
                (UInt32)[touches indexOfObject:touch] + 1, // index
                2,                                         // identity
                eventMask,                                 // eventMask
                (IOHIDFloat)touchLocation.x,               // x
                (IOHIDFloat)touchLocation.y,               // y
                0.0,                                       // z
                pressure,                                  // tipPressure
                0,                                         // twist
                5.0,                                       // minor radius
                5.0,                                       // major radius
                1.0,                                       // quality
                1.0,                                       // density
                1.0,                                       // irregularity
                (IOHIDFloat)isTouching,                    // range
                (IOHIDFloat)isTouching,                    // touch
                0);                                        // options
        IOHIDEventSetIntegerValue(
            fingerEvent, kIOHIDEventFieldDigitizerIsDisplayIntegrated, 1);
        IOHIDEventAppendEvent(handEvent, fingerEvent);
        CFRelease(fingerEvent);
    }
    return handEvent;
}
