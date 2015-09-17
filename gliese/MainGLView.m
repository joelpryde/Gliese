//
//  GLView.m
//  OpenGLES_iPhone
//
//  Created by mmalc Crawford on 11/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <CoreMedia/CoreMedia.h>
#import <Twitter/TWTweetComposeViewController.h>

#import "Globals.h"
#import "ViewController.h"
#import "MainGLView.h"
#import "ShaderManager.h"
#import "Shader.h"
#import "MapManager.h"
#import "glieseCoords.h"
#import "GLFuncs.h"
#import "GLButton.h"

#import "ModeProtocol.h"
#import "ShadeMode.h"
#import "MapMode.h"

#define COMPOSITE_WIDTH 1024/4
#define COMPOSITE_HEIGHT 768/4

@interface MainGLView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation MainGLView

@synthesize context;
@synthesize shadeMode = _shadeMode;
@synthesize mapMode = _mapMode;
@synthesize isPortrait = _isPortrait;

static MainGLView* sharedInstance = nil;

+ (MainGLView*)Instance
{
    return sharedInstance;
}

-(int)Width
{
    float scale = [UIScreen mainScreen].scale;
    return [[MainGLView Instance] UIWidth] * scale;
}
-(int)Height
{
    float scale = [UIScreen mainScreen].scale;
    return [[MainGLView Instance] UIHeight] * scale;
}
-(int)UIWidth
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    return _isPortrait ? screenFrame.size.width : screenFrame.size.height;
}
-(int)UIHeight
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    return _isPortrait ? screenFrame.size.height : screenFrame.size.width;
}

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (GLuint *)textures
{
    return _textures;
}

- (id) initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame pixelFormat:GL_RGB565 depthFormat:0 preserveBackbuffer:NO];
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(GLuint)format 
{
	return [self initWithFrame:frame pixelFormat:format depthFormat:0 preserveBackbuffer:NO];
}

- (id) initWithFrame:(CGRect)frame pixelFormat:(GLuint)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained
{
	if((self = [super initWithFrame:frame])) 
	{
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        [self setup];
        sharedInstance = self;
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
        [self setup];
        sharedInstance = self;
    }
    
    
    return self;
}

-(void)setup
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
    _audioTime = 0.0;
    _startTime = CFAbsoluteTimeGetCurrent();
    [self setContext:aContext];
    self.multipleTouchEnabled = YES;
    [self setDisplayFramebuffer];
    _shaderManager = [[ShaderManager alloc] init];
    _mapManager = [[MapManager alloc] init];
    [self setupTextures];
    
    // create our modes
    _shadeMode = [[ShadeMode alloc] init];
    _mapMode = [[MapMode alloc] init];
    _currentMode = _shadeMode;    
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    
    // Tear down context.
    //if ([EAGLContext currentContext] == context)
    //    [EAGLContext setCurrentContext:nil];
    
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

// generate textures
- (void)setupTextures
{
    // create buffer to save images to
    _saveImageBuffer = (GLubyte *)malloc(1024*(768+30)*4);
	CGImageRef spriteImage;
	CGContextRef spriteContext;
	GLubyte *spriteData;
	size_t	width, height;
	
	// Use OpenGL ES to generate names for the textures.
	glGenTextures(TEXTURE_COUNT, _textures);
	
	for (int i=0; i < TEXTURE_COUNT; i++)
	{
		// Creates a Core Graphics image from an image file
		switch(i)
		{
			case 0: spriteImage = [UIImage imageNamed:@"glieseAtlas.png"].CGImage;	break;
		}
		
		// Get the width and height of the image
		width = CGImageGetWidth(spriteImage);
		height = CGImageGetHeight(spriteImage);
		
		if(spriteImage)
		{
			// Allocated memory needed for the bitmap context
			spriteData = (GLubyte *)malloc(width * height * 4);
			// Uses the bitmatp creation function provided by the Core Graphics framework.
			spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
			// After you create the context, you can draw the sprite image to the context.
			CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
			// You don't need the context at this point, so you need to release it to avoid memory leaks.
			CGContextRelease(spriteContext);
			// Bind the texture name. 
			glBindTexture(GL_TEXTURE_2D, _textures[i]);
			// Speidfy a 2D texture image, provideing the a pointer to the image data in memory
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, (size_t)0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
			// Release the image data
			free(spriteData);
		}
	}
    
    // create LUT texture
    glGenTextures(TEXTURE_COUNT, &_fftTexture);
    _fftData = (GLfloat *)malloc(128 * 4);
    glBindTexture(GL_TEXTURE_2D, _fftTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 128, 128, 0, GL_LUMINANCE, GL_FLOAT, _fftData);
    /*
    for (int i=0; i<128; i++)
    {
        lutData[i] = sinf((float)i/512.0f * PI * 2.0f);
    }
    glBindTexture(GL_TEXTURE_2D, _lutTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 512, 512, 0, GL_LUMINANCE, GL_FLOAT, lutData);
    free(lutData);*/
}


