#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ObjectiveCAbstractPlugIn.h"

@class ObjectiveCAbstractPlugIn;

@interface ObjectiveCPlugInViewController : QCPlugInViewController {
  
  // List of frameworks required to compile the snippet
  NSMutableArray *frameworks;
  
  NSComboBox *openWithComboBox;
  
  ObjectiveCAbstractPlugIn *plugIn;
}

@property (retain) NSMutableArray *frameworks;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSComboBox *openWithComboBox;

- (IBAction) openWithSelectedEditor;

@end
