//
//  VMMultiHandleSlider.m
//  VMMultiHandleSlider
//
//  Created by Sun Peng on 7/8/14.
//  Copyright (c) 2014 Void Main. All rights reserved.
//

#import "VMMultiHandleSlider.h"

#define kSliderHandlerWidth  13
#define kSliderHandlerHeight 17
#define kSliderBarHeight     4
#define kSliderBarColor      [NSColor blackColor]

#define kStaticViewTag       1001
#define kDynamicViewTag      1002

@interface VMSliderHandle : NSObject {
    ValueBlock _valueBlock;
}

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSImage   *handleImage;
@property (nonatomic)         float      curRatio;
@property (nonatomic, weak)   NSView    *handleView;

- (void)setValueBlock:(ValueBlock)valueBlock;
- (float)curValue;

@end

@implementation VMSliderHandle

- (void)setValueBlock:(ValueBlock)valueBlock {
    _valueBlock = valueBlock;
}

- (float)curValue
{
    float value = self.curRatio;
    if (_valueBlock) {
        value = _valueBlock(value);
    }

    return value;
}

@end

@implementation VMMultiHandleSlider

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSImage *sliderBarImage = [self sliderBarImage];
        float startX = (frame.size.width - sliderBarImage.size.width) * 0.5;
        float startY = (frame.size.height - sliderBarImage.size.height) * 0.5;
        NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(startX, startY, sliderBarImage.size.width, sliderBarImage.size.height)];
        imageView.image = sliderBarImage;
        imageView.tag = 0;
        [self addSubview:imageView];
    }
    return self;
}

- (NSImage *)sliderBarImage
{
    float slidableWidth = self.bounds.size.width - kSliderHandlerWidth;
    NSImage *barImage = [[NSImage alloc] initWithSize:NSMakeSize(slidableWidth, kSliderBarHeight)];
    [barImage lockFocus];
    [kSliderBarColor set];
    NSRectFill(NSMakeRect(0, 0, barImage.size.width, barImage.size.height));
    [barImage unlockFocus];
    return barImage;
}

- (void)setValueChangedBlock:(ValueChangedBlock)valueChangedBlock
{
    _valueChangedBlock = valueChangedBlock;
}

- (void)addHandle:(NSString *)name image:(NSImage *)image initRatio:(float)initRatio valueBlock:(ValueBlock)valueBlock
{
    if (self.handles == nil) {
        self.handles = [[NSMutableDictionary alloc] init];
    }

    VMSliderHandle *handle = [[VMSliderHandle alloc] init];
    handle.name = name;
    handle.handleImage = image;
    handle.curRatio = initRatio;
    [handle setValueBlock:valueBlock];
    [self.handles setObject:handle forKey:name];

    float slidableWidth = self.bounds.size.width - kSliderHandlerWidth;
    float midY = NSMidY(self.bounds);
    NSRect handleRect = NSMakeRect(slidableWidth * handle.curRatio, midY - kSliderHandlerHeight * 0.5, kSliderHandlerWidth, kSliderHandlerHeight);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, kSliderHandlerWidth, kSliderHandlerHeight)];
    imageView.image = handle.handleImage;
    imageView.tag = kDynamicViewTag;
    [self addSubview:imageView];
    imageView.frame = handleRect;

    handle.handleView = imageView;

    [self setNeedsDisplay:YES];
}

#pragma mrak -
#pragma mark Mouse Events
- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    for (NSView *view in self.subviews) {
        if (view.tag == kDynamicViewTag) {
            if (NSPointInRect(clickPoint, view.frame)) {
                self.activeHandleView = view;
                for (NSString *key in self.handles) {
                    VMSliderHandle *handle = [self.handles objectForKey:key];
                    if (handle.handleView == view) {
                        self.activeHandle = handle;
                        break;
                    }
                }
                self.activeBoundary = [self boundaryForView:self.activeHandleView];
                self.lastValue = self.activeHandle.curRatio;
                break;
            }
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (self.activeHandleView == nil) {
        return [super mouseDragged:theEvent];
    }

    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    float left = [[self.activeBoundary objectAtIndex:0] floatValue];
    float right = [[self.activeBoundary objectAtIndex:1] floatValue];
    float newX = clickPoint.x;
    float halfWidth = self.activeHandleView.frame.size.width * 0.5;
    if (newX - halfWidth < left)  newX = left  + halfWidth;
    if (newX + halfWidth > right) newX = right - halfWidth;

    self.activeHandleView.frame = NSMakeRect(newX - self.activeHandleView.frame.size.width * 0.5, self.activeHandleView.frame.origin.y, self.activeHandleView.frame.size.width, self.activeHandleView.frame.size.height);
    float slidableWidth = self.bounds.size.width - kSliderHandlerWidth;
    float ratio = (newX - halfWidth) / slidableWidth;
    self.activeHandle.curRatio = ratio;

    float changeDiff = ABS(self.activeHandle.curRatio - self.lastValue);
    if (changeDiff > FLT_EPSILON && _valueChangedBlock) {
        self.lastValue = self.activeHandle.curRatio;

        NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
        for (NSString *key in self.handles) {
            VMSliderHandle *handle = [self.handles objectForKey:key];
            [values setObject:[NSNumber numberWithFloat:[handle curValue]] forKey:key];
        }
        _valueChangedBlock([values copy]);
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    self.activeHandle = nil;
    self.activeHandleView = nil;
    self.activeBoundary = nil;
}

#pragma mark -
#pragma mark Help methods
- (NSArray *)boundaryForView:(NSView *)view
{
    NSMutableArray *boundary = [[NSMutableArray alloc] initWithCapacity:2];
    float min = 0;
    float max = self.frame.size.width;
    float viewLeftBounday = view.frame.origin.x;
    float viewRightBounday = view.frame.origin.x + view.frame.size.width;
    for (NSView *subview in view.superview.subviews) {
        if (subview != view && subview.tag == kDynamicViewTag) {
            float leftBoundary = subview.frame.origin.x;
            float rightBoundary = subview.frame.origin.x + subview.frame.size.width;
            if (rightBoundary < viewLeftBounday && rightBoundary > min) {
                min = rightBoundary;
            }

            if (leftBoundary > viewRightBounday && leftBoundary < max) {
                max = leftBoundary;
            }
        }
    }

    [boundary setObject:[NSNumber numberWithFloat:min] atIndexedSubscript:0];
    [boundary setObject:[NSNumber numberWithFloat:max] atIndexedSubscript:1];
    return [boundary copy];
}


@end
