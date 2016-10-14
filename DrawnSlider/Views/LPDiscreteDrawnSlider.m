//
//  LPDiscreteDrawnSlider.m
//  Producer
//
//  Created by Paul Shapiro on 6/19/15.
//  Copyright (c) 2015 Lunarpad Corporation. All rights reserved.
//

#import "LPDiscreteDrawnSlider.h"



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Macros



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Constants

// todo: integrate these with any other constants; instance level methods?

const CGFloat kKnobRadius                                           = 8;
CGFloat const LPDiscreteDrawnSlider_metric_marginX                  = kKnobRadius;
CGFloat const LPDiscreteDrawnSlider_metric_tickArea_marginX         = LPDiscreteDrawnSlider_metric_marginX/2;
CGFloat const LPDiscreteDrawnSlider_metric_bottomMargin             = 4;
CGFloat const LPDiscreteDrawnSlider_metric_tickMark_bottomMargin    = 6;
CGFloat const LPDiscreteDrawnSlider_metric_lineHeight               = 4;

const CGFloat kSliderTrackThickness                                 = 3;


////////////////////////////////////////////////////////////////////////////////
#pragma mark - C



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Interface

@interface LPDiscreteDrawnSlider ()

@property (atomic) BOOL _isEnabled;

@property (atomic) NSUInteger _numberOfTickMarks;
@property (atomic) NSUInteger _currentSeekIndex;

@property (atomic) BOOL isMouseDown;
@property (atomic) NSUInteger numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint;

@end


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Implementation

@implementation LPDiscreteDrawnSlider



