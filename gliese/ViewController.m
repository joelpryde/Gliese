//
//  ViewController.m
//  glise
//
//  Created by Joel Pryde on 2/14/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>
#import <mach/mach.h>

#import "HelpViewController.h"
#import "ViewController.h"
#import "MainGLView.h"
#import "GLTextView.h"
#import "ExternalGLView.h"
#import "ShaderManager.h"
#import "Shader.h"
#import "GLEasing.h"

@interface ViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation ViewController

@synthesize animating, context, displayLink;
@synthesize isEditingShader=_isEditingShader;
@synthesize isInShaderView=_isInShaderViewA;

static ViewController* sharedInstance = nil;

+ (ViewController*)Instance
{
    return sharedInstance;
}

- (void)awakeFromNib
{
    sharedInstance = self;
    animating = FALSE;
    animationFrameInterval = 2;
        
    self.displayLink = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sharedInstance = self;
    _isEditingShader = false;
    _isKeyboardShown = false;
    _isInShaderViewA = true;
    animationFrameInterval = 2;
    _orientation = UIInterfaceOrientationPortrait;
    _animStartTime = CFAbsoluteTimeGetCurrent();
    
    // add text display
    _textView = [[GLTextView alloc] initWithFrame:CGRectMake(0, 64, 768, 1024-64)];
    _textView.delegate = self;
    [_textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_textView setSpellCheckingType:UITextSpellCheckingTypeNo];
    
    // text hide/show
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window]; 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window];     
    
    [self createShaderScrollView];
    [self createGLView];
    [self updateShaderButtons];
    [self arrangeScrollView:_orientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self stopAnimation];
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate
{
    _orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self arrangeScrollView:_orientation];
    [[MainGLView Instance] setOrientation:_orientation];
    if (_isEditingShader)
        [self updateTextViewFrame];
    return YES;
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1) 
    {
        animationFrameInterval = frameInterval;
        if (animating) 
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) 
    {
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(draw)];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) 
    {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

-(void)draw
{
    double lerpValue = MIN(MAX((CFAbsoluteTimeGetCurrent() - _animStartTime)*2.0, 0.0), 1.0);
    CGRect viewFrame = [MainGLView Instance].isPortrait ? CGRectMake(0, 0, 768, 1024) : CGRectMake(0, 0, 1024, 768);
    _glView.hidden = false;
    if (!_isInShaderViewA)
    {
        _glView.frame = CGRectMake(LinearInterpolation(lerpValue, _shaderButtonRect.origin.x+2, 0.0), 
                                   LinearInterpolation(lerpValue, _shaderButtonRect.origin.y+2, 0.0), 
                                   LinearInterpolation(lerpValue, _shaderButtonRect.size.width-4, viewFrame.size.width), 
                                   LinearInterpolation(lerpValue, _shaderButtonRect.size.height-4, viewFrame.size.height));
        [_glView draw];
    }
    else 
    {
        if (lerpValue < 1.0)
        {
            _glView.frame = CGRectMake(LinearInterpolation( 1.0 - lerpValue, _shaderButtonRect.origin.x+2, 0.0), 
                                       LinearInterpolation( 1.0 - lerpValue, _shaderButtonRect.origin.y+2, 0.0), 
                                       LinearInterpolation( 1.0 - lerpValue, _shaderButtonRect.size.width-4, viewFrame.size.width), 
                                       LinearInterpolation( 1.0 - lerpValue, _shaderButtonRect.size.height-4, viewFrame.size.height));
            [_glView draw];
        }
        else
            _glView.hidden = true;
    }
    
    // also draw our external view if we have one
    if ([ExternalGLView Instance] != nil)
        [[ExternalGLView Instance] draw];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (_updateShaderTimer != nil)
    {
        [_updateShaderTimer invalidate];
        _updateShaderTimer = nil;
    }
    _updateShaderTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                            target:self selector:@selector(updateShaderText)
                                            userInfo:nil repeats:NO];
        
}

- (void)updateShaderText
{
    _updateShaderTimer = nil;
    NSString* fragmentStr = _textView.text;
    NSString* error = [[ShaderManager Instance] updateEdittingShader:fragmentStr];
    [_textView setError:error];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    _isKeyboardShown = true;
    [self updateTextViewFrame];
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    _isKeyboardShown = false;
    [self updateTextViewFrame];
}

-(void)updateTextViewFrame
{
    if (_isKeyboardShown)
    {
        if ([MainGLView Instance].isPortrait)
            [_textView setFrame:CGRectMake(0, 64, [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight] - (264 + 44) - 64)];
        else
            [_textView setFrame:CGRectMake(0, 64, [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight] - (352 + 44) - 64)];
    }
    else
    {
        [_textView setFrame:CGRectMake(0, 64, [[MainGLView Instance] UIWidth], [[MainGLView Instance] UIHeight]-64)];
    }
}

-(void)showEdit:(bool)show
{
    if(show && ![_textView isDescendantOfView:[self view]])
    {
        _textView.text = [ShaderManager Instance].editShaderText;
        [self.view addSubview:_textView];
        [_textView becomeFirstResponder];
        _isEditingShader = true;
    }
    else if (!show && [_textView isDescendantOfView:[self view]])
    {
        [_textView removeFromSuperview];
        _isEditingShader = false;
    }
}

-(void)createGLView
{
    _shaderButtonRect = CGRectMake(0, 0, 0, 0); //CGRectMake(0, 0, 1024, 768);
    _glView = [[MainGLView alloc] initWithFrame:_shaderButtonRect];
    [_glView setUserInteractionEnabled:false];
    [self.view addSubview:_glView];
}

