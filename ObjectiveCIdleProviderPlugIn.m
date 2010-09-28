#import "ObjectiveCIdleProviderPlugIn.h"

@implementation ObjectiveCIdleProviderPlugIn

+ (NSString *) defaultSourceName {
  return @"provider";
}

+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeIdle;
}

@end
