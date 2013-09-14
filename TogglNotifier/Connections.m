//
//  TNRefreshHandler.m
//  TogglNotifier
//
//  Created by Jason Cheatham on 9/7/13.
//  Copyright (c) 2013 Jason Cheatham. All rights reserved.
//

#import "Connections.h"

@implementation TNDefaultRequestHandler

//
// Initializer
//
- (id)initWithApp:(TNAppDelegate *)app
{
    self = [super init];
    if (self) {
        _app = app;
        _finished = false;
    }
    return self;
}

//
// A response was received on the connection
//
- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"received response: %ld", (long)httpResponse.statusCode);
    
    long code = httpResponse.statusCode;
    if (code >= 400) {
        [self.app setError:@"Error talking to Toggl"];
    }
}

//
// The connection finished loading
//
// Either this or didFailWithError are guaranteed to be called
//
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _finished = true;
}

//
// There was an error while transferring info on a connector
//
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"connection failed! Error - %@ %@", [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [_app setError:@"The connection failed"];
    _finished = true;
}

//
// Data was received
//
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // do nothing by default
}

@end

//////////////////////////////////////////////////////////

@implementation TNRefreshHandler

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"received data");
    NSError *error = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:kNilOptions
                                                       error:&error];
    BOOL isActive = false;
    
    for (NSDictionary *entry in array) {
        long val = [[entry valueForKey:@"duration"] integerValue];
        if (val < 0) {
            isActive = true;
            
            NSString *idAndTitle = [NSString stringWithFormat:@"%@|%@",
                                    [entry valueForKey:@"id"],
                                    [entry valueForKey:@"description"]];
            
            [self.app setActive:idAndTitle];
            break;
        }
    }
    
    if (!isActive) {
        NSLog(@"no timers are active");
        [self.app setStopped];
    }
}

@end

//////////////////////////////////////////////////////////

@implementation TNStopTimerHandler

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"received response: %ld", (long)httpResponse.statusCode);

    long code = httpResponse.statusCode;
    if (code >= 200 && code < 300) {
        NSLog(@"timer was stopped");
        [self.app setStopped];
    } else {
        NSLog(@"timer was not stopped");
    }
}

@end


