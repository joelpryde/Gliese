#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#define MAXMODES 10

@interface GLButton : NSObject 
{
	CGRect _dimensions;
    
    CGRect _textureRects[MAXMODES];
    CGRect _pressedTextureRects[MAXMODES];
		
	UITouch* _touch;
	NSString* _pressSelector;
	NSString* _releaseSelector;
	
	bool _isPressed;
    int _modeCount;
    int _mode;
}

@property(readonly) CGRect dimensions;
@property(readonly) UITouch* touch;
@property(readonly) bool isPressed;
@property(readonly) int mode;


- (id)initWithDimensions:(CGRect)dimensions TextureRect:(CGRect)textureRect PressedTextureRect:(CGRect)pressedTextureRect PressSelector:(NSString*)pressSelector ReleaseSelector:(NSString*)releaseSelector;
- (id)initDimensions:(CGRect)dimensions PressSelector:(NSString*)pressSelector ReleaseSelector:(NSString*)releaseSelector;
- (void)addModeTextureRect:(CGRect)textureRect PressedTextureRect:(CGRect)pressedTextureRect;
- (void)nextMode;
- (void)draw;
- (void)draw:(double)lerpValue;
- (bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
