#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import "ObjectiveCAbstractPlugIn.h"

@class ObjectiveCAbstractPlugIn;

@interface ObjectiveCPlugInViewController : QCPlugInViewController {
  
  // List of frameworks required to compile the snippet
  NSMutableArray *frameworks;
  
  ObjectiveCAbstractPlugIn *plugIn;
  
  NSImageView *statusImageView;
  
  //NSError *currentError;
}

@property (readonly) ObjectiveCAbstractPlugIn *plugIn;
@property (retain) NSMutableArray *frameworks;
@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) IBOutlet NSImageView *statusImageView;
//@property (retain, nonatomic) NSError *currentError;

- (IBAction) openWithXcode: (id) sender;
- (IBAction) checkForUpdates: (id) sender;
- (IBAction) recompile: (id) sender;
- (IBAction) import: (id) sender;
- (IBAction) share: (id) sender;
- (IBAction) clear: (id) sender;

@end
