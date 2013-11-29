//
//  ViewOne.m
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "ViewOne.h"

vec gOrigin1 = {0.0, 0.0, 0.0};


@implementation ViewOne

// Main Functions
// ----------------------------------------------------

- (void) awakeFromNib
{
	
}



- (void) resetcam
{
	// Set Aperature
	cam.aperture = 40;
	
	
	// Set Rotation Angles
	cam.rot = gOrigin1;
	
	
	// Set Camera Position
	cam.pos.x = 0;//-(m->maxx + m->minx)/2;
	cam.pos.y = 0;//-(m->maxy + m->miny)/2;
	cam.pos.z = -4;//-((m->maxz + m->minz)/2 + (m->maxz - m->minz)*4);
	
	
	// Set Camera Direction
	cam.dir.x = 0;
	cam.dir.y = 0;
	cam.dir.z = -cos(cam.rot.y);
	
	[self setNeedsDisplay: YES];
}



- (id) initWithFrame:(NSRect)frameRect
{
	NSOpenGLPixelFormat *pf = [ViewOne basicPixelFormat];
	
	// Read in Model
	m = [[Model alloc] init];
	
	
	// Camera Setup
	cam.near = (m->maxz - m->minz)*2;
	cam.far = 4*cam.near;
	
	if (cam.near < 0.00001)
		cam.near = 0.00001;
	
	if (cam.far < 1.0)
		cam.far = 1.0;
	
	cam.rot.x = cam.rot.y = cam.rot.z = 0;
	cam.u = createVec(1, 0, 0);
	cam.v = createVec(0, 1, 0);
	cam.n = createVec(0, 0, 1);
	
	
	// Determine max coordinates of model
	float max = 1;
	if (m->maxx - m->minx > max)
		max = m->maxx - m->minx;
	if (m->maxy - m->miny > max)
		max = m->maxy - m->miny;
	if (m->maxz - m->minz >max)
		max = m->maxz - m->minz;
	
	
	// Initialize Polygon Mode
	polyMode = GL_FILL;
	
	
	// Initialize movement incrment
	increment = max/50;
	
	
	// Initialize Color
	color[0] = 1.0;
	color[1] = 1.0;
	color[2] = 1.0;
	
	
	// Initialize MVM and PM
	mvm = [[ModelView alloc] initWithCamera: &cam];
	pm = [[Projection alloc] init];
	
	self = [super initWithFrame: frameRect pixelFormat: pf];
	
	[[self openGLContext] makeCurrentContext];
	
	shader = [[Shader alloc] initWithShaderName:@"shader"];
	program = [shader getProgram];
	glUseProgramObjectARB(program);
	
	GLint location = glGetUniformLocationARB(program, "colors");
	glUniform3f(location, color[0], color[1], color[2]);
	
	return self;
}



+ (NSOpenGLPixelFormat*) basicPixelFormat
{
	NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16,
        (NSOpenGLPixelFormatAttribute)nil
    };
    
	return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
}



- (void) drawRect:(NSRect)bounds
{
	[self resizeGL];
	[self updateModelView];
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glPolygonMode(GL_FRONT_AND_BACK, polyMode);
	glFrontFace(cullMode);
	
	[self drawObject];
	
	if ([self inLiveResize])
		glFlush();
	else
		[[self openGLContext] flushBuffer];
}



- (void) resizeGL
{
	NSRect rectView = [self bounds];
	
	if ((cam.viewHeight != rectView.size.height) || (cam.viewWidth != rectView.size.width))
	{
		cam.viewHeight = rectView.size.height;
		cam.viewWidth = rectView.size.width;
		
		glViewport(0, 0, cam.viewWidth, cam.viewHeight);
		[self updateProjection];
	}
}



