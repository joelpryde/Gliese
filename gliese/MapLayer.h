//
//  MapLayer.h
//  gliese
//
//  Created by Joel Pryde on 11/3/11.
//  Copyright 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

float sign(CGPoint p1, CGPoint p2, CGPoint p3);
bool PointInTriangle(CGPoint pt, CGPoint v1, CGPoint v2, CGPoint v3);

struct LayerPt
{
    CGPoint _pt;
    CGPoint _uv;
    
    bool _selected;
    int _touchIdx;
};

@interface MapLayer : NSObject 
{
@private
    struct LayerPt _pts[4];
    int _selectedPt;
    bool _selected;
}

@property bool selected;

-(id)initAtPt:(CGPoint)pt;

-(void)drawUI;
-(void)drawOutput;
-(bool)downPtLayer:(CGPoint)pt;
-(bool)downSelectLayer:(CGPoint)pt;
-(void)movePtLayer:(CGPoint)pt;
-(void)upPtLayer:(CGPoint)pt;
-(bool)pointInside:(CGPoint)pt;

@end
