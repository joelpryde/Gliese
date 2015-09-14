//
//  MapMode.m
//  gliese
//
//  Created by Joel Pryde on 11/26/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import "MapMode.h"
#import "ShaderManager.h"
#import "MapManager.h"
#import "MainGLView.h"
#import "glFuncs.h"
#import "GLButton.h"
#import "GLShaderFuncs.h"
#import "glieseCoords.h"

#import <QuartzCore/QuartzCore.h>

@implementation MapMode

-(id)init
{
    [super init];
    
    _buttons = [[NSMutableArray alloc] init];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shadeReleased:) name:@"shadeReleaseEventType" object:nil ];
    _modeButton = [[GLButton alloc] initWithDimensions:CGRectMake( 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_SHADE PressedTextureRect:COORDS_GLIESE_BUTTON_SHADE_PRESS PressSelector:@"shadePressEventType" ReleaseSelector:@"shadeReleaseEventType"];
    [_buttons addObject:_modeButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMapReleased:) name:@"newMapReleaseEventType" object:nil ];
    _mapNewButton = [[GLButton alloc] initWithDimensions:CGRectMake( 1 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_MAPNEW PressedTextureRect:COORDS_GLIESE_BUTTON_MAPNEW_PRESS PressSelector:@"newMapPressEventType" ReleaseSelector:@"newMapReleaseEventType"];
	[_buttons addObject:_mapNewButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMapReleased:) name:@"deleteMapReleaseEventType" object:nil ];
    _mapDeleteButton = [[GLButton alloc] initWithDimensions:CGRectMake( 2 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_MAPDELETE PressedTextureRect:COORDS_GLIESE_BUTTON_MAPDELETE_PRESS PressSelector:@"deleteMapPressEventType" ReleaseSelector:@"deleteMapReleaseEventType"];
	[_buttons addObject:_mapDeleteButton];
    
    return self;
}

/*
 Drawing
*/


-(void)draw
{
    // draw mapping layers
    [self drawLayersOutput];
    //[self drawLayersInput];
    
    glUseProgram([ShaderManager Instance].textureProgram);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [MainGLView Instance].textures[0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, 1024, 768, 0, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    GLint texture1Uniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "s_texture");
    glUniform1i(texture1Uniform, 0);
    
    // draw buttons
    [[MainGLView Instance] drawTextureRect:COORDS_GLIESE_BUTTON_BACK at:CGRectMake(0, 0, 1024, 66)];
    for (GLButton* button in _buttons)
        [button draw];
    
    // draw map layer's ui
    [[MapManager Instance] drawUI];
}

-(void)drawLayersOutput
{
    // setup viewport
    glViewport(0, 0, [[MainGLView Instance] Width], [[MainGLView Instance] Height]);
    
    // Use shader program.
    glUseProgram([ShaderManager Instance].mappingProgram);
    
    // setup projection
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, 1, 1, 0, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].mappingProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    // draw output
    glBindTexture(GL_TEXTURE_2D, [[MainGLView Instance] getCompositeTexture]);
    [[MapManager Instance] drawOutput];
}

-(void)drawLayersInput
{
    // setup viewport
    glViewport(0, 0, 1024, 768);
    
    // Use shader program.
    glUseProgram([ShaderManager Instance].textureProgram);
    
    // setup projection
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, 1, 1, 0, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    // draw input
    glBindTexture(GL_TEXTURE_2D, [[MainGLView Instance] getCompositeTexture]);
    [[MapManager Instance] drawInput];
}

/*
 Handle Touches
*/

- (void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    bool buttonPress = false;
    for (GLButton* button in _buttons)
        buttonPress |= [button touchesBegan:inTouches withEvent:event];
    if (!buttonPress)
        [[MapManager Instance] touchesBegan:inTouches withEvent:event];
}

- (void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    for (GLButton* button in _buttons)
        [button touchesMoved:inTouches withEvent:event];
	[[MapManager Instance] touchesMoved:inTouches withEvent:event];
}

- (void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    for (GLButton* button in _buttons)
        [button touchesEnded:inTouches withEvent:event];
	[[MapManager Instance] touchesEnded:inTouches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    [[MapManager Instance] touchesCancelled:inTouches withEvent:event];
}

-(void)doubleTap:(CGPoint)pt
{
    [[MapManager Instance] doubleTap:CGPointMake(pt.x/1024, pt.y/768)];
}

-(void)shadeReleased:(NSNotification *) notification
{
    [[MainGLView Instance] setMode:true];
}

-(void)newMapReleased:(NSNotification *) notification
{
    [[MapManager Instance] addNewLayer];
}

-(void)deleteMapReleased:(NSNotification *) notification
{
    [[MapManager Instance] deleteCurrentLayer];
}


@end
