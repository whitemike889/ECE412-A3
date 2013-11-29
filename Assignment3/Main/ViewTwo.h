//
//  ViewTwo.h
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Header.h"
#import "Shader.h"
#import "Model.h"
#import "Controller.h"
#import "Matrix.h"


@interface ViewTwo : NSOpenGLView
{
	camera		cam;
	GLfloat		shapeSize;
	Model		*m;
	
	float		increment;
	
	GLenum		polyMode;
	GLenum		cullMode;
	
	NSPoint		start;
	
	float		color[3];
	
	ModelView	*mvm;
	Projection	*pm;
	
	IBOutlet id con;
	
	Shader *shader;
	GLhandleARB program;
}

+ (NSOpenGLPixelFormat*) basicPixelFormat;

- (void) drawObject;
- (void) updateProjection;
- (void) updateModelView;
- (void) resizeGL;
- (void) resetCamera;
- (void) updateCamera: (float)posx :(float)posy :(float)posz :(float)dirx :(float)diry :(float)dirz;
- (void) updateColor: (float)red :(float)green :(float)blue;
- (void) updateNearFar: (float)near :(float)far;
- (void) updateMode: (int)tag;
- (void) updateCulling: (int)tag;
- (void) printCamera;
- (void) loadModel: (NSString *)s;
- (GLuint) loadShader;

- (void) keyDown:(NSEvent *)theEvent;

- (void) drawRect:(NSRect)bounds;
- (void) prepareOpenGL;
- (void) update;

- (id) initWithFrame: (NSRect)frameRect;
- (void) awakeFromNib;


@end
