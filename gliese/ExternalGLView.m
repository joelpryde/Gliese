//
//  GLView.m
//  OpenGLES_iPhone
//
//  Created by mmalc Crawford on 11/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ExternalGLView.h"
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <CoreMedia/CoreMedia.h>

#import "ShaderManager.h"
//#import "MapManager.h"
#import "glFuncs.h"
#import "GLShaderFuncs.h"
#import "MainGLView.h"

@interface ExternalGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation ExternalGLView

static ExternalGLView* sharedInstance = nil;

+ (ExternalGLView*)Instance
{
    return sharedInstance;
}

@synthesize context;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:.
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self) 
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;    
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        sharedInstance = self;
    }
    
    return self;
}

-(void)setup
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:[[MainGLView Instance].context sharegroup]];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    	
    [self setContext:aContext];
    [self setFramebuffer];
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    
    [context release];
    [super dealloc];
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext) 
    {
        [self deleteFramebuffer];        
        [context release];
        context = [newContext retain];
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer) 
    {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);    
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    if (context) 
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) 
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) 
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context) 
    {
        [EAGLContext setCurrentContext:context];
        if (!defaultFramebuffer)
            [self createFramebuffer];
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);    
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context) 
    {
        [EAGLContext setCurrentContext:context];    
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return success;
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
}

/*
    Handle Drawing
*/

-(void)draw
{
    [EAGLContext setCurrentContext:context];
    [self setFramebuffer];
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // setup viewport
    glViewport(0, 0, self.window.frame.size.width, self.window.frame.size.height);
    
    // draw mapping layers
    [self drawLayers];
    [self presentFramebuffer];
}

-(void)drawLayers
{
    // Use shader program.
    glUseProgram([ShaderManager Instance].textureProgram);
    
    // setup projection
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, 1, 0, 1, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].textureProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);

    glBindTexture(GL_TEXTURE_2D, [[MainGLView Instance] getCompositeTexture]);
    drawRect(CGRectMake(0, 0, 1, 1));
    //[[MapManager Instance] drawOutputWithProgram:[ShaderManager Instance].mappingProgram];
}

@end
