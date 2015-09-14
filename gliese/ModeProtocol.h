//
//  Mode.h
//  gliese
//
//  Created by Joel Pryde on 11/26/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModeProtocol <NSObject>

// drawing
-(void)draw;

// touches
-(void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event;
-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event;

@end
