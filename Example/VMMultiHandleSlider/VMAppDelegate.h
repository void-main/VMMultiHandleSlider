//
//  VMAppDelegate.h
//  VMMultiHandleSlider
//
//  Created by Sun Peng on 7/8/14.
//  Copyright (c) 2014 Void Main. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VMMultiHandleSlider;
@interface VMAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet VMMultiHandleSlider *multiHandleSlider;

@end
