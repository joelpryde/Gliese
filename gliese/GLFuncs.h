//
//  glFuncs.h
//  jecTile
//
//  Created by Joel Pryde on 11/2/11.
//  Copyright 2011 Physipop. All rights reserved.
//

#ifndef GLFuncs_h
#define GLFuncs_h

#define PI	 3.1415926535897932384626433832795
#define PI_OVER_180	 0.017453292519943295769236907684886
#define PI_OVER_360	 0.0087266462599716478846184538424431

void drawRect(CGRect rect);
void drawRectPts(CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4);
void drawRectOutline(CGRect rect, float thickness);
void drawWarpRectPts(GLuint program, CGPoint pt1, CGPoint pt2, CGPoint pt3, CGPoint pt4, int gridX, int gridY);

void gldMultMatrix(float *MatrixB,float MatrixA[16]);
void gldLoadIdentity(float *m);
void gldPerspective(float *m, float fov, float aspect,float zNear, float zFar);
void gldTranslatef(float *m,float x,float y, float z);
void gldScalef(float *m,float x,float y, float z);
void gldRotatef(float *m, float a, float x,float y, float z);
void gldOrtho(float *m, float left, float right, float bottom, float top, float Znear, float Zfar);

void setupProjection(GLint program, bool flipped);
CGColorRef CGColorCreateRGB(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);

#endif