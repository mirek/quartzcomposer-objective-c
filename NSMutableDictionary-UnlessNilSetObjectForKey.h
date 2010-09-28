#import <Cocoa/Cocoa.h>

@interface NSMutableDictionary (UnlessNilSetObjectForKey)

- (void) unlessNilSetObject: (id) anObject forKey: (id) aKey;

@end
