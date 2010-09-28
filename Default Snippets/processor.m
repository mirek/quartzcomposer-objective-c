// # Quartz Composer Objective-C Snippet
//
// type:      Processor
// variant:   Execute
//
// version:   0.0.20100921
// name:      Hello World
// summary:   Simple Objective-C Processor example
// copyright: © 2010 Mirek Rusin, Released under MIT License
// authors:
//   - Mirek Rusin <mirek [at] me [dot] com>
// description: |-
//   Hello World Objective-C Processor snippet for Quartz Composer.
//  
//   To run this snippet you will need "Objective-C PlugIn" available at:
//   http://quartzcomposer.com/plugins
//  
//   Available types for inputs and outputs:
//   * Boolean
//   * Index
//   * Number
//   * String
//   * Color
//   * Image
//   * Structure
//   
// frameworks:
//   - Foundation
//   - Quartz
//   
// inputs:
//
//   string:
//     type: String
//     name: Input string
//
//   at:
//     type: String
//     name: Second input string
//   
// outputs:
//   output:
//     type: String
//     name: Output string
//   
// changelog:
//
//   - date:        2010-09-21
//     description: Updated to support
//
//   - date:        2010-03-02
//     description: Created
//

#include <Foundation/Foundation.h>
#include <Quartz/Quartz.h>

// Main execute function
BOOL execute(NSDictionary *inputs, NSDictionary **outputs) {

  // Get inputs, key names relate to inputs defined above in YAML comment section
  NSString *inputString = [inputs objectForKey: @"string"];
  NSString *inputAt = [inputs objectForKey: @"at"];

  // If any of the inputs is not defined, bail the execution
  if (inputString == nil || inputAt == nil)
    return NO;
    
  // Processing
  NSString *outputString = [NSString stringWithFormat: @"%@ at %@", inputString, inputAt];
  
  // Set outputs (note double indirection for outputs argument)
  *outputs = [NSDictionary dictionaryWithObjectsAndKeys:
              outputString, @"output",
              nil];
  
  return YES;
}

// You can save this file and test by compiling and running in the console without Quartz Composer (for testing):
//
//   gcc -framework Foundation -framework Quartz test.m -o test && ./test
//
int main(int argc, char* argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Hello World", @"string",
                          @"whatever", @"at",
                          nil];

  NSDictionary *outputs = nil;

  if (execute(inputs, &outputs)) {
    NSLog(@"OK\n%@", outputs);
  } else {
    NSLog(@"FAIL");
  }

  [pool drain];

  return 0;
}
