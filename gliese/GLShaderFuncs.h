//
//  GLShaderFuncs.h
//  jecTile
//
//  Created by Joel Pryde on 11/15/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#ifndef jecTile_GLShaderFuncs_h
#define jecTile_GLShaderFuncs_h

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXCOORD,
    NUM_ATTRIBUTES
};

NSString* compileShaderFile(GLuint *shader, GLenum type, NSString *file);
NSString* compileShaderStr(GLuint *shader, GLenum type, NSString *source);
BOOL linkProgram(GLuint prog);
BOOL validateProgram(GLuint prog);

GLuint loadShaderFile(NSString* vsFile, NSString* fsFile, NSString** errorStr);
GLuint loadShaderStr(NSString* vsStr, NSString* fsStr, NSString** errorStr);

NSString* getShaderString(NSString *file);
NSString* recompileFragmentShader(GLuint program, NSString *fragmentStr);

#endif
