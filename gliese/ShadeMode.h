//
//  VJMode.h
//  gliese
//
//  Created by Joel Pryde on 11/26/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModeProtocol.h"

@class GLButton;

@interface ShadeMode : NSObject <ModeProtocol>
{
    GLButton* _infoButton;
    GLButton* _closeButton;
    NSMutableArray* _buttons;
    GLButton* _sizeButton;
    //GLButton* _modeButton;
    bool _isShowingButtons;
    
    int _sizeMode;
    CGPoint _mousePt;
    
    CFTimeInterval  _animStartTime;
}

@property (readonly) int sizeMode;
@property (readonly) CGPoint mousePt;
@property (readonly) bool isShowingButtons;

+ (ShadeMode*)Instance;

// drawing
-(void)draw;
-(void)drawComposite;

// touches
-(void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event;

-(void)setShaderParams:(NSSet *)inTouches withEvent:(UIEvent *)event;

@end
