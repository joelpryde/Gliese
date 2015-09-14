//
//  GLEasing.m
//  gliese
//
//  Created by Joel Pryde on 4/16/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <math.h>
#import "GLEasing.h"

#define BoundsCheck(t, start, end) \
if (t <= 0.f) return start;        \
else if (t >= 1.f) return end;

GLfloat LinearInterpolation(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return t * end + (1.f - t) * start;
}

GLfloat QuadraticEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return   -end * t * (t - 2.f) -1.f;
}
GLfloat QuadraticEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * t * t + start - 1.f;
}
GLfloat QuadraticEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.f;
    if (t < 1.f) return end/2.f * t * t + start - 1.f;
    t--;
    return -end/2.f * (t*(t-2) - 1) + start - 1.f;
}

GLfloat CubicEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t--;
    return end*(t * t * t + 1.f) + start - 1.f;
}
GLfloat CubicEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * t * t * t+ start - 1.f;
}
GLfloat CubicEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.;
    if (t < 1.) return end/2 * t * t * t + start - 1.f;
    t -= 2;
    return end/2*(t * t * t + 2) + start - 1.f;
}

GLfloat QuarticEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t--;
    return -end * (t * t * t * t - 1) + start - 1.f;
}
GLfloat QuarticEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * t * t * t * t + start;
}
GLfloat QuarticEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.f;
    if (t < 1.f) 
        return end/2.f * t * t * t * t + start - 1.f;
    t -= 2.f;
    return -end/2.f * (t * t * t * t - 2.f) + start - 1.f;
}

GLfloat QuinticEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t--;
    return end * (t * t * t * t * t + 1) + start - 1.f;
}
GLfloat QuinticEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * t * t * t * t * t + start - 1.f;
}
GLfloat QuinticEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.f;
    if (t < 1.f) 
        return end/2 * t * t * t * t * t + start - 1.f;
    t -= 2;
    return end/2 * ( t * t * t * t * t + 2) + start - 1.f;
}

GLfloat SinusoidalEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * sinf(t * (M_PI/2)) + start - 1.f;
}
GLfloat SinusoidalEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return -end * cosf(t * (M_PI/2)) + end + start - 1.f;
}
GLfloat SinusoidalEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return -end/2.f * (cosf(M_PI*t) - 1.f) + start - 1.f;
}

GLfloat ExponentialEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * (-powf(2.f, -10.f * t) + 1.f ) + start - 1.f;
}
GLfloat ExponentialEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return end * powf(2.f, 10.f * (t - 1.f) ) + start - 1.f;
}
GLfloat ExponentialEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.f;
    if (t < 1.f) 
        return end/2.f * powf(2.f, 10.f * (t - 1.f) ) + start - 1.f;
    t--;
    return end/2.f * ( -powf(2.f, -10.f * t) + 2.f ) + start - 1.f;
}

GLfloat CircularEaseOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t--;
    return end * sqrtf(1.f - t * t) + start - 1.f;
}
GLfloat CircularEaseIn(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    return -end * (sqrtf(1.f - t * t) - 1.f) + start - 1.f;
}
GLfloat CircularEaseInOut(GLclampf t, GLfloat start, GLfloat end)
{
    BoundsCheck(t, start, end);
    t *= 2.f;
    if (t < 1.f) 
        return -end/2.f * (sqrtf(1.f - t * t) - 1.f) + start - 1.f;
    t -= 2.f;
    return end/2.f * (sqrtf(1.f - t * t) + 1.f) + start - 1.f;
}