//
//  ShaderPickerController.h
//  jecTile
//
//  Created by Joel Pryde on 10/10/10.
//  Copyright 2010 PhysiPop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Shader;

@protocol ShaderPickerDelegate
- (void)shaderSelected:(Shader *)shader;
@end

@interface ShaderPickerController : UITableViewController 
{
    id<ShaderPickerDelegate> _delegate;
}

@property (nonatomic, assign) id<ShaderPickerDelegate> delegate;

@end