////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Entrypoints

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)dealloc
{
    [self teardown];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Setup

- (void)setup
{
    __isEnabled = YES;
    __numberOfTickMarks = 1;
    __currentSeekIndex = 0;
    
    [self startObserving];
}

- (void)startObserving
{
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle - Imperatives - Teardown

- (void)teardown
{
    [self stopObserving];
}

- (void)stopObserving
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Lookups - Interactivity

- (BOOL)enabled
{
    return __isEnabled;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Overrides - Interactions

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Geometry

- (CGFloat)trackXOrigin
{
    return LPDiscreteDrawnSlider_metric_marginX;
}

- (CGFloat)trackXEnd
{
    NSRect bounds = [self bounds];
    
    return NSMaxX(bounds) - LPDiscreteDrawnSlider_metric_marginX;
}

- (CGFloat)trackMidpointY
{
    return ceilf(NSMaxY(_bounds)/2.0 + LPDiscreteDrawnSlider_metric_bottomMargin) + 0.5;
}

- (CGFloat)tickAreaXOrigin
{
    return [self trackXOrigin] + LPDiscreteDrawnSlider_metric_tickArea_marginX;
}

- (CGFloat)widthOfAreaForTickMarks
{
    return [self trackXEnd] - [self trackXOrigin] - 2*LPDiscreteDrawnSlider_metric_tickArea_marginX;
}

- (NSBezierPath *)_new_knobBezierPath
{
    // First, primitive metrics…
    // Y
    CGFloat knobSquareUpperSectionHeight = 9;
    CGFloat knobTriangularLowerSectionHeight = 9;
    CGFloat knobTotalHeight = knobSquareUpperSectionHeight + knobSquareUpperSectionHeight;
    CGFloat knobCenterY = [self trackMidpointY];
    CGFloat const knobYOffset = -2;
    CGFloat knobTopY = knobCenterY + knobSquareUpperSectionHeight + knobYOffset;
    CGFloat knobBottomY = knobTopY - knobTotalHeight;
    
    // X
    CGFloat knobWidth = kKnobRadius * 2;
    CGFloat knobXCenter = [self xPositionOfTickMarkAtIndex:__currentSeekIndex] + 0.5;
    CGFloat knobXLeftSide = knobXCenter - knobWidth/2;
    CGFloat knobXRightSide = knobXCenter + knobWidth/2;
    
    // X + Y
    CGFloat knobSquareUpperSectionTopCornersRadius = 2;
    
    // Second, aggregate metrics for the path (points)
    NSPoint knobPointerTipPoint = NSMakePoint(knobXCenter, knobBottomY);
    NSPoint knobTriangleAndSquareJoin_leftSidePoint = NSMakePoint(knobXLeftSide, knobBottomY + knobTriangularLowerSectionHeight);
    NSPoint knobSquareCornerJoin_leftSide_bottomPoint = NSMakePoint(knobXLeftSide, knobTopY - knobSquareUpperSectionTopCornersRadius);
    NSPoint knobSquareCornerJoin_leftSide_topPoint = NSMakePoint(knobXLeftSide + knobSquareUpperSectionTopCornersRadius, knobTopY);
    NSPoint knobSquareCornerJoin_rightSide_topPoint = NSMakePoint(knobXRightSide - knobSquareUpperSectionTopCornersRadius, knobTopY);
    NSPoint knobSquareCornerJoin_rightSide_bottomPoint = NSMakePoint(knobXRightSide, knobTopY - knobSquareUpperSectionTopCornersRadius);
    NSPoint knobTriangleAndSquareJoin_rightSidePoint = NSMakePoint(knobXRightSide, knobBottomY + knobTriangularLowerSectionHeight);
    // and from here, we can close the path back to knobPointerTipPoint

    // Third, implementation specific – we will need these corner points as "control points" for doing rounded corners
    NSPoint knobWholeRectangle_ULRoundedCorner_controlPoint = knobSquareCornerJoin_leftSide_bottomPoint;
    NSPoint knobWholeRectangle_URRoundedCorner_controlPoint = knobSquareCornerJoin_rightSide_topPoint;
    
    NSBezierPath *bezierPath = [[NSBezierPath alloc] init];
    { // Now to construct the path… we are starting with the pointer tip point
        
        [bezierPath moveToPoint:knobPointerTipPoint];
        [bezierPath lineToPoint:knobTriangleAndSquareJoin_leftSidePoint];
        [bezierPath lineToPoint:knobSquareCornerJoin_leftSide_bottomPoint];
        [bezierPath curveToPoint:knobSquareCornerJoin_leftSide_topPoint
                   controlPoint1:knobWholeRectangle_ULRoundedCorner_controlPoint
                   controlPoint2:knobWholeRectangle_ULRoundedCorner_controlPoint]; // upper left rounded corner
        [bezierPath lineToPoint:knobSquareCornerJoin_rightSide_topPoint];
        [bezierPath curveToPoint:knobSquareCornerJoin_rightSide_bottomPoint
                   controlPoint1:knobWholeRectangle_URRoundedCorner_controlPoint
                   controlPoint2:knobWholeRectangle_URRoundedCorner_controlPoint]; // upper right rounded corner
        [bezierPath lineToPoint:knobTriangleAndSquareJoin_rightSidePoint];
        [bezierPath closePath]; // close back to knobPointerTipPoint
        
    }
    
    return bezierPath;
}

- (CGFloat)xPositionOfTickMarkAtIndex:(NSUInteger)index
{
    return [self new_xPositionOfTickMarkAtIndex:index];
}

- (CGFloat)new_xPositionOfTickMarkAtIndex:(NSUInteger)index
{
    CGFloat raw_x; // kKnobRadius is added to give left margin track inset
    {
        if (__numberOfTickMarks == 0 || __numberOfTickMarks == 1) {
            raw_x = [self tickAreaXOrigin] + [self widthOfAreaForTickMarks]/2;
        } else if (index == 0) { // first one, but in the case that there is more than one tick mark
            raw_x = [self tickAreaXOrigin];
        } else if (index == __numberOfTickMarks - 1) { // last one, but not the first one
            raw_x = [self tickAreaXOrigin] + [self widthOfAreaForTickMarks];
        } else { // Then we are at some index in between the first and the last…
            // The strategy here is to divide up the space between the first and last tick marks.
            // We divide it into 1 more parts than the number of ticks which are to be in that area (i.e. number of ticks - 2 + 1).
            // Then we simply place the tick marks at the far edge of each corresponding subdivision. The extra, last subdivision (from the +1)
            // will be left-over and will not have a redundant tick mark placed there.
            
            CGFloat widthOfEachTickSubdivision = [self widthOfAreaForTickMarks] / (float)(__numberOfTickMarks - 1); // here, we are creating
            NSAssert(index > 0, @"index <= 0");
            CGFloat xOffsetOfThisIndexTickMark = [self tickAreaXOrigin] + index*widthOfEachTickSubdivision;
            
            raw_x = xOffsetOfThisIndexTickMark;
        }
    }
    CGFloat finalized_x = floorf(raw_x);
//    DDLogInfo(@"index %lu -> x %f", index, finalized_x);
    
    return finalized_x;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Lookups - Appearance

- (CGFloat)opacity
{
    return __isEnabled ? 1.0 : 0.5;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Lookups - Properties

- (NSUInteger)numberOfTickMarks
{
    return __numberOfTickMarks;
}

- (NSUInteger)currentSeekIndex
{
    return __currentSeekIndex;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Accessors - Layout - Overrides

- (NSUInteger)_tickIndexForXPosition:(CGFloat)xPosition
{ // this code might seem kind lame compared to doing the vector math to convert xposition to tick index,
  // but implementing -_tickIndexForXPosition: like this means we don't have to continuously maintain the inverse of -xPositionOfTickMarkAtIndex:
  // whenever it changes, making this more maintainable and flexible (i.e. if you want to customize the tick mark positions in a subclass)
    { // Sanitizations
        xPosition = floorf(xPosition); // we do this because we need to be able to compare it to the output of -xPositionOfTickMarkAtIndex:, which is floored
    }
    if (__numberOfTickMarks <= 1) {
        return 0; // only one to choose from
    }
    if (xPosition <= [self xPositionOfTickMarkAtIndex:0]) { // before the beginning -> first tick index
        return 0;
    } else if (xPosition >= [self xPositionOfTickMarkAtIndex:__numberOfTickMarks - 1]) { // past the end -> last tick index
        return __numberOfTickMarks - 1;
    }
    { // Now we know we're within the tick area…
        for (NSUInteger testIndex = 0 ; testIndex < __numberOfTickMarks ; testIndex++) {
            if (testIndex == __numberOfTickMarks - 1) {
                DDLogWarn(@"Couldn't locate the tick mark until the very last tick mark. Is it correct that you're selecting the very last one? If not, there's a bug here or in what supplies the xPosition.");
                
                return __numberOfTickMarks - 1; // we still didn't match it, so it must be just before the last tick (not past the end - we caught that above)
            }
            CGFloat xOfTestIndex = [self xPositionOfTickMarkAtIndex:testIndex];
            NSUInteger nextIterationTestIndex = testIndex + 1; // we know this is not out-of-bounds, due to the check just above
            CGFloat distanceFromTestIndexToNextTickIndex = [self xPositionOfTickMarkAtIndex:nextIterationTestIndex] - xOfTestIndex;
            CGFloat halfOfDistanceToNextTick = distanceFromTestIndexToNextTickIndex/2;
            CGFloat distanceFrom_xPosition_to_xOfTestIndex = xPosition - xOfTestIndex;
            CGFloat magnitudeOf_distanceFrom_xPosition_to_xOfTestIndex = fabs(distanceFrom_xPosition_to_xOfTestIndex);
//            DDLogInfo(@"%f <= %f? %d",
//                      magnitudeOf_distanceFrom_xPosition_to_xOfTestIndex,
//                      halfOfDistanceToNextTick,
//                      magnitudeOf_distanceFrom_xPosition_to_xOfTestIndex <= halfOfDistanceToNextTick ? YES : NO);
            if (magnitudeOf_distanceFrom_xPosition_to_xOfTestIndex <= halfOfDistanceToNextTick) { // here, we're finding which tick mark xPosition is spatially closer to
                return testIndex;
            }
        }
    }
    DDLogError(@"Couldn't locate tick through all conditions. Must be a bug?");
    
    return 0;
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Setters

- (void)setNumberOfTickMarks:(NSUInteger)numberOfTickMarks
{
    {
        numberOfTickMarks = MAX(numberOfTickMarks, 1); // stick to >= 0
    }
    __numberOfTickMarks = numberOfTickMarks;
    [self setNeedsDisplay:YES];
}

- (void)setCurrentSeekIndex:(NSUInteger)currentSeekIndex
{
    [self setCurrentSeekIndex:currentSeekIndex shouldCheckIfCurrentlyExecutingMouseTracking:YES]; // default to YES since this is the public interface
}

- (void)setCurrentSeekIndex:(NSUInteger)currentSeekIndex shouldCheckIfCurrentlyExecutingMouseTracking:(BOOL)shouldCheckIfCurrentlyExecutingMouseTracking
{
    if (shouldCheckIfCurrentlyExecutingMouseTracking) {
        if (_numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint > 0) {
//            DDLogWarn(@"Asked to %@ but currently tracking %lu mouse events.",
//                      NSStringFromSelector(_cmd),
//                      _numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint);
            
            return; // this is probably the result of some kind of asynchrony on the part of whoever is listening for slider actions, which
            // then comes back to setCurrentSeekIndex:…
        }
    }
    {
        currentSeekIndex = MAX(currentSeekIndex, 0); // stick to >= 0
        currentSeekIndex = MIN(currentSeekIndex, __numberOfTickMarks - 1); // stick to <= __numberOfTickMarks-1
    }
    __currentSeekIndex = currentSeekIndex;
    [self setNeedsDisplay:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Interactions - Mouse Tracking

- (void)_trackMouseWithStartPoint:(NSPoint)p
{
    NSEvent *event = nil;
    { // mouse-down styling
        _isMouseDown = YES;
        [self setNeedsDisplay:YES];
    }
    {
        if (_numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint > 0) {
            DDLogWarn(@"Asked to track mouse while still handling mouse events.");
        }
        _numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint += 1; // mark that we're currently working
    }
    while ([event type] != NSLeftMouseUp) { // track while mouse down
        @autoreleasepool
        { // create a pool to flush each time through the cycle
            event = [[self window] nextEventMatchingMask: NSLeftMouseDraggedMask | NSLeftMouseUpMask];
            NSPoint convertedPoint = [self convertPoint: [event locationInWindow] fromView:nil];
            NSUInteger newSeekIndex = [self _tickIndexForXPosition:convertedPoint.x];
//            DDLogInfo(@"convertedPoint.x %f -> newSeekIndex %lu", convertedPoint.x, newSeekIndex);
            if (newSeekIndex != __currentSeekIndex) {
                [self setCurrentSeekIndex:newSeekIndex shouldCheckIfCurrentlyExecutingMouseTracking:NO];
                [self sendActionToTarget];
            }
        }
    }
    { // done working
        _numberOfCurrentlyExecutingCallsTo_trackMouseWithStartPoint -= 1;
    }
    { // mouse-up styling
        _isMouseDown = NO;
        [self setNeedsDisplay:YES];
    }
}

- (void)sendActionToTarget
{
    [self.target performSelectorOnMainThread:self.action withObject:nil waitUntilDone:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Setters

- (void)setEnabled:(BOOL)isEnabled
{
    __isEnabled = isEnabled;
    [self setNeedsDisplay:YES];
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    CGContextRef context = [NSGraphicsContext currentContext].graphicsPort;
    CGContextSaveGState(context);
    {
        CGContextSetAlpha(context, [self opacity]);

        [self draw_sliderTrackInContext:context];
        [self draw_tickMarksInContext:context];
        [self draw_knobInContext:context];
    }
    CGContextRestoreGState(context);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Slider

- (void)draw_sliderTrackInContext:(CGContextRef)context
{ // Slider track
    CGContextSaveGState(context);
    {
        NSBezierPath *sliderPath = [NSBezierPath bezierPath];
        {
            CGFloat trackMidpointY = [self trackMidpointY];
            [sliderPath moveToPoint:NSMakePoint([self trackXOrigin], trackMidpointY)];
            [sliderPath lineToPoint:NSMakePoint([self trackXEnd], trackMidpointY)];
            [sliderPath setLineWidth:kSliderTrackThickness];
            [sliderPath setLineCapStyle:NSRoundLineCapStyle];
        }
        NSColor *trackColor = [NSColor colorWithRed:163.0/255.0
                                              green:163.0/255.0
                                               blue:163.0/255.0
                                              alpha:1.0];
        [trackColor setStroke];
        [sliderPath stroke];
    }
    CGContextRestoreGState(context);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Knob

- (void)draw_knobInContext:(CGContextRef)context
{
    NSBezierPath *knobPath = [self _new_knobBezierPath];

    static CGFloat fillColor_mouseDownValue = 236.0/255.0;
    static CGFloat fillColor_mouseUpValue = 255.0/255.0;
    CGFloat fillColor_value;
    {
        if (_isMouseDown == YES) {
            fillColor_value = fillColor_mouseDownValue;
        } else {
            fillColor_value = fillColor_mouseUpValue;
        }
    }
    NSColor *fillColor = [NSColor colorWithWhite:fillColor_value alpha:1];
    CGContextSaveGState(context);
    { // Draw bg w/shadow, but line on top in separate context state
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetShouldAntialias(context, YES);
        
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(0, -1),
                                    2,
                                    [NSColor colorWithWhite:0 alpha:0.15].CGColor);
        
        [fillColor setFill];
        [knobPath fill];
    }
    CGContextRestoreGState(context);
    
    NSColor *strokeColor = [NSColor colorWithWhite:0 alpha:0.19];
    CGContextSaveGState(context);
    {
        CGContextSetAllowsAntialiasing(context, YES);
        CGContextSetShouldAntialias(context, YES);

        [strokeColor setStroke];
        [knobPath stroke];
    }
    CGContextRestoreGState(context);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Imperatives - Drawing - Tick Marks

- (void)draw_tickMarksInContext:(CGContextRef)context
{
    NSColor *lineColor = [NSColor colorWithWhite:125.0/255.0 alpha:1];
    
    CGFloat lineBottomY = LPDiscreteDrawnSlider_metric_bottomMargin + LPDiscreteDrawnSlider_metric_tickMark_bottomMargin;
    CGFloat lineTopY = lineBottomY + LPDiscreteDrawnSlider_metric_lineHeight;

    CGContextSaveGState(context);
    {
        CGContextSetAllowsAntialiasing(context, NO);
        CGContextSetShouldAntialias(context, NO);
        
        NSUInteger numberOfTickMarks = __numberOfTickMarks; // capture it in case it changes?
        if (numberOfTickMarks > [self widthOfAreaForTickMarks]) { // just draw a filled block - silly to draw more! :P
            {
                CGContextSetFillColorWithColor(context, lineColor.CGColor);
            }
            {
                NSRect rectToFill = NSMakeRect([self tickAreaXOrigin],
                                               lineBottomY,
                                               [self widthOfAreaForTickMarks],
                                               LPDiscreteDrawnSlider_metric_lineHeight);
                CGContextFillRect(context, rectToFill);
            }
        } else {
            CGContextSetLineWidth(context, 1);
            CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
            
//            DDLogInfo(@"drawing %lu tick marks", numberOfTickMarks);

            for (NSUInteger i = 0 ; i < numberOfTickMarks ; i++) {
                CGFloat x = [self xPositionOfTickMarkAtIndex:i];
                {
                    CGContextMoveToPoint(context,       x, lineBottomY);
                    CGContextAddLineToPoint(context,    x, lineTopY);
                }
                CGContextStrokePath(context);
            }
        }
    }
    CGContextRestoreGState(context);
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark - Runtime - Delegation - Interactions

- (void)mouseDown:(NSEvent *)event
{
    if (!__isEnabled) { // no beep
        return;
    }
    
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    if ([[self _new_knobBezierPath] containsPoint:p]) {
        [self _trackMouseWithStartPoint:p];
    } else {
        [self setCurrentSeekIndex:[self _tickIndexForXPosition:p.x] shouldCheckIfCurrentlyExecutingMouseTracking:NO];
        [self sendActionToTarget];
        [self _trackMouseWithStartPoint:p];
    }
}

@end
