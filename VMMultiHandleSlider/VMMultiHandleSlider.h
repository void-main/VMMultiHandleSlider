//
//  VMMultiHandleSlider.h
//  VMMultiHandleSlider
//
//  Created by Sun Peng on 7/8/14.
//  Copyright (c) 2014 Void Main. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef float(^ValueBlock)(float);
typedef void(^ValueChangedBlock)(NSDictionary *handles);

@class VMSliderHandle;
@interface VMMultiHandleSlider : NSView {
    ValueChangedBlock _valueChangedBlock;
}

@property (nonatomic, weak)   VMSliderHandle      *activeHandle;
@property (nonatomic, weak)   NSView              *activeHandleView;
@property (nonatomic)         NSArray             *activeBoundary;
@property (nonatomic, retain) NSMutableDictionary *handles;
@property (nonatomic, strong) NSMutableDictionary *values;
@property (nonatomic)         float                lastValue;

- (void)setValueChangedBlock:(ValueChangedBlock)valueChangedBlock;

- (void)addHandle:(NSString *)name image:(NSImage *)image initRatio:(float)initRatio valueBlock:(ValueBlock)valueBlock invValueBlock:(ValueBlock)invValueBlock;

@end
