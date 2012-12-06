#import "ObjectiveCPlugInViewController.h"

@implementation ObjectiveCPlugInViewController

@synthesize frameworks;
@synthesize statusImageView;

- (id) initWithPlugIn: (QCPlugIn *) plugIn_ viewNibName: (NSString *) viewNibName {
  if (self = [super initWithPlugIn: plugIn_ viewNibName: viewNibName]) {
    self.frameworks = [NSMutableArray arrayWithObjects:
                       [NSMutableDictionary dictionaryWithObjectsAndKeys: @"Foundation", @"name", nil],
                       [NSMutableDictionary dictionaryWithObjectsAndKeys: @"Cocoa", @"name", nil], nil];
    
    // Observe for plugIn state changes and update status image
    [self.plugIn addObserver: self
                  forKeyPath: @"status"
                     options: NO
                     context: NULL];
  }
  return self;
}

- (void) dealloc {
  [self.plugIn removeObserver: self forKeyPath: @"status"];
  [super dealloc];
}

- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *)context
{
  if (object == self.plugIn) {
    if ([keyPath isEqualToString: @"status"]) {
      if ([object status]) {
        NSString *baseName = [NSString stringWithFormat: @"status-%@", [object status]];
        NSString *fileName = [[NSBundle bundleForClass: [self class]] pathForResource: baseName ofType: @"png"];
        NSImage *image = [[NSImage alloc] initByReferencingFile: fileName];
        self.statusImageView.image = image;
        [image release];
      }
    }
  }
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

#pragma mark Actions

- (void) openWithXcode: (id) sender {
  [self.plugIn.onTheFly openWithXcode];
}

- (void) checkForUpdates: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://quartzcomposer.com/plugins/34-objective-c"]];
}

- (void) recompile: (id) sender {
  [self.plugIn recompileIfNecessaryAndReloadDynamicLibrary];
}

- (void) import: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://quartzcomposer.com/snippets"]];
}

- (void) share: (id) sender {
  [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: @"http://quartzcomposer.com/my/snippets"]];
}

- (void) clear: (id) sender {
}

@end
