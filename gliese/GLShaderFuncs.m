//
//  GLShaderFuncs.c
//  jecTile
//
//  Created by Joel Pryde on 11/15/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <stdio.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLShaderFuncs.h"

NSString* compileShaderFile(GLuint *shader, GLenum type, NSString *file)
{
    NSString* source = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return @"Failed to load vertex shader";
    }
    return compileShaderStr(shader, type, source);
}

NSString* compileShaderStr(GLuint *shader, GLenum type, NSString *source)
{
    GLint status;
    NSString* error = nil;
    const GLchar *sourceStr = (GLchar *)[source UTF8String];
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &sourceStr, NULL);
    glCompileShader(*shader);
    
    //#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        error = [NSString stringWithFormat:@"Shader compile log:\n%s", log];
        NSLog(@"%@", error);
        free(log);
    }
    //#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
    }
    
    if (error != nil || status == 0)
        return error;
    else
        return nil;
}

BOOL linkProgram(GLuint prog)
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

BOOL validateProgram(GLuint prog)
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

GLuint loadShaderFile(NSString* vsFile, NSString* fsFile, NSString** errorStr)
{
    NSString *vsShaderPathname = [[NSBundle mainBundle] pathForResource:vsFile ofType:@"vsh"];
    NSString* vsSource = [NSString stringWithContentsOfFile:vsShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (!vsSource)
    {
        if (errorStr)
            *errorStr = @"Failed to load vertex shader file";
        return -1;
    }
    
    NSString *fsShaderPathname = [[NSBundle mainBundle] pathForResource:fsFile ofType:@"fsh"];
    NSString* fsSource = [NSString stringWithContentsOfFile:fsShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (!fsSource)
    {
        if (errorStr)
            *errorStr = @"Failed to load fragment shader file";
        return -1;
    }
    
    return loadShaderStr(vsSource, fsSource, errorStr);
}

GLuint loadShaderStr(NSString* vsStr, NSString* fsStr, NSString** errorStr)
{
    GLuint vertShader, fragShader;
    
    // Create shader program.
    GLint program = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString* error = compileShaderStr(&vertShader, GL_VERTEX_SHADER, vsStr);
    if (error != nil)
    {
        if (errorStr)
            *errorStr = error;
        return -1;
    }
    
    // Create and compile fragment shader.
    error = compileShaderStr(&fragShader, GL_FRAGMENT_SHADER, fsStr);
    if (error != nil)
    {
        if (errorStr)
            *errorStr = error;
        return -1;
    }
    
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_TEXCOORD, "texcoord");
    
    // Link program.
    if (!linkProgram(program))
    {
        if (errorStr)
            *errorStr = @"Failed to link program";
        return -1;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    return program;
}

NSString* getShaderString(NSString *file)
{
    NSString* source;
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:file ofType:@"fsh"];
    source = [NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil];
    if (!source)
    {
        NSLog(@"Failed to load shader");
        return nil;
    }
    return source;
}

GLchar shaderSource[40000];
NSString* recompileFragmentShader(GLuint program, NSString *fragmentStr)
{
    GLsizei shaderCount;
    GLuint shaders[2];
    glGetAttachedShaders(program, 2, &shaderCount, shaders);  
    
    // detach old shader and get the old source
    GLsizei shaderSrcLen;
    glGetShaderSource(shaders[1], 40000, &shaderSrcLen, shaderSource);
    shaderSource[shaderSrcLen] = '\0'; // null terminate
    //NSLog(@"ShaderSrc: %s", shaderSource);
    glDetachShader(program, shaders[1]);
    
    // Create and compile fragment shader.
    GLuint fragShader;
    NSString* compileError = compileShaderStr(&fragShader, GL_FRAGMENT_SHADER, fragmentStr);
    if (compileError != nil)
    {
        //NSLog(@"Failed to compile fragment shader");
        
        // try to recompile old one!
        NSString* compileError = compileShaderStr(&fragShader, GL_FRAGMENT_SHADER, [NSString stringWithUTF8String:shaderSource]);
        if (compileError != nil)
            return compileError;
    }
    //NSLog(@"Shader recompile SUCCESS!");
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    //glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    //glBindAttribLocation(program, ATTRIB_TEXCOORD, "texcoord");
    
    // Link program.
    if (!linkProgram(program))
    {
        //NSLog(@"Failed to link program: %d", program);
        if (fragShader)
            glDeleteShader(fragShader);
        if (program)
            glDeleteProgram(program);
        return [NSString stringWithFormat:@"Failed to link program: %d", program];
    }
    
    // Release vertex and fragment shaders.
    if (fragShader)
        glDeleteShader(fragShader);
    return compileError;
}


