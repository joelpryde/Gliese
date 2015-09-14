//
//  GLFuncs.m
//  jecTile
//
//  Created by Joel Pryde on 11/15/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <math.h>
#import "GLFuncs.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

void drawRect(CGRect rect)
{
    CGPoint pt1, pt2, pt3, pt4;
    
    // tl pt
    pt1 = rect.origin;
    
    // tr pt
    pt2 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y);
    
    // bl pt
    pt3 = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height);
    
    // br pt
    pt4 = CGPointMake(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
    
    drawRectPts(pt1, pt2, pt3, pt4);
}

void drawRectPts(CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4)
{
    // setup layer
    GLfloat squareVertices[] = {
        pt1.x, 1.0f - pt1.y,
        pt2.x, 1.0f - pt2.y,
        pt3.x, 1.0f - pt3.y,
        pt4.x, 1.0f - pt4.y,
    };
    
    static const GLfloat textureVertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    // draw layer
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

void drawRectOutline(CGRect rect, float thickness)
{
    // left side
    drawRect(CGRectMake(rect.origin.x, rect.origin.y, thickness, rect.size.height));
    // right side
    drawRect(CGRectMake(rect.origin.x + rect.size.width - thickness, rect.origin.y, thickness, rect.size.height));
    // top side
    drawRect(CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, thickness * 0.75));
    // bottom side
    drawRect(CGRectMake(rect.origin.x, rect.origin.y + rect.size.height - thickness * 0.75, rect.size.width, thickness * 0.75));
}

void drawWarpRectPts(GLuint program, CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4, int gridX, int gridY)
{
    GLint pt1Uniform = glGetUniformLocation(program, "Pt1");
    glUniform2f(pt1Uniform, pt1.x, pt1.y);
    GLint pt2Uniform = glGetUniformLocation(program, "Pt2");
    glUniform2f(pt2Uniform, pt2.x, pt2.y);
    GLint pt3Uniform = glGetUniformLocation(program, "Pt3");
    glUniform2f(pt3Uniform, pt3.x, pt3.y);
    GLint pt4Uniform = glGetUniformLocation(program, "Pt4");
    glUniform2f(pt4Uniform, pt4.x, pt4.y);
    
    GLfloat squareVertices[gridX*gridY*8];
    GLfloat textureVertices[gridX*gridY*8];
    
    float gridWidth = 1.0/gridX;
    float gridHeight = 1.0/gridY;
    
    for (int x=0; x<gridX; x++)
    {
        for (int y=0; y<gridY; y++)
        {
            float xVal = gridWidth * x;
            float yVal = gridHeight * y;
            
            // tl
            squareVertices[x*8+y*gridX*8] = textureVertices[x*8+y*gridX*8] = xVal;
            squareVertices[x*8+y*gridX*8+1] = textureVertices[x*8+y*gridX*8+1] = yVal;
            
            // tr
            squareVertices[x*8+y*gridX*8+2] = textureVertices[x*8+y*gridX*8+2] = xVal + gridWidth;
            squareVertices[x*8+y*gridX*8+3] = textureVertices[x*8+y*gridX*8+3] = yVal;
            
            // bl
            squareVertices[x*8+y*gridX*8+4] = textureVertices[x*8+y*gridX*8+4] = xVal;
            squareVertices[x*8+y*gridX*8+5] = textureVertices[x*8+y*gridX*8+5] = yVal + gridHeight;
            
            // br
            squareVertices[x*8+y*gridX*8+6] = textureVertices[x*8+y*gridX*8+6] = xVal + gridWidth;
            squareVertices[x*8+y*gridX*8+7] = textureVertices[x*8+y*gridX*8+7] = yVal + gridHeight;
        }
    }
    
    // draw layer
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, gridX*gridY*4);
}

void gldMultMatrix(float *MatrixB,float MatrixA[16])
{
    float NewMatrix[16];
    int i; 
    for(i = 0; i < 4; i++)
    { 
        //Cycle through each vector of first matrix.
        NewMatrix[i*4] = MatrixA[i*4] * MatrixB[0] + MatrixA[i*4+1] * MatrixB[4] + MatrixA[i*4+2] * MatrixB[8] + MatrixA[i*4+3] * MatrixB[12];
        NewMatrix[i*4+1] = MatrixA[i*4] * MatrixB[1] + MatrixA[i*4+1] * MatrixB[5] + MatrixA[i*4+2] * MatrixB[9] + MatrixA[i*4+3] * MatrixB[13];
        NewMatrix[i*4+2] = MatrixA[i*4] * MatrixB[2] + MatrixA[i*4+1] * MatrixB[6] + MatrixA[i*4+2] * MatrixB[10] + MatrixA[i*4+3] * MatrixB[14];
        NewMatrix[i*4+3] = MatrixA[i*4] * MatrixB[3] + MatrixA[i*4+1] * MatrixB[7] + MatrixA[i*4+2] * MatrixB[11] + MatrixA[i*4+3] * MatrixB[15];
    }
    /*this should combine the matrixes*/
    
    memcpy(MatrixB,NewMatrix,64);
}

