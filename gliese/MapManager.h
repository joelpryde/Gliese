//
//  MapManager.h
//  gliese
//
//  Created by Joel Pryde on 11/15/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EAGLView;
@class MapLayer;

@interface MapManager : NSObject
{
    NSMutableArray* _layers;
    
    GLuint _MapFrameTexture;
    GLuint _MapFrameUniform;
}

+ (MapManager*)Instance;

- (void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event;

-(void)doubleTap:(CGPoint)pt;
-(void)drawUI;
-(void)drawInput;
-(void)drawOutput;

-(void)addNewLayer;
-(void)deleteCurrentLayer;

@end