- (void) updateProjection
{
	// Calculate Projection Here
	
	GLdouble ratio, radians, wd2;
	GLdouble left, right, top, bottom;
	
	[[self openGLContext] makeCurrentContext];
	
	radians = 0.0174532925 * cam.aperture / 2;
	wd2 = cam.near * tan(radians);
	ratio = cam.viewWidth / (float) cam.viewHeight;
	
	if (ratio >= 1.0)
	{
		left = -ratio * wd2;
		right = ratio * wd2;
		top = wd2;
		bottom = -wd2;
	}
	else
	{
		left = -wd2;
		right = wd2;
		top = wd2 / ratio;
		bottom = -wd2 / ratio;
	}
	
	
	// Create Projection Matrix
	[pm setFrustum:left :right :top :bottom :cam.near :cam.far];
	
	
	// Send to Shader
	GLfloat *proj = [pm returnMatrix];
	GLint location = glGetUniformLocationARB(program, "proj");
	glUniformMatrix4fvARB(location, 1, GL_TRUE, proj);
	free(proj);
}



- (void) updateModelView
{
	[[self openGLContext] makeCurrentContext];
	
	
	// Create ModelView Matrix
	[mvm reset];
	[mvm rotateZ: cam.rot.z];
	[mvm rotateY: cam.rot.y];
	[mvm rotateX: cam.rot.x];
	[mvm translate: cam.pos.x :cam.pos.y :cam.pos.z];
	
	
	// Send to Shader
	GLfloat *model = [mvm returnMatrix];
	GLint location = glGetUniformLocationARB(program, "mvm");
	glUniformMatrix4fvARB(location, 1, GL_TRUE, model);
	free(model);
	
	[con updateLabels:cam.pos.x :cam.pos.y :cam.pos.z :cam.rot.x :cam.rot.y :cam.rot.z];
}



- (void) drawObject
{
	/*
	glBegin(GL_LINES);
	glVertex3f(-1, 0, 0);
	glVertex3f(1, 0, 0);
	glVertex3f(0, -1, 0);
	glVertex3f(0, 1, 0);
	glVertex3f(0, 0, -1);
	glVertex3f(0, 0, 1);
	glEnd();
	*/
	
	glBegin(GL_TRIANGLES);
	int x, y, z;
	for (int i=0; i<m->facenum; i++)
	{
		x = m->f[i].x-1;
		y = m->f[i].y-1;
		z = m->f[i].z-1;
		
		glVertex3f(m->v[x].x, m->v[x].y, m->v[x].z);
		glVertex3f(m->v[y].x, m->v[y].y, m->v[y].z);
		glVertex3f(m->v[z].x, m->v[z].y, m->v[z].z);
	}
	glEnd();
	
}



// Controll Functions
// ----------------------------------------------------

- (void) loadModel:(NSString *)s
{
	// Create Model
	[m release];
	
	m = [[Model alloc] initWithFile:s];
	
	
	// Set Near and Far Values
	cam.near = (m->maxz - m->minz) * 2;
	cam.far = 4 * cam.near;
	
	if (cam.near < 0.00001)
		cam.near = 0.00001;
	
	if (cam.far < 1.0)
		cam.far = 1.0;
	
	
	// Set Rotation Angles to Zero
	cam.rot.x = cam.rot.y = cam.rot.z = 0;
	
	
	// Get Max Values from Model
	float axis = 0;
	float max = 1;
	
	if (m->maxx - m->minx > max)
		max = m->maxx - m->minx;
	if (m->maxy - m->miny > max)
	{
		max = m->maxy - m->miny;
		axis = 1;
	}
	if (m->maxz - m->minz >max)
	{
		max = m->maxz - m->minz;
		axis = 2;
	}
	
	
	// Set Polygon Mode
	polyMode = GL_FILL;
	
	
	// Set Increment
	increment = max / 50;
	//increment = 0.5;
	
	
	[self resetcam];
	[con setNearFar:cam.near :cam.far];
	[self updateProjection];
	[self setNeedsDisplay: YES];
}



- (void) updateColor:(float)red :(float)green :(float)blue
{
	NSLog(@"%@", self);
	color[0] = red/255;
	color[1] = green/255;
	color[2] = blue/255;
	
	GLint location = glGetUniformLocationARB(program, "colors");
	glUniform3f(location, color[0], color[1], color[2]);
	
	[self setNeedsDisplay: YES];
}



