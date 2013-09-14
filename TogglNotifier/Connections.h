//
//  TNRefreshHandler.h
//  TogglNotifier
//
//  Created by Jason Cheatham on 9/7/13.
//  Copyright (c) 2013 Jason Cheatham. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TNAppDelegate.h"

/////////////////////////////////////////////////

@protocol TNRequestHandler

@property (atomic, readonly) BOOL finished;

@end

/////////////////////////////////////////////////

@interface TNDefaultRequestHandler : NSObject<NSURLConnectionDataDelegate,
                                              TNRequestHandler>

@property (atomic, readonly) BOOL finished;
@property (atomic, readonly) TNAppDelegate *app;

- (id)initWithApp:(TNAppDelegate *)app;

@end

/////////////////////////////////////////////////

@interface TNRefreshHandler : TNDefaultRequestHandler
@end

@interface TNStopTimerHandler : TNDefaultRequestHandler
@end