-(void)createShaderScrollView
{
    _shaderScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _shaderScrollView.pagingEnabled = YES;
    _shaderScrollView.showsHorizontalScrollIndicator = NO;
    _shaderScrollView.showsVerticalScrollIndicator = NO;
    _shaderScrollView.scrollsToTop = NO;
    _shaderScrollView.delegate = self;    
    _shaderScrollView.backgroundColor = [UIColor blueColor];//[UIColor clearColor];
    [self.view addSubview:_shaderScrollView];
    
    /*
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    int imageValue=[appDelegate getimageClickedValue];
    [scrollView scrollRectToVisible:CGRectMake(320*imageValue, 0, 320 , 440) animated:NO];*/
}

-(void)arrangeScrollView:(UIInterfaceOrientation)interfaceOrientation
{
    bool portrait = (interfaceOrientation == UIDeviceOrientationPortrait ||
                     interfaceOrientation == UIDeviceOrientationPortraitUpsideDown);
    if (portrait)
    {
        _shaderScrollView.frame = CGRectMake(0, 0, 768, 1024);
        _shaderScrollView.contentSize = CGSizeMake(768, 1024);
    }
    else 
    {
        _shaderScrollView.frame = CGRectMake(0, 0, 1024, 768);
        _shaderScrollView.contentSize = CGSizeMake(1024, 768);
    }
    
    int pageCount = 0;
    int pageWidth = portrait ? 768 : 1024;
    int x = 50;
    int y = 60;
    int divisor = 1;
    for (UIButton* shaderButton in _shaderScrollView.subviews)
    {
        shaderButton.frame=CGRectMake(x + pageCount * pageWidth, y, 200, 140);
        
        if (divisor % (portrait ? 3 : 4) == 0)
        {
            y += 170; 
            if ( portrait && y > 1024 - 160)
            {
                y = 20;
                pageCount++;
            }
            if ( !portrait && y > 768 - 160)
            {
                y = 20;
                pageCount++;
            }
            x = 50;
        }
        else
        {
            x += 230;
        }
        divisor++;
    }
    
    _shaderScrollView.contentSize = CGSizeMake((pageCount + 1) * pageWidth, _shaderScrollView.contentSize.height);
}

-(void)updateShaderButtons
{
    // remove old buttons
    for (UIButton* button in _shaderScrollView.subviews)
    {
        [button removeFromSuperview];
        //[button release];
    }
    
    // create new buttons
    for (int i = 0; i < [[ShaderManager Instance].shaders count]; i++) 
    {
        Shader* shader = [[[ShaderManager Instance].shaders allValues] objectAtIndex:i];
        UIButton* shaderButton=[UIButton buttonWithType:UIButtonTypeCustom];
        shaderButton.backgroundColor = [UIColor whiteColor];
        shaderButton.tag=i;
        shaderButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        [shaderButton setImage:shader.image forState:UIControlStateNormal];
        [shaderButton addTarget:self action:@selector(shaderButtonSelected:) forControlEvents:UIControlEventTouchUpInside];     
        [_shaderScrollView addSubview:shaderButton];
        
        UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
        longpressGesture.minimumPressDuration = 1;
        [longpressGesture setDelegate:self];
        [shaderButton addGestureRecognizer:longpressGesture];
        [longpressGesture release];
    }
    
    // add a seperate button for new shader
    UIButton* newshaderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    newshaderButton.backgroundColor = [UIColor whiteColor];
    newshaderButton.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [newshaderButton setImage:[UIImage imageNamed:@"newShaderButton.png"] forState:UIControlStateNormal];
    newshaderButton.tag=-1;
    [newshaderButton addTarget:self action:@selector(shaderButtonSelected:) forControlEvents:UIControlEventTouchUpInside];     
    [_shaderScrollView addSubview:newshaderButton];
}

-(void)showShaderView
{
    _isInShaderViewA = true;
    [self updateShaderButtons];
    [self arrangeScrollView:_orientation];
    [self showEdit:false];
    
    [_glView setUserInteractionEnabled:false];
    _animStartTime = CFAbsoluteTimeGetCurrent();
}

-(void)shaderButtonSelected:(UIButton*)shaderButton
{
    //[_shaderScrollView removeFromSuperview];
    if (shaderButton.tag == -1)
    {
        // create new shader
        Shader* shader = [[ShaderManager Instance] createNewShader];
        [[ShaderManager Instance] saveUserShaders];
        [shader load];
    }
    else 
    {
        Shader* shader = [[[ShaderManager Instance].shaders allValues] objectAtIndex:shaderButton.tag];
        [shader load];
    }
    _isInShaderViewA = false;
    _animStartTime = CFAbsoluteTimeGetCurrent();
    [_glView setUserInteractionEnabled:true];
    _shaderButtonRect = shaderButton.frame;
}

-(void)longPressHandler:(UILongPressGestureRecognizer *)gestureRecognizer 
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) 
    {
        _longPressShaderIdx = (int)((UIButton*)gestureRecognizer.view).tag;
        UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:@"Delete"
                                                   otherButtonTitles:nil];
        
        [action showFromRect:gestureRecognizer.view.frame inView:gestureRecognizer.view.superview animated:NO];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) 
    {
        case 0:
            {
                // delete shader
                Shader* shader = [[[ShaderManager Instance].shaders allValues] objectAtIndex:_longPressShaderIdx];
                [[ShaderManager Instance] deleteShader:shader];
                [[ShaderManager Instance] saveUserShaders];
                [self updateShaderButtons];
                [self arrangeScrollView:_orientation];
            }
            break;
            
        case 1:
            // duplicate shader
            break;
    }
}

-(void)pushHelpController
{
    HelpViewController* helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    [self.navigationController pushViewController:helpViewController animated:true];
}

@end
