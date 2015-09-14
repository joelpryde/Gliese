//
//  MapManager.m
//  gliese
//
//  Created by Joel Pryde on 11/15/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import "MapManager.h"
#import "MapLayer.h"
#import "glFuncs.h"
#import "MainGLView.h"

@implementation MapManager

static MapManager* sharedInstance = nil;

+ (MapManager*)Instance
{
    return sharedInstance;
}

-(id)init
{
    [super init];
    
    // setup initial layer
    _layers = [[NSMutableArray alloc] init];
    MapLayer* layer = [[MapLayer alloc] init];
    layer.selected = true;
    [_layers addObject:layer];
    
    sharedInstance = self;
    return self;
}

- (void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event
{    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:[MainGLView Instance]];
    
    // try to select a pt
    for (MapLayer* layer in _layers)
    {
        if (layer.selected)
        {
            if ([layer downPtLayer:CGPointMake(location.x/1024, 1-location.y/768)])
            {
                [pool release];
                return;
            }
        }
    }
    
    // select a layer if we have no pt selected
    for (MapLayer* layer in _layers)
    {
        if ([layer downSelectLayer:CGPointMake(location.x/1024, 1-location.y/768)])
        {
            // unselect other layers and select this one
            for (MapLayer* layer in _layers)
                layer.selected = false;
            layer.selected = true;
            [pool release];
            return;
        }
    }
    
    // otherwise unselect everything
    for (MapLayer* layer in _layers)
        layer.selected = false;
    
    [pool release];
}

- (void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:[MainGLView Instance]];
    
    for (MapLayer* layer in _layers)
    {
        if (layer.selected)
            [layer movePtLayer:CGPointMake(location.x/1024, 1-location.y/768)];
    }
    [pool release];
}

- (void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:[MainGLView Instance]];
    
    for (MapLayer* layer in _layers)
    {
        if (layer.selected)
            [layer upPtLayer:CGPointMake(location.x/1024, 1-location.y/768)];
    }
    [pool release];
}

-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    
}

-(void)doubleTap:(CGPoint)pt
{
    // first check to see if we are inside of a layer
    for (MapLayer* layer in _layers)
    {
        if ([layer pointInside:pt])
        {
            [_layers removeObject:layer];
            return;
        }
    }
    
    [_layers addObject:[[MapLayer alloc] initAtPt:pt]];
}

-(void)drawUI
{
    // draw the layers
    for (MapLayer* layer in _layers)
    {
        if (layer.selected)
            [layer drawUI];
    }
}

-(void)drawInput
{
    drawRect(CGRectMake(0.0, 0.0, 1.0, 1.0));
}

-(void)drawOutput
{
    // draw the layers
    for (MapLayer* layer in _layers)
        [layer drawOutput];
}

-(void)addNewLayer
{
    for (MapLayer* layer in _layers)
        layer.selected = false;
    MapLayer* layer = [[MapLayer alloc] init];
    [_layers addObject:layer];
    layer.selected = true;
    
}

-(void)deleteCurrentLayer
{
    for (MapLayer* layer in _layers)
    {
        if (layer.selected)
            [_layers removeObject:layer];
    }
}

@end
