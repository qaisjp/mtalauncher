//
//  MTAAppDelegate.h
//  MTA Launcher
//
//  Created by Qais Patankar on 17/06/2014.
//  Copyright (c) 2014 multitheftauto. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MTAPathFinder.h"

@class MTAConsoleView;

@interface MTAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction) cancelButton:(id) sender;
- (IBAction) actionButton:(id) sender;

- (void) logMessage:(NSString*) message;
- (void) updateStatusBar:(NSString*)message progress:(double)progress;
- (void) checkUpdater;

@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *statusMessage;
@property (assign) IBOutlet NSTextView *consoleText;
@property (strong) MTAPathFinder *pathFinder;
@property (weak) IBOutlet NSButton *actionBtn;

@end
