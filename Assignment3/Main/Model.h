//
//  Model.h
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Header.h"

typedef struct {
	float x, y, z;
} vertex;

typedef struct {
	int x, y, z;
} face;



@interface Model : NSObject
{
@public
	// Points
	vertex	*v;
	int		vertnum;
	
	// Polygons
	face	*f;
	int		facenum;
	
	// Min/Max
	float	minx, miny, minz, maxx, maxy, maxz;
}

- (id) init;
- (id) initWithFile: (NSString *) file;
- (void) determine_bound: (int)i;
- (void) release;

@end

