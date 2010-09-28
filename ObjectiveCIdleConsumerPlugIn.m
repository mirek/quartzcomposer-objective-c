#import "ObjectiveCIdleConsumerPlugIn.h"

@implementation ObjectiveCIdleConsumerPlugIn

+ (NSString *) defaultSourceName {
  return @"consumer";
}

+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeIdle;
}

@end
