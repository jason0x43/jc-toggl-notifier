//
//  TNAppDelegate.m
//  TogglNotifier
//
//  Created by Jason Cheatham on 9/5/13.
//  Copyright (c) 2013 Jason Cheatham. All rights reserved.
//

#import "TNAppDelegate.h"
#import "Connections.h"

@implementation TNAppDelegate

NSString *const TOGGL_API = @"https://www.toggl.com/api/v8";

NSString *apiKey;
NSMenuItem *activeTimerItem;
NSString *activeTimerId;
NSStatusItem *statusItem;
NSObject<TNRequestHandler> *requestHandler;

//////////////////////////////////////////////////////////
//
// startup
//
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    apiKey = nil;
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    [menu setAutoenablesItems:NO];

    activeTimerItem = [menu addItemWithTitle:@"No active timer"
                                      action:@selector(cancelActiveTimer)
                               keyEquivalent:@""];
    [activeTimerItem setEnabled:NO];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *refresh = nil;
    refresh = [menu addItemWithTitle:@"Refresh..."
                              action:@selector(refresh)
                       keyEquivalent:@""];
    
    NSMenuItem *quit = nil;
    quit = [menu addItemWithTitle:@"Quit"
                           action:@selector(terminate:)
                    keyEquivalent:@""];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.image = [NSImage imageNamed:@"toggl_default.png"];
    statusItem.alternateImage = [NSImage imageNamed:@"toggl_selected.png"];
    statusItem.toolTip = @"ToggleNotifier";
    statusItem.highlightMode = YES;
    statusItem.menu = menu;
    
    requestHandler = nil;
    
    [NSTimer scheduledTimerWithTimeInterval:180.0
                                     target:self
                                   selector:@selector(timedRefresh:)
                                   userInfo:nil
                                    repeats:YES];
    
    [self refresh];
}

//////////////////////////////////////////////////////////
//
// Mark the status as active and show the timer title
//
- (void)setActive:(NSString *)idAndTitle
{
    NSLog(@"setting the active timer to %@", idAndTitle);
    statusItem.image = [NSImage imageNamed:@"toggl_active.png"];
    NSRange idx = [idAndTitle rangeOfString:@"|"];
    if (idx.location != NSNotFound) {
        activeTimerId = [idAndTitle substringToIndex:idx.location];
        activeTimerItem.title = [idAndTitle substringFromIndex:(idx.location +
                                                                1)];
        NSLog(@"timer id: %@", activeTimerId);
        NSLog(@"timer title: %@", activeTimerItem.title);
        [activeTimerItem setEnabled:YES];
    } else {
        activeTimerId = nil;
        activeTimerItem.title = idAndTitle;
        NSLog(@"no timer id");
        NSLog(@"timer title: %@", activeTimerItem.title);
        [activeTimerItem setEnabled:NO];
    }
}

//////////////////////////////////////////////////////////
//
// Mark the status as stopped and show a default message
//
- (void)setStopped
{
    NSLog(@"setting to stopped");
    statusItem.image = [NSImage imageNamed:@"toggl_default.png"];
    activeTimerItem.title = @"No active timer";
    activeTimerId = nil;
    [activeTimerItem setEnabled:NO];
}

//
// Mark the status as errored and show the error
//
- (void)setError:(NSString *)message
{
    NSLog(@"setting an error message: %@", message);
    statusItem.image = [NSImage imageNamed:@"toggl_error.png"];
    activeTimerItem.title = message;
    activeTimerId = nil;
    [activeTimerItem setEnabled:NO];
}

//
// Set the API key to use for communicating with Toggl
//
- (void)setApiKey:(NSString *)anApiKey
{
    NSLog(@"setting the API key: %@", anApiKey);
    apiKey = anApiKey;
    [self refresh];
}

//
// Indicate whether a request is active
//
- (BOOL)isRequestActive
{
    return (requestHandler != nil && !requestHandler.finished);
}

//
// Get a mutable request for getting or posting
//
- (NSMutableURLRequest *)createRequest:(NSURL *)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *keyString = [NSString stringWithFormat:@"%@:api_token", apiKey];
    NSString *authString =
        [self base64ForData:[keyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", authString];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];
    return request;
}

//
// Refresh from Toggl
//
- (void)refresh
{
    NSLog(@"trying to check time entries...");
    
    if (apiKey == nil) {
        NSLog(@"no API key has been set");
        [self setError:@"No API key has been set"];
        return;
    }

    if ([self isRequestActive]) {
        NSLog(@"a request is in progress");
        return;
    }
    
    NSLog(@"checking time entries...");
    NSString *urlStr = [NSString stringWithFormat:@"%@/time_entries",
                        TOGGL_API];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [self createRequest:url];
    
    requestHandler = [[TNRefreshHandler alloc] initWithApp:self];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request
                                                    delegate:requestHandler];
    
    if (!conn) {
        NSLog(@"connection wasn't created");
        [self setError:@"Couldn't open a connection"];
        requestHandler = nil;
    }
}

//
// Helper to call refresh from a timer
//
- (void)timedRefresh:(NSTimer*)timer
{
    [self refresh];
}

//
// Cancel the active timer, if one is active
//
- (void)cancelActiveTimer
{
    NSLog(@"canceling active timer");

    if (apiKey == nil) {
        NSLog(@"no API key has been set");
        return;
    }
    
    if (activeTimerId != nil) {
        if ([self isRequestActive]) {
            NSLog(@"a request is in progress");
            return;
        }
        
        NSLog(@"stopping time entry %@...", activeTimerId);
        NSString *urlStr =
            [NSString stringWithFormat:@"%@/time_entries/%@/stop",
             TOGGL_API, activeTimerId];
        NSURL *url = [NSURL URLWithString:urlStr];
        
        NSMutableURLRequest *request = [self createRequest:url];
        request.HTTPMethod = @"PUT";
        
        requestHandler = [[TNStopTimerHandler alloc] initWithApp:self];
        NSURLConnection *conn =
            [[NSURLConnection alloc] initWithRequest:request
                                            delegate:requestHandler];
        
        if (!conn) {
            NSLog(@"connection wasn't created");
            [self setError:@"Couldn't open a connection"];
            requestHandler = nil;
        }
    }
}

//
// Base64 encode a block of data
//
// This is used to generate the authorization header from the API key
//
- (NSString*)base64ForData:(NSData*)theData
{
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    for (NSInteger i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

@end
