#include <Foundation/Foundation.h>
#include <Quartz/Quartz.h>

// Main execute function
BOOL execute(NSDictionary *inputs, NSMutableDictionary *outputs) {
  // Get inputs, ignore execution if nil
  NSString *inputString = [inputs objectForKey: @"inputString"];
  if (inputString == nil)
    return NO; // Returning NO will prevent patch execution for the current frame
  
  // Processing
  NSString *outputString = [inputString stringByAppendingString: @"... Hello World!!!"];
  
  // Set outputs
  [outputs setObject: outputString forKey: @"outputString"];
  
  // All good, return YES to execute frame for this patch
  return YES;
}

// This main(...) function is optional, you can remove it.
// It's here just for testing outside Quartz Composer from Terminal.
// In order to test - save this file as "hello_world.m", then run & compile with:
//
//   gcc -framework Foundation -framework Quartz hello_world.m -o test && ./test
//
int main(int argc, char* argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  
  NSMutableDictionary *inputs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"Objective-C", @"inputString",
                                 nil];
  
  NSMutableDictionary *outputs = [NSMutableDictionary dictionary];
  
  if (execute(inputs, outputs)) {
    NSLog(@"OK\n%@", outputs);
  } else {
    NSLog(@"FAIL");
  }
  
  [pool drain];
  return 0;
}

/* OBJECTIVE-C YAML SNIPPET VERSION 1.0

name:      Hello World
summary:   Simple Hello World example, single text input and output.
copyright: © 2010 Mirek Rusin <mirek [at] me [dot] com> - Public Domain
description: |-
  Hello World Objective-C snippet for Quartz Composer example.
  
  To run this snippet you will need "Objective-C Patch" available from:
  http://quartzcomposer.com/plugins
  
  Available types for inputs and outputs:
  * Boolean
  * Index
  * Number
  * String
  * Color
  * Image
  * Structure

frameworks:
 - Foundation
 - Quartz

inputs:
  inputString:
    type:        String
    name:        Input string
    description: Any input string

outputs:
  outputString:
    type:        String
    name:        Output string
    description: Input string with "... Hello World!"

changelog:
  - date:        2010-02-27
    description: Updated documentation
    
  - date:        2010-02-26
    description: Created

*/
