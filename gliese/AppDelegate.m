//
//  AppDelegate.m
//  glise
//
//  Created by Joel Pryde on 2/14/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ExternalViewController.h"
#import "Globals.h"

// UINavigationController subclass to pass down orientation methods to top view controller
@interface RotationAwareNavigationController : UINavigationController

@end

@implementation RotationAwareNavigationController

-(NSUInteger)supportedInterfaceOrientations {
    UIViewController *top = self.topViewController;
    return top.supportedInterfaceOrientations;
}

-(BOOL)shouldAutorotate {
    UIViewController *top = self.topViewController;
    return [top shouldAutorotate];
}

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize externalWindow = _externalWindow;
@synthesize viewController = _viewController;
@synthesize externalVC = _externalVC;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // copy files into this location if we need to
    [self initFiles];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    UINavigationController *navigationController = [[[RotationAwareNavigationController alloc] initWithRootViewController:self.viewController] autorelease];
    
    [self.window setRootViewController:navigationController];
    [self.window makeKeyAndVisible];
    
    self.externalWindow = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    _checkScreenTimer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                                        target:self selector:@selector(checkScreens:)
                                                        userInfo:nil repeats:YES];
    
    _globals = [[Globals alloc] init];
    [[Globals Instance] setupAudioUnit];
    [[Globals Instance] startAudioUnit];

    return YES;
}

-(void)initFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *libraryPath = [documentsDirectory stringByAppendingPathComponent:@"glieseLibrary.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:libraryPath])
    {
        // create library
        NSError *error;
        NSString *initPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InitFiles"];
        
        for (NSString* file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:initPath error:&error])
        {
            NSLog(@"Source Path: %@\n Dest Path: %@", [initPath stringByAppendingPathComponent:file], [documentsDirectory stringByAppendingPathComponent:file]);
            if ([[NSFileManager defaultManager] copyItemAtPath:[initPath stringByAppendingPathComponent:file] 
                                                    toPath:[documentsDirectory stringByAppendingPathComponent:file] 
                                                     error:&error]){
                NSLog(@"File successfully copied");
            } else {
                NSLog(@"Error description-%@ \n", [error localizedDescription]);
                NSLog(@"Error reason-%@", [error localizedFailureReason]);
            }
        }
    }
}

- (void)checkScreens:(NSTimer*)theTimer
{
    // Check for external screen.
	if (!_screenFound && [[UIScreen screens] count] > 1) 
    {
        _screenFound = true;
		NSLog(@"Found an external screen.");
        
		// Internal display is 0, external is 1.
		_externalScreen = [[[UIScreen screens] objectAtIndex:1] retain];
		_screenModes = [_externalScreen.availableModes retain];
        
        // for now just choose first screen
        //[self chooseExternalScreen:[_screenModes objectAtIndex:0]];
		
		// Allow user to choose from available screen-modes (pixel-sizes).
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"External Display Size" 
														 message:@"Choose a size for the external display." 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:nil] autorelease];
		for (UIScreenMode *mode in _screenModes) 
        {
			CGSize modeScreenSize = mode.size;
			[alert addButtonWithTitle:[NSString stringWithFormat:@"%.0f x %.0f pixels", modeScreenSize.width, modeScreenSize.height]];
		}
		[alert show];
	} 
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIScreenMode *desiredMode = [_screenModes objectAtIndex:buttonIndex];
    [self chooseExternalScreen:desiredMode];
}

- (void)chooseExternalScreen:(UIScreenMode *)desiredMode
{
    _externalScreen.currentMode = desiredMode;
    _externalWindow.screen = _externalScreen;
    
    [_screenModes release];
    [_externalScreen release];
    
    CGRect rect = CGRectZero;
    rect.size = desiredMode.size;
    _externalWindow.frame = rect;
    _externalWindow.clipsToBounds = YES;
    
    _externalWindow.hidden = NO;
    [_externalWindow makeKeyAndVisible];
    
    _externalVC = [[ExternalViewController alloc] initWithNibName:@"ExternalViewController" bundle:nil];
    CGRect frame = [_externalScreen applicationFrame];
    switch(_externalVC.interfaceOrientation){
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        case UIInterfaceOrientationUnknown:
            [_externalVC.view setFrame:frame];
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [_externalVC.view setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width)];
            break;
    }
    
    [_externalWindow addSubview:_externalVC.view];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[Globals Instance] stopAudioUnit];
    [[Globals Instance] finishAudioUnit];
}

@end
