//
//  ObjectiveCPlugIn.h
//  Objective-C
//
//  Created by Mirek Rusin on 26/02/2010.
//  Copyright (c) 2010 Inteliv Ltd. All rights reserved.
//

//#ifndef ObjectiveCAbstractPlugIn_H
//#define ObjectiveCAbstractPlugIn_H 1

#import <Quartz/Quartz.h>

//#import <QuartzComposer/QuartzComposer.h>
//#import <QuartzComposer/QCPatch.h>

#import "OnTheFly.h"
#import "NSMutableDictionary-UnlessNilSetObjectForKey.h"
#import "ObjectiveCPlugInViewController.h"

// The status of the plugin
//enum  {
//  ObjectiveCPlugInStatusIdle,
//  ObjectiveCPlugInStatusWarning,
//  ObjectiveCPlugInStatusError,
//  ObjectiveCPlugInStatusOk
//} ObjectiveCPlugInStatus;

#define kObjectiveCPlugInStatusIdle    @"idle"
#define kObjectiveCPlugInStatusWarning @"warning"
#define kObjectiveCPlugInStatusError   @"error"
#define kObjectiveCPlugInStatusOk      @"ok"

typedef NSString ObjectiveCPlugInStatus;

@interface ObjectiveCAbstractPlugIn : QCPlugIn {
  OnTheFly *onTheFly;
  
  NSString *source;
  NSData   *bundleData;
  NSString *status;
  
  NSMutableDictionary *onTheFlyInputs;
  NSMutableDictionary *onTheFlyOutputs;
}

@property (retain) NSString *source;
@property (retain) NSData *bundleData;

@property (retain) OnTheFly *onTheFly;
@property (retain) NSMutableDictionary *onTheFlyInputs;
@property (retain) NSMutableDictionary *onTheFlyOutputs;

@property (nonatomic, retain) NSString *status;

+ (NSString *) defaultSource;
+ (NSString *) defaultSourceName;
+ (NSString *) executionModeName;
+ (NSString *) timeModeName;

- (void) keepOnlyInputPortsWithKeys: (NSArray *) keys;
- (void) keepOnlyOutputPortsWithKeys: (NSArray *) keys;
- (BOOL) inputPortExistsForKey: (NSString *) key;
- (BOOL) outputPortExistsForKey: (NSString *) key;
- (void) removeOutputPortForKey: (NSString *) key;
- (void) removeInputPortForKey: (NSString *) key;
- (void) addOutputPortWithType: (NSString *) type forKey: (NSString *) key withAttributes: (NSDictionary *) attributes;
- (void) addInputPortWithType: (NSString *) type forKey: (NSString *) key withAttributes: (NSDictionary *) attributes;
- (BOOL) outputPortExistsWithType: (NSString *) type forKey: (NSString *) key;
- (BOOL) inputPortExistsWithType: (NSString *) type forKey: (NSString *) key;
- (void) updatePorts;

- (void) recompileIfNecessaryAndReloadDynamicLibrary;

+ (NSInteger) executableArchitecture;
+ (NSString *) IBOutlet executableArchitectureString;

//- (id) objectForKey: (NSString *) key;

@end

//#endif
