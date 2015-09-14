//
//  MapMode.h
//  gliese
//
//  Created by Joel Pryde on 11/26/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModeProtocol.h"

@class GLButton;

@interface MapMode : NSObject <ModeProtocol>
{
    NSMutableArray* _buttons;
    GLButton* _modeButton;
    GLButton* _mapNewButton;
    GLButton* _mapDeleteButton;
}
// drawing
-(void)draw;
-(void)drawLayersOutput;
-(void)drawLayersInput;

// touches
-(void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event;


@end

