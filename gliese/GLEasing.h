//
//  GLEasing.h
//  gliese
//
//  Created by Joel Pryde on 4/16/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#ifndef gliese_GLEasing_h
#define gliese_GLEasing_h


GLfloat LinearInterpolation(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuadraticEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuadraticEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuadraticEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat CubicEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat CubicEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat CubicEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuarticEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuarticEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuarticEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuinticEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuinticEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat QuinticEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat SinusoidalEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat SinusoidalEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat SinusoidalEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat ExponentialEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat ExponentialEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat ExponentialEaseInOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat CircularEaseOut(GLclampf t, GLfloat start, GLfloat end);
GLfloat CircularEaseIn(GLclampf t, GLfloat start, GLfloat end);
GLfloat CircularEaseInOut(GLclampf t, GLfloat start, GLfloat end);

#endif
