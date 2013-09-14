//
//  TNAppDelegate.h
//  TogglNotifier
//
//  Created by Jason Cheatham on 9/5/13.
//  Copyright (c) 2013 Jason Cheatham. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TNAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, setter=setStatus:) NSString *status;

- (void)refresh;
- (void)setActive:(NSString *)title;
- (void)setStopped;
- (void)setError:(NSString *)message;
- (void)setApiKey:(NSString *)key;

@end
