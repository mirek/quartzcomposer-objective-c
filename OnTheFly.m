//
//  OnTheFly.m
//  Objective-C
//
//  Created by Mirek Rusin on 26/02/2010.
//  Copyright 2010 Inteliv Ltd. All rights reserved.
//
// TODO:
// * remove initwithsourcepath

#import "OnTheFly.h"

@implementation OnTheFly

@synthesize log;
@synthesize dynamicLibraryPath;
@synthesize sourceString;
@synthesize sourcePath;
@synthesize onDeallocItemsToRemove;
@synthesize backgroundThread;
@synthesize lastProcessedSourceTimestamp;
@synthesize state;

- (OnTheFly *) init {
  if (self = [super init]) {
    canExecute = NO;
    executeFunction = NULL;
    
    log = [[NSMutableArray alloc] init];
    onDeallocItemsToRemove = [[NSMutableArray alloc] init];

//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithDouble: 3.0], @"sleep",
//                             nil];
    //backgroundThread = [[NSThread alloc] initWithTarget: self selector: @selector(backgroundThreadExecuteWithOptions:) object: options];
    //[backgroundThread start];
    
    sourceString = [NSString stringWithString: @"//"];
    lastProcessedSourceTimestamp = nil;
    
    meta = [[NSMutableDictionary alloc] init];
    
    // TODO:
    // - generate temp paths
    // - save to file if data is available
    state = kOnTheFlyStateInitialized;
  }
  return self;
}

- (OnTheFly *) initWithSourceString: (NSString *) aSourceString {
  if (self = [self init]) {
    sourceString = [aSourceString retain];
  }
  return self;
}

#pragma mark Background thread support

- (void) backgroundThreadStart {
  [self.backgroundThread start];
}

- (void) backgroundThreadCancel {
  [self.backgroundThread cancel];
}

// @options :sleep 
- (void) backgroundThreadExecuteWithOptions: (NSDictionary *) options {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  // Defaults when options = nil
  NSTimeInterval sleep = 3.0;
  
  if (options) {
    sleep = [(NSNumber *)[options objectForKey: @"sleep"] doubleValue];
  }
  
  while (![self.backgroundThread isCancelled]) {
  
    NSLog(@" * comment is %@", [self mainCommentString]);
//    NSLog(@" * source %@", [self sourceLastModificationDate]);
//    NSLog(@" * dylib  %@", [self dynamicLibraryLastModificationDate]);
//    
    [self reloadDynamicLibraryIfNecessary];
//    if ([self isSourceFileNewerThanDynamicLibraryFile]) {
//      [self recompile];
//    }
    [NSThread sleepForTimeInterval: sleep];
  }
  [pool drain];
}

#pragma mark State management

//- (void) setState: (int) value {
//  switch (state) {
//    case kOnTheFlyStateInitialized:
//      switch (value) {
//        case kOnTheFlyStateSourceSet:
//          state = value;
//          break;
//        default:
//          break;
//      }
//      break;
//
//    }
//  }
//}

#pragma mark Source management

- (void) setSourceString:(NSString *) value {
  if (value != sourceString) {
    if (sourceString)
      [sourceString release];
    sourceString = [value retain];
    
    variant = [OnTheFly variantWithString: [self variant]];
    
    // We've got new source string, rebuild meta comment
  }
}

- (BOOL) loadSourceFromFile {
  NSError *error = nil;
  self.sourceString = [NSString stringWithContentsOfFile: [self sourcePath] encoding: NSUTF8StringEncoding error: &error];
  if (error) {
    [self logWithErrorObject: error];
    return NO;
  } else {
    return YES;
  }
}

- (BOOL) saveSourceToFile {
  NSError *error = nil;
  NSString *source = [self sourceString];
  if (source == nil) {
    [self logWarning: @"Source string is nil, not saving to file"];
    return NO;
  } else {
    NSString *sourcePath_ = [self sourcePath];
    if (sourcePath_ == nil) {
      [self logError: @"Can't save source to file, source path is nil"];
      return NO;
    } else {
      [self logInfo: [NSString stringWithFormat: @"Will save to file at (%@) %@ contents: (%@, %i bytes)", [sourcePath_ class], sourcePath_, [source class], [source length]]];
      if (![source writeToFile: sourcePath_ atomically: YES encoding: NSUTF8StringEncoding error: &error]) {
        [self logWithErrorObject: error];
        return NO;
      } else {
        return YES;
      }
    }
  }
}