- (void)createFramebuffer
{
    if (context && !_defaultFramebuffer) 
    {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &_defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &_colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        
        
        // create composites
        _currentComposite = 0;
        for (int s = 0; s < 3; s++)
        {
            for (int i = 0; i < 2; i++)
            {
                // composite framebuffer object
                glGenFramebuffers(1, &_compositeFramebuffer[s][i]);
                glBindFramebuffer(GL_FRAMEBUFFER, _compositeFramebuffer[s][i]);
                glGenRenderbuffers(1, &_compositeRenderbuffer[s][i]);
                glBindRenderbuffer(GL_RENDERBUFFER, _compositeRenderbuffer[s][i]);
                glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, COMPOSITE_WIDTH * (int)powf(2, s), COMPOSITE_HEIGHT * (int)powf(2, s));
                glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _compositeRenderbuffer[s][i]);	
                
                // composite framebuffer texture target
                glGenTextures(1, &_compositeTexture[s][i]);
                glBindTexture(GL_TEXTURE_2D, _compositeTexture[s][i]);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                glHint(GL_GENERATE_MIPMAP_HINT, GL_NICEST);        
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, COMPOSITE_WIDTH * (int)powf(2, s), COMPOSITE_HEIGHT * (int)powf(2, s), 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
                glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _compositeTexture[s][i], 0);
            }
        }
    }
}

- (void)deleteFramebuffer
{
    if (context) 
    {
        [EAGLContext setCurrentContext:context];
        if (_defaultFramebuffer) 
        {
            glDeleteFramebuffers(1, &_defaultFramebuffer);
            _defaultFramebuffer = 0;
        }
        if (_colorRenderbuffer) 
        {
            glDeleteRenderbuffers(1, &_colorRenderbuffer);
            _colorRenderbuffer = 0;
        }
        
        for (int s=0; s<3; s++)
        {
            for (int i=0; i<2; i++)
            {
                if (_compositeRenderbuffer[s]) 
                {
                    glDeleteRenderbuffers(1, &_compositeRenderbuffer[s][i]);
                    _compositeRenderbuffer[s][i] = 0;
                }
            }
        }
    }
}

