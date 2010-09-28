//
//  SettingsTestApplicationDelegate.h
//  Objective-C
//
//  Created by Mirek Rusin on 06/03/2010.
//  Copyright 2010 Inteliv Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SettingsTestApplicationDelegate : NSObject <NSApplicationDelegate> {
  NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
