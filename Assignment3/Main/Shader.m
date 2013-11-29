//
//  Shader.m
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Shader.h"

@implementation Shader

- (id) initWithShaderName:(NSString *)shaderName
{
	self = [super init];
	
	const GLcharARB *fragSource;
	const GLcharARB *vertSource;
	
	
	// Get Path of Shaders
	NSBundle *appBundle = [NSBundle mainBundle];
	NSString *fragString = [appBundle pathForResource:shaderName ofType:@"frag"];
	NSString *vertString = [appBundle pathForResource:shaderName ofType:@"vert"];
	
	
	// Read Shaders
	NSError *error;
	fragString = [NSString stringWithContentsOfFile:fragString encoding:NSASCIIStringEncoding error:&error];
	fragSource = (GLcharARB *)[fragString cStringUsingEncoding:NSASCIIStringEncoding];
	vertString = [NSString stringWithContentsOfFile:vertString encoding:NSASCIIStringEncoding error:&error];
	vertSource = (GLcharARB *)[vertString cStringUsingEncoding:NSASCIIStringEncoding];
	
	
	// Compile Shaders
	GLhandleARB vertexShader, fragmentShader;
	fragmentShader = [self compileShader:GL_FRAGMENT_SHADER_ARB :&fragSource];
	vertexShader = [self compileShader:GL_VERTEX_SHADER_ARB :&vertSource];
	
	// Link Shaders
	obj = glCreateProgramObjectARB();
	
	glAttachObjectARB(obj, vertexShader);
	glAttachObjectARB(obj, fragmentShader);
	
	glDeleteObjectARB(vertexShader);
	glDeleteObjectARB(fragmentShader);
	
	[self linkProgram];
	
	return self;
}



- (GLhandleARB) compileShader:(GLenum)type :(const GLcharARB **)shader
{
	GLhandleARB shaderHandle = NULL;
	
	if (shader != NULL)
	{
		shaderHandle = glCreateShaderObjectARB(type);
		glShaderSourceARB(shaderHandle, 1, shader, NULL);
		glCompileShaderARB(shaderHandle);
		
		GLint length = 0;
		glGetObjectParameterivARB(shaderHandle, GL_OBJECT_INFO_LOG_LENGTH_ARB, &length);
		
		if (length > 0)
		{
			GLcharARB *log = (GLcharARB *)malloc(length);
			if (log != NULL)
			{
				glGetInfoLogARB(shaderHandle, length, &length, log);
				NSLog(@" Shader Compile Log:\n%s\n", log);
				free(log);
			}
		}
		GLint compiled = 1;
		glGetObjectParameterivARB(shaderHandle, GL_OBJECT_COMPILE_STATUS_ARB, &compiled);
		
		if (compiled == 0)
		{
			NSLog(@"Shader did not compile\n");
		}
	}
	
	return shaderHandle;
}



- (void) linkProgram
{
	glLinkProgramARB(obj);
	
	GLint length = 0;
	glGetObjectParameterivARB(obj, GL_OBJECT_INFO_LOG_LENGTH_ARB, &length);
	
	if (length > 0)
	{
		GLcharARB *log = (GLcharARB *)malloc(length);
		if (log != NULL)
		{
			glGetInfoLogARB(obj, length, &length, log);
			NSLog(@"Link Log:\n%s\n", log);
			free(log);
		}
	}
	
	GLint linked = 1;
	glGetObjectParameterivARB(obj, GL_OBJECT_LINK_STATUS_ARB, &linked);
	
	if (linked == 0)
	{
		NSLog(@"Shader did not link\n");
	}
}



- (GLhandleARB) getProgram
{
	return obj;
}

@end
