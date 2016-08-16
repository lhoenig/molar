//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSObject.h"

@class AVExternalDevice, FBSDisplay, NSSet, UIScreen, UITraitCollection;

@protocol SBStarkSessionConfiguring <NSObject>
@property(readonly, copy, nonatomic) NSSet *sessionProtocols;
@property(readonly, nonatomic, getter=isPairedVehicle) _Bool pairedVehicle;
@property(readonly, nonatomic, getter=isOEMIconVisible) _Bool OEMIconVisible;
@property(readonly, nonatomic, getter=isKnownVehicle) _Bool knownVehicle;
@property(readonly, nonatomic, getter=isGeoSupported) _Bool geoSupported;
@property(readonly, nonatomic, getter=isConnectedWirelessly) _Bool connectedWirelessly;
@property(readonly, nonatomic, getter=isAmbientBrightnessNighttime) _Bool ambientBrightnessNighttime;
@property(readonly, copy, nonatomic) UITraitCollection *traitCollection;
@property(readonly, nonatomic) double screenScale;
@property(readonly, retain, nonatomic) UIScreen *screen;
@property(readonly, retain, nonatomic) FBSDisplay *display;
@property(readonly, nonatomic) long long layoutJustification;
@property(readonly, nonatomic) unsigned long long interactionAffordances;
@property(readonly, retain, nonatomic) AVExternalDevice *device;
@end

