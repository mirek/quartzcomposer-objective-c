#import "ObjectiveCProviderPlugIn.h"

@implementation ObjectiveCProviderPlugIn

+ (NSString *) defaultSourceName {
  return @"provier";
}

+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeNone;
}

@end
