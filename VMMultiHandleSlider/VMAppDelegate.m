//
//  VMAppDelegate.m
//  VMMultiHandleSlider
//
//  Created by Sun Peng on 7/8/14.
//  Copyright (c) 2014 Void Main. All rights reserved.
//

#import "VMAppDelegate.h"
#import "VMMultiHandleSlider.h"

@implementation VMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.multiHandleSlider addHandle:@"High"
                                image:[NSImage imageNamed:@"hud_slider-knobWhite-N"]
                            initRatio:1.0
                           valueBlock:^float(float inVal) {
                               return inVal;
                           }
     ];

    [self.multiHandleSlider addHandle:@"Low"
                                image:[NSImage imageNamed:@"hud_slider-knobBlack-N"]
                            initRatio:0.0
                           valueBlock:^float(float inVal) {
                               return inVal;
                           }
     ];

    [self.multiHandleSlider addHandle:@"Gamma"
                                image:[NSImage imageNamed:@"hud_slider-knobGray-N"]
                            initRatio:0.5
                           valueBlock:^float(float inVal) {
                               return inVal * 2;
                            }
     ];

    [self.multiHandleSlider setValueChangedBlock:^(NSDictionary *handles) {
        NSLog(@"Low: %f | High: %f | Gamma: %f", [[handles objectForKey:@"Low"] floatValue], [[handles objectForKey:@"High"] floatValue], [[handles objectForKey:@"Gamma"] floatValue]);
    }];
}

@end