void gldLoadIdentity(float *m)
{
    m[0] = 1;
    m[1] = 0;
    m[2] = 0;
    m[3] = 0;
    
    m[4] = 0;
    m[5] = 1;
    m[6] = 0;
    m[7] = 0;
    
    m[8] = 0;
    m[9] = 0;
    m[10] = 1;
    m[11] = 0;
    
    m[12] = 0;
    m[13] = 0;
    m[14] = 0;
    m[15] = 1;
}

void gldPerspective(float *m, float fov, float aspect,float zNear, float zFar)
{
    const float h = 1.0f/tan(fov*PI_OVER_360);
    float neg_depth = zNear-zFar;
    
    float m2[16] = {0};
    
    m2[0] = h / aspect;
    m2[1] = 0;
    m2[2] = 0;
    m2[3] = 0;
    
    m2[4] = 0;
    m2[5] = h;
    m2[6] = 0;
    m2[7] = 0;
    
    m2[8] = 0;
    m2[9] = 0;
    m2[10] = (zFar + zNear)/neg_depth;
    m2[11] = -1;
    
    m2[12] = 0;
    m2[13] = 0;
    m2[14] = 2.0f*(zNear*zFar)/neg_depth;
    m2[15] = 0;
    
    gldMultMatrix(m,m2);
}

void gldTranslatef(float *m,float x,float y, float z)
{
    float m2[16] = {0};
    
    m2[0] = 1;
    m2[1] = 0;
    m2[2] = 0;
    m2[3] = 0;
    
    m2[4] = 0;
    m2[5] = 1;
    m2[6] = 0;
    m2[7] = 0;
    
    m2[8] = 0;
    m2[9] = 0;
    m2[10] = 1;
    m2[11] = 0;
    
    m2[12] = x;
    m2[13] = y;
    m2[14] = z;
    m2[15] = 1;
    
    gldMultMatrix(m,m2);
}

void gldScalef(float *m,float x,float y, float z)
{
    float m2[16] = {0};
    
    m2[0] = x;
    m2[1] = 0;
    m2[2] = 0;
    m2[3] = 0;
    
    m2[4] = 0;
    m2[5] = y;
    m2[6] = 0;
    m2[7] = 0;
    
    m2[8] = 0;
    m2[9] = 0;
    m2[10] = z;
    m2[11] = 0;
    
    m2[12] = 0;
    m2[13] = 0;
    m2[14] = 0;
    m2[15] = 1;
    
    gldMultMatrix(m,m2);
}

void gldRotatef(float *m, float a, float x,float y, float z)
{
    float angle=a;
    float m2[16] = {0};
    
    m2[0] = 1+(1-cos(angle))*(x*x-1);
    m2[1] = -z*sin(angle)+(1-cos(angle))*x*y;
    m2[2] = y*sin(angle)+(1-cos(angle))*x*z;
    m2[3] = 0;
    
    m2[4] = z*sin(angle)+(1-cos(angle))*x*y;
    m2[5] = 1+(1-cos(angle))*(y*y-1);
    m2[6] = -x*sin(angle)+(1-cos(angle))*y*z;
    m2[7] = 0;
    
    m2[8] = -y*sin(angle)+(1-cos(angle))*x*z;
    m2[9] = x*sin(angle)+(1-cos(angle))*y*z;
    m2[10] = 1+(1-cos(angle))*(z*z-1);
    m2[11] = 0;
    
    m2[12] = 0;
    m2[13] = 0;
    m2[14] = 0;
    m2[15] = 1;
    
    gldMultMatrix(m,m2);
}

void gldOrtho(float *m, float left, float right, float bottom, float top, float Znear, float Zfar)
{
    float a = 2.0f / (right - left);
    float b = 2.0f / (top - bottom);
    float c = -2.0f / (Zfar - Znear);
    
    float tx = - (right + left)/(right - left);
    float ty = - (top + bottom)/(top - bottom);
    float tz = - (Zfar + Znear)/(Zfar - Znear);
    
    float m2[16] = {
        a, 0, 0, 0,
        0, b, 0, 0,
        0, 0, c, 0,
        tx, ty, tz, 1
    };
    
    gldMultMatrix(m,m2);
}

void setupProjection(GLint program, bool flipped)
{
    float projection[16];
    gldLoadIdentity(projection);
    if (flipped)
        gldOrtho(projection, 0, 1, 0, 1, -1, 1);
    else
        gldOrtho(projection, 0, 1, 0, 1, -1, 1);
    //gldRotatef(projection, PI/2.0f, 0.0f, 0.0f, 1.0f);
    //gldTranslatef(projection, -1.0f, 0.0f, 0.0f);
    GLint projectionUniform = glGetUniformLocation(program, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
}

CGColorRef CGColorCreateRGB(CGFloat red, CGFloat green,
                            CGFloat blue, CGFloat alpha)
{
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    const CGFloat myColor[] = {red, green, blue, alpha};
    CGColorRef color = CGColorCreate(rgb, myColor);
    CGColorSpaceRelease(rgb);
    return color;
}

