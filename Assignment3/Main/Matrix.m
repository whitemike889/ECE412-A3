//
//  Matrix.m
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Matrix.h"

vec createVec(float x, float y, float z)
{
	vec r;
	r.x = x;
	r.y = y;
	r.z = z;
	
	return r;
}



// Implementation for Matrix Class
@implementation Matrix

- (id) init
{
	self = [super init];
	
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
		{
			if (i == j)
				m[i][j] = 1;
			else
				m[i][j] = 0;
		}
	
	return self;
}



- (float **) copy
{
	// Allocate Memory
	float **r = malloc(sizeof(float*)*4);
	for (int i=0; i<4; i++)
		r[i] = malloc(sizeof(float)*4);
	
	// Copy Values
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			r[i][j] = m[i][j];
	
	return r;
}



- (void) reset
{
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			if (i == j)
				m[i][j] = 1;
			else
				m[i][j] = 0;
}



- (float *) returnMatrix
{
	float *r = malloc(sizeof(float)*16);
	
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			r[(i*4)+j] = m[i][j];
	
	return r;
}



- (void) multiplyWith: (float[4][4]) a
{
	float **temp = [self copy];
	
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
		{
			m[i][j] = 0;
			for (int k=0; k<4; k++)
				m[i][j] += temp[i][k]*a[k][j];
		}
	
	free(temp);
}



- (void) print
{
	for (int i=0; i<4; i++)
		NSLog(@"|\t%f\t%f\t%f\t%f\t|\n", m[i][0], m[i][1], m[i][2], m[i][3]);
	NSLog(@"\n\n");
}



- (void) print: (float**) a
{
	for (int i=0; i<4; i++)
		NSLog(@"|\t%f\t%f\t%f\t%f\t|\n", a[i][0], a[i][1], a[i][2], a[i][3]);
	NSLog(@"\n\n");
}

@end



// Implementation for ModelView Matrix Class
@implementation ModelView

- (id) initWithCamera:(camera *) cam
{
	self = [super init];
	
	m[0][0] = cam->u.x;
	m[0][1] = cam->u.y;
	m[0][2] = cam->u.z;
	m[0][3] = 0;
	
	m[1][0] = cam->v.x;
	m[1][1] = cam->v.y;
	m[1][2] = cam->v.z;
	m[1][3] = 0;
	
	m[2][0] = cam->n.x;
	m[2][1] = cam->n.y;
	m[2][2] = cam->n.z;
	m[2][3] = 0;
	
	for (int i=0; i<3; i++)
		m[3][i] = 0;
	
	m[3][3] = 1;
	
	return self;
}


- (void) rotateX: (float) a;
{
	// Convert to radians
	float angle = a;//*-0.0174532925;
	
	
	// Create Transformation Matrix
	float t[4][4];
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			t[i][j] = 0;
	t[0][0] = t[3][3] = 1;
	t[1][1] = cos(angle);
	t[1][2] = sin(angle)*(-1);
	t[2][1] = sin(angle);
	t[2][2] = cos(angle);
	
	[self multiplyWith: t];
}



- (void) rotateY: (float) a;
{
	// Convert to radians
	float angle = a;// * -0.0174532925;
	
	
	// Create Transformation Matrix
	float t[4][4];
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			t[i][j] = 0;
	t[1][1] = t[3][3] = 1;
	t[0][0] = cos(angle);
	t[0][2] = sin(angle);
	t[2][0] = sin(angle)*(-1);
	t[2][2] = cos(angle);
	
	[self multiplyWith: t];
}



- (void) rotateZ: (float) a;
{
	// Convert to radians
	float angle = a;// * -0.0174532925;
	
	
	// Create Transformation Matrix
	float t[4][4];
	for (int i=0; i<4; i++)
		for (int j=0; j<4; j++)
			t[i][j] = 0;
	t[2][2] = t[3][3] = 1;
	t[0][0] = cos(angle);
	t[0][1] = sin(angle)*(-1);
	t[1][0] = sin(angle);
	t[1][1] = cos(angle);
	
	[self multiplyWith: t];
}



- (void) translate:(float)x :(float)y :(float)z
{
	for (int i=0; i<3; i++)
		m[i][3] = m[i][0]*x + m[i][1]*y + m[i][2]*z;
}

@end



@implementation Projection

- (id) init
{
	self = [super init];
	
	return self;
}



- (void) setFrustum:(float)l :(float)r :(float)t :(float)b :(float)n :(float)f
{
	m[0][0] = (2*n)/(r-l);
	m[0][2] = (r+l)/(r-l);
	m[1][1] = (2*n)/(t-b);
	m[1][2] = (t+b)/(t-b);
	m[2][2] = -(f+n)/(f-n);
	m[2][3] = -(2*f*n)/(f-n);
	m[3][2] = -1;
	m[3][3] = 0;
}

@end
