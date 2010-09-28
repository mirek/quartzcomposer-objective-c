#import "NSMutableDictionary-UnlessNilSetObjectForKey.h"

@implementation NSMutableDictionary (UnlessNilSetObjectForKey)

- (void) unlessNilSetObject: (id) anObject forKey: (id) aKey {
  if (anObject != nil)
    [self setObject: anObject forKey: aKey];
}

@end
