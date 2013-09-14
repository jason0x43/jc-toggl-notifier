//
//  TNRefreshCommand.m
//  TogglNotifier
//
//  Created by Jason Cheatham on 9/6/13.
//  Copyright (c) 2013 Jason Cheatham. All rights reserved.
//

#import "Commands.h"
#import "TNAppDelegate.h"

//////////////////////////////////////////////////

@implementation TNRefreshCommand

- (id)performDefaultImplementation {
    NSLog(@"received refresh command via AppleScript");
    [(TNAppDelegate *)[[NSApplication sharedApplication] delegate] refresh];
    return nil;
}

@end

//////////////////////////////////////////////////

@implementation TNSetActiveCommand

- (id)performDefaultImplementation {
    NSString *title = [[self evaluatedArguments] valueForKey:@""];
    NSLog(@"received active timer title via AppleScript: %@", title);
    [(TNAppDelegate *)[[NSApplication sharedApplication] delegate]
     setActive:title];
    return nil;
}

@end

//////////////////////////////////////////////////

@implementation TNSetStoppedCommand

- (id)performDefaultImplementation {
    NSLog(@"received stop command via AppleScript");
    [(TNAppDelegate *)[[NSApplication sharedApplication] delegate] setStopped];
    return nil;
}

@end

//////////////////////////////////////////////////

@implementation TNSetErrorCommand

- (id)performDefaultImplementation {
    NSString *message = [[self evaluatedArguments] valueForKey:@""];
    NSLog(@"received error message via AppleScript: %@", message);
    [(TNAppDelegate *)[[NSApplication sharedApplication] delegate]
     setError:message];
    return nil;
}

@end

//////////////////////////////////////////////////

@implementation TNSetApiKeyCommand

- (id)performDefaultImplementation {
    NSString *apiKey = [[self evaluatedArguments] valueForKey:@""];
    NSLog(@"received API key via AppleScript: %@", apiKey);
    [(TNAppDelegate *)[[NSApplication sharedApplication] delegate]
     setApiKey:apiKey];
    return nil;
}

@end