//
//  GLView.h
//  OpenGLES_iPhone
//
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define TEXTURE_COUNT 1

@class ShaderManager;
@class MapManager;
@class EAGLContext;
@protocol ModeProtocol;
@class ShadeMode;
@class MapMode;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface MainGLView : UIView 
{
@private
    EAGLContext *context;
    
    GLuint _textures[TEXTURE_COUNT];
    GLuint _fftTexture;
    GLfloat *_fftData;
    GLubyte *_saveImageBuffer;
    
    ShaderManager* _shaderManager;
    MapManager* _mapManager;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
        
    // normal display framebuffer
    GLuint _defaultFramebuffer, _colorRenderbuffer;
        
    // composite framebuffer
    int _currentComposite;
    GLuint _compositeTexture[3][2];
	GLuint _compositeRenderbuffer[3][2], _compositeFramebuffer[3][2];
    
    double _audioTime;
    CFTimeInterval _startTime;
    
    ShadeMode* _shadeMode;
    MapMode* _mapMode;
    id<ModeProtocol> _currentMode;
    bool _isPortrait;
    bool _isTweetCapturing;
}

@property (nonatomic, retain) EAGLContext *context;
@property (readonly) GLuint* textures;
@property (readonly) ShadeMode* shadeMode;
@property (readonly) MapMode* mapMode;
@property (readonly) bool isPortrait;

+(MainGLView*)Instance;
-(int)Width;
-(int)Height;
-(int)UIWidth;
-(int)UIHeight;

-(id)initWithFrame:(CGRect)frame;
-(id)initWithFrame:(CGRect)frame pixelFormat:(GLuint)format;
-(id)initWithFrame:(CGRect)frame pixelFormat:(GLuint)format depthFormat:(GLuint)depth preserveBackbuffer:(BOOL)retained;

-(void)setup;
-(void)setupTextures;

-(void)setDisplayFramebuffer;
-(void)setCompositeFramebuffer;
-(BOOL)presentFramebuffer;
-(GLuint)getCompositeTexture;

-(void)updateFFTTexture;
-(UIImage*)saveBufferToImageWidth:(int)width Height:(int)height;
-(void)compositeDraw;
-(void)draw;
-(void)drawNormRect:(CGRect)normRect at:(CGRect)destRect;
-(void)drawTextureRect:(CGRect)textureRect at:(CGRect)destRect;

-(float)getTime;
-(void)setMode:(bool)shadeMode;
-(void)setOrientation:(UIInterfaceOrientation)interfaceOrientation;
-(void)tweetCapture:(UIImage*)captureImage;
-(void)tweetImage;

@end
