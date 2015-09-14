//
//  ExternalViewController.h
//  jecTile
//
//  Created by Joel Pryde on 11/14/11.
//  Copyright (c) 2011 Physipop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExternalViewController : UIViewController
{
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

-(void)startAnimation;
-(void)stopAnimation;
-(void)draw;


@end
