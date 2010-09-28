#import "ObjectiveCConsumerPlugIn.h"

@implementation ObjectiveCConsumerPlugIn

+ (NSString *) defaultSourceName {
  return @"consumer";
}

+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeConsumer;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeNone;
}

@end
