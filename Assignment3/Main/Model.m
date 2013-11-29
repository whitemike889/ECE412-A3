//
//  Model.m
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Model.h"



@implementation Model

- (id) init
{
	self = [super init];
	
	v = NULL;
	f = NULL;
	
	vertnum = 0;
	facenum = 0;
	
	maxx = 1;
	minx = -1;
	maxy = 1;
	
	miny = maxz = minz = 0;
	
	return self;
}


- (id) initWithFile:(NSString *)file
{
	self = [self init];
	
	// Initialize Variables
	vertnum = 0;
	facenum = 0;
	
	maxx = 1;
	minx = -1;
	maxy = 1;
	
	miny = maxz = minz = 0;
	
	
	// Open File and make sure its valid
	FILE *fp;
	const char *path = [file UTF8String];
	fp = fopen(path, "r");
	
	if (fp == NULL)
	{
		NSLog(@"File not found");
		exit(1);
	}
	
	
	// Parse object
	int bars = 0;
	char ch1, ch2;
	v = (vertex *) malloc(sizeof(vertex));
	f = (face *) malloc(sizeof(face));
	
	fscanf(fp, "%c%c", &ch1, &ch2);
	while (ch1 != 'v' && ch2 != ' ')
		fscanf(fp, "%c%c", &ch1, &ch2);
	
	
	// Read Verticies
	while (ch1 == 'v' && ch2 == ' ')
	{
		v = (vertex *) realloc(v, sizeof(vertex)*(vertnum+1));
		fscanf(fp, "%f %f %f\n", &v[vertnum].x, &v[vertnum].y, &v[vertnum].z);
		[self determine_bound: vertnum];
		fscanf(fp, "%c%c", &ch1, &ch2);
		vertnum++;
	}
	
	
	// Read Faces
	while (ch1 != 'f')
		fscanf(fp, "%c", &ch1);
	
	while (ch1 != '\n')
	{
		fscanf(fp, "%c", &ch1);
		if (ch1 == '/')
			bars = 1;
	}
	
	while (ch1 != 'f')
	{
		fseek(fp, -2, SEEK_CUR);
		fscanf(fp, "%c", &ch1);
	}
	
	while (ch1 == 'f')
	{
		f = (face *) realloc(f, sizeof(face)*(facenum+1));
		if (bars)
			fscanf(fp, " %d//%d %d//%d %d//%d\n", &f[facenum].x, &f[facenum].x, &f[facenum].y, &f[facenum].y, &f[facenum].z, &f[facenum].z);
		else
			fscanf(fp, " %d %d %d\n", &f[facenum].x, &f[facenum].y, &f[facenum].z);
		
		facenum++;
		
		if (feof(fp))
			break;
		
		fscanf(fp, "%c", &ch1);
	}
	
	fclose(fp);
	
	return self;
}



- (void) determine_bound:(int)i
{
	if (v[i].x > maxx)
		maxx = v[i].x;
	else
		if (v[i].x < minx)
			minx = v[i].x;
	
	if (v[i].y > maxy)
		maxy = v[i].y;
	else
		if (v[i].y < miny)
			miny = v[i].y;
	
	if (v[i].z > maxz)
		maxz = v[i].z;
	else
		if (v[i].z < minz)
			minz = v[i].z;
}



- (void) release
{
	if (v != NULL)
		free(v);
	
	if (f != NULL)
		free(f);
}

@end
