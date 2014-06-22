//
//  MTAAppDelegate.m
//  MTA Launcher
//
//  Created by Qais Patankar on 17/06/2014.
//  Copyright (c) 2014 multitheftauto. All rights reserved.
//

#import "MTAAppDelegate.h"
#import "MTAPathFinder.h"

@implementation MTAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    bool forcePath = false;
    NSArray *args = [NSProcessInfo.processInfo arguments];
    if (args.count >= 2){
        if ([args[1] isEqual: @"forcepathselect"]){
            forcePath = true;
        }
    }
    
    // This line is required to force the window to show
    [self.window makeKeyAndOrderFront:self];

    self.pathFinder = [MTAPathFinder new];
    [self.pathFinder findPaths:self force:forcePath];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

// Quit the magic program
- (IBAction) cancelButton:(id) sender {
    // Clean up - do we need to delete an existing download?
    
    // Close the app
    [NSApp terminate:self];

}

- (IBAction) actionButton:(id) sender {
    [self.pathFinder manuallySelectPath];
}

- (void) logMessage:(NSString *) message {
    
    NSString* oldString = self.consoleText.string;
    NSString* appendedMessage = [message stringByAppendingString:@"\n"];
    self.consoleText.string = [oldString stringByAppendingString:appendedMessage];
}

- (void) updateStatusBar:(NSString *)message progress:(double)progress {
    
    self.statusMessage.stringValue = message;
    if (![message isEqualToString:@""]) {
        [self logMessage:message];
    }

    
    NSProgressIndicator* progressIndicator = self.progressIndicator;
    
    // Progress is -1, so it's indeterminate
    if (progress == -1){
        progressIndicator.indeterminate = true;
    }
    else {
        // Progress is not -1, so set the progress
        progressIndicator.indeterminate = false;
        self.progressIndicator.doubleValue = progress;
    }
    
    [progressIndicator startAnimation:progressIndicator];
}

- (void) checkUpdater {
    // Call updater

}
@end