- (void) updateNearFar:(float)n :(float)f
{
	cam.near = n;
	cam.far = f;
	
	[self updateProjection];
	[self setNeedsDisplay: YES];
}



- (void) updateMode: (int)tag
{
	switch (tag)
	{
		case 0:
			polyMode = GL_FILL;
			break;
		case 1:
			polyMode = GL_LINE;
			break;
		case 2:
			polyMode = GL_POINT;
			break;
	}
	
	[self setNeedsDisplay: YES];
}



- (void) updateCulling:(int)tag
{
	switch (tag)
	{
		case 0:
			cullMode = GL_CW;
			break;
		case 1:
			cullMode = GL_CCW;
			break;
	}
	
	[self setNeedsDisplay: YES];
}



- (void) debuglog
{
	GLfloat model[16];
	glGetFloatv(GL_MODELVIEW_MATRIX, model);
	
	GLfloat proj[16];
	glGetFloatv(GL_PROJECTION_MATRIX, proj);
	
	
	FILE *fp;
	fp = fopen("/Users/Michael/Desktop/DebugLog.txt", "w");
	
	
	fprintf(fp, "Camera\n");
	fprintf(fp, "posx = %f, posy = %f, posz = %f\ndirx = %f, diry = %f, dirz = %f\n", cam.pos.x, cam.pos.y, cam.pos.z, cam.dir.x, cam.dir.y, cam.dir.z);
	
	fprintf(fp, "\n\nModel View Matrix\n");
	for (int i=0; i<4; i++)
		fprintf(fp, "|\t%f\t%f\t%f\t%f\t|\n", model[i], model[i+4], model[i+8], model[i+12]);
	
	fprintf(fp, "\n\nProjection Matrix\n");
	for (int i=0; i<16; i+=4)
		fprintf(fp, "|\t%f\t%f\t%f\t%f\t|\n", proj[i], proj[i+4], proj[i+8], proj[i+12]);
	
	fclose(fp);
}



// UI Functions
// ----------------------------------------------------

- (void) keyDown:(NSEvent *)theEvent
{
	NSString *characters = [theEvent characters];
	if ([characters length])
	{
		unichar character = [characters characterAtIndex:0];
		switch (character)
		{
				// Movement
				
				// Forward
			case 'w':
				cam.pos.z += increment;
				[self setNeedsDisplay: YES];
				break;
				
				// Back
			case 's':
				cam.pos.z -= increment;
				[self setNeedsDisplay: YES];
				break;
				
				// Left
			case 'a':
				cam.pos.x += increment;
				[self setNeedsDisplay: YES];
				break;
				
				// Right
			case 'd':
				cam.pos.x -= increment;
				[self setNeedsDisplay: YES];
				break;
				
				// Up
			case 'g':
				cam.pos.y += increment;
				[self setNeedsDisplay: YES];
				break;
				
				// Down
			case 'h':
				cam.pos.y -= increment;
				[self setNeedsDisplay: YES];
				break;
				
				
				// Rotation
			case 'j':
				cam.rot.y -= radian;
				[self setNeedsDisplay: YES];
				break;
			case 'l':
				cam.rot.y += radian;
				[self setNeedsDisplay: YES];
				break;
				
			case 'v':
				cam.rot.z += radian;
				cam.u.x = sin(cam.rot.z);
				cam.u.y = cos(cam.rot.z);
				
				cam.v.x = cos(cam.rot.z);
				cam.v.y = sin(cam.rot.z);
				[self setNeedsDisplay: YES];
				break;
			case 'n':
				cam.rot.z -= radian;
				cam.u.x = sin(cam.rot.z);
				cam.u.y = cos(cam.rot.z);
				[self setNeedsDisplay: YES];
				break;
				
			case 'i':
				cam.rot.x -= radian;
				[self setNeedsDisplay: YES];
				break;
			case 'k':
				cam.rot.x += radian;
				[self setNeedsDisplay: YES];
				break;
				
		}
	}
	
	[[self nextKeyView] keyDown:theEvent];
}


-(BOOL)acceptsFirstResponder
{
	return YES;
}


@end
