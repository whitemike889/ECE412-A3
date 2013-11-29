//
//  Controller.m
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Controller.h"

@implementation MyCustomView


- (IBAction)openModel:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	
	[openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result) {
		if (result == NSOKButton)
		{
			NSURL *selection = openPanel.URLs[0];
			NSString *path = [selection.path stringByResolvingSymlinksInPath];
			[OpenGLView1 loadModel:path];
			[OpenGLView2 loadModel:path];
		}
	}];
	
}

- (IBAction)resetCam:(id)sender
{
	[OpenGLView1 resetcam];
	[OpenGLView2 resetcam];
}


- (IBAction)changeColor:(id)sender
{
	NSLog(@"send to: %@", OpenGLView1);
	[OpenGLView1 updateColor: [red integerValue]
						   : [green integerValue]
						   : [blue integerValue]];
}


- (IBAction) changeNearFar:(id)sender
{
	[OpenGLView1 updateNearFar: [near floatValue] :[far floatValue]];
}


- (void) setNearFar:(float)n :(float)f
{
	[near setIntegerValue: n];
	[far setIntegerValue: f];
}


- (IBAction)changeMode:(id)sender
{
	[OpenGLView1 updateMode: [[sender selectedCell] tag]];
}


- (IBAction)changeCull:(id)sender
{
	[OpenGLView1 updateCulling: [[sender selectedCell] tag]];
}


- (IBAction)debug:(id)sender
{
	[OpenGLView1 debuglog];
}


- (void) updateLabels: (float)px :(float)py :(float)pz :(float)dx :(float) dy :(float)dz;
{
	[posx setFloatValue:px];
	[posy setFloatValue:py];
	[posz setFloatValue:pz];
	[dirx setFloatValue:dx*180/M_PI];
	[diry setFloatValue:dy*180/M_PI];
	[dirz setFloatValue:dz*180/M_PI];
}


@end
