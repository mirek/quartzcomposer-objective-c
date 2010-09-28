//
//  ObjectiveCPlugIn.m
//  Objective-C
//
//  Created by Mirek Rusin on 26/02/2010.
//  Copyright (c) 2010 Inteliv Ltd. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "ObjectiveCAbstractPlugIn.h"

#define kQCPlugIn_Name        @"Objective-C"
#define kQCPlugIn_Description @"Objective-C (%@, time mode %@) PlugIn"

//@interface QCPlugInPatch (Extras)
//- (id) state;
//@end

@interface QCPlugIn (Extras)
- (id) patch;
@end

@implementation ObjectiveCAbstractPlugIn

@synthesize onTheFly;
@synthesize source;
@synthesize bundleData;
@synthesize onTheFlyInputs;
@synthesize onTheFlyOutputs;

//- (id) objectForKey: (NSString *) key {
//  NSLog(@"objectForKey: %@", key);
//  return nil;
//}

// Default source based on defaultSourceName. Do not override this method,
// instead set the proper name in defaultSourceName class method in the subclass.
+ (NSString *) defaultSource {
  NSBundle *bundle = [NSBundle bundleForClass: self];
  NSString *path = [bundle pathForResource: [self defaultSourceName] ofType: @"m"];
  NSLog(@"INFO: Will load default source from %@", path);
  return [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: nil];
}

// Override this class method in the subclasses, full path will be generated
// based on this name (without extension, .m is assumed)
+ (NSString *) defaultSourceName {
  return nil;
}

+ (NSString *) executionModeName {
  switch ([self executionMode]) {
    case kQCPlugInExecutionModeProvider:
      return @"Provider";
      break;
    case kQCPlugInExecutionModeProcessor:
      return @"Processor";
      break;
    case kQCPlugInExecutionModeConsumer:
      return @"Consumer";
      break;
    default:
      return @"Unknown";
      break;
  }
}

+ (NSString *) timeModeName {
  switch ([self timeMode]) {
    case kQCPlugInTimeModeNone:
      return @"None";
      break;
    case kQCPlugInTimeModeIdle:
      return @"Idle";
      break;
    case kQCPlugInTimeModeTimeBase:
      return @"TimeBase";
      break;
    default:
      return @"Unknown";
      break;
  }
}

+ (NSDictionary *) attributes {
	return [NSDictionary dictionaryWithObjectsAndKeys:
          kQCPlugIn_Name, QCPlugInAttributeNameKey,
          [NSString stringWithFormat: kQCPlugIn_Description, [self executionModeName], [self timeModeName]], QCPlugInAttributeDescriptionKey,
          nil];
}

// Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
+ (NSDictionary *) attributesForPropertyPortWithKey: (NSString *) key {
	return nil;
}

- (id) init {
	if (self = [super init]) {
    self.onTheFlyInputs = [NSMutableDictionary dictionary];
    self.onTheFlyOutputs = [NSMutableDictionary dictionary];
    
//    if ([self respondsToSelector: @selector(patch)]) {
//      id patch = [self performSelector: @selector(patch)];
//      if ([patch respondsToSelector: @selector(state)]) {
//        id state = [patch performSelector: @selector(state)];
//        NSLog(@"init state %@", state);
//      }
//    }

    onTheFly = [[OnTheFly alloc] init];
    
    // NOTE: The source is set by setValue:forKey: when the patch is loaded from qtz
    //       It doesn't make sense to set it here.
    
    
//    self.onTheFly = [[OnTheFly alloc] initWithSourceString: self.source];
    
//    [self.onTheFly addObserver: self
//                    forKeyPath: @"source"
//                       options: NO
//                       context: nil];
//    
//    [self.onTheFly bind: @"bundleData" toObject: self.onTheFly withKeyPath: @"bundleData" options: nil];
	}
	return self;
}

//- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context {
//  if (object == self.onTheFly) {
//    if ([keyPath isEqualToString: @"source"]) {
//      self.source = onTheFly.source;
//    }
//  }
//}

- (IBAction) recompileIfNecessaryAndReloadDynamicLibrary {
  // Update source
  [self.onTheFly loadSourceFromFile];
  //self.source = [onTheFly sourceString];
  [self setValue: [onTheFly sourceString] forKey: @"source"];
  [self.onTheFly recompileIfNecessaryAndReloadDynamicLibrary];
  
  NSLog(@" log is %@", [self.onTheFly log]);
}

