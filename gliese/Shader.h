//
//  Shader.h
//  gliese
//
//  Created by Joel Pryde on 2/28/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shader : NSObject <NSCoding>
{
    NSString* _name;
    NSString* _file;
    NSString* _fsText;
    
    UIImage* _image;
    bool _hasImage;
}

@property (readonly) NSString* fsText;
@property (readonly) bool hasImage;
@property (readonly) UIImage* image;
@property (readonly) NSString* name;

+(NSString*)createUniqueShaderKey;

-(id)initWithFile:(NSString*)name;
-(id)init;
-(id)initWithName:(NSString*)name FSText:(NSString*)fsText;

-(NSString*)getTemplateText:(NSString*)shaderText;
-(NSString*)updateShaderText:(NSString*)shaderText;
-(NSString*)load;
-(void)saveImage:(UIImage*)image;

@end