//- (NSString *) sourceString {
//  if (sourceString) {
//    return sourceString;
//  } else {
//    if ([self poolSourceFromFile]) {
//      return sourceString;
//    } else {
//      return nil;
//    }
//  }
//}

// Clear log, unload old library, compile if needed (ie. source is newer?)
//- (NSArray *) recompile {
//  [self unloadDynamicLibrary];
//  return [self recompileIfNecessary];
//}

+ (NSString *) generateTemporarySourcePath {
  //int pid = [[NSProcessInfo processInfo] processIdentifier];
  NSTimeInterval unixtime = [[[NSDate alloc] init] timeIntervalSince1970];
  u_int32_t random = arc4random();
  NSArray *components = [NSArray arrayWithObjects:
                         NSTemporaryDirectory(),
                         [NSString stringWithFormat: @"objective-c-snippet.%u.%u.m", (unsigned int)unixtime, (unsigned int)random],
                         nil];
  return [NSString pathWithComponents: components];
}

+ (NSString *) dynamicLibraryPathWithSourcePath: (NSString *) sourcePath {
  return [[sourcePath stringByDeletingPathExtension] stringByAppendingPathExtension: @"dylib"];
}

// Map variant string name to enum
// This is internal function
+ (OnTheFlyVariant) variantWithString: (NSString *) variantString {
  OnTheFlyVariant r = kOnTheFlyVariantBasicExecuteFunction;
  if ([variantString isEqualToString: @"BasicExecuteFunction"])
    r = kOnTheFlyVariantBasicExecuteFunction;
  else if ([variantString isEqualToString: @"ExtendedExecuteFunction"])
    r = kOnTheFlyVariantExtendedExecuteFunction;
  else   if ([variantString isEqualToString: @"ExtendedExecuteFunctionWithPlugIn"])
    r = kOnTheFlyVariantExtendedExecuteFunctionWithPlugIn;
  else
    NSLog(@"ERROR: unknown variant name %@, will use BasicExecuteFunction", variantString);
  return r;
}

- (NSString *) sourcePath {
  if (sourcePath == nil) {
    sourcePath = [[self.class generateTemporarySourcePath] retain];
    if (sourcePath == nil) {
      [self logError: @"Couldn't generate temporary source path"];
    } else {
      [self saveSourceToFile];
      //[onDeallocItemsToRemove addObject: sourcePath];
    }
  }
  return sourcePath;
}

- (NSString *) dynamicLibraryPath {
  if (dynamicLibraryPath != nil) {
    return dynamicLibraryPath;
  } else {
    if ([self sourcePath]) {
      self.dynamicLibraryPath = [[self.class dynamicLibraryPathWithSourcePath: [self sourcePath]] retain];
      if (self.dynamicLibraryPath == nil) {
        [self logError: @"Couldn't get dynamic library path from source path"];
        return nil;
      } else {
        //[onDeallocItemsToRemove addObject: dynamicLibraryPath];
        return dynamicLibraryPath;
      }
    } else {
      [self logError: @"Dynamic library path not set, source path not set, bail"];
      return nil;
    }
  }
}

//- (void) updateSourceFileWithString: (NSString *) string {
//  
//}

- (BOOL) executeWithPlugIn: (QCPlugIn *) plugIn
                   context: (id<QCPlugInContext>) context
                    atTime: (NSTimeInterval) time
             withArguments: (NSDictionary *) arguments
                    inputs: (NSDictionary *) inputs
                   outputs: (NSDictionary **) outputs
{
  if ([self canExecute]) {
    BOOL r = NO;
    switch (variant) {
      case kOnTheFlyVariantBasicExecuteFunction:
        r = ((BasicExecuteFunction)executeFunction)(inputs, outputs);
        break;
      case kOnTheFlyVariantExtendedExecuteFunction:
        r = ((ExtendedExecuteFunction)executeFunction)(context, time, arguments, inputs, outputs);
        break;
      case kOnTheFlyVariantExtendedExecuteFunctionWithPlugIn:
        r = ((ExtendedExecuteFunctionWithPlugIn)executeFunction)(plugIn, context, time, arguments, inputs, outputs);
        break;
      default:
        [self logError: [NSString stringWithFormat: @"Unknown variant %i", variant]];
        break;
    }
    if (!r)
      [self logWarning: @"Execute function failed"];
    return r;
  } else {
    return NO;
  }
}

- (BOOL) canExecute {
  return canExecute;
}