- (void) updatePorts {
  NSArray *inputKeys = [[onTheFly inputs] allKeys];
  for (NSString *key in inputKeys) {
    NSDictionary *input = [[onTheFly inputs] objectForKey: key];
    NSString *inputPortType = [NSString stringWithFormat: @"QCPortType%@", [input objectForKey: @"type"]];
    NSMutableDictionary *inputPortAttributes = [NSMutableDictionary dictionary];
    [inputPortAttributes unlessNilSetObject: inputPortType                    forKey: QCPortAttributeTypeKey];
    [inputPortAttributes unlessNilSetObject: [input objectForKey: @"name"]    forKey: QCPortAttributeNameKey];
    [inputPortAttributes unlessNilSetObject: [input objectForKey: @"default"] forKey: QCPortAttributeDefaultValueKey];
    [inputPortAttributes unlessNilSetObject: [input objectForKey: @"minimum"] forKey: QCPortAttributeMinimumValueKey];
    [inputPortAttributes unlessNilSetObject: [input objectForKey: @"maximum"] forKey: QCPortAttributeMaximumValueKey];
    [inputPortAttributes unlessNilSetObject: [input objectForKey: @"menu"]    forKey: QCPortAttributeMenuItemsKey];
    if ([input objectForKey: @"menu"]) {
      NSLog(@"i: %@, %@, %@, %@", [input objectForKey: @"menu"], [[input objectForKey: @"menu"] class], [[input objectForKey: @"menu"] objectAtIndex: 0],
            [[[input objectForKey: @"menu"] objectAtIndex: 0] class]);
    }
    if ([self inputPortExistsForKey: key]) {
      if (![self inputPortExistsWithType: inputPortType forKey: key]) {
        [self removeInputPortForKey: key];
        [self addInputPortWithType: inputPortType forKey: key withAttributes: inputPortAttributes];
      }
    } else {
      [self addInputPortWithType: inputPortType forKey: key withAttributes: inputPortAttributes];
    }
  }
  [self keepOnlyInputPortsWithKeys: inputKeys];
  
  NSArray *outputKeys = [[onTheFly outputs] allKeys];
  for (NSString *key in outputKeys) {
    NSDictionary *output = [[onTheFly outputs] objectForKey: key];
    NSString *outputPortType = [NSString stringWithFormat: @"QCPortType%@", [output objectForKey: @"type"]];
    NSMutableDictionary *outputPortAttributes = [NSMutableDictionary dictionary];
    [outputPortAttributes unlessNilSetObject: outputPortType                    forKey: QCPortAttributeTypeKey];
    [outputPortAttributes unlessNilSetObject: [output objectForKey: @"name"]    forKey: QCPortAttributeNameKey];
    [outputPortAttributes unlessNilSetObject: [output objectForKey: @"default"] forKey: QCPortAttributeDefaultValueKey];
    [outputPortAttributes unlessNilSetObject: [output objectForKey: @"minimum"] forKey: QCPortAttributeMinimumValueKey];
    [outputPortAttributes unlessNilSetObject: [output objectForKey: @"maximum"] forKey: QCPortAttributeMaximumValueKey];
    [outputPortAttributes unlessNilSetObject: [output objectForKey: @"menu"]    forKey: QCPortAttributeMenuItemsKey];
    if ([self outputPortExistsForKey: key]) {
      if (![self outputPortExistsWithType: outputPortType forKey: key]) {
        [self removeOutputPortForKey: key];
        [self addOutputPortWithType: outputPortType forKey: key withAttributes: outputPortAttributes];
      }
    } else {
      [self addOutputPortWithType: outputPortType forKey: key withAttributes: outputPortAttributes];
    }
  }
  [self keepOnlyOutputPortsWithKeys: outputKeys];
}

// Release any non garbage collected resources created in -init
- (void) finalize {
	[super finalize];
}

// Release any resources created in -init
- (void) dealloc {
	[super dealloc];
}

- (void) setValue: (id) value forKey: (NSString *) key {
  if ([key isEqualToString: @"source"]) {
    
    // HACK: Ok, this is a hack but when instantiating this patch object form qtz
    // this is the only place to do it? 
    //if ([value isEqualToString: @"// Null"]) {
    if (value == nil || ([value isKindOfClass: [NSString class]] && [value length] == 0)) {
      value = [self.class defaultSource];
    }
    
    NSLog(@"INFO: Setting source to value with length %i bytes", [(NSString *)value length]);
    
    self.onTheFly.sourceString = value;
    [self.onTheFly saveSourceToFile];
    [onTheFly recompileIfNecessaryAndReloadDynamicLibrary];
    //self.log = [onTheFly dumpLogAsStringAndClear];
    [self updatePorts];
//    
//    [self recompileIfNecessaryAndReloadDynamicLibrary];
  }
  [super setValue: value forKey: key];
}

// Return a list of the KVC keys corresponding to the internal settings of the plug-in.
+ (NSArray *) plugInKeys {
	return [NSArray arrayWithObjects:
          @"source",
          nil];
}

// Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
// The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
- (id) serializedValueForKey: (NSString *) key {
	return [super serializedValueForKey: key];
}

// Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
// Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
- (void) setSerializedValue: (id) serializedValue forKey: (NSString *) key {
	[super setSerializedValue: serializedValue forKey: key];
}

// Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
// You can return a subclass of QCPlugInViewController if necessary.
- (QCPlugInViewController *) createViewController {
  //@throw [NSError errorWithDomain: @"" code: 0 userInfo: nil];
	return [[ObjectiveCPlugInViewController alloc] initWithPlugIn: self viewNibName: @"Settings"];
}

//
// Dynamic ports
//

- (void) keepOnlyInputPortsWithKeys: (NSArray *) keys {
  for (NSString *key in [self.onTheFlyInputs allKeys])
    if ([keys indexOfObject: key] == NSNotFound)
      [self removeInputPortForKey: key];
}

- (void) keepOnlyOutputPortsWithKeys: (NSArray *) keys {
  for (NSString *key in [self.onTheFlyOutputs allKeys])
    if ([keys indexOfObject: key] == NSNotFound)
      [self removeOutputPortForKey: key];
}

- (BOOL) inputPortExistsForKey: (NSString *) key {
  return [self inputPortExistsWithType: nil forKey: key];
}

- (BOOL) outputPortExistsForKey: (NSString *) key {
  return [self outputPortExistsWithType: nil forKey: key];
}

- (BOOL) inputPortExistsWithType: (NSString *) type forKey: (NSString *) key {
  NSDictionary *port = [self.onTheFlyInputs objectForKey: key];
  if (port == nil) {
    return NO;
  } else {
    return type == nil || [[port objectForKey: @"type"] isEqualToString: type];
  }
}

- (BOOL) outputPortExistsWithType: (NSString *) type forKey: (NSString *) key {
  NSDictionary *port = [self.onTheFlyOutputs objectForKey: key];
  if (port == nil) {
    return NO;
  } else {
    return type == nil || [[port objectForKey: @"type"] isEqualToString: type];
  }
}

- (void) addInputPortWithType: (NSString *) type forKey: (NSString *) key withAttributes: (NSDictionary *) attributes {
  [super addInputPortWithType: type forKey: key withAttributes: attributes];
  NSDictionary *port = [NSDictionary dictionaryWithObjectsAndKeys:
                        type,       @"type",
                        attributes, @"attributes",
                        nil];
  [self.onTheFlyInputs setObject: port forKey: key];
}

- (void) addOutputPortWithType: (NSString *) type forKey: (NSString *) key withAttributes: (NSDictionary *) attributes {
  [super addOutputPortWithType: type forKey: key withAttributes: attributes];
  NSDictionary *port = [NSDictionary dictionaryWithObjectsAndKeys:
                        type,       @"type",
                        attributes, @"attributes",
                        nil];
  [self.onTheFlyOutputs setObject: port forKey: key];
}

- (void) removeInputPortForKey: (NSString *) key {
  [super removeInputPortForKey: key];
  [self.onTheFlyInputs removeObjectForKey: key];
}

- (void) removeOutputPortForKey: (NSString *) key {
  [super removeOutputPortForKey: key];
  [self.onTheFlyOutputs removeObjectForKey: key];
}

@end

//
// Execution
//
@implementation ObjectiveCAbstractPlugIn (Execution)

- (BOOL) startExecution: (id<QCPlugInContext>) context {
	return YES;
}

// Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
- (void) enableExecution: (id<QCPlugInContext>) context {
}

// Called by Quartz Composer whenever the plug-in instance needs to execute.
// Only read from the plug-in inputs and produce a result (by writing to the plug-in
// outputs or rendering to the destination OpenGL context) within that method and nowhere else.
// Return NO in case of failure during the execution (this will prevent rendering of the current
// frame to complete).
// 
// The OpenGL context for rendering can be accessed and defined for CGL macros using:
// CGLContextObj cgl_ctx = [context CGLContextObj];
- (BOOL) execute: (id<QCPlugInContext>) context atTime: (NSTimeInterval) time withArguments: (NSDictionary *) arguments {
  NSMutableDictionary *inputs_ = [NSMutableDictionary dictionary];
  NSDictionary *outputs_ = nil;
  
  // Prepare inputs
  for (NSString *key in [self.onTheFlyInputs allKeys]) {
    id inputValue = [self valueForInputKey: key];
    [inputs_ unlessNilSetObject: inputValue forKey: key];
  }
  
  if ([onTheFly executeWithPlugIn: self 
                          context: context
                           atTime: time
                    withArguments: arguments 
                           inputs: inputs_
                          outputs: &outputs_])
  {
    // Get outputs
    if (outputs_) {
      for (NSString *key in [self.onTheFlyOutputs allKeys]) {
        id outputValue = [outputs_ objectForKey: key];
#ifdef DEBUG
        //NSLog(@"setValue: (%@) forOuputKey: %@", outputValue, key);
#endif
        [self setValue: outputValue forOutputKey: key];
      }
    }
    return YES;
  } else {
    return NO;
  }
}

// Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
- (void) disableExecution: (id<QCPlugInContext>) context {
}

// Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
- (void) stopExecution: (id<QCPlugInContext>) context {
}

@end
