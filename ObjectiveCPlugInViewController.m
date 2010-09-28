#import "ObjectiveCPlugInViewController.h"

@implementation ObjectiveCPlugInViewController

@synthesize openWithComboBox;
@synthesize frameworks;

- (id) initWithPlugIn: (QCPlugIn *) plugIn_ viewNibName: (NSString *) viewNibName {
  if (self = [super initWithPlugIn: plugIn_ viewNibName: viewNibName]) {
    self.frameworks = [NSMutableArray arrayWithObjects:
                       [NSMutableDictionary dictionaryWithObjectsAndKeys: @"Foundation", @"name", nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys: @"Cocoa", @"name", nil], nil];
    
    // TODO: read from defaults
    [self.openWithComboBox selectItemAtIndex: 0];
  }
  return self;
}

- (void) setWindow: (NSWindow *) value {
  if ([super respondsToSelector: @selector(setWindow:)])
    [super performSelector: @selector(setWindow:) withObject: value];
}

// HACK: Look out, changes on every invocation
- (NSWindow *) window {
  for (id window_ in [[NSApplication sharedApplication] windows])
    if ([[window_ className] isEqualToString: @"GFInspectorWindow"])
      return window_;
  return nil;
}

- (IBAction) openWithSelectedEditor {
  NSString *name = [self.openWithComboBox objectValueOfSelectedItem];
  if ([name isEqualToString: @"TextMate"])
    [self.plugIn.onTheFly openWithTextMate];
  else if ([name isEqualToString: @"Xcode"])
    [self.plugIn.onTheFly openWithXcode];
  else if ([name isEqualToString: @"TextEdit"])
    [self.plugIn.onTheFly openWithTextEdit];
  else
    return; // pass
}


@end
