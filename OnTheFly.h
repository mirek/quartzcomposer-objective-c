#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <dlfcn.h>
#import "RegexKitLite.h"
#import "YAMLSerialization.h"

typedef BOOL (*BasicExecuteFunction)(NSDictionary *inputs, NSDictionary **outputs);
typedef BOOL (*ExtendedExecuteFunction)(id<QCPlugInContext> context, NSTimeInterval time, NSDictionary *arguments, NSDictionary *inputs, NSDictionary **outputs);
typedef BOOL (*ExtendedExecuteFunctionWithPlugIn)(QCPlugIn *plugIn, id<QCPlugInContext> context, NSTimeInterval time, NSDictionary *arguments, NSDictionary *inputs, NSDictionary **outputs);

// Variants for execute function as enums so we can use fast switch statements
typedef enum {
  kOnTheFlyVariantUnknown,
  kOnTheFlyVariantBasicExecuteFunction,
  kOnTheFlyVariantExtendedExecuteFunction,
  kOnTheFlyVariantExtendedExecuteFunctionWithPlugIn
} OnTheFlyVariant;

typedef enum {
  kOnTheFlyStateInitialized,
  kOnTheFlyStateSourceSet,
  kOnTheFlyStateCommentMissing,
  kOnTheFlyStateCommentFound,
  kOnTheFlyStateCommentSectionsInvalid,
  kOnTheFlyStateCommentSectionsValid,
  kOnTheFlyStateCompiling,
  kOnTheFlyStateCompileError,
  kOnTheFlyStateReady
} OnTheFlyState;

@interface OnTheFly : NSObject {
  
  // Dynamic library
  void *dynamicLibrary;
  
  OnTheFlyVariant variant;
  OnTheFlyState state;
  
  void *executeFunction;
  NSString *dynamicLibraryPath;
  
  // Source
  NSString *sourceString;
  NSString *sourcePath;
  
  // Meta (main comment cache)
  NSMutableDictionary *meta;

  NSMutableArray *log;
  
  NSMutableArray *onDeallocItemsToRemove;
  
  NSThread *backgroundThread;
  
  BOOL canExecute;
  
  NSDate *lastProcessedSourceTimestamp;
}

@property (retain) NSMutableArray *log;
@property (retain) NSString *dynamicLibraryPath;
@property (retain) NSString *sourceString;
@property (retain) NSString *sourcePath;
@property (retain) NSMutableArray *onDeallocItemsToRemove;
@property (retain) NSThread *backgroundThread;
@property (retain) NSDate *lastProcessedSourceTimestamp;

@property (assign) OnTheFlyState state;

- (OnTheFly *) init;
- (OnTheFly *) initWithSourceString: (NSString *) sourceString;
//- (OnTheFly *) initWithSourcePath: (NSString *) sourcePath;
//- (NSString *) stringFromSourcePath;

- (NSString *) sourceString;
- (NSString *) sourcePath;

- (void) backgroundThreadStart;
- (void) backgroundThreadCancel;
- (void) backgroundThreadExecuteWithOptions: (NSDictionary *) options;

// Logging
- (void) logWithType: (NSString *) type message: (NSString *) message;
- (void) logWithErrorObject: (NSError *) error;
- (void) logError: (NSString *) message;
- (void) logWarning: (NSString *) message;
- (void) logInfo: (NSString *) message;
//- (NSString *) logEntriesJoinedByString: (NSString *) separator;
//- (NSString *) logEntriesWithType: (NSString *) type joinedByString: (NSString *) separator;
//- (void) dumpLog;
//- (NSString *) dumpLogAsString;
//- (NSString *) dumpLogAsStringAndClear;
- (void) clearLog;
- (BOOL) isLogEmpty;

// Smart source synchronization
//- (BOOL) synchronizeSource;

//
// Main comment
//
- (NSString *) mainCommentString;
- (NSDictionary *) mainCommentAttributes;
- (id) mainCommentAttributeForKey: (NSString *) key;
- (NSString *) variant;
- (NSString *) type;
- (NSString *) timeMode;
- (NSArray *) frameworks;
- (NSString *) summary;
- (NSString *) copyright;
- (NSString *) description;
- (NSDictionary *) inputs;
- (NSDictionary *) outputs;

- (NSDate *) sourceLastModificationDate;
- (NSDate *) dynamicLibraryLastModificationDate;

- (BOOL) isSourceFileNewerThanDynamicLibraryFile;
- (NSTestComparisonOperation) compareSourceAndDynamicLibraryFileModificationDate;
- (BOOL) saveSourceToFile;
- (BOOL) loadSourceFromFile;

+ (OnTheFlyVariant) variantWithString: (NSString *) variantString;

//
// Dynamic library
//
- (BOOL) canExecute;
- (BOOL) reloadDynamicLibraryIfNecessary;
- (BOOL) reloadDynamicLibrary;
- (BOOL) loadDynamicLibrary;
- (void) unloadDynamicLibrary;
- (BOOL) isDynamicLibraryLoaded;
- (NSString *) dynamicLibraryPath;
- (NSArray *) recompileIfNecessary;
- (NSArray *) recompileIfNecessaryAndReloadDynamicLibrary;
- (BOOL) loadDynamicLibraryIfNotLoaded;

//
// Compiling
//
- (BOOL) didCompileForCurrentSource;
- (BOOL) needsRecompiling;

- (BOOL) executeWithPlugIn: (QCPlugIn *) plugIn
                   context: (id<QCPlugInContext>) context
                    atTime: (NSTimeInterval) time
             withArguments: (NSDictionary *) arguments
                    inputs: (NSDictionary *) inputs
                   outputs: (NSDictionary **) outputs;

- (void) openWithTextMate;
- (void) openWithXcode;
- (void) openWithTextEdit;

// Class methods

+ (void) openWithTextMate: (NSString *) path;
+ (void) openWithXcode: (NSString *) path;

+ (NSString *) dynamicLibraryPathWithSourcePath: (NSString *) sourcePath;
+ (NSString *) generateTemporarySourcePath;

+ (NSString *) whichGCC;
+ (NSString *) which: (NSString *) command;
+ (NSString *) outputWithCommand: (NSString *) command
                stripWhitespaces: (BOOL) stripWhitespaces;

+ (NSString  *) outputWithCommand: (NSString *) command
                        arguments: (NSArray *) arguments
                 stripWhitespaces: (BOOL) stripWhitespaces;

+ (NSArray *) executeCommand: (NSString *) command
               withArguments: (NSArray *) arguments;

// Returns array of [stdout, stderr] as strings
+ (NSArray *) executeCommand: (NSString *) command
               withArguments: (NSArray *) arguments
         standardInputString: (NSString *) standardInputString;

+ (NSMutableArray *) argumentsWithOutputPath: (NSString *) outputPath
                                   inputPath: (NSString *) inputPath 
                                  frameworks: (NSArray *) frameworks;

+ (NSArray *) gccCompileWithOutputPath: (NSString *) outputPath 
                             inputPath: (NSString *) inputPath
                            frameworks: (NSArray *) frameworks;


+ (NSFileHandle *) temporaryFileHandleWithBasename: (NSString *) basename
                                         extension: (NSString *) extension
                                    closeOnDealloc: (BOOL) closeOnDealloc;

+ (NSFileHandle *) temporaryFileHandleWithTemplate: (NSString *) template_
                                    closeOnDealloc: (BOOL) closeOnDealloc;

@end
