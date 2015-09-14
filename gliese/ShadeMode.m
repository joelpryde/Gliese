//
//  ShadeMode.m
//  gliese
//
//  Created by Joel Pryde on 11/26/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import "ShadeMode.h"
#import "MainGLView.h"
#import "glFuncs.h"
#import "GLShaderFuncs.h"
#import "ShaderManager.h"
#import "Globals.h"
#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "GLButton.h"
#import "ViewController.h"
#import "glieseCoords.h"
#import "GLEasing.h"

@implementation ShadeMode

@synthesize sizeMode = _sizeMode;
@synthesize mousePt = _mousePt;
@synthesize isShowingButtons = _isShowingButtons;

static ShadeMode* sharedInstance = nil;

+ (ShadeMode*)Instance
{
    return sharedInstance;
}

-(id)init
{
    [super init];
    sharedInstance = self;
    
    _buttons = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoReleased:) name:@"infoReleaseEventType" object:nil ];
	_infoButton = [[GLButton alloc] initWithDimensions:CGRectMake( 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_INFO PressedTextureRect:COORDS_GLIESE_BUTTON_INFO_PRESS PressSelector:@"infoPressEventType" ReleaseSelector:@"infoReleaseEventType"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeReleased:) name:@"closeReleaseEventType" object:nil ];
	_closeButton = [[GLButton alloc] initWithDimensions:CGRectMake( 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_CLOSE_PRESS PressedTextureRect:COORDS_GLIESE_BUTTON_CLOSE PressSelector:@"closePressEventType" ReleaseSelector:@"closeReleaseEventType"];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectReleased:) name:@"selectReleaseEventType" object:nil ];
	[_buttons addObject:[[GLButton alloc] initWithDimensions:CGRectMake( 1 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_SELECT PressedTextureRect:COORDS_GLIESE_BUTTON_SELECT_PRESS PressSelector:@"selectPressEventType" ReleaseSelector:@"selectReleaseEventType"]];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editReleased:) name:@"editReleaseEventType" object:nil ];
	[_buttons addObject:[[GLButton alloc] initWithDimensions:CGRectMake( 2 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_EDIT PressedTextureRect:COORDS_GLIESE_BUTTON_EDIT_PRESS PressSelector:@"editPressEventType" ReleaseSelector:@"editReleaseEventType"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeReleased:) name:@"sizeReleaseEventType" object:nil ];
    _sizeButton = [[GLButton alloc] initDimensions:CGRectMake( 3 * 60 + 10, 7, 50, 50 ) PressSelector:@"sizePressEventType" ReleaseSelector:@"sizeReleaseEventType"];
    [_sizeButton addModeTextureRect:COORDS_GLIESE_BUTTON_SCREEN1 PressedTextureRect:COORDS_GLIESE_BUTTON_SCREEN1_PRESS];
    [_sizeButton addModeTextureRect:COORDS_GLIESE_BUTTON_SCREEN2 PressedTextureRect:COORDS_GLIESE_BUTTON_SCREEN2_PRESS];
    [_sizeButton addModeTextureRect:COORDS_GLIESE_BUTTON_SCREEN4 PressedTextureRect:COORDS_GLIESE_BUTTON_SCREEN4_PRESS];
	[_buttons addObject:_sizeButton];
    [_sizeButton nextMode];
    _sizeMode = _sizeButton.mode;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetReleased:) name:@"tweetReleaseEventType" object:nil ];
	[_buttons addObject:[[GLButton alloc] initWithDimensions:CGRectMake( 4 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_TWEET PressedTextureRect:COORDS_GLIESE_BUTTON_TWEET_PRESS PressSelector:@"tweetPressEventType" ReleaseSelector:@"tweetReleaseEventType"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(helpReleased:) name:@"helpReleaseEventType" object:nil ];
	[_buttons addObject:[[GLButton alloc] initWithDimensions:CGRectMake( 5 * 60 + 10, 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_HELP PressedTextureRect:COORDS_GLIESE_BUTTON_HELP_PRESS PressSelector:@"helpPressEventType" ReleaseSelector:@"helpReleaseEventType"]];
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modeReleased:) name:@"modeReleaseEventType" object:nil ];
	_modeButton = [[GLButton alloc] initWithDimensions:CGRectMake( 768 - (1 * 60 + 10), 7, 50, 50 ) TextureRect:COORDS_GLIESE_BUTTON_MAP PressedTextureRect:COORDS_GLIESE_BUTTON_MAP_PRESS PressSelector:@"modePressEventType" ReleaseSelector:@"modeReleaseEventType"];
	[_buttons addObject:_modeButton];*/
    
    return self;
}

/* 
 drawing
*/

-(double)getLerpValue
{
    double timeElapsed = CFAbsoluteTimeGetCurrent() - _animStartTime;
    if (_isShowingButtons)
        return QuadraticEaseInOut(timeElapsed*4.0, 0.0, 10.0)/10.0;
    else
        return (10.0 - QuadraticEaseInOut(timeElapsed*4.0, 0.0, 10.0))/10.0;        
}

