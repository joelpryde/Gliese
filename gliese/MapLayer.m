//
//  MapLayer.m
//  gliese
//
//  Created by Joel Pryde on 11/3/11.
//  Copyright 2011 Physipop. All rights reserved.
//

#import "MapLayer.h"
#import "ShaderManager.h"
#import "MainGLView.h"
#import "glieseCoords.h"
#import "glFuncs.h"

float sign(CGPoint p1, CGPoint p2, CGPoint p3)
{
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
}

bool PointInTriangle(CGPoint pt, CGPoint v1, CGPoint v2, CGPoint v3)
{
    bool b1, b2, b3;
    
    b1 = sign(pt, v1, v2) < 0.0f;
    b2 = sign(pt, v2, v3) < 0.0f;
    b3 = sign(pt, v3, v1) < 0.0f;
    
    return ((b1 == b2) && (b2 == b3));
}

@implementation MapLayer

@synthesize selected = _selected;

-(id)init
{
    self = [super init];
    if (self) 
    {
        // tl pt
        float start = 0.0f;
        float end = 1.0f;
        _pts[0]._pt.x = start;
        _pts[0]._pt.y = start;
        
        // tr pt
        _pts[1]._pt.x = end;
        _pts[1]._pt.y = start;
        
        // bl pt
        _pts[2]._pt.x = start;
        _pts[2]._pt.y = end;
        
        // br pt
        _pts[3]._pt.x = end;
        _pts[3]._pt.y = end;

    }
    
    return self;
}

-(id)initAtPt:(CGPoint)pt
{
    self = [super init];
    if (self) 
    {
        float size = 0.1f;
        CGPoint newPt = CGPointMake(pt.x, pt.y);
        
        // tl pt
        _pts[0]._pt.x = newPt.x - size;
        _pts[0]._pt.y = newPt.y - size;
        
        // tr pt
        _pts[1]._pt.x = newPt.x + size;
        _pts[1]._pt.y = newPt.y - size;
        
        // bl pt
        _pts[2]._pt.x = newPt.x - size;
        _pts[2]._pt.y = newPt.y + size;
        
        // br pt
        _pts[3]._pt.x = newPt.x + size;
        _pts[3]._pt.y = newPt.y + size;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)drawUI
{
    for (int i=0; i<4; i++)
    {
        [[MainGLView Instance] drawTextureRect:_pts[i]._selected ? COORDS_GLIESE_MAPPT_PRESS : COORDS_GLIESE_MAPPT at:CGRectMake(_pts[i]._pt.x * 1024.0 - 55.0/2, (768.0 - _pts[i]._pt.y * 768.0) - 55.0/2, 55.0, 55.0)];
    }
}

-(void)drawOutput
{
    GLint selectedUniform = glGetUniformLocation([ShaderManager Instance].mappingProgram, "selected");
    glUniform1i(selectedUniform, _selected ? 1 : 0);
    drawWarpRectPts([ShaderManager Instance].mappingProgram, _pts[0]._pt, _pts[1]._pt, _pts[2]._pt, _pts[3]._pt, 4, 4);
}

-(bool)downPtLayer:(CGPoint)pt
{
    // check each pt
    for (int i=0; i<4; i++)
    {
        float offset=0.03f;
        CGRect testRect = CGRectMake( _pts[i]._pt.x - offset, _pts[i]._pt.y - offset, offset*2, offset*2 ); 
        if (CGRectContainsPoint(testRect, pt))
        {
            _pts[i]._selected = true;
            return true;
        }
    }
    return false;
}

-(bool)downSelectLayer:(CGPoint)pt
{
    return [self pointInside:pt];
}

-(void)movePtLayer:(CGPoint)pt
{
    // check each pt
    for (int i=0; i<4; i++)
    {
        if (_pts[i]._selected)
        {
            CGPoint testPt = CGPointMake(pt.x, pt.y);
            _pts[i]._pt.x = testPt.x;
            _pts[i]._pt.y = testPt.y;
        }
    }
}

-(void)upPtLayer:(CGPoint)pt
{
    // check each pt
    for (int i=0; i<4; i++)
    {
        _pts[i]._selected = false;
    }
}

-(bool)pointInside:(CGPoint)pt
{
    return (PointInTriangle(pt, _pts[0]._pt, _pts[1]._pt, _pts[2]._pt) ||
            PointInTriangle(pt, _pts[1]._pt, _pts[3]._pt, _pts[2]._pt) );
}


@end
