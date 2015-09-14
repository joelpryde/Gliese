#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "MainGLView.h"
#import "GLButton.h"

@implementation GLButton

@synthesize dimensions = _dimensions;
@synthesize touch = _touch;
@synthesize isPressed = _isPressed;
@synthesize mode = _mode;

- (id)initWithDimensions:(CGRect)dimensions TextureRect:(CGRect)textureRect PressedTextureRect:(CGRect)pressedTextureRect PressSelector:(NSString*)pressSelector ReleaseSelector:(NSString*)releaseSelector
{
    [self initDimensions:dimensions PressSelector:pressSelector ReleaseSelector:releaseSelector];
    _textureRects[0] = textureRect;
    _pressedTextureRects[0] = pressedTextureRect;
    _modeCount = 1;
	
	return self;
}

- (id)initDimensions:(CGRect)dimensions PressSelector:(NSString*)pressSelector ReleaseSelector:(NSString*)releaseSelector
{
    _dimensions = dimensions;
    _modeCount = 0;
	_isPressed = false;
	_pressSelector = [pressSelector copy];
	_releaseSelector = [releaseSelector copy];
    
	return self;
}

- (void)addModeTextureRect:(CGRect)textureRect PressedTextureRect:(CGRect)pressedTextureRect
{
    _modeCount++;
    _textureRects[_modeCount-1] = textureRect;
    _pressedTextureRects[_modeCount-1] = pressedTextureRect;
}

- (void)nextMode
{
    _mode = (_mode+1) % _modeCount;
}

- (void)draw
{
	CGRect textureRect;
    textureRect = _isPressed ? _pressedTextureRects[_mode] : _textureRects[_mode];
	[[MainGLView Instance] drawTextureRect:textureRect at:_dimensions];
}

- (void)draw:(double)lerpValue
{
	CGRect textureRect;
    textureRect = _isPressed ? _pressedTextureRects[_mode] : _textureRects[_mode];
	[[MainGLView Instance] drawTextureRect:textureRect at:CGRectMake(_dimensions.origin.x, _dimensions.origin.y - 66.0 * (1.0 - lerpValue), _dimensions.size.width, _dimensions.size.height)];
}

- (bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 0) return false;
	UITouch *touch = [[touches allObjects] objectAtIndex:0];
	CGPoint location = [touch locationInView:[MainGLView Instance]];
	if (CGRectContainsPoint(_dimensions, location))
	{
		_touch = touch;
		[[NSNotificationCenter defaultCenter] postNotificationName:_pressSelector object:nil ];
		_isPressed = true;
        return true;
	}
    return false;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 0) return;
	if (![touches containsObject:_touch]) return;
	
	CGPoint location = [_touch locationInView:[MainGLView Instance]];
	if (_isPressed)
	{
		if (CGRectContainsPoint(_dimensions, location))
		{
		}
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:_releaseSelector object:nil ];
			_isPressed = false;
			_touch = nil;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if ([touches count] == 0) return;
	if (![touches containsObject:_touch]) return;
	if (_isPressed)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:_releaseSelector object:nil ];
		_isPressed = false;
		_touch = nil;
	}
}

@end
