//
//  Matrix.h
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Header.h"


typedef struct {
	GLdouble x, y, z;
} vec;

vec createVec(float x, float y, float z);



typedef struct {
	// Camear Position
	vec			pos;
	vec			dir;
	vec			up;
	
	
	// CCS
	vec			u;
	vec			v;
	vec			n;
	
	
	// Rotation Angles
	vec			rot;
	
	
	// Near and Far
	GLfloat		near;
	GLfloat		far;
	
	GLdouble	aperture;
	GLint		viewWidth, viewHeight;
	
} camera;



@interface Matrix : NSObject
{
	float m[4][4];
};

- (id) init;
- (float **) copy;
- (void) reset;
- (float *) returnMatrix;
- (void) multiplyWith: (float[4][4]) a;
- (void) print;
- (void) print: (float**) a;

@end



@interface ModelView : Matrix

- (id) initWithCamera:(camera *) c;
- (void) rotateX: (float) angle;
- (void) rotateY: (float) angle;
- (void) rotateZ: (float) angle;
- (void) translate: (float)x :(float)y :(float)z;

@end



@interface Projection : Matrix

- (id) init;
- (void) setFrustum: (float)l :(float)r :(float)t :(float)b :(float)n :(float)f;

@end