- (NSDate *) sourceLastModificationDate {
  return [[[NSFileManager defaultManager] attributesOfItemAtPath: [self sourcePath] error: nil] fileModificationDate];
}

- (NSDate *) dynamicLibraryLastModificationDate {
  return [[[NSFileManager defaultManager] attributesOfItemAtPath: [self dynamicLibraryPath] error: nil] fileModificationDate];
}

- (BOOL) isSourceFileNewerThanDynamicLibraryFile {
  return [self compareSourceAndDynamicLibraryFileModificationDate] == NSOrderedDescending;
}

// Returns NSOrderedDescending if source is newer
- (NSTestComparisonOperation) compareSourceAndDynamicLibraryFileModificationDate {
  NSError *error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSDate *sourceLastModificationDate = [[fileManager attributesOfItemAtPath: [self sourcePath] error: &error] fileModificationDate];
  if (error != nil) {
    [self logWithErrorObject: error];
    return NO;
  }
  NSDate *dynamicLibraryLastModificationDate = [[fileManager attributesOfItemAtPath: [self dynamicLibraryPath] error: &error] fileModificationDate];
  if (error != nil) {
    [self logWithErrorObject: error];
    return NO;
  }
  return [sourceLastModificationDate compare: dynamicLibraryLastModificationDate];
}

- (BOOL) isDynamicLibraryLoaded {
  return dynamicLibrary != NULL;
}

- (BOOL) reloadDynamicLibraryIfNecessary {
  if (canExecute != YES || [self isSourceFileNewerThanDynamicLibraryFile]) {
    return [self reloadDynamicLibrary];
  } else {
    return YES;
  }
}

- (BOOL) reloadDynamicLibrary {
  [self unloadDynamicLibrary];
  return [self loadDynamicLibrary];
}

- (BOOL) loadDynamicLibrary {
  NSArray *outputAndError = [self recompileIfNecessary];
  if (outputAndError != nil && [[outputAndError objectAtIndex: 1] length] > 0) {
    [self logError: @"Compile error, bailing loading dynamic library"];
    return NO;
  }
  
  dynamicLibrary = dlopen([[self dynamicLibraryPath] UTF8String], RTLD_LAZY);
  if (dynamicLibrary == NULL) {
    [self logError: [NSString stringWithCString: dlerror() encoding: NSUTF8StringEncoding]];
    return NO;
  } else {
    executeFunction = dlsym(dynamicLibrary, "execute");
    if (executeFunction == NULL) {
      canExecute = NO;
      [self logError: [NSString stringWithCString: dlerror() encoding: NSUTF8StringEncoding]];
      [self unloadDynamicLibrary];
      return NO;
    } else {
      //NSLog(@"* func %p, dylib %p", basicExecuteFunction, dynamicLibrary);
      canExecute = YES;
      return YES;
    }
  }
}

- (BOOL) loadDynamicLibraryIfNotLoaded {
  if (![self isDynamicLibraryLoaded]) {
    [self loadDynamicLibrary];
  }
  BOOL isDynamicLibraryLoaded = [self isDynamicLibraryLoaded];
  if (!isDynamicLibraryLoaded) {
    [self logError: @"Couldn't load dynamic library"];
  }
  return isDynamicLibraryLoaded;
}

#pragma mark Logging

- (void) logWithType: (NSString *) type message: (NSString *) message {
#ifdef DEBUG
  NSLog(@"%@: %@", type, message);
#endif
  [self.log addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                        type,    @"level",
                        message, @"message",
                        nil]];
}

- (void) logWithErrorObject: (NSError *) error {
  [self logError: [error localizedDescription]];
}

- (void) logError: (NSString *) message {
#ifndef DEBUG
  NSLog(@"ERROR %@", message);
#endif
  [self logWithType: @"ERROR" message: message];
}

- (void) logWarning: (NSString *) message {
  [self logWithType: @"WARN " message: message];
}

- (void) logInfo: (NSString *) message {
  [self logWithType: @"INFO " message: message];
}

//- (void) dumpLog {
//  printf("%s\n", [[self dumpLogAsString] UTF8String]);
//}

//- (NSString *) dumpLogAsStringAndClear {
//  NSString *dumpLogAsString = [self dumpLogAsString];
//  [self clearLog];
//  return dumpLogAsString;
//}

