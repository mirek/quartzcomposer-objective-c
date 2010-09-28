//
//  ObjectiveCProcessorPlugIn.m
//  Objective-C
//
//  Created by Mirek Rusin on 28/02/2010.
//  Copyright 2010 Inteliv Ltd. All rights reserved.
//

#import "ObjectiveCProcessorPlugIn.h"

@implementation ObjectiveCProcessorPlugIn

+ (NSString *) defaultSourceName {
  return @"processor";
}

+ (QCPlugInExecutionMode) executionMode {
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode {
	return kQCPlugInTimeModeNone;
}

@end
