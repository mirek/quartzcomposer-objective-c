// # Quartz Composer Objective-C Snippet
//
// type:      Consumer
// time_mode: None
// variant:   ExtendedExecuteFunctionWithPlugIn
//
// version:   0.0.20100307
// name:      Hello World
// summary:   Simple text input and text output example
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
//   - ApplicationServices
//   
// inputs:
//   n:
//     type: Index
//     name: Particles
//   color:
//     type: Color
//     name: Color
//
// outputs:
//   fake:
//     type: String
//     name: Fake placeholder
//   
// changelog:
//   - date:        2010-03-02
//     description: Created
//

#include <Foundation/Foundation.h>
#include <ApplicationServices/ApplicationServices.h>
#include <Quartz/Quartz.h>
#import <OpenGL/CGLMacro.h>

BOOL execute(QCPlugIn *plugIn, id<QCPlugInContext> context, NSTimeInterval time, NSDictionary *arguments, NSDictionary *inputs, NSDictionary **outputs) {
  
  GLint saveMode;
  GLenum error;
  
  // Get inputs, ignore execution if nil
  NSNumber *inputN = [inputs objectForKey: @"n"];
  if (inputN == nil)
    inputN = [NSNumber numberWithInteger: 100];

  CGColorRef inputColor = NULL; //(CGColorRef)[inputs objectForKey: @"color"];
  if (inputColor == NULL)
    inputColor = CGColorCreateGenericRGB(0.5, 0.5, 0.5, 0.5);

  CGLContextObj cgl_ctx = [context CGLContextObj];
  if (cgl_ctx == NULL) {
    [context logMessage: @"cgl_ctx is NULL"];
    return NO;
  }

  // Save and set the modelview matrix.
  glGetIntegerv(GL_MATRIX_MODE, &saveMode);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();

  const CGFloat *inputColorComponents = CGColorGetComponents(inputColor);
  glColor4f(inputColorComponents[0], inputColorComponents[1], inputColorComponents[2], inputColorComponents[3]);
  
  int n = 100;
  GLfloat *vertices = (GLfloat *)calloc(n, sizeof(GLfloat) * 2);
  
  int i = 0;
  for (i = 0; i < n; i += 2) {
    vertices[i + 0] = ((arc4random() % 100) / 100.0) - 0.5;
    vertices[i + 1] = ((arc4random() % 100) / 100.0) - 0.5;
  }
  
  glVertexPointer(2, GL_FLOAT, 0, vertices);
  glEnableClientState(GL_VERTEX_ARRAY);
  glDrawArrays(GL_POINTS, 0, n);
  glDisableClientState(GL_VERTEX_ARRAY);

  free(vertices);

  // Restore the modelview matrix.
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();
  glMatrixMode(saveMode);

  // Check for OpenGL errors and log them if there are errors.
  if (error = glGetError())
    [context logMessage: @"OpenGL error %04X", error];
  
  return (error ? NO : YES);
}