//- (NSString *) dumpLogAsString {
//  NSMutableArray *lines = [NSMutableArray array];
//  for (NSArray *logEntry in self.log)
//    [lines addObject: [logEntry componentsJoinedByString: @": "]];
//  return [lines componentsJoinedByString: @"\n"];
//}

- (void) clearLog {
  [self.log removeAllObjects];
}

- (BOOL) isLogEmpty {
  return [self.log count] == 0;
}

#pragma mark Dynamic library

- (BOOL) isDynamicLibraryCompiled {
  return [[NSFileManager defaultManager] fileExistsAtPath: [self dynamicLibraryPath]];
}

#pragma mark Source management


#pragma mark Main comment

- (NSString *) mainCommentString {
  NSString *source = [self sourceString];
  if (source != nil) {
    //[self logInfo: [NSString stringWithFormat: @"Will try to find main comment in (%@, %i bytes)", [source class], [source length]]];
    NSString *mainCommentStringWithComments = [source stringByMatching: @"\\/\\/\\s#\\sQuartz Composer Objective-C Snippet(\\n(\\/\\/[^\\n]*\\n)*)" capture: 1L];
    return [mainCommentStringWithComments stringByReplacingOccurrencesOfRegex: @"[\\n]\\/\\/ ?" withString: @"\n"];
    //return mainCommentStringWithComments;
    //return [source stringByMatching: @"(?s)/\\*(.*?)\\*/" capture: 1L];
  } else {
    [self logError: @"Source string is empty, can't get main comment section"];
    return nil;
  }
}

- (NSDictionary *) mainCommentAttributes {
  NSString *mainCommentString = [self mainCommentString];
  if (mainCommentString) {
    id r = [YAMLSerialization YAMLWithData: [mainCommentString dataUsingEncoding: NSUTF8StringEncoding]
                                   options: kYAMLReadOptionStringScalars
                                     error: nil];
    if (r == nil) {
      [self logError: @"Parsing main comment section failed"];
      return nil;
    } else {
      return [r objectAtIndex: 0];
    }
  } else {
    [self logError: @"Main comment string empty, can't parse with YAML"];
    return nil;
  }
}

- (id) mainCommentAttributeForKey: (NSString *) key {
  NSDictionary *mainCommentAttributes = [self mainCommentAttributes];
  if (mainCommentAttributes) {
    return [mainCommentAttributes objectForKey: key];
  } else {
    [self logError: [NSString stringWithFormat: @"Can't get comment attribute for key %@", key]];
    return nil;
  }
}

- (NSString *) variant {
  return [self mainCommentAttributeForKey: @"variant"];
}

- (NSString *) type {
  return [self mainCommentAttributeForKey: @"type"];
}

- (NSString *) timeMode {
  return [self mainCommentAttributeForKey: @"time_mode"];
}

- (NSArray *) frameworks {
  return [self mainCommentAttributeForKey: @"frameworks"];
}

- (NSString *) summary {
  return [self mainCommentAttributeForKey: @"summary"];
}

- (NSString *) copyright {
  return [self mainCommentAttributeForKey: @"copyright"];
}

- (NSString *) description {
  return [self mainCommentAttributeForKey: @"description"];
}

- (NSDictionary *) inputs {
  return [self mainCommentAttributeForKey: @"inputs"];
}

- (NSDictionary *) outputs {
  return [self mainCommentAttributeForKey: @"outputs"];
}

- (BOOL) needsRecompiling {
  return ![self isDynamicLibraryCompiled] || [self isSourceFileNewerThanDynamicLibraryFile];
}

// Compares last processed timestamp with source timestamp
- (BOOL) didCompileForCurrentSource {
  if (self.lastProcessedSourceTimestamp != nil) {
    return [self.lastProcessedSourceTimestamp compare: [self sourceLastModificationDate]] == NSOrderedSame;
  } else {
    return NO;
  }
}

- (NSArray *) recompileIfNecessaryAndReloadDynamicLibrary {
  NSArray *recompileIfNecessary = [self recompileIfNecessary];
  [self reloadDynamicLibrary];
  return recompileIfNecessary;
}

