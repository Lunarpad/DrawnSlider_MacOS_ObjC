# DrawnSlider\_MacOS\_ObjC:

**Platform:** MacOS

**Language:** Objective-C

An extremely performant, completely custom-drawn alternative to `NSlider`, with a very sensible API.

One of the awesome features of [Producer](http://www.getproducer.com) is its ability to capture the frames of data going through a running iOS app that you are building. Producer uses that data to power a feature called Tracer as part of its debugging tools suite, the UI of which contains a horizontal `NSSlider` with tick marks that lets you scrub through the frames of data. For production apps and bigger projects, this can end up being tens or hundreds of thousands of frames of data, meaning thousands of tick marks in the `NSSlider` user interface.

We started to notice during stress-testing that Producer would get rather slow when it had to deal with so many data frames. Part of the solution was to optimize our file IO, but it turns out that a surprisingly huge amount of CPU time was being spent by `NSSlider` doing the drawing for the incredible number of tick marks in the UI.

That's why we created `LPDiscreteDrawnSlider`. It re-implements all of `NSSlider`'s visual styling and interaction behavior in order to provide a viable alternative for high-demand applications. 

We also took the opportunity to simplify the API a bit. :)


## Installation:

To install, simply download the source for this module and include `./DrawnSlider` in your Xcode project. 

## How it works:

`LPDiscreteDrawnSlider` is simply a subclass of `NSView` which implements the drawing and interactions of an `NSlider` from scratch in a much more highly performant manner. It's styled to look exactly like an incremental `NSlider` (including enabled state, slider knob interactions, etc.), but it can be completely customized.

## Usage

All you have to do is create an instance of `LPDiscreteDrawnSlider` as you would with an `NSSlider`, like so:


	- (void)setup_frameSlider
	{
	    LPDiscreteDrawnSlider *view = [[LPDiscreteDrawnSlider alloc] init];
	    view.target = self;
	    view.action = @selector(frameSliderDidAct);
	    view.frame = [self _new_sliderFrame];
    	//
	    self.frameSlider = view;
	    [self.view addSubview:view];
	}
	- (NSRect)_new_sliderFrame
	{
	    CGFloat w = self.view.frame.size.width - rightMargin - leftMargin;
		CGFloat h = 40;
	    NSRect frame = NSMakeRect(leftMargin, y, w, h);
    	//
	    return frame;
	}
	
To configure and read the slider state aside from `target` and `action`, the following methods are available:

	- (BOOL)enabled;
	- (void)setEnabled:(BOOL)isEnabled;

	- (void)setNumberOfTickMarks:(NSUInteger)numberOfTickMarks;
	- (NSUInteger)numberOfTickMarks;

	- (void)setCurrentSeekIndex:(NSUInteger)currentSeekIndex;
	- (NSUInteger)currentSeekIndex;


# Contributing

If you find this code useful and make any expansions to it we encourage you to submit a pull request so that others may get the benefit of your work. Contributors will be credited.