-(void)draw
{
    // draw composite
    [self drawComposite];
    
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
    //gldOrtho(projection, 0, [MainGLView Width], [MainGLView Height], 0, -1, 1);
    gldOrtho(projection, 0, [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight], 0, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    GLint texture1Uniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "s_texture");
    glUniform1i(texture1Uniform, 0);
    
    // draw buttons
    if (![[ViewController Instance] isInShaderView])
    {
        double lerpValue = [self getLerpValue];
        //NSLog(@"%f", lerpValue);
        [[MainGLView Instance] drawTextureRect:COORDS_GLIESE_BUTTON_BACK at:CGRectMake(-2, -68 + lerpValue * 66, [[MainGLView Instance] UIWidth]+2, 66)];
        if (_isShowingButtons)
        {
            [_closeButton draw];
        }
        else
            [_infoButton draw];
            
        for (GLButton* button in _buttons)
            [button draw:lerpValue];
    }
}

-(void)drawComposite
{
    glUseProgram([ShaderManager Instance].textureProgram);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [[MainGLView Instance] getCompositeTexture]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, [[MainGLView Instance] UIWidth], 0, [[MainGLView Instance] UIHeight], -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    GLint texture1Uniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "s_texture");
    glUniform1i(texture1Uniform, 0);
    
    // draw shaded buffer
    CGRect viewFrame = [MainGLView Instance].isPortrait ? CGRectMake(0, 0, [MainGLView Instance].frame.size.width, [MainGLView Instance].frame.size.height) : CGRectMake(0, 0, [MainGLView Instance].frame.size.width, [MainGLView Instance].frame.size.height);
    if ([[ViewController Instance] isInShaderView])
        [[MainGLView Instance] drawNormRect:CGRectMake(0, 0, 1, 1) at:viewFrame];
    else 
    {
        if ([ViewController Instance].isEditing)
        {
            if ([MainGLView Instance].isPortrait)
                [[MainGLView Instance] drawNormRect:CGRectMake(0, 0, 1, 1) at:CGRectMake(0, (264 + 44), [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight] - (264 + 44))];
            else
                [[MainGLView Instance] drawNormRect:CGRectMake(0, 0, 1, 1) at:CGRectMake(0, (264 + 44), [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight] - (264 + 44))];
        }
        else
            [[MainGLView Instance] drawNormRect:CGRectMake(0, 0, 1, 1) at:viewFrame];
    }
        
}

-(void)setShaderParams:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:[MainGLView Instance]];
    _mousePt = CGPointMake(location.x/[[MainGLView Instance] UIWidth], 1.0f - location.y/[[MainGLView Instance] UIHeight]);
}

/* 
 touches
*/

-(void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
    bool infoPressed = false;
    if (![[ViewController Instance] isInShaderView])
    {
        if (_isShowingButtons)
            infoPressed = [_closeButton touchesBegan:touches withEvent:event];
        else
            infoPressed = [_infoButton touchesBegan:touches withEvent:event];
        if (_isShowingButtons)
        {
            for (GLButton* button in _buttons)
                [button touchesBegan:touches withEvent:event];
        }
    }
    
    if (!infoPressed && [touches count] > 0)
    {
        if (![[ViewController Instance] isInShaderView])
            [self setShaderParams:inTouches withEvent:event];
    }
    [pool release];
}

-(void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
    if (![[ViewController Instance] isInShaderView])
    {
        if (_isShowingButtons)
            [_closeButton touchesMoved:touches withEvent:event];
        else
            [_infoButton touchesMoved:touches withEvent:event];
        if (_isShowingButtons)
        {
            for (GLButton* button in _buttons)
                [button touchesMoved:touches withEvent:event];
        }
    }
    
    if ([touches count] > 0)
    {
        if (![[ViewController Instance] isInShaderView])
            [self setShaderParams:inTouches withEvent:event];
    }
    [pool release];
}

-(void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableSet* touches = [[NSMutableSet alloc] initWithSet:inTouches];
    
    if (![[ViewController Instance] isInShaderView])
    {
        if (_isShowingButtons)
            [_closeButton touchesEnded:touches withEvent:event];
        else
            [_infoButton touchesEnded:touches withEvent:event];
        if (_isShowingButtons)
        {
            for (GLButton* button in _buttons)
                [button touchesEnded:touches withEvent:event];
        }
    }
    [pool release];
}

-(void)touchesCancelled:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    
}

/*
 Button presses
 */
-(void)infoReleased:(NSNotification *) notification
{
    _isShowingButtons = true;
    _animStartTime = CFAbsoluteTimeGetCurrent();

}
-(void)closeReleased:(NSNotification *) notification
{
    _isShowingButtons = false;
    _animStartTime = CFAbsoluteTimeGetCurrent();
}
-(void)selectReleased:(NSNotification *) notification
{
    [[ViewController Instance] showShaderView];
}
-(void)editReleased:(NSNotification *) notification
{
    [[ViewController Instance] showEdit:![ViewController Instance].isEditingShader];
}
-(void)sizeReleased:(NSNotification *) notification
{
    [_sizeButton nextMode];
    _sizeMode = _sizeButton.mode;
}
-(void)tweetReleased:(NSNotification *) notification
{
    [[MainGLView Instance] tweetImage];
}
-(void)helpReleased:(NSNotification *) notification
{
    [[ViewController Instance] pushHelpController];
}
-(void)modeReleased:(NSNotification *) notification
{
    [[MainGLView Instance] setMode:false];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}


@end
