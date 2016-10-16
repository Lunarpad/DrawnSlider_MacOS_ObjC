//
//  LPDiscreteDrawnSlider.h
//  DrawnSlider_MacOS_ObjC
//
//  Created by Paul Shapiro on 6/19/15.
//  Copyright (c) 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPDiscreteDrawnSlider : NSView

- (id)init;

- (BOOL)enabled;
- (void)setEnabled:(BOOL)isEnabled;

@property (atomic, weak) id target;
@property (atomic) SEL action;

- (void)setNumberOfTickMarks:(NSUInteger)numberOfTickMarks;
- (NSUInteger)numberOfTickMarks;

- (void)setCurrentSeekIndex:(NSUInteger)currentSeekIndex;
- (NSUInteger)currentSeekIndex;

@end
