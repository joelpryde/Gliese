//
//  Shader.m
//  gliese
//
//  Created by Joel Pryde on 2/28/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import "Shader.h"
#import "ShaderManager.h"
#import "GLShaderFuncs.h"

@implementation Shader

@synthesize fsText = _fsText;
@synthesize hasImage = _hasImage;
@synthesize image = _image;
@synthesize name = _name;

+(NSString*)createUniqueShaderKey
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString* keyString = [NSString stringWithString:(NSString*)newUniqueIdString];
    
    CFRelease(newUniqueId);
    CFRelease(newUniqueIdString);
    return keyString;
}

-(id)initWithFile:(NSString*)name
{
    _name = name;
    NSArray* paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    _file = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.fsh",name]];
    
    NSError* error;
    _fsText = [[NSString alloc] initWithContentsOfFile:_file encoding:NSUTF8StringEncoding error:&error];
    _hasImage = false;
    return self;
}

-(id)init
{
    [super init];
    
    _name = [[Shader createUniqueShaderKey] copy];
    _fsText = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TemplateDraw" ofType:@"fsh"] encoding:NSUTF8StringEncoding error:nil];
    return self;
}

-(id)initWithName:(NSString*)name FSText:(NSString*)fsText
{
    _name = name;
    _file = nil;
    
    _fsText = [fsText copy];
    _hasImage = false;
    return self;
}

-(NSString*)getTemplateText:(NSString*)shaderText
{
    NSString* templateSource = [ShaderManager Instance].templateSource;
    return [templateSource stringByReplacingOccurrencesOfString:@"/* Template */" withString:shaderText];
}

-(NSString*)updateShaderText:(NSString*)shaderText
{
    NSString* error = recompileFragmentShader([ShaderManager Instance].currentProgram, [self getTemplateText:shaderText]);
    if (error == nil)
    {
        // save shader
        _fsText = shaderText;
        _hasImage = false;
    }
    return error;
}

-(NSString*)load
{
    [[ShaderManager Instance] setCurrentShader:self];
    return recompileFragmentShader([ShaderManager Instance].currentProgram, [self getTemplateText:_fsText]);
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_file forKey:@"file"];
    [coder encodeObject:_fsText forKey:@"text"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        _name = [coder decodeObjectForKey:@"name"];
        [_name retain];
        _file = [coder decodeObjectForKey:@"file"];
        [_file retain];
        _fsText = [coder decodeObjectForKey:@"text"];
        [_fsText retain];
        
        // load image if we have one
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent: 
                          [NSString stringWithFormat:@"%@.jpg", _name] ];
        _image = [[UIImage alloc] initWithContentsOfFile:path];
        if (_image != nil)
            _hasImage = true;
        
    }
    return self;
}

-(void)saveImage:(UIImage*)image
{
    // write to disk
    NSLog(@"Saving image: %@", _name);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: 
                      [NSString stringWithFormat:@"%@.jpg", _name]];
    //NSString* path = [documentsDirectory stringByAppendingPathComponent: 
    //                  [NSString stringWithString: @"test.jpg"] ];
    
    NSData* data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:path atomically:YES];
    _image = image;
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        
    _hasImage = true;
}


@end