- (void)setDisplayFramebuffer
{
    if (context) 
    {
        [EAGLContext setCurrentContext:context];
        if (!_defaultFramebuffer)
            [self createFramebuffer];
        glBindFramebuffer(GL_FRAMEBUFFER, _defaultFramebuffer);
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}

- (void)setCompositeFramebuffer
{
    if (context)
    {
        if (!_defaultFramebuffer)
            [self createFramebuffer];
        glBindFramebuffer(GL_FRAMEBUFFER, _compositeFramebuffer[_shadeMode.sizeMode][_currentComposite]);
        glViewport(0, 0, [[MainGLView Instance] Width], [[MainGLView Instance] Height]);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    if (context) 
    {
        [EAGLContext setCurrentContext:context];    
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    return success;
}

-(GLuint)getCompositeTexture
{
    return _compositeTexture[_shadeMode.sizeMode][_currentComposite];
}

- (void)layoutSubviews
{
    // The framebuffer will be re-created at the beginning of the next setFramebuffer method call.
    [self deleteFramebuffer];
    
    // Set the scale factor to be the same as the main screen
    if ([self respondsToSelector: NSSelectorFromString(@"contentScaleFactor")]) 
    {
        [self setContentScaleFactor:[[UIScreen mainScreen] scale]];
    }
}

/*
 Handle Drawing
*/

-(void)updateFFTTexture
{
    for (int i=0; i<128; i++)
        _fftData[i] = [Globals Instance].currentBuffer[i] * 0.01;
    glBindTexture(GL_TEXTURE_2D, _fftTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, 128, 128, 0, GL_LUMINANCE, GL_FLOAT, _fftData);
}

-(UIImage*)saveBufferToImageWidth:(int)width Height:(int)height
{
    // read pixels
    glReadPixels(0,0,width,height,GL_RGBA,GL_UNSIGNED_BYTE, _saveImageBuffer);
    
    // save pixels
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, _saveImageBuffer, width*(height+30)*4, NULL);
    CGImageRef iref = CGImageCreate(width,height,8,32,width*4,CGColorSpaceCreateDeviceRGB(),
                                    kCGBitmapByteOrderDefault, ref, NULL, true, kCGRenderingIntentDefault);
    uint32_t* pixels = (uint32_t *)malloc(width*height*4);
    CGContextRef icontext = CGBitmapContextCreate(pixels, width, height, 8, width*4, CGImageGetColorSpace(iref), kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(icontext, 0.0, height);
    CGContextScaleCTM(icontext, 1.0, -1.0);
    CGContextDrawImage(icontext, CGRectMake(0.0, 0.0, width, height), iref);   
    CGImageRef outputRef = CGBitmapContextCreateImage(icontext);
    UIImage* image = [[UIImage alloc] initWithCGImage:outputRef];
    
    //Dealloc
	CGDataProviderRelease(ref);
	CGImageRelease(iref);
	CGContextRelease(icontext);
	free(pixels);
    
    return image;
}

-(void)compositeDraw
{
    [self setCompositeFramebuffer];
    
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // setup viewport
    glViewport(0, 0, COMPOSITE_WIDTH * (int)powf(2, _shadeMode.sizeMode), COMPOSITE_HEIGHT * (int)powf(2, _shadeMode.sizeMode));
            
    // Use shader program.
    glUseProgram([ShaderManager Instance].currentProgram);
    
    GLint texture2Uniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "audioBuffer");
    glUniform1i(texture2Uniform, 0);
    GLint texture1Uniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "backBuffer");
    glUniform1i(texture1Uniform, 1);
    
    // bind fft texture
    [self updateFFTTexture];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _fftTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    // bind back buffer
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _compositeTexture[_shadeMode.sizeMode][(_currentComposite == 0) ? 1 : 0]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);    
    
    // setup projection
    float projection[16];
    gldLoadIdentity(projection);
    gldOrtho(projection, 0, 1, 0, 1, -1, 1);
    GLint projectionUniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "projection");
    glUniformMatrix4fv(projectionUniform, 1, 0, &projection[0]);
    
    GLint timeUniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "time");
    glUniform1f(timeUniform, [self getTime]);
    //glUniform1f(timeUniform, [Globals Instance].audioLevel * 10.0);
    //glUniform1f(timeUniform, [[Globals Instance] updateAudioPeak]);
    
    GLint mouseUniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "mouse");
    glUniform2f(mouseUniform, _shadeMode.mousePt.x, _shadeMode.mousePt.y);
    GLint resolutionUniform = glGetUniformLocation([ShaderManager Instance].currentProgram, "resolution");
    glUniform2f(resolutionUniform, COMPOSITE_WIDTH * (int)powf(2, _shadeMode.sizeMode), COMPOSITE_HEIGHT * (int)powf(2, _shadeMode.sizeMode));
        
    drawRect(CGRectMake(0.0, 0.0, 1.0, 1.0));
    
    // draw shader/twitter image
    if ( [ShaderManager Instance].currentShader != nil && (![ShaderManager Instance].currentShader.hasImage || _isTweetCapturing))
    {
        int width = COMPOSITE_WIDTH * (int)powf(2, _shadeMode.sizeMode);
        int height = COMPOSITE_HEIGHT * (int)powf(2, _shadeMode.sizeMode);
        UIImage* image = [self saveBufferToImageWidth:width Height:height];
        if (_isTweetCapturing)
        {
            //[self tweetCapture:image];
        }
        else
            [[ShaderManager Instance].currentShader saveImage:image];
    }
}