- (NSArray *) recompileIfNecessary {
  if ([self needsRecompiling] && ![self didCompileForCurrentSource]) {
    self.lastProcessedSourceTimestamp = [self sourceLastModificationDate];
    
    NSArray *frameworks = [self frameworks];
    if (frameworks == nil || [frameworks count] == 0) {
      [self logError: @"No frameworks defined, bailing compilation"];
      return nil;
    }
    
    NSString *sourcePath_ = [self sourcePath];
    if (sourcePath_ == nil) {
      [self logError: @"Source path is nil, bailing compilation"];
      return nil;
    }
    
    NSString *dynamicLibraryPath_ = [self dynamicLibraryPath];
    if (dynamicLibraryPath_ == nil) {
      [self logError: @"Dynamic library path is nil, bailing compilation"];
      return nil;
    }
    
    NSString *frameworkNames = @"N/A";
    if (frameworks)
      frameworkNames = [frameworks componentsJoinedByString: @", "];
    
    [self logInfo: [NSString stringWithFormat: @"Will recompile from %@ to %@ with frameworks: %@", sourcePath_, dynamicLibraryPath_, frameworkNames]];
    NSArray *compileOutputAndError = [self.class gccCompileWithOutputPath: dynamicLibraryPath_ inputPath: sourcePath_ frameworks: frameworks];
    NSString *compileOutput = [compileOutputAndError objectAtIndex: 0];
    NSString *compileError = [compileOutputAndError objectAtIndex: 1];
    if (![compileOutput isEqualToString: @""])
      [self logWarning: [NSString stringWithFormat: @"Compile warnings:\n%@", compileOutput]];
    if (![compileError isEqualToString: @""])
      [self logError: [NSString stringWithFormat: @"Compile errors:\n%@", compileError]];
    return compileOutputAndError;
  } else {
    return nil;
  }
}

- (void) unloadDynamicLibrary {
  canExecute = NO;
  executeFunction = NULL;
  if ([self isDynamicLibraryLoaded]) {
    [self logInfo: @"Unloading dynamic library"];
    dlclose(dynamicLibrary);
    //unlink([dynamicLibraryPath UTF8String]);
  }
}

+ (NSArray *) executeCommand: (NSString *) command
               withArguments: (NSArray *) arguments
{
  return [self executeCommand: command withArguments: arguments standardInputString: nil];
}

+ (NSArray *) executeCommand: (NSString *) command
               withArguments: (NSArray *) arguments
         standardInputString: (NSString *) standardInputString
{
  NSPipe *standardInputPipe  = [NSPipe pipe];
  NSPipe *standardOutputPipe = [NSPipe pipe];
  NSPipe *standardErrorPipe  = [NSPipe pipe];
  
  NSFileHandle *standardInputFileHandle  = [standardInputPipe fileHandleForWriting];
  NSFileHandle *standardOutputFileHandle = [standardOutputPipe fileHandleForReading];
  NSFileHandle *standardErrorFileHandle  = [standardErrorPipe fileHandleForReading];
  
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: command];
  
  if (arguments != nil)
    [task setArguments: arguments];
  
  if (standardInputString)
    [task setStandardInput:  standardInputPipe];
  
  [task setStandardOutput: standardOutputPipe];
  [task setStandardError:  standardErrorPipe];
  
  id result = nil;
  
  @try {
    
    // Raises an NSInvalidArgumentException if the launch path has not been set or is invalid or if it fails to create a process.
    [task launch];
    
    if (standardInputString) {
      [standardInputFileHandle writeData: [standardInputString dataUsingEncoding: NSUTF8StringEncoding]];
      [standardInputFileHandle closeFile];
    }
    
    NSData *standardOutputData = [standardOutputFileHandle readDataToEndOfFile];
    NSData *standardErrorData = [standardErrorFileHandle readDataToEndOfFile];
    
    NSString *standardOutputString = [[NSString alloc] initWithData: standardOutputData encoding: NSUTF8StringEncoding];
    NSString *standardErrorString = [[NSString alloc] initWithData: standardErrorData encoding: NSUTF8StringEncoding];
    
    result = [NSArray arrayWithObjects: standardOutputString, standardErrorString, nil];
  }
  @catch (NSException *exception) {
    NSLog(@"ERROR: Exception when trying to launch command '%@', %@", command, exception);
    result = nil;
  }
  return result;
}

+ (NSString *) which: (NSString *) command {
  return [self outputWithCommand: @"/usr/bin/which" arguments: [NSArray arrayWithObjects: command, nil] stripWhitespaces: YES];
}

// Can throw 'NSInvalidArgumentException', reason: 'launch path not accessible'
+ (NSString  *) outputWithCommand: (NSString *) command stripWhitespaces: (BOOL) stripWhitespaces {
  return [self outputWithCommand: command arguments: nil stripWhitespaces: stripWhitespaces];
}

