//
//  MTAPathFinder.m
//  MTA Launcher
//
//  Created by Qais Patankar on 18/06/2014.
//  Copyright (c) 2014 multitheftauto. All rights reserved.
//

#import "MTAPathFinder.h"
#import "MTAAppDelegate.h"
@implementation MTAPathFinder

- (void) findPaths: (MTAAppDelegate*)app force:(BOOL)forcepathselect {
    [app logMessage:@"Finding paths.."];
    self.app = app;
    
    if (forcepathselect) {
        [app logMessage:@"Forcing path selection..."];
    } else {
        [app updateStatusBar:@"Checking if a path is saved..." progress:-1];

        // Get the gamepath
        NSData* data = [NSUserDefaults.standardUserDefaults dataForKey:@"com.multitheftauto.gtapath"];

        BOOL     stale;
        NSError* error;
        
        NSURL* gamePath = [NSURL URLByResolvingBookmarkData:data options:NSURLBookmarkResolutionWithoutUI relativeToURL:NULL bookmarkDataIsStale:&stale error:&error];
        
        if (!error && gamePath && [self checkIfValidPath:gamePath]) {
            if (stale) {
                // It's old, redo symlinks and resave.
                [self finishedPathFinding:gamePath];
                return;
            }
        
            [app logMessage:[NSString stringWithFormat:@"Valid gamePath found.. %@", gamePath.absoluteString]];
            
            // It is valid, meaning all symbolic links have already been set up
            [app checkUpdater];
        
            return;
        }
        else {
            [app logMessage:@"No (valid) path saved!"];
        }
        

        // Right so we've checked if it's saved.
        // It's not saved.
        // So let's check the expected locations.
        NSURL* url;
        NSString* basePath = @"file://";
        
        
        // First check Steam, because it's sort of a special issue here.
        // This is because the exe is named "gta-sa.exe" instead of
        // "gta_sa.exe", so we need to set a special variable.
        self.steamExe = true;
        NSString* steamPath = @"~/Library/Application%20Support/Steam/SteamApps/common/grand%20theft%20auto%20-%20san%20andreas".stringByExpandingTildeInPath;
    
        url = [NSURL URLWithString:[basePath stringByAppendingString:steamPath]];
        if ([self checkIfValidPath:url]){
            [self finishedPathFinding:url];
            return;
        }
        self.steamExe = false; // we're not playing with a steam install anymore
        
        
        NSString* homeAppPath = @"~/Applications".stringByExpandingTildeInPath;
        NSURL* homeAppURL = [NSURL URLWithString:[basePath stringByAppendingString:homeAppPath]];
        NSURL* mainAppURL = [NSURL URLWithString:@"file:///Applications"];
        
        // Note how we've hardcoded "2" objects in the for loop below
        NSArray* filenames = [NSArray arrayWithObjects:
                              @"GTA%20San%20Andreas.app",
                              @"Grand%20Theft%20Auto%20-%20San%20Andreas.app",
                              nil];
        
        // Loop each path and find it
        for (NSUInteger i = 0; i < 2; i++) {
            url = [homeAppURL URLByAppendingPathComponent:filenames[i]];
            if ([self checkIfValidPath:url]){
                [self finishedPathFinding:url];
                return;
            }
            
            url = [mainAppURL URLByAppendingPathComponent:filenames[i]];
            if ([self checkIfValidPath:url]){
                [self finishedPathFinding:url];
                return;
            }
        }
    }
    
    [app logMessage:@"Could not find path!"];
    
    // Give up, show the button and ask them
    app.actionBtn.hidden = false;
    [self manuallySelectPath];
}


- (void)saveURLToUserDefaults: (NSURL*)url {
    
    NSError* error = NULL;
    
    NSData* data = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile includingResourceValuesForKeys:NULL relativeToURL:NULL error:&error];
    
    [NSUserDefaults.standardUserDefaults setObject:data forKey:@"com.multitheftauto.gtapath"];
}


- (bool)checkIfValidPath: (NSURL*)url {
    // This function assumes a valid directory that contains the gta exe, not app.
    [self.app updateStatusBar:[NSString stringWithFormat:@"Checking %@", url.absoluteString] progress:-1];
    
    // So we check if path/gta_sa.exe and path/models/gta3.img
    // If both exist, return true
    NSURL* exe = [url URLByAppendingPathComponent:(self.steamExe ? @"gta-sa.exe" : @"gta_sa.exe")];
    NSURL* gta3 = [url URLByAppendingPathComponent:@"models/gta3.img"];

    [self.app updateStatusBar:@"" progress:0];
    return exe.fileReferenceURL && gta3.fileReferenceURL;
}


- (void)finishedPathFinding: (NSURL *)url{
    // Hide the select button
    self.app.actionBtn.hidden = true;

    [self.app updateStatusBar:@"Saving path to configuration..." progress:-1];
    [self saveURLToUserDefaults:url];
    
    // We also need to do the symlinks
    [self.app updateStatusBar:@"Adding symbolic links..." progress:-1];
    [self makeSymlinks: url];
    
    // Tell them we areeee readdyyy TO RUMBLE!
    [self.app checkUpdater];
}

- (void)makeSymlinks:(NSURL *)gameURL{
    NSFileManager* manager = [NSFileManager defaultManager];
    
    NSError* error;
    
    // Let's assume this is a fresh install. We need to make a base symlink to our appdata.
    NSURL* appDir = NSBundle.mainBundle.bundleURL;
    
    NSLog(@"Appdir: %@", appDir.absoluteString);
    
    
}

- (void)manuallySelectPath {
    
    MTAAppDelegate* app = self.app;
    
    // Update the status bar
    [app updateStatusBar:@"Waiting for user response..." progress: -1];
    
    // Create the File Open Dialog class.
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    panel.canChooseFiles = true;
    panel.canChooseDirectories = false;
    panel.title = @"Select GTA.app or gtasa.exe";
    panel.allowedFileTypes = [NSArray arrayWithObjects:@"com.microsoft.windows-executable", @"com.apple.application-bundle", nil];
    panel.allowsMultipleSelection = false;

    
    // Display the dialog.  If the OK button was pressed, process the path
    NSInteger buttonPressed = panel.runModal;
    if ( buttonPressed == NSOKButton ) {
        
        NSURL* url = panel.URLs[0];
        
        // Check if an app file is selected so we can internally append the correct path to the GTA dir
        if ([url.pathExtension isEqualToString: @"app"]) {
            url = [url URLByAppendingPathComponent:
               @"/Contents/Resources/transgaming/c_drive/Program Files/Rockstar Games/GTA San Andreas"
               isDirectory:true
            ];

            // Now check if it's valid, just ensure they just didn't select a random application
            if (![url fileReferenceURL]){
                [app updateStatusBar:@"" progress:0];
                [self.app logMessage:@"Invalid app selected!"];
                return;
            }
        }
        else if ([url.pathExtension isEqualToString: @"exe"]){
            // Check if it's a steam exe, if so, set the variable
            if ([[url.lastPathComponent stringByDeletingPathExtension] isEqualToString:@"gta-sa"]){
                self.steamExe = true;
            }
            
            // This is the exe, so get the directory
            url = [url URLByDeletingLastPathComponent];
        
        }

        if ([self checkIfValidPath:url]) {
            [self finishedPathFinding:url];
            return;
        }
        
        self.steamExe = false; // Just in case, set steamExe false
        
        [app logMessage:@"Invalid GTA:SA path!"];
    }
    else if ( buttonPressed == NSCancelButton ) {
        [app updateStatusBar:@"" progress:0];
        [app logMessage:@"Please select the GTA directory"];
    }
}


@end
