//
//  Shader.h
//  Assignment3
//
//  Created by Michael Hickman on 11/29/13.
//  Copyright (c) 2013 Michael Hickman. All rights reserved.
//

#import "Header.h"

@interface Shader : NSObject
{
	GLhandleARB obj;
}

- (id) initWithShaderName:(NSString *)shaderName;
- (GLhandleARB) compileShader:(GLenum)type :(const GLcharARB **)shader;
- (void) linkProgram;
- (GLhandleARB) getProgram;

@end
