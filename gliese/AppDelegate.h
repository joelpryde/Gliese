//
//  AppDelegate.h
//  glise
//
//  Created by Joel Pryde on 2/14/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class ExternalViewController;
@class Globals;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    // for external display
	UIWindow *_externalWindow;
	NSArray *_screenModes;
	UIScreen *_externalScreen;
    ExternalViewController *_externalVC;
    Globals* _globals;
    bool _screenFound;
    NSTimer *_checkScreenTimer;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIWindow *externalWindow;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) ExternalViewController *externalVC;

- (void)initFiles;
- (void)chooseExternalScreen:(UIScreenMode *)desiredMode;
- (void)checkScreens:(NSTimer*)theTimer;


@end
