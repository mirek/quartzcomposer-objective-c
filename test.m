#include "OnTheFly.h"

int main(int argc, char* argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  //NSArray *frameworks = [NSArray arrayWithObjects: @"Foundation", @"Quartz", nil];
  //NSLog(@"%@", [OnTheFly argumentsWithPath: @"my.m" frameworks: frameworks]);
  //NSLog(@"'%@'", [OnTheFly whichGCC]);
  
  //OnTheFly *onTheFly = [[OnTheFly alloc] initWithSourcePath: @"/Users/Mirek/Projects/quartzcomposer/objc/d.m"];
  OnTheFly *onTheFly = [[OnTheFly alloc] initWithSourceString: [NSString stringWithContentsOfFile: @"objective-c-processor-snippet-1.0.m" encoding: NSUTF8StringEncoding error: nil]];
  
//  OnTheFlyAssembler *assembler = [[OnTheFlyAssembler alloc] init];
//  NSString *grammar = [NSString stringWithContentsOfFile: @"objective-c-snippet-1.0.grammar" encoding: NSUTF8StringEncoding error: nil];
  
  //NSLog(@" using grammar %@", grammar);
  
//  PKParser *parser = [[PKParserFactory factory] parserFromGrammar: grammar assembler: assembler];
//  [parser parse: [onTheFly sourceString]];
  
//  PKTokenizer *t = [PKTokenizer tokenizerWithString: [onTheFly sourceString]];
//  [t setTokenizerState:t.symbolState from:'/' to:'/'];
//  PKToken *eof = [PKToken EOFToken];
//  PKToken *tok = nil;
//  while ((tok = [t nextToken]) != eof) {
//    NSLog(@"(%@) (%.1f) : %@", 
//          tok.stringValue, tok.floatValue, [tok debugDescription]);
//  }
  
  //NSLog(@"%@", [onTheFly sourceString]);
  //NSLog(@"%@", [onTheFly mainCommentString]);
//  NSLog(@"description: %@", [onTheFly description]);
//  NSLog(@"sourceLastModificationDate: %@", [onTheFly sourceLastModificationDate]);
//  NSLog(@"dynamicLibraryLastModificationDate: %@", [onTheFly dynamicLibraryLastModificationDate]);
//NSLog(@"compare: %i", [onTheFly compareSourceAndDynamicLibraryFileModificationDate]);

  
//  NSLog(@" * dynlib %@", [onTheFly dynamicLibraryPath]);
//  NSLog(@" * compile ", [onTheFly recompileIfNecessary]);
  NSLog(@" * reload %i", [onTheFly reloadDynamicLibraryIfNecessary]);
  
  //NSLog(@" * main comment %@", [onTheFly mainCommentString]);
  
  //[OnTheFly openWithTextMate: [onTheFly sourcePath]];
  
  NSDictionary *inputs = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Quartz Composer", @"string",
                          nil];
  
  NSDictionary *outputs = nil;
  
  while (TRUE) {

    if ([onTheFly canExecute]) {
      if ([onTheFly executeWithPlugIn: nil context: nil atTime: 0 withArguments: nil inputs: inputs outputs: &outputs]) {
        NSLog(@"OK\n%@", outputs);
      } else {
        NSLog(@"FAIL");
        [onTheFly dumpLog];
      }
    } else {
      NSLog(@"cant execute now");
    }
    
    if (![onTheFly isLogEmpty]) {
      [onTheFly dumpLog];
      [onTheFly clearLog];
    }
    
    [onTheFly recompileIfNecessary];
    [NSThread sleepForTimeInterval: 5.0];
  }
  
  NSLog(@"Fin.");
  
  [onTheFly release];
  
  [pool drain];
  return 0;
}