// Can throw 'NSInvalidArgumentException', reason: 'launch path not accessible'
+ (NSString  *) outputWithCommand: (NSString *) command arguments: (NSArray *) arguments stripWhitespaces: (BOOL) stripWhitespaces {
  NSPipe *standardOutputPipe = [NSPipe pipe];
  NSFileHandle *standardOutputFileHandle = [standardOutputPipe fileHandleForReading];
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath: command];
  if (arguments != nil)
    [task setArguments: arguments];
  [task setStandardOutput: standardOutputPipe];
  [task launch];
  NSData *standardOutputData = [standardOutputFileHandle readDataToEndOfFile];
  NSString *standardOutputString = [[NSString alloc] initWithData: standardOutputData encoding: NSUTF8StringEncoding];
  if (stripWhitespaces)
    standardOutputString = [standardOutputString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return standardOutputString;
}

+ (NSString *) whichGCC {
  return [self which: @"gcc"];
}

+ (void) openWithXcode: (NSString *) path {
  [[NSWorkspace sharedWorkspace] openFile: path withApplication: @"Xcode" andDeactivate: YES];
}

+ (void) openWithTextEdit: (NSString *) path {
  [[NSWorkspace sharedWorkspace] openFile: path withApplication: @"TextEdit" andDeactivate: YES];
}

+ (void) openWithTextMate: (NSString *) path {
  [[NSWorkspace sharedWorkspace] openFile: path withApplication: @"TextMate" andDeactivate: YES];
}

- (void) openWithTextMate {
  [self.class openWithTextMate: self.sourcePath];
}

- (void) openWithXcode {
  [self.class openWithXcode: self.sourcePath];
}

- (void) openWithTextEdit {
  [self.class openWithTextEdit: self.sourcePath];
}

+ (NSMutableArray *) argumentsWithOutputPath: (NSString *) outputPath inputPath: (NSString *) inputPath frameworks: (NSArray *) frameworks {
  // TODO: check if nil
  NSMutableArray *arguments = [NSMutableArray array];
  [arguments addObject: @"-bundle"];
  for (NSString *framework in frameworks) {
    [arguments addObject: @"-framework"];
    [arguments addObject: framework];
  }
  [arguments addObject: inputPath];
  [arguments addObject: @"-o"];
  [arguments addObject: outputPath];
  return arguments;
}

+ (NSArray *) gccCompileWithOutputPath: (NSString *) outputPath inputPath: (NSString *) inputPath frameworks: (NSArray *) frameworks {
  NSString *command = [self whichGCC];
  NSMutableArray *arguments = [self argumentsWithOutputPath: outputPath inputPath: inputPath frameworks: frameworks];
  return [self executeCommand: command withArguments: arguments];
}

+ (NSFileHandle *) temporaryFileHandleWithBasename: (NSString *) basename extension: (NSString *) extension closeOnDealloc: (BOOL) closeOnDealloc {
  return [self temporaryFileHandleWithTemplate: [NSString stringWithFormat: @"%@-XXXXXX.%@", basename, extension] closeOnDealloc: closeOnDealloc];
}

+ (NSFileHandle *) temporaryFileHandleWithTemplate: (NSString *) template closeOnDealloc: (BOOL) closeOnDealloc {
  NSString *temporaryFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent: template];
  const char *temporaryFileTemplateCString = [temporaryFileTemplate fileSystemRepresentation];
  char *temporaryFileNameCString = (char *)malloc(strlen(temporaryFileTemplateCString) + 1);
  strcpy(temporaryFileNameCString, temporaryFileTemplateCString);
  int fileDescriptor = mkstemp(temporaryFileNameCString);
  if (fileDescriptor == -1) {
    return nil;
  } else {
    // NSString *temporaryFileName = [[NSFileManager defaultManager] stringWithFileSystemRepresentation: temporaryFileNameCString
    // return temporaryFileName;
    
    free(temporaryFileNameCString);
    
    return [[NSFileHandle alloc] initWithFileDescriptor: fileDescriptor
                                         closeOnDealloc: closeOnDealloc];
    
  }
}

- (void) dealloc {
  [log release];
  [onDeallocItemsToRemove release];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  // TODO: only when temporary? What about crash?
  // [fileManager removeItemAtPath: [self sourcePath] error: nil];
  for (NSString *path in onDeallocItemsToRemove)
    [fileManager removeItemAtPath: path error: nil];
  
  [backgroundThread cancel];
  
  [super dealloc];
}

@end