-(void)draw
{   
    [EAGLContext setCurrentContext:context];
    
    // draw composite
    [self compositeDraw];
    
    // draw into display framebuffer
    [self setDisplayFramebuffer];
    
    // clear
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // setup viewport
    glViewport(0, 0, [[MainGLView Instance] Width], [[MainGLView Instance] Height]);
    
    // draw UI
    [_currentMode draw];
        
    // present framebuffer
    [self presentFramebuffer];
    _currentComposite = (_currentComposite + 1) % 2;
}

-(void)drawNormRect:(CGRect)normRect at:(CGRect)destRect
{    
    // setup layer
    GLfloat squareVertices[] = {
        destRect.origin.x,                          destRect.origin.y,
        destRect.origin.x + destRect.size.width,    destRect.origin.y,
        destRect.origin.x,                          destRect.origin.y + destRect.size.height,
        destRect.origin.x + destRect.size.width,    destRect.origin.y + destRect.size.height,
    };
    
    GLfloat textureVertices[] = {
        normRect.origin.x,                               normRect.origin.y,
        normRect.origin.x + normRect.size.width,         normRect.origin.y,
        normRect.origin.x,                               normRect.origin.y + normRect.size.height,
        normRect.origin.x + normRect.size.width,         normRect.origin.y + normRect.size.height,
    };
        
    // draw layer
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


-(void)drawTextureRect:(CGRect)textureRect at:(CGRect)destRect
{    
    // setup layer
    GLfloat squareVertices[] = {
        destRect.origin.x,                          destRect.origin.y,
        destRect.origin.x + destRect.size.width,    destRect.origin.y,
        destRect.origin.x,                          destRect.origin.y + destRect.size.height,
        destRect.origin.x + destRect.size.width,    destRect.origin.y + destRect.size.height,
    };
    
    GLfloat textureVertices[] = {
        textureRect.origin.x,                               textureRect.origin.y,
        textureRect.origin.x + textureRect.size.width,      textureRect.origin.y,
        textureRect.origin.x,                               textureRect.origin.y + textureRect.size.height,
        textureRect.origin.x + textureRect.size.width,      textureRect.origin.y + textureRect.size.height,
    };
    
    for (int i=0; i<8; i++)
        textureVertices[i] = textureVertices[i] / 1024.0f;
    
    // draw layer
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(1);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

-(float)getTime
{
    CFTimeInterval currentTime = CFAbsoluteTimeGetCurrent();
    CFTimeInterval difference = currentTime - _startTime;
    return difference;
}

-(void)setMode:(bool)shadeMode
{
    _currentMode = shadeMode ? _shadeMode : _mapMode;
}

-(void)setOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    _isPortrait = (interfaceOrientation == UIDeviceOrientationPortrait ||
                     interfaceOrientation == UIDeviceOrientationPortraitUpsideDown);
}

/*
-(void)tweetCapture:(UIImage*)captureImage
{
    _isTweetCapturing = false;
    
    TWTweetComposeViewController* tweetView = [[TWTweetComposeViewController alloc] init];
    [tweetView setInitialText:@"I made this with #glieseapp!"];
    [tweetView addImage:captureImage];
    
    TWTweetComposeViewControllerCompletionHandler 
    completionHandler = ^(TWTweetComposeViewControllerResult result) 
    {
        switch (result)
        {
            case TWTweetComposeViewControllerResultCancelled:
                NSLog(@"Twitter Result: canceled");
                break;
            case TWTweetComposeViewControllerResultDone:
                NSLog(@"Twitter Result: sent");
                break;
            default:
                NSLog(@"Twitter Result: default");
                break;
        }
        [[ViewController Instance] dismissModalViewControllerAnimated:YES];
    };
    [tweetView setCompletionHandler:completionHandler];
    [[ViewController Instance] presentModalViewController:tweetView animated:YES];
}*/


/*
 Handle Touches
 */

- (void)touchesBegan:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    [_currentMode touchesBegan:inTouches withEvent:event];
}

- (void)touchesMoved:(NSSet *)inTouches withEvent:(UIEvent *)event
{
    [_currentMode touchesMoved:inTouches withEvent:event];
}

- (void)touchesEnded:(NSSet *)inTouches withEvent:(UIEvent *)event
{   
    [_currentMode touchesEnded:inTouches withEvent:event];
}

- (void)tweetImage
{
    _isTweetCapturing = true;
}

@end
