//
//  ViewController.h
//  glise
//
//  Created by Joel Pryde on 2/14/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shader;
@class GLTextView;
@class MainGLView;

@interface ViewController : UIViewController <UITextViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
{
@private
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    UIInterfaceOrientation _orientation;
    
    GLTextView *_textView;
    bool _isEditingShader;
    
    MainGLView* _glView;
    UIScrollView* _shaderScrollView;
    int _longPressShaderIdx;
    bool _isKeyboardShown;
    bool _isInShaderViewA;
    CGRect _shaderButtonRect;
    CFTimeInterval  _animStartTime;
    
    NSTimer* _updateShaderTimer;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (readonly) bool isEditingShader;
@property (readonly) bool isInShaderView;

+(ViewController*)Instance;

-(void)startAnimation;
-(void)stopAnimation;
-(void)draw;
-(void)textViewDidChange:(UITextView *)textView;
-(void)showEdit:(bool)show;
-(void)shaderButtonSelected:(UIButton*)shaderButton;

-(void)createGLView;
-(void)createShaderScrollView;
-(void)updateShaderButtons;
-(void)arrangeScrollView:(UIInterfaceOrientation)interfaceOrientation;
-(void)updateTextViewFrame;
-(void)updateShaderText;

-(void)showShaderView;
-(void)pushHelpController;

@end
