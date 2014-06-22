//
//  MTAPathFinder.h
//  MTA Launcher
//
//  Created by Qais Patankar on 18/06/2014.
//  Copyright (c) 2014 multitheftauto. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTAAppDelegate;

@interface MTAPathFinder : NSObject

- (void) findPaths:(MTAAppDelegate*)app force:(BOOL)forcepathselect;
- (void) manuallySelectPath;
- (bool) checkIfValidPath:(NSURL*)url;
- (void) finishedPathFinding:(NSURL*)url;
- (void) saveURLToUserDefaults:(NSURL*)url;
- (void) makeSymlinks:(NSURL*)gameURL;

@property (strong) MTAAppDelegate* app     ;
@property (assign) BOOL            steamExe;
@end
