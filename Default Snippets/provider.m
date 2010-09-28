// # Quartz Composer Objective-C Snippet
//
// type:      Provider
// time_mode: Idle
// variant:   Execute
//
// version:   0.0.20100307
// name:      Hello World
// summary:   Simple text input and text output example.
// copyright: © 2010 Mirek Rusin - Public Domain
// authors:
//   - Mirek Rusin <mirek [at] me [dot] com>
// description: |-
//   Hello World Objective-C Provider snippet for Quartz Composer.
//  
//   To run this snippet you will need "Objective-C PlugIn" available from:
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
//   Have fun!
//   Mirek Rusin
//   
// frameworks:
//   - Foundation
//   - Quartz
//   
// inputs:
//   mouseX:
//     type: Number
//     name: Mouse X Position
//   
//   mouseY:
//     type: Number
//     name: Mouse Y Position
//   
// outputs:
//   points:
//     type: Array
//     name: Points
//   
// changelog:
//   - date:        2010-03-02
//     description: Created
//

#include <Foundation/Foundation.h>
#include <Quartz/Quartz.h>

BOOL execute(NSDictionary *inputs, NSDictionary **outputs) {
  int i, j, sx, sy;
  double x, y, vx, vy, dx, dy, r;
  double slowDown = 0.0001;
  NSDictionary *vertex;
  NSDictionary *velocity;
  NSNumber *key;
  
  if (![inputs objectForKey: @"mouseX"] || ![inputs objectForKey: @"mouseY"])
    return NO;
  
  static int n = 1000;
  int newN = n;
  if ([inputs objectForKey: @"n"])
    newN = [[inputs objectForKey: @"n"] integerValue];
  
  static NSMutableDictionary *vertices = nil;
  static NSMutableDictionary *velocities = nil;
  
  if (vertices == nil || newN != n) {
    n = newN;
    vertices = [[NSMutableDictionary alloc] init];
    velocities = [[NSMutableDictionary alloc] init];
    for (i = 0; i < n; i++) {
      key = [NSNumber numberWithInteger: i];
      vertex = [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithDouble: (arc4random() % 1000) / 1000.0 - 0.5], @"0",
                [NSNumber numberWithDouble: (arc4random() % 1000) / 1000.0 - 0.5], @"1",
                [NSNumber numberWithDouble: 0.0], @"2",
                nil];
      velocity = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSNumber numberWithDouble: 0.0], @"0",
                  [NSNumber numberWithDouble: 0.0], @"1",
                  [NSNumber numberWithDouble: 0.0], @"2",
                  nil];
      [vertices setObject: vertex forKey: key];
      [velocities setObject: velocity forKey: key];
    }
  }
  
  double mouseX = [[inputs objectForKey: @"mouseX"] doubleValue];
  double mouseY = [[inputs objectForKey: @"mouseY"] doubleValue];
  
  for (i = 0; i < n; i++) {
    key = [NSNumber numberWithInteger: i];
    vertex = [vertices objectForKey: key];
    velocity = [velocities objectForKey: key];
    x = [[vertex objectForKey: @"0"] doubleValue];
    y = [[vertex objectForKey: @"1"] doubleValue];
    vx = [[velocity objectForKey: @"0"] doubleValue];
    vy = [[velocity objectForKey: @"1"] doubleValue];
    dx = mouseX - x;
    dy = mouseY - y;
    sx = dx > 0.0 ? -1 : 1;
    sy = dy > 0.0 ? -1 : 1;
    r = sqrt(dx*dx + dy*dy);
    vx += (1.0 / (r*r)) * slowDown * sx;
    vy += (1.0 / (r*r)) * slowDown * sy;
    x += vx;
    y += vy;
    vertex = [NSMutableDictionary dictionaryWithObjectsAndKeys:
              [NSNumber numberWithDouble: x], @"0",
              [NSNumber numberWithDouble: y], @"1",
              [NSNumber numberWithDouble: 0.0], @"2",
              nil];
    velocity = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithDouble: vx], @"0",
                [NSNumber numberWithDouble: vy], @"1",
                [NSNumber numberWithDouble: 0.0], @"2",
                nil];
    [vertices setObject: vertex forKey: key];
    [velocities setObject: velocity forKey: key];
  }
  
  // Set outputs (via double indirection)
  // if (*outputs)
  //   [*outputs release];
  *outputs = [[NSDictionary dictionaryWithObjectsAndKeys:
               vertices,   @"vertices",
               velocities, @"velocities",
               nil] retain];
  
  return YES;